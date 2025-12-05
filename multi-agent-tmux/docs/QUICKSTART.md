# Multi-Agent Tmux - クイックスタートガイド

このガイドでは、マルチエージェントシステムを5分で始める方法を説明します。

---

## 📋 前提条件

- tmux がインストールされていること
- Claude Code がインストールされていること

---

## 🚀 3ステップで始める

### 1. tmuxセッションを作成

```bash
cd multi-agent-tmux
./setup.sh
```

3つのClaude Codeエージェントが起動した tmux セッションが作成されます。

### 2. ワークフローを実行

```bash
./orchestrate.sh simple-test
```

これだけです！各エージェントに自動的にタスクが振り分けられます。

### 3. 進捗を確認

```bash
tmux attach -t claude
```

tmuxセッションにアタッチして、各エージェントの作業を確認できます。

**ペイン間の移動**:
- `Ctrl-b o` - 次のペインに移動
- `Ctrl-b q` - ペイン番号を表示
- `Ctrl-b d` - デタッチ（バックグラウンドで実行継続）

---

## 📝 利用可能なワークフロー

```bash
./orchestrate.sh --list
```

現在利用可能なワークフロー：
- `simple-test` - 動作確認用のシンプルなテスト

---

## 🎯 カスタムワークフローの作成

### ワークフローファイルの形式

`workflows/my-workflow.md`:

```markdown
# My Custom Workflow

ワークフローの説明

---

## AGENT1

エージェント1のタスク内容

---

## AGENT2

エージェント2のタスク内容

---

## AGENT3

エージェント3のタスク内容
```

### 実行

```bash
./orchestrate.sh my-workflow
```

---

## 💡 手動でのタスク振り分け

orchestrate.shを使わず、手動でタスクを振り分けることもできます。

### エイリアス形式（簡単）

```bash
./send-message.sh エージェント1 "タスク内容"
./send-message.sh エージェント2 "タスク内容"
./send-message.sh エージェント3 "タスク内容"
```

### セッション名+ペイン番号形式

```bash
./send-message.sh claude 1 "タスク内容"
./send-message.sh claude 2 "タスク内容"
./send-message.sh claude 3 "タスク内容"
```

---

## 📚 より詳しい情報

### エイリアス一覧

| エイリアス | ペイン | 役割 |
|-----------|--------|------|
| `ボス`, `command` | 0 | タスクの振り分け |
| `エージェント1`, `agent1` | 1 | タスク実行 |
| `エージェント2`, `agent2` | 2 | タスク実行 |
| `エージェント3`, `agent3` | 3 | タスク実行 |

### 完了フラグを使った協調動作

テンプレートを使用して、全エージェントの完了を待機する仕組みを実装できます：

```bash
# 詳細は templates/task-template.md を参照
cat templates/task-template.md
```

### ヘルパースクリプト

```bash
# 完了フラグをクリア
./clear-flags.sh
```

---

## 🔧 トラブルシューティング

### tmuxセッションが見つからない

```bash
# セッション一覧を確認
tmux list-sessions

# セッションを再作成
./setup.sh
```

### エージェントが応答しない

```bash
# ペイン一覧を確認
tmux list-panes -t claude:claude

# ペインの内容を確認
tmux capture-pane -t claude:claude.1 -p -S -50
```

### ワークフローが実行できない

```bash
# ワークフローファイルの形式を確認
cat workflows/simple-test.md

# 必須セクション:
# ## AGENT1
# ## AGENT2
# ## AGENT3
```

---

## 📖 詳細ドキュメント

- [USAGE.md](../USAGE.md) - 詳細な使用ガイド
- [templates/task-template.md](../templates/task-template.md) - タスク振り分けテンプレート
- [docs/message-sending-design.md](message-sending-design.md) - 技術設計

---

## 🎉 次のステップ

1. **サンプルワークフローを試す**
   ```bash
   ./orchestrate.sh simple-test
   ```

2. **自分のワークフローを作成**
   ```bash
   # workflows/my-workflow.md を作成
   ./orchestrate.sh my-workflow
   ```

3. **テンプレートで協調動作を実装**
   ```bash
   cat templates/task-template.md
   ```

---

**マルチエージェントシステムを楽しんでください！** 🚀
