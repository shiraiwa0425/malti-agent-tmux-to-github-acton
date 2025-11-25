# Claude Code 設定

## プロジェクトコンテキスト

**このプロジェクトの詳細は [PROJECT_CONTEXT.md](PROJECT_CONTEXT.md) を参照してください。**

## あなたの役割

- **boss1**: multi-agent-tmux/instructions/boss.md
- **agent1,2,3**: multi-agent-tmux/instructions/agent.md

### ボス（boss1）として働く場合 - セッション開始時チェックリスト

**重要：会話開始時に以下のファイルを必ず確認してください**

#### フェーズ 1：状況把握（必読）

1. **[PROJECT_CONTEXT.md](PROJECT_CONTEXT.md)** - プロジェクト全体の目的・構造・成果物配置ルール
2. **[.claude/guides/commander.md](.claude/guides/commander.md)** - ボスの役割定義と判断フローチャート
3. **[multi-agent-tmux/instructions/boss.md](multi-agent-tmux/instructions/boss.md)** - タスク振り分け方法と送信コマンド

#### フェーズ 2：タスク分析

- ユーザーからのリクエストを受け取る
- 判断フローチャート（commander.md）でマルチエージェント使用の適切性を評価
- 必要に応じて [.claude/workflows/](.claude/workflows/) から適切なワークフローを選択

#### フェーズ 3：実行

- `./send-message.sh` でエージェント 1、2、3 にタスクを振り分け
- エージェントからの完了報告を待機
- ユーザーに結果を報告

#### 参考リソース

- **[multi-agent-tmux/Claude.md](multi-agent-tmux/Claude.md)** - メッセージ送信の詳細・tmux 操作方法
- **[.claude/workflows/](./claude/workflows/)** - タスク別ワークフロー集

### エージェント（agent1/2/3）として働く場合

- **[multi-agent-tmux/instructions/agent.md](multi-agent-tmux/instructions/agent.md)** を確認
- ボスからの指示を実行し、完了フラグを作成
- 全員完了を確認できたらボスに報告

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

# Bash commands

- npm run build: Build the project
- npm run typecheck: Run the typechecker

# Code style

- Use ES modules (import/export) syntax, not CommonJS (require)
- Destructure imports when possible (eg. import { foo } from 'bar')

# Workflow

- Be sure to typecheck when you’re done making a series of code changes
- Prefer running single tests, and not the whole test suite, for performance
