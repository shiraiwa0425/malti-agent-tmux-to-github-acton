# Claude Code 設定

## プロジェクトコンテキスト

**[PROJECT_CONTEXT.md](PROJECT_CONTEXT.md) を参照してください。**

必読ドキュメント・参考リソースもすべて PROJECT_CONTEXT.md に記載されています。

## あなたの役割

| 役割 | 指示書 |
|------|--------|
| ボス（boss1） | [multi-agent-tmux/instructions/boss.md](multi-agent-tmux/instructions/boss.md) |
| エージェント（agent1/2/3） | [multi-agent-tmux/instructions/agent.md](multi-agent-tmux/instructions/agent.md) |

## スラッシュコマンド

| コマンド | 説明 |
|----------|------|
| `/multi-agent-setup` | tmuxセッションのセットアップ |
| `/evaluate` | マルチエージェント評価の実行 |

# Bash commands

- npm run build: Build the project
- npm run typecheck: Run the typechecker

# Code style

- Use ES modules (import/export) syntax, not CommonJS (require)
- Destructure imports when possible (eg. import { foo } from 'bar')

# Workflow

- Be sure to typecheck when you’re done making a series of code changes
- Prefer running single tests, and not the whole test suite, for performance
