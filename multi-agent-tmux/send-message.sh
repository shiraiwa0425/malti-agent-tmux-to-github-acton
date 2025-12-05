#!/bin/bash

# 依存コマンド確認
if ! command -v tmux >/dev/null 2>&1; then
    echo "エラー: tmux が見つかりません。brew install tmux などでインストールしてください。" >&2
    exit 1
fi

# AI_SESSION環境変数（setup.shで自動設定）
# 未設定の場合は自動でclaudeを使う（非対話でハングしないようにする）
DEFAULT_SESSION="${AI_SESSION:-${DEFAULT_SESSION:-claude}}"

SEND_SLEEP="${SEND_SLEEP:-0.5}"
RESPONSE_WAIT="${RESPONSE_WAIT:-5}"
CAPTURE_LINES="${CAPTURE_LINES:-30}"

# エイリアスは関数で解決（連想配列を使わない互換性の高い方法）

usage() {
    cat <<'EOF'
使用方法:
  ./send-message.sh <セッション名> <ペイン番号|エイリアス> <メッセージ...>
  ./send-message.sh <エイリアス> <メッセージ...>  # 既定セッション(claude)に送信

セッション名:
  claude              Claude用セッション
  codex               Codex用セッション
  gemini              Gemini用セッション

エイリアス例:
  ボス / コマンドセンター / ユーザー -> ペイン0
  エージェント1 -> ペイン1
  エージェント2 -> ペイン2
  エージェント3 -> ペイン3

環境変数:
  AI_SESSION    - 現在のセッション名 (未設定時は claude を使用)
  DEFAULT_SESSION - AI_SESSION未設定時に使うセッション名 (デフォルト: claude)
  SEND_CTRL_D   - Ctrl-Dを送るか (デフォルト: claude=true / codex=false)
  SEND_SLEEP    - キー送信間の待機時間(秒) (デフォルト: 0.5)
  RESPONSE_WAIT - AI応答待ち時間(秒) (デフォルト: 5)
  CAPTURE_LINES - キャプチャする行数 (デフォルト: 30)

例:
  ./send-message.sh エージェント1 "タスク内容"           # 現在のセッションに送信
  ./send-message.sh claude エージェント1 "タスク内容"   # claudeセッションに送信
  ./send-message.sh codex エージェント1 "タスク内容"    # codexセッションに送信
  ./send-message.sh gemini エージェント1 "タスク内容"   # geminiセッションに送信
EOF
    exit 1
}

resolve_alias() {
    local key="$1"
    case "$key" in
        "ボス"|"コマンドセンター"|"command"|"command-center"|"ユーザー")
            echo "0"
            return 0
            ;;
        "エージェント1"|"agent1")
            echo "1"
            return 0
            ;;
        "エージェント2"|"agent2")
            echo "2"
            return 0
            ;;
        "エージェント3"|"agent3")
            echo "3"
            return 0
            ;;
        *)
            return 1
            ;;
    esac
}

if [ $# -lt 2 ]; then
    usage
fi

if resolve_alias "$1" >/dev/null 2>&1; then
    SESSION_NAME="$DEFAULT_SESSION"
    PANE_NUMBER="$(resolve_alias "$1")"
    shift 1
else
    if [ $# -lt 3 ]; then
        usage
    fi
    SESSION_NAME="$1"
    TARGET="$2"
    shift 2
    if resolve_alias "$TARGET" >/dev/null 2>&1; then
        PANE_NUMBER="$(resolve_alias "$TARGET")"
    else
        PANE_NUMBER="$TARGET"
    fi
fi

if [ $# -lt 1 ]; then
    usage
fi

MESSAGE="$*"

# Codex CLI は Ctrl-D を受け取ると終了してしまうため、セッション名に応じて送信方法を変える
if [ -z "${SEND_CTRL_D:-}" ]; then
    if [ "$SESSION_NAME" = "codex" ]; then
        SEND_CTRL_D="false"
    else
        SEND_CTRL_D="true"
    fi
fi

# セッションが存在するか確認
if ! tmux has-session -t "$SESSION_NAME" 2>/dev/null; then
    echo "エラー: セッション '$SESSION_NAME' が見つかりません"
    echo "利用可能なセッション:"
    tmux list-sessions
    exit 1
fi

# ウィンドウ名を取得（最初のウィンドウを使用）
WINDOW_NAME=$(tmux list-windows -t "$SESSION_NAME" -F "#{window_name}" | head -1)

# ターゲットペインの指定
TARGET_PANE="$SESSION_NAME:$WINDOW_NAME.$PANE_NUMBER"

# ペインが存在するか確認
if ! tmux list-panes -t "$SESSION_NAME:$WINDOW_NAME" -F "#{pane_index}" | grep -q "^$PANE_NUMBER$"; then
    echo "エラー: ペイン $PANE_NUMBER が見つかりません"
    echo "利用可能なペイン:"
    tmux list-panes -t "$SESSION_NAME:$WINDOW_NAME" -F "#{pane_index}: #{pane_current_command}"
    exit 1
fi

echo "セッション '$SESSION_NAME' のペイン $PANE_NUMBER にメッセージを送信します..."
echo "メッセージ: $MESSAGE"

# メッセージを送信（テキスト入力）
tmux send-keys -t "$TARGET_PANE" -- "$MESSAGE"

# Enterキーで入力を確定
sleep "$SEND_SLEEP"
tmux send-keys -t "$TARGET_PANE" C-m

# Claude Codeの場合は、Ctrl-Dでメッセージを送信
if [ "$SEND_CTRL_D" = "true" ]; then
    sleep "$SEND_SLEEP"
    echo "メッセージを送信中（Enter + Ctrl-D）..."
    tmux send-keys -t "$TARGET_PANE" C-d
else
    echo "メッセージを送信中（Enterのみ送信: Ctrl-Dは送信しません）..."
fi

# 応答を待機
echo "AIの応答を待っています（${RESPONSE_WAIT}秒）..."
sleep "$RESPONSE_WAIT"

# ペインの内容をキャプチャして表示
echo ""
echo "=== ペイン $PANE_NUMBER の内容 ==="
tmux capture-pane -t "$TARGET_PANE" -p -S -"$CAPTURE_LINES"

echo ""
echo "完了しました。"
