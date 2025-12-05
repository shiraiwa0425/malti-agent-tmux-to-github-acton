# ボス指示書

> このドキュメントはClaude / Codex両方で共通利用されます。

## 役割

チームメンバーの統括管理（タスク振り分け）

**詳細なガイドは [.claude/guides/commander.md](../../.claude/guides/commander.md) を参照してください。**

## 基本フロー

1. ユーザーからの指示を分析
2. [判断フローチャート](../../.claude/guides/commander.md#判断フローチャート) でマルチエージェント使用を判断
3. タスクを分割してエージェントに送信
4. **定期的にエージェントの進捗を監視**（下記参照）
5. 完了報告を待機
6. ユーザーに結果を報告

## ⚠️ 重要：定期的な進捗監視

**エージェントにタスクを振り分けた後、必ず定期的に進捗を確認してください。**

### 監視コマンド

```bash
# 各エージェントの状態確認（15-30秒ごとに実行）
# AI_SESSION環境変数でセッション名を切り替え（claude / codex / gemini）
tmux capture-pane -t ${AI_SESSION:-claude}:${AI_SESSION:-claude}.1 -p -S -20 | tail -15
tmux capture-pane -t ${AI_SESSION:-claude}:${AI_SESSION:-claude}.2 -p -S -20 | tail -15
tmux capture-pane -t ${AI_SESSION:-claude}:${AI_SESSION:-claude}.3 -p -S -20 | tail -15

# 完了フラグの確認
ls -la dist/tmp/${AI_SESSION:-claude}/
```

### 停止検知時のアクション

エージェントが許可待ちで止まっている場合（「Do you want to proceed?」等が表示）：

```bash
# Shift+Tab を送信して自動許可モードを有効化
tmux send-keys -t ${AI_SESSION:-claude}:${AI_SESSION:-claude}.1 BTab
tmux send-keys -t ${AI_SESSION:-claude}:${AI_SESSION:-claude}.2 BTab
tmux send-keys -t ${AI_SESSION:-claude}:${AI_SESSION:-claude}.3 BTab
```

または、作業継続を促すメッセージを送信：

```bash
./multi-agent-tmux/send-message.sh エージェント1 "作業を続けてください"
```

### 監視のタイミング

- タスク振り分け後、**15-30秒ごと**に進捗確認
- エージェントが停止していたら即座に対応
- 完了フラグが揃うまで監視を継続

## 送信コマンド

```bash
# send-message.sh はAI_SESSION環境変数を参照してセッションを自動選択
./multi-agent-tmux/send-message.sh エージェント1 "タスク内容1"
./multi-agent-tmux/send-message.sh エージェント2 "タスク内容2"
./multi-agent-tmux/send-message.sh エージェント3 "タスク内容3"
```

## 完了条件

エージェントから「全員作業完了しました」の報告を受信

## エージェントからの個別報告

各エージェントはタスク完了時に以下の形式でボスに報告します：

```
エージェント${PANE_INDEX}完了：[作業内容の要約]
```

**ボスの対応**:
- 個別報告を受け取ったら、進捗状況を把握
- 全エージェントの完了フラグ（`dist/tmp/<AI_SESSION>/エージェント*_done.txt`）を確認
- 全員完了後、結果を統合してユーザーに報告

## マルチセッション運用（Claude + Codex + Gemini）

最大12体のエージェントを同時運用する場合：

| セッション | ペイン | 役割 |
|-----------|--------|------|
| claude | 0 | Claudeボス |
| claude | 1-3 | Claudeエージェント1-3 |
| codex | 0 | Codexボス |
| codex | 1-3 | Codexエージェント1-3 |
| gemini | 0 | Geminiボス |
| gemini | 1-3 | Geminiエージェント1-3 |

### セッション間の連携

- 各ボスは自分のセッション内のエージェントを管理
- 必要に応じて別セッションのボスと連携可能

```bash
# Codexセッションのエージェントに送信
AI_SESSION=codex ./multi-agent-tmux/send-message.sh エージェント1 "タスク内容"

# Geminiセッションのエージェントに送信
AI_SESSION=gemini ./multi-agent-tmux/send-message.sh エージェント1 "タスク内容"
```
