#!/bin/bash
# session_log.sh
# SessionStartフックで呼び出され、開発コンテキストをロードする
# tmuxセッション内の場合はペイン番号で役割を自動判定:
#   - ペイン0: ボス
#   - ペイン1,2,3: エージェント
# tmux外の場合は通常起動として扱う

log_dir="./.claude/hooks/logs"
mkdir -p "$log_dir"

timestamp=$(date +"%Y%m%d-%H%M%S")
log_file="$log_dir/session_log.jsonl"
error_log="$log_dir/error.log"

# エラーハンドリング: エラー発生時にログを残す
trap 'echo "[${timestamp}] ERROR: Script failed at line $LINENO: $BASH_COMMAND" >> "$error_log"' ERR

input=$(cat)

# 全体をまとめた最終ログ保存（JSON Lines形式で追記）
echo "[${timestamp}] $input" >> "$log_file"

# ペイン番号を取得（tmux内の場合のみ）
if [ -n "$TMUX" ]; then
  pane_index=$(tmux display-message -p '#{pane_index}')
else
  pane_index=""
fi

# 起動ログ（デバッグ用）
echo "[${timestamp}] Session started - PANE=${pane_index:-none}, TMUX=${TMUX:+set}, PWD=$PWD" >> "$log_file"

# ロードしたファイルを記録する配列
loaded_files=()

# --- ヘルパー関数: ファイルを読み込んで出力 ---
load_file() {
  local file_path="$1"
  if [ -f "$file_path" ]; then
    echo "=== $(basename "$file_path") ==="
    cat "$file_path"
    echo ""
    # ロードしたファイルを記録
    loaded_files+=("$file_path")
    return 0
  fi
  return 1
}

# --- ヘルパー関数: 複数ファイルをループで読み込む ---
load_files() {
  local header="$1"
  shift
  local files=("$@")

  if [ -n "$header" ]; then
    echo ""
    echo "━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━"
    echo "  $header"
    echo "━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━"
    echo ""
  fi

  for file_path in "${files[@]}"; do
    load_file "$file_path"
  done
}

# --- 1. 環境変数の読み込み (.env ファイルがあれば) ---
if [ -n "$CLAUDE_ENV_FILE" ] && [ -f ".env" ]; then
  # .envファイルの内容をCLAUDE_ENV_FILEに追記（コメント行と空行を除く）
  grep -v '^#' .env | grep -v '^$' | sed 's/^/export /' >> "$CLAUDE_ENV_FILE"
fi

# --- 2. セッション情報を出力 ---
echo "=== セッション初期化 ==="
echo "プロジェクト: $(basename "$PWD")"
echo "ブランチ: $(git branch --show-current 2>/dev/null || echo 'N/A')"
echo "最終コミット: $(git log -1 --oneline 2>/dev/null || echo 'N/A')"
echo ""

# --- 3. 役割に応じたマークダウンファイルを読み込む ---
context_dir="./.claude/context"

# 必読ファイルリスト（通常起動時に読み込む）
required_files=(
  "./PROJECT_CONTEXT.md"
  "./.claude/guides/commander.md"
  "./multi-agent-tmux/instructions/boss.md"
)

if [ -d "$context_dir" ]; then
  # tmuxセッション内の場合、ペイン番号で役割を自動判定
  if [ -n "$TMUX" ]; then
    if [ "$pane_index" = "0" ]; then
      # ペイン0 = ボス
      load_file "$context_dir/boss.md"
    else
      # ペイン1,2,3 = エージェント（番号付き）
      export AGENT_NUMBER="$pane_index"
      load_file "$context_dir/agent.md"
    fi
  else
    # 通常起動（tmux外）
    load_file "$context_dir/default.md"
    # 必読ファイルを自動出力
    load_files "必読ファイル自動読み込み" "${required_files[@]}"
  fi
fi

# --- 4. ロードしたファイルをログに記録 ---
if [ ${#loaded_files[@]} -gt 0 ]; then
  files_json=$(printf '%s\n' "${loaded_files[@]}" | jq -R -s -c 'split("\n") | map(select(length > 0))')
  echo "[${timestamp}] Loaded files: $files_json" >> "$log_file"
fi

exit 0
