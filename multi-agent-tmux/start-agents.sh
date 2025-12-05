#!/usr/bin/env bash
set -euo pipefail

# Bash 4.x以上を要求
if ((BASH_VERSINFO[0] < 4)); then
    echo "エラー: Bash 4.0以上が必要です（現在: ${BASH_VERSION}）"
    echo "macOSの場合: brew install bash"
    exit 1
fi

# マルチエージェント起動スクリプト
# Claude/Codex/Geminiのtmuxセッションを起動（対話的選択対応）

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"

# 色定義
readonly RED='\033[0;31m'
readonly GREEN='\033[0;32m'
readonly YELLOW='\033[1;33m'
readonly BLUE='\033[0;34m'
readonly CYAN='\033[0;36m'
readonly BOLD='\033[1m'
readonly NC='\033[0m'

# ログ関数
log_info() { echo -e "${BLUE}[INFO]${NC} $1"; }
log_success() { echo -e "${GREEN}[SUCCESS]${NC} $1"; }
log_warning() { echo -e "${YELLOW}[WARNING]${NC} $1"; }
log_error() { echo -e "${RED}[ERROR]${NC} $1"; }

# セッション稼働状態を取得
get_session_status() {
    local session_name="$1"
    if tmux has-session -t "$session_name" 2>/dev/null; then
        echo "running"
    else
        echo "stopped"
    fi
}

# セッション状態を表示（1セッション分）
print_session_status() {
    local session_name="$1"
    local status
    status=$(get_session_status "$session_name")

    if [ "$status" = "running" ]; then
        echo -e "${GREEN}●${NC} $session_name セッション: ${GREEN}稼働中${NC}"
        tmux list-panes -t "$session_name" -F "    ペイン #{pane_index}: #{pane_current_command}" 2>/dev/null || true
    else
        echo -e "${RED}○${NC} $session_name セッション: ${RED}停止${NC}"
    fi
}

usage() {
    cat <<EOF
マルチエージェント起動スクリプト

使用方法:
    ./start-agents.sh [オプション]

オプション:
    （なし）            対話的に起動するセッションを選択
    --claude-only       Claude用セッションのみ起動
    --codex-only        Codex用セッションのみ起動
    --gemini-only       Gemini用セッションのみ起動
    --all               すべてのセッションを起動 (Claude + Codex + Gemini)
    --attach <session>  起動後に指定セッションにアタッチ (claude/codex/gemini)
    --status            現在のセッション状態を表示
    --stop              すべてのセッションを停止
    -h, --help          このヘルプを表示

例:
    ./start-agents.sh                    # 対話的に選択
    ./start-agents.sh --claude-only      # Claudeのみ起動
    ./start-agents.sh --gemini-only      # Geminiのみ起動
    ./start-agents.sh --all              # 全て起動
    ./start-agents.sh --status           # 状態確認

セッション切り替え（tmux内）:
    Ctrl-b s    セッション一覧を表示
    Ctrl-b (    前のセッション
    Ctrl-b )    次のセッション

成果物の配置:
    すべての成果物は dist/outputs/ に配置されます
EOF
    exit 0
}

# セッション状態確認
show_status() {
    echo ""
    log_info "=== tmuxセッション状態 ==="
    echo ""
    print_session_status "claude"
    echo ""
    print_session_status "codex"
    echo ""
    print_session_status "gemini"
    echo ""
}

# セッション停止
stop_sessions() {
    log_info "セッションを停止しています..."

    for session in claude codex gemini; do
        if tmux has-session -t "$session" 2>/dev/null; then
            tmux kill-session -t "$session"
            log_success "$session セッションを停止しました"
        fi
    done

    log_success "完了"
}

# セッション起動
start_session() {
    local session_name="$1"

    if tmux has-session -t "$session_name" 2>/dev/null; then
        log_warning "$session_name セッションは既に稼働中です"
        return 0
    fi

    log_info "${session_name}用セッションを起動中..."
    "$SCRIPT_DIR/setup.sh" --no-prompt "$session_name"
    log_success "${session_name}用セッション起動完了"
}

