# /multi-agent-setup

multi-agent-tmuxのセットアップと使用に必要な全コンテキストを提供します。

## setup.shについて

`multi-agent-tmux/setup.sh`は、tmuxセッション内で複数のClaude Codeエージェントを起動するスクリプトです。

## 必須ドキュメント

このコマンドを実行すると、以下のドキュメントをすべて確認する必要があります：

### プロジェクト全体の理解
- **[PROJECT_CONTEXT.md](../PROJECT_CONTEXT.md)** - プロジェクト全体の目的と構造

### Claude Code設定
- **[CLAUDE.md](../CLAUDE.md)** - Claude Code固有の設定と役割定義

### Multi-agent tmux システム
- **[multi-agent-tmux/Claude.md](../multi-agent-tmux/Claude.md)** - システムの使用ガイド、メッセージ送信方法、基本操作

### エージェント役割定義
- **[multi-agent-tmux/instructions/boss.md](../multi-agent-tmux/instructions/boss.md)** - ボス（タスク振り分け）の役割
- **[multi-agent-tmux/instructions/agent.md](../multi-agent-tmux/instructions/agent.md)** - エージェント（タスク実行）の役割

### 評価ワークフロー
- **[.claude/commands/evaluate.md](./evaluate.md)** - マルチエージェント評価コマンド

## クイックリファレンス

### セッション起動
```bash
cd multi-agent-tmux
./setup.sh
```

### メッセージ送信
```bash
./send-message.sh エージェント1 "タスク内容"
./send-message.sh ボス "メッセージ"
```

### エイリアス
- `ボス` / `コマンドセンター` → ペイン0（タスク振り分け）
- `エージェント1` / `agent1` → ペイン1（タスク実行）
- `エージェント2` / `agent2` → ペイン2（タスク実行）
- `エージェント3` / `agent3` → ペイン3（タスク実行）

## 使用方法

1. このコマンド（`/multi-agent-setup`）を実行
2. 上記の必須ドキュメントを確認
3. `multi-agent-tmux/setup.sh`でセッションを起動
4. エージェントにタスクを振り分け
