#!/bin/bash
# clear-flags.sh
# 完了フラグをクリアするヘルパースクリプト

# スクリプトのディレクトリを基準にdist/tmpを特定
SCRIPT_DIR="$(cd "$(dirname "$0")" && pwd)"
TMP_DIR="$SCRIPT_DIR/../dist/tmp"
# セッションごとに完了フラグを分離（AI_SESSION未設定時はclaudeを既定）
SESSION_DIR="$TMP_DIR/${AI_SESSION:-claude}"

echo "完了フラグをクリアします...(session: ${AI_SESSION:-claude})"
mkdir -p "$SESSION_DIR"

# 旧パスに残ったフラグも掃除しつつ、セッション別ディレクトリをクリア
rm -f "$TMP_DIR"/*.txt 2>/dev/null
rm -f "$SESSION_DIR"/*.txt 2>/dev/null
echo "クリア完了"

# 完了フラグの状態を表示
FLAG_COUNT=$(find "$SESSION_DIR" -maxdepth 1 -name "*.txt" 2>/dev/null | wc -l)
echo "現在の完了フラグ数: $FLAG_COUNT"
echo "保存場所: $SESSION_DIR"
