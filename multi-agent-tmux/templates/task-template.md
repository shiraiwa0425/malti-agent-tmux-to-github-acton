# タスク振り分けテンプレート

このテンプレートは、ボスがエージェントにタスクを振り分ける際に使用します。
完了フラグの作成を標準化し、協調動作を保証します。

## 基本テンプレート

```bash
./send-message.sh <エージェント名> "あなたは<エージェント名>です。

【タスク】
<具体的なタスク内容>

【完了後】
以下のコマンドを実行してください：
\`\`\`bash
FLAG_DIR="../dist/tmp/${AI_SESSION:-claude}"
mkdir -p "$FLAG_DIR"
touch "$FLAG_DIR/<エージェント名>_done.txt"

# 全員の完了確認
if [ -f "$FLAG_DIR/エージェント1_done.txt" ] && [ -f "$FLAG_DIR/エージェント2_done.txt" ] && [ -f "$FLAG_DIR/エージェント3_done.txt" ]; then
    echo \"全員の作業完了を確認\"
    ./send-message.sh ボス \"全員作業完了しました\"
else
    echo \"他のエージェントの完了を待機中...\"
fi
\`\`\`"
```

## エージェント別テンプレート

### エージェント1へのタスク振り分け

```bash
./send-message.sh エージェント1 "あなたはエージェント1です。

【タスク】
<タスク内容>

【完了後】
以下のコマンドを実行してください：
\`\`\`bash
FLAG_DIR="../dist/tmp/${AI_SESSION:-claude}"
mkdir -p "$FLAG_DIR"
touch "$FLAG_DIR/エージェント1_done.txt"

# 全員の完了確認
if [ -f "$FLAG_DIR/エージェント1_done.txt" ] && [ -f "$FLAG_DIR/エージェント2_done.txt" ] && [ -f "$FLAG_DIR/エージェント3_done.txt" ]; then
    echo \"全員の作業完了を確認\"
    ./send-message.sh ボス \"全員作業完了しました\"
else
    echo \"他のエージェントの完了を待機中...\"
fi
\`\`\`"
```

### エージェント2へのタスク振り分け

```bash
./send-message.sh エージェント2 "あなたはエージェント2です。

【タスク】
<タスク内容>

【完了後】
以下のコマンドを実行してください：
\`\`\`bash
FLAG_DIR="../dist/tmp/${AI_SESSION:-claude}"
mkdir -p "$FLAG_DIR"
touch "$FLAG_DIR/エージェント2_done.txt"

# 全員の完了確認
if [ -f "$FLAG_DIR/エージェント1_done.txt" ] && [ -f "$FLAG_DIR/エージェント2_done.txt" ] && [ -f "$FLAG_DIR/エージェント3_done.txt" ]; then
    echo \"全員の作業完了を確認\"
    ./send-message.sh ボス \"全員作業完了しました\"
else
    echo \"他のエージェントの完了を待機中...\"
fi
\`\`\`"
```

### エージェント3へのタスク振り分け

```bash
./send-message.sh エージェント3 "あなたはエージェント3です。

【タスク】
<タスク内容>

【完了後】
以下のコマンドを実行してください：
\`\`\`bash
FLAG_DIR="../dist/tmp/${AI_SESSION:-claude}"
mkdir -p "$FLAG_DIR"
touch "$FLAG_DIR/エージェント3_done.txt"

# 全員の完了確認
if [ -f "$FLAG_DIR/エージェント1_done.txt" ] && [ -f "$FLAG_DIR/エージェント2_done.txt" ] && [ -f "$FLAG_DIR/エージェント3_done.txt" ]; then
    echo \"全員の作業完了を確認\"
    ./send-message.sh ボス \"全員作業完了しました\"
else
    echo \"他のエージェントの完了を待機中...\"
fi
\`\`\`"
```

## 完全な実行例

### 3つのエージェントに並行タスクを振り分ける

```bash
# 事前準備：完了フラグをクリア
./clear-flags.sh

# エージェント1: README.md要約
./send-message.sh エージェント1 "あなたはエージェント1です。

【タスク】
親ディレクトリのREADME.mdを読んで、3行で要約してください。

【完了後】
以下のコマンドを実行してください：
\`\`\`bash
FLAG_DIR="../dist/tmp/${AI_SESSION:-claude}"
mkdir -p "$FLAG_DIR"
touch "$FLAG_DIR/エージェント1_done.txt"

# 全員の完了確認
if [ -f "$FLAG_DIR/エージェント1_done.txt" ] && [ -f "$FLAG_DIR/エージェント2_done.txt" ] && [ -f "$FLAG_DIR/エージェント3_done.txt" ]; then
    echo \"全員の作業完了を確認\"
    ./send-message.sh ボス \"全員作業完了しました\"
else
    echo \"他のエージェントの完了を待機中...\"
fi
\`\`\`"

# エージェント2: PROJECT_CONTEXT.mdから評価項目抽出
./send-message.sh エージェント2 "あなたはエージェント2です。

【タスク】
親ディレクトリのPROJECT_CONTEXT.mdから「評価項目例」セクションを抽出して、箇条書きで表示してください。

【完了後】
以下のコマンドを実行してください：
\`\`\`bash
FLAG_DIR="../dist/tmp/${AI_SESSION:-claude}"
mkdir -p "$FLAG_DIR"
touch "$FLAG_DIR/エージェント2_done.txt"

# 全員の完了確認
if [ -f "$FLAG_DIR/エージェント1_done.txt" ] && [ -f "$FLAG_DIR/エージェント2_done.txt" ] && [ -f "$FLAG_DIR/エージェント3_done.txt" ]; then
    echo \"全員の作業完了を確認\"
    ./send-message.sh ボス \"全員作業完了しました\"
else
    echo \"他のエージェントの完了を待機中...\"
fi
\`\`\`"

# エージェント3: CLAUDE.mdから役割抽出
./send-message.sh エージェント3 "あなたはエージェント3です。

【タスク】
親ディレクトリのCLAUDE.mdから「あなたの役割」セクションを抽出して表示してください。

【完了後】
以下のコマンドを実行してください：
\`\`\`bash
FLAG_DIR="../dist/tmp/${AI_SESSION:-claude}"
mkdir -p "$FLAG_DIR"
touch "$FLAG_DIR/エージェント3_done.txt"

# 全員の完了確認
if [ -f "$FLAG_DIR/エージェント1_done.txt" ] && [ -f "$FLAG_DIR/エージェント2_done.txt" ] && [ -f "$FLAG_DIR/エージェント3_done.txt" ]; then
    echo \"全員の作業完了を確認\"
    ./send-message.sh ボス \"全員作業完了しました\"
else
    echo \"他のエージェントの完了を待機中...\"
fi
\`\`\`"
```

## 重要なポイント

1. **完了フラグファイル名の統一**: `../dist/tmp/${AI_SESSION:-claude}/<エージェント名>_done.txt`
2. **全員の完了確認**: すべてのエージェントの完了フラグをチェック
3. **最後の完了者が報告**: 条件分岐で最後に完了したエージェントがボスに報告
4. **事前クリア**: 新しいタスク実行前に`./clear-flags.sh`を実行

## ヘルパースクリプト

完了フラグをクリアするヘルパースクリプト（`clear-flags.sh`）：

使用方法：
```bash
./clear-flags.sh
```

保存場所: `dist/tmp/<AI_SESSION>/`（PROJECT_CONTEXT.mdのルールに準拠、複数セッション運用時はセッション別ディレクトリを使用）
