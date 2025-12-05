#!/usr/bin/env bash
set -euo pipefail

# Bash 4.x以上を要求
if ((BASH_VERSINFO[0] < 4)); then
    echo "エラー: Bash 4.0以上が必要です（現在: ${BASH_VERSION}）"
    echo "macOSの場合: brew install bash"
    exit 1
fi

# 色定義
readonly BLUE='\033[0;34m'
readonly GREEN='\033[0;32m'
readonly RED='\033[0;31m'
readonly NC='\033[0m'

# ログ関数
log_info() { echo -e "${BLUE}[INFO]${NC} $1"; }
log_success() { echo -e "${GREEN}[SUCCESS]${NC} $1"; }
log_error() { echo -e "${RED}[ERROR]${NC} $1"; }

# 依存コマンド確認
if ! command -v tmux >/dev/null 2>&1; then
    log_error "tmux が見つかりません。brew install tmux などでインストールしてください。"
    exit 1
fi

# 使用方法
usage() {
    cat <<'EOF'
使用方法:
  ./setup.sh [オプション] [セッション名]

セッション名:
  claude              Claude用セッション（デフォルト）
  codex               Codex用セッション
  gemini              Gemini用セッション

オプション:
  -y                  作成後に自動でセッションにアタッチ
  -f, --force         既存セッションがあっても削除して再作成
  -h, --help          このヘルプを表示

例:
  ./setup.sh                 # Claudeセッションを作成
  ./setup.sh codex           # Codexセッションを作成
  ./setup.sh -y claude       # Claudeセッションを作成して自動アタッチ
EOF
    exit 0
}

# コマンドライン引数の処理
AUTO_ATTACH=false
FORCE_KILL=false
SESSION_NAME="claude"

while [[ $# -gt 0 ]]; do
    case "$1" in
        -y)
            AUTO_ATTACH=true
            shift
            ;;
        -f|--force)
            FORCE_KILL=true
            shift
            ;;
        -h|--help)
            usage
            ;;
        claude|codex|gemini)
            SESSION_NAME="$1"
            shift
            ;;
        *)
            echo "不明なオプション: $1"
            usage
            ;;
    esac
done

# セッション名に応じてAIツールを決定
declare -A AI_TOOLS=(
    ["claude"]="claude"
    ["codex"]="codex"
    ["gemini"]="gemini"
)
AI_TOOL="${AI_TOOLS[$SESSION_NAME]:-claude}"

# AIツールが存在するか確認
if ! command -v "$AI_TOOL" >/dev/null 2>&1; then
    log_error "AIツール '$AI_TOOL' が見つかりません。PATH を確認してください。"
    exit 1
fi

# 定数定義
readonly WINDOW_NAME="$SESSION_NAME"
readonly PANE_DELAY=0.2
readonly COMMAND_DELAY=0.2
readonly -a PANE_ROLES=("ボス" "エージェント1" "エージェント2" "エージェント3")
readonly -a PANE_SUMMARIES=(
    "ボス（タスク振り分け）"
    "エージェント1（タスク実行）"
    "エージェント2（タスク実行）"
    "エージェント3（タスク実行）"
)
readonly PANE_COUNT=${#PANE_ROLES[@]}

# 既存のセッションがあれば中止（--force でのみ削除）
if tmux has-session -t "$SESSION_NAME" 2>/dev/null; then
    if [ "$FORCE_KILL" = true ]; then
        log_info "既存のセッション '$SESSION_NAME' を削除しています (--force)..."
        tmux kill-session -t "$SESSION_NAME"
    else
        log_error "既存のセッション '$SESSION_NAME' が稼働中です。終了せずに中断します。"
        echo "    既存を削除して作り直す場合は --force を指定してください。"
        echo "    例: ./setup.sh --force $SESSION_NAME"
        exit 1
    fi
fi

# 新しいセッションを作成（最初のペイン）
tmux new-session -d -s "$SESSION_NAME" -n "$SESSION_NAME"

# 追加のペインを必要数だけ作成
for ((i = 1; i < ${#PANE_ROLES[@]}; i++)); do
    tmux split-window -h -t "$SESSION_NAME:$WINDOW_NAME"
    sleep "$PANE_DELAY"
done

# 各ペインで初期セットアップを実行（ボス/エージェントで環境変数を分ける）
for i in "${!PANE_ROLES[@]}"; do
    target="$SESSION_NAME:$WINDOW_NAME.$i"
    tmux send-keys -t "$target" "clear" C-m
    sleep "$COMMAND_DELAY"
    tmux send-keys -t "$target" "echo \"=== ペイン${i}: ${PANE_ROLES[$i]} ===\"" C-m
    sleep "$COMMAND_DELAY"

    # ペイン0はボス、それ以外はエージェント
    # PANE_INDEXを明示的に渡すことで、各ペインが自分の番号を確実に知れる
    # AI_SESSIONで現在のセッション名（claude/codex）を設定
    if [ "$i" -eq 0 ]; then
        role="boss"
        role_jp="ボス"
    else
        role="agent"
        role_jp="エージェント${i}"
    fi

    # 環境変数を設定してAIツールを起動
    tmux send-keys -t "$target" "export AGENT_ROLE=$role PANE_INDEX=$i AI_SESSION=$SESSION_NAME && $AI_TOOL" C-m
    sleep "$PANE_DELAY"
done

# Codexセッションの場合、起動後に役割を伝える初期プロンプトを送信
if [ "$SESSION_NAME" = "codex" ]; then
    log_info "Codex起動待機中（初期プロンプト送信まで10秒）..."
    sleep 10  # Codex起動を待つ
fi

# 左右均等レイアウトに調整（4つのペインを均等に）
tmux select-layout -t "$SESSION_NAME:$WINDOW_NAME" even-horizontal

# 最初のペイン（左）- ボスにフォーカス
tmux select-pane -t "$SESSION_NAME:$WINDOW_NAME.0"

echo ""
echo "=========================================="
echo "tmuxセッション '$SESSION_NAME' を作成しました。"
echo "AIツール: $AI_TOOL"
echo "${PANE_COUNT}つのペイン（マルチエージェント構成）が動作しています。"
for i in "${!PANE_SUMMARIES[@]}"; do
    echo "  - ペイン${i}: ${PANE_SUMMARIES[$i]}"
done
echo ""
echo "接続: tmux attach -t $SESSION_NAME"
echo "=========================================="
echo ""

if [[ "$AUTO_ATTACH" == true ]]; then
    echo "自動的にセッションに接続します..."
    tmux attach -t "$SESSION_NAME"
else
    echo "自動的にセッションに接続しますか？ (y/n)"
    read -r response
    if [[ "$response" =~ ^[Yy]$ ]]; then
        tmux attach -t "$SESSION_NAME"
    fi
fi