# 対話的選択メニュー
interactive_menu() {
    echo ""
    echo -e "${CYAN}╔══════════════════════════════════════════════════════════╗${NC}"
    echo -e "${CYAN}║          マルチエージェントシステム起動                    ║${NC}"
    echo -e "${CYAN}╚══════════════════════════════════════════════════════════╝${NC}"
    echo ""

    # 現在の状態を表示
    echo -e "現在の状態:"
    local claude_status codex_status gemini_status
    claude_status=$(get_session_status "claude")
    codex_status=$(get_session_status "codex")
    gemini_status=$(get_session_status "gemini")

    if [ "$claude_status" = "running" ]; then
        echo -e "  Claude: ${GREEN}稼働中${NC}"
    else
        echo -e "  Claude: ${RED}停止${NC}"
    fi

    if [ "$codex_status" = "running" ]; then
        echo -e "  Codex:  ${GREEN}稼働中${NC}"
    else
        echo -e "  Codex:  ${RED}停止${NC}"
    fi

    if [ "$gemini_status" = "running" ]; then
        echo -e "  Gemini: ${GREEN}稼働中${NC}"
    else
        echo -e "  Gemini: ${RED}停止${NC}"
    fi
    echo ""

    echo -e "${BOLD}起動するセッションを選択してください:${NC}"
    echo ""
    echo "  1) Claude のみ"
    echo "  2) Codex のみ"
    echo "  3) Gemini のみ"
    echo "  4) 全部 (Claude + Codex + Gemini)"
    echo "  5) キャンセル"
    echo ""

    read -rp "選択 [1-5]: " choice

    case "$choice" in
        1) START_CLAUDE=true;  START_CODEX=false; START_GEMINI=false ;;
        2) START_CLAUDE=false; START_CODEX=true;  START_GEMINI=false ;;
        3) START_CLAUDE=false; START_CODEX=false; START_GEMINI=true  ;;
        4) START_CLAUDE=true;  START_CODEX=true;  START_GEMINI=true  ;;
        5|"")
            log_info "キャンセルしました"
            exit 0
            ;;
        *)
            log_error "無効な選択です"
            exit 1
            ;;
    esac
}

# 起動完了メッセージ
print_completion_message() {
    echo ""
    log_success "起動完了！"
    echo ""
    echo "接続方法:"
    [ "$START_CLAUDE" = true ] && echo "  tmux attach -t claude"
    [ "$START_CODEX" = true ]  && echo "  tmux attach -t codex"
    [ "$START_GEMINI" = true ] && echo "  tmux attach -t gemini"
    echo ""
    echo "セッション切り替え（tmux内）:"
    echo "  Ctrl-b s    セッション一覧を表示"
    echo "  Ctrl-b (    前のセッション"
    echo "  Ctrl-b )    次のセッション"
    echo ""
    echo "成果物の配置:"
    echo "  dist/outputs/ に配置されます"
    echo ""
}

# グローバル変数
START_CLAUDE=false
START_CODEX=false
START_GEMINI=false
ATTACH_SESSION=""
INTERACTIVE=true

# メイン処理
main() {

    # 引数解析
    while [[ $# -gt 0 ]]; do
        case "$1" in
            --claude-only)
                START_CLAUDE=true; START_CODEX=false; START_GEMINI=false; INTERACTIVE=false
                shift ;;
            --codex-only)
                START_CLAUDE=false; START_CODEX=true; START_GEMINI=false; INTERACTIVE=false
                shift ;;
            --gemini-only)
                START_CLAUDE=false; START_CODEX=false; START_GEMINI=true; INTERACTIVE=false
                shift ;;
            --all)
                START_CLAUDE=true; START_CODEX=true; START_GEMINI=true; INTERACTIVE=false
                shift ;;
            --attach)
                ATTACH_SESSION="$2"
                shift 2 ;;
            --status)
                show_status
                exit 0 ;;
            --stop)
                stop_sessions
                exit 0 ;;
            -h|--help)
                usage ;;
            *)
                log_error "不明なオプション: $1"
                usage ;;
        esac
    done

    # 対話的メニュー
    if [ "$INTERACTIVE" = true ]; then
        interactive_menu
    fi

    echo ""
    echo -e "${CYAN}╔══════════════════════════════════════════════════════════╗${NC}"
    echo -e "${CYAN}║          セッション起動中...                              ║${NC}"
    echo -e "${CYAN}╚══════════════════════════════════════════════════════════╝${NC}"
    echo ""

    # セッション起動
    [ "$START_CLAUDE" = true ] && start_session "claude"
    [ "$START_CODEX" = true ]  && start_session "codex"
    [ "$START_GEMINI" = true ] && start_session "gemini"

    echo ""
    show_status
    print_completion_message

    # アタッチ
    if [ -n "$ATTACH_SESSION" ]; then
        if tmux has-session -t "$ATTACH_SESSION" 2>/dev/null; then
            log_info "$ATTACH_SESSION セッションにアタッチします..."
            tmux attach -t "$ATTACH_SESSION"
        else
            log_error "セッション '$ATTACH_SESSION' が見つかりません"
            exit 1
        fi
    fi
}

main "$@"
