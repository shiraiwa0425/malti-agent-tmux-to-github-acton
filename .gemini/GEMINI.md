# Gemini Agent 設定

## プロジェクトコンテキスト

**このプロジェクトの詳細は [PROJECT_CONTEXT.md](../PROJECT_CONTEXT.md) を参照してください。**

すべての AI が確認すべき観点は、[PROJECT_CONTEXT.md](../PROJECT_CONTEXT.md) の「すべての AI が確認すべき観点」セクションを参照してください。
作業開始前に、PROJECT_CONTEXT.md の「必読ファイル」セクションも必ず確認してください。

## あなたの役割

| 役割                       | 指示書                                                       |
| -------------------------- | ------------------------------------------------------------ |
| ボス（boss）               | [docs/instructions/boss.md](../docs/instructions/boss.md)       |
| エージェント（agent1/2/3） | [docs/instructions/agent.md](../docs/instructions/agent.md)     |

> 指示書はClaude/Codex/Gemini共通です。

## Gemini 固有の設定

### メッセージ送信方式

- Gemini CLI は Claude と同様に **Enter + Ctrl-D** でメッセージを送信します
- `send-message.sh` は自動的にこの方式を使用します

### 環境変数

Gemini セッションでは以下の環境変数が設定されます：

| 変数名 | 値 | 説明 |
|--------|------|------|
| `AI_SESSION` | `gemini` | 現在のセッション名 |
| `AGENT_ROLE` | `boss` / `agent` | ボスかエージェントか |
| `PANE_INDEX` | `0` / `1` / `2` / `3` | ペイン番号 |

### セッション作成

```bash
# Geminiセッションを作成
./multi-agent-tmux/setup.sh gemini

# セッションに接続
tmux attach -t gemini
```

### メッセージ送信

```bash
# Geminiセッションのエージェントに送信
./multi-agent-tmux/send-message.sh gemini エージェント1 "タスク内容"

# または AI_SESSION 環境変数を使用
AI_SESSION=gemini ./multi-agent-tmux/send-message.sh エージェント1 "タスク内容"
```

## 参考リソース

- [PROJECT_CONTEXT.md](../PROJECT_CONTEXT.md) - プロジェクト全体の共通情報
- [multi-agent-tmux/USAGE.md](../multi-agent-tmux/USAGE.md) - マルチエージェント使用ガイド
- [README.md](../README.md) - プロジェクト概要
