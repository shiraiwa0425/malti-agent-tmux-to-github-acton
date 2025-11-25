#!/bin/bash

# エラーハンドリング
set -e

# セッション情報を出力（Claudeのコンテキストに追加される）
echo "=== セッション初期化 ==="
echo "プロジェクト: $(basename $CLAUDE_PROJECT_DIR)"
echo "ブランチ: $(git branch --show-current 2>/dev/null || echo 'N/A')"
echo "最終コミット: $(git log -1 --oneline 2>/dev/null || echo 'N/A')"
echo ""

# セッション初期化フック
# SessionStart時に自動実行
# CLAUDE_ROLE環境変数でボス/エージェントを区別
# このスクリプトの出力はClaude Codeにシステムメッセージとして渡されます

if [ "$CLAUDE_ROLE" = "boss" ]; then
    # ボス用の初期化メッセージ
    cat <<'EOF'

━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━
  BOSSエージェント初期化
━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━

あなたはボス（ペイン0）です。

【自動アクション - 必ず実行してください】
以下のファイルをReadツールで読み込んでください：

1. PROJECT_CONTEXT.md - プロジェクト全体の目的・構造
2. CLAUDE.md - Claude Code設定と役割定義
3. .claude/guides/commander.md - ボスの役割と判断フローチャート
4. multi-agent-tmux/instructions/boss.md - タスク振り分け方法
5. multi-agent-tmux/Claude.md - メッセージ送信方法・tmux操作
6. .claude/commands/multi-agent-setup.md - セットアップコマンド
7. .claude/commands/evaluate.md - 評価コマンド
8. multi-agent-tmux/instructions/agent.md - エージェントの役割定義

【ワークフロー】
1. ユーザーのリクエストを受け取る
2. 判断フローチャートでマルチエージェント使用の適切性を評価
3. ワークフローを選択（.claude/workflows/）
4. タスクを分割してエージェントに振り分け

【コマンド例】
./send-message.sh エージェント1 "タスク内容"
./send-message.sh エージェント2 "タスク内容"
./send-message.sh エージェント3 "タスク内容"

【自動アクション2 - ファイル読み込み後に必ず実行してください】
上記ファイルを読み込んだ後、以下のコマンドでエージェント1,2,3を初期化してください：

cd multi-agent-tmux && ./send-message.sh エージェント1 "あなたはエージェント1です。以下のファイルを読み込んで役割を理解してください：
1. PROJECT_CONTEXT.md
2. multi-agent-tmux/instructions/agent.md
読み込み完了したら「エージェント1準備完了」と報告してください。"

cd multi-agent-tmux && ./send-message.sh エージェント2 "あなたはエージェント2です。以下のファイルを読み込んで役割を理解してください：
1. PROJECT_CONTEXT.md
2. multi-agent-tmux/instructions/agent.md
読み込み完了したら「エージェント2準備完了」と報告してください。"

cd multi-agent-tmux && ./send-message.sh エージェント3 "あなたはエージェント3です。以下のファイルを読み込んで役割を理解してください：
1. PROJECT_CONTEXT.md
2. multi-agent-tmux/instructions/agent.md
読み込み完了したら「エージェント3準備完了」と報告してください。"

【準備完了】
エージェント初期化コマンド実行後、ユーザーのリクエストを待機してください。

━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━

EOF

elif [ "$CLAUDE_ROLE" = "agent" ]; then
    # エージェント用の初期化メッセージ
    cat <<'EOF'

━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━
  エージェント初期化
━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━

あなたはエージェント（タスク実行者）です。

【自動アクション - 必ず実行してください】
以下のファイルをReadツールで読み込んでください：

1. PROJECT_CONTEXT.md - プロジェクト全体の目的・構造（成果物配置ルール）
2. multi-agent-tmux/instructions/agent.md - エージェントの役割と完了報告方法

【あなたの役割】
- ボスからの指示を受けてタスクを実行
- 完了後、完了フラグを作成
- 全員完了を確認できたらボスに報告

【完了報告の流れ】
1. タスク実行
2. 完了フラグ作成: touch ./tmp/エージェントX_done.txt
3. 全員完了確認 → ボスに報告: ./send-message.sh ボス "全員作業完了しました"

【成果物の配置ルール】
- すべての成果物は dist/ ディレクトリに配置
- タイムスタンプ付きサブディレクトリを使用（例: dist/outputs/20250121-143022-task-name/）

【準備完了】
上記ファイルを読み込んだ後、ボスからの指示を待機してください。

━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━

EOF

else
    # CLAUDE_ROLEが設定されていない場合（通常起動）
    cat <<'EOF'

━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━
  Claude Code 初期化
━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━

マルチエージェントシステムのプロジェクトです。

【確認事項】
CLAUDE.mdを読んで役割を確認してください。

━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━

EOF
fi

# Exit code 0で終了すると、上記のstdoutがClaudeのコンテキストに追加されます
exit 0
