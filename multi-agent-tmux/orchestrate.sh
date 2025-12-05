#!/bin/bash

# マルチエージェントオーケストレーションスクリプト
# 使用方法: ./orchestrate.sh <ワークフロー名>

set -e

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
WORKFLOW_DIR="${SCRIPT_DIR}/workflows"

# 色定義
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
BLUE='\033[0;34m'
NC='\033[0m' # No Color

# ログ関数
log_info() {
    echo -e "${BLUE}[INFO]${NC} $1"
}

log_success() {
    echo -e "${GREEN}[SUCCESS]${NC} $1"
}

log_warning() {
    echo -e "${YELLOW}[WARNING]${NC} $1"
}

log_error() {
    echo -e "${RED}[ERROR]${NC} $1"
}

# 使用方法表示
usage() {
    cat <<EOF
マルチエージェントオーケストレーションツール

使用方法:
    ./orchestrate.sh <ワークフロー名>
    ./orchestrate.sh --list

オプション:
    --list              利用可能なワークフローを一覧表示
    --help              このヘルプを表示

例:
    ./orchestrate.sh three-js-page
    ./orchestrate.sh code-review
EOF
}

# ワークフロー一覧表示
list_workflows() {
    log_info "利用可能なワークフロー:"
    echo ""

    if [ -d "$WORKFLOW_DIR" ]; then
        for workflow in "$WORKFLOW_DIR"/*.md; do
            if [ -f "$workflow" ]; then
                basename "$workflow" .md
            fi
        done
    else
        log_warning "ワークフローディレクトリが見つかりません: $WORKFLOW_DIR"
    fi
}

# tmuxセッションの存在確認
check_tmux_session() {
    if ! tmux has-session -t claude 2>/dev/null; then
        log_error "tmuxセッション 'claude' が見つかりません"
        log_info "setup.shを実行してセッションを作成してください"
        exit 1
    fi
    log_success "tmuxセッション 'claude' を確認"
}

# エージェントにメッセージ送信
send_to_agent() {
    local pane=$1
    local message=$2
    local agent_name=$3

    log_info "[$agent_name] タスクを送信中..."

    # set -e 環境下でエラーハンドリングを適切に行うため if でラップ
    if "${SCRIPT_DIR}/send-message.sh" claude "$pane" "$message"; then
        log_success "[$agent_name] タスク送信完了"
    else
        log_error "[$agent_name] タスク送信失敗 (tmuxセッション欠落または無効なペイン番号の可能性)"
        return 1
    fi
}

# エージェントの進捗確認
check_agent_progress() {
    local pane=$1
    local agent_name=$2

    log_info "[$agent_name] 進捗を確認中..."

    # ペインの最新50行を取得（set -e環境下でエラーハンドリング）
    local output
    if ! output=$(tmux capture-pane -t claude:claude.$pane -p -S -50 2>&1); then
        log_error "[$agent_name] ペイン情報の取得に失敗 (無効なペイン番号の可能性)"
        return 2
    fi

    # 作業中かどうかを判定（簡易的）
    if echo "$output" | grep -q "Thinking\|Lollygagging\|Levitating\|Forging"; then
        log_info "[$agent_name] 作業中..."
        return 1
    elif echo "$output" | grep -q "────────"; then
        log_success "[$agent_name] 作業完了の可能性"
        return 0
    else
        log_warning "[$agent_name] 状態不明"
        return 2
    fi
}

# すべてのエージェントの完了を待機
wait_for_agents() {
    local panes=("$@")
    local max_wait=300  # 最大5分待機
    local elapsed=0
    local check_interval=10

    log_info "エージェントの完了を待機中..."

    while [ $elapsed -lt $max_wait ]; do
        local all_done=true

        for i in "${!panes[@]}"; do
            local pane=${panes[$i]}
            local agent_name="エージェント$((i+1))"

            # set -e を一時的に無効化して非ゼロリターンを許可
            local status
            set +e
            check_agent_progress "$pane" "$agent_name"
            status=$?
            set -e

            if [ $status -eq 0 ]; then
                # 完了状態
                :
            elif [ $status -eq 1 ]; then
                # 作業中
                all_done=false
            else
                # エラーまたは不明な状態 (status == 2)
                log_warning "[$agent_name] エラーまたは不明な状態を検出 - 待機を続行"
                all_done=false
            fi
        done

        if [ "$all_done" = true ]; then
            log_success "すべてのエージェントが完了しました"
            return 0
        fi

        sleep $check_interval
        elapsed=$((elapsed + check_interval))
        log_info "待機中... (${elapsed}s / ${max_wait}s)"
    done

    log_warning "タイムアウト: 一部のエージェントが完了していない可能性があります"
    return 1
}

# メイン処理
main() {
    local workflow_name=$1

    # 引数チェック
    if [ -z "$workflow_name" ]; then
        usage
        exit 1
    fi

    # オプション処理
    case "$workflow_name" in
        --list)
            list_workflows
            exit 0
            ;;
        --help)
            usage
            exit 0
            ;;
    esac

    # ワークフローファイルの存在確認
    local workflow_file="${WORKFLOW_DIR}/${workflow_name}.md"

    if [ ! -f "$workflow_file" ]; then
        log_error "ワークフローが見つかりません: $workflow_name"
        log_info "利用可能なワークフロー:"
        list_workflows
        exit 1
    fi

    log_info "ワークフローを読み込み: $workflow_name"

    # tmuxセッション確認
    check_tmux_session

    # ワークフローファイルからタスクを抽出して実行
    log_info "ワークフローからタスクを抽出中..."

    # 各エージェントのタスクを抽出
    local task1 task2 task3

    # エージェント1のタスク抽出（## AGENT1 から ## AGENT2 の前まで）
    task1=$(sed -n '/^## AGENT1$/,/^## AGENT2$/p' "$workflow_file" | grep -v '^## ' | sed '/^$/d' | sed '/^---$/d')

    # エージェント2のタスク抽出（## AGENT2 から ## AGENT3 の前まで）
    task2=$(sed -n '/^## AGENT2$/,/^## AGENT3$/p' "$workflow_file" | grep -v '^## ' | sed '/^$/d' | sed '/^---$/d')

    # エージェント3のタスク抽出（## AGENT3 から最後まで）
    task3=$(sed -n '/^## AGENT3$/,$p' "$workflow_file" | grep -v '^## ' | sed '/^$/d' | sed '/^---$/d')

    # タスクが空でないか確認
    if [ -z "$task1" ] || [ -z "$task2" ] || [ -z "$task3" ]; then
        log_error "ワークフローファイルの形式が不正です"
        log_info "必須セクション: ## AGENT1, ## AGENT2, ## AGENT3"
        exit 1
    fi

    log_success "タスク抽出完了"

    # デバッグ: 抽出されたタスクを表示
    log_info "=== エージェント1のタスク ==="
    echo "$task1"
    echo ""
    log_info "=== エージェント2のタスク ==="
    echo "$task2"
    echo ""
    log_info "=== エージェント3のタスク ==="
    echo "$task3"
    echo ""

    # 各エージェントにタスクを送信
    log_info "エージェントにタスクを送信中..."

    send_to_agent 1 "$task1" "エージェント1" || exit 1
    send_to_agent 2 "$task2" "エージェント2" || exit 1
    send_to_agent 3 "$task3" "エージェント3" || exit 1

    log_success "すべてのタスク送信完了"

    # エージェントの完了を待機（オプション）
    log_info "エージェントの作業を監視しますか？ (y/N)"
    read -t 5 -r response || response="n"

    if [[ "$response" =~ ^[Yy]$ ]]; then
        wait_for_agents 1 2 3
    else
        log_info "監視をスキップしました"
        log_info "tmux attach -t claude で各エージェントの進捗を確認できます"
    fi

    exit 0
}

# スクリプト実行
main "$@"
