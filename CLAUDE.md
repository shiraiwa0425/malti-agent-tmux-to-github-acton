# Claude Code 設定

## プロジェクトコンテキスト

**このプロジェクトの詳細は [PROJECT_CONTEXT.md](PROJECT_CONTEXT.md) を参照してください。**

## あなたの役割

- **boss1**: multi-agent-tmux/instructions/boss.md
- **agent1,2,3**: multi-agent-tmux/instructions/agent.md

### スラッシュコマンド

#### /multi-agent-setup

multi-agent-tmux のセットアップに必要な全コンテキストを提供します。

**使用タイミング**: `multi-agent-tmux/setup.sh` を使用する前に実行してください。

詳細は [.claude/commands/multi-agent-setup.md](.claude/commands/multi-agent-setup.md) を参照してください。

#### /evaluate

マルチエージェントの評価ワークフローを開始します。

詳細は [.claude/commands/evaluate.md](.claude/commands/evaluate.md) を参照してください。

### マルチエージェント連携

multi-agent-tmux と連携するので、[multi-agent-tmux/Claude.md](multi-agent-tmux/Claude.md) を参照してください。

## 参考リソース

- [PROJECT_CONTEXT.md](PROJECT_CONTEXT.md) - プロジェクト全体の共通情報
- [.claude/commands/multi-agent-setup.md](.claude/commands/multi-agent-setup.md) - Multi-agent セットアップコンテキスト
- [.claude/commands/evaluate.md](.claude/commands/evaluate.md) - 評価コマンドの詳細
- [multi-agent-tmux/Claude.md](multi-agent-tmux/Claude.md) - Multi-agent tmux の使用ガイド
- [multi-agent-tmux/instructions/boss.md](multi-agent-tmux/instructions/boss.md) - ボスの役割定義
- [multi-agent-tmux/instructions/agent.md](multi-agent-tmux/instructions/agent.md) - エージェントの役割定義
