# Claude Code フック - BOSS自動初期化

## 概要

このディレクトリには、Claude Codeのセッション開始時に自動実行されるフックスクリプトが含まれています。

## フックの目的

BOSSエージェント（ペイン0）として動作する際に、セッション開始時に必要なコンテキストを自動的に読み込み、必要なファイルの確認を促すためのものです。

## 実装内容

### 1. init_boss.sh

セッション開始時（startup/resume）に自動実行されるスクリプトです。

**機能**:
- BOSSエージェントとしての役割を明示
- セッション開始時に確認すべきファイルリストを表示
- ワークフローの概要を提示
- コマンド例を表示

**実行タイミング**:
- 新規セッション開始時（startup）
- 既存セッション再開時（resume）

### 2. settings.json設定

`.claude/settings.json`で以下のように設定されています：

```json
{
  "hooks": {
    "SessionStart": [
      {
        "matcher": "startup|resume",
        "hooks": [
          {
            "type": "command",
            "command": ".claude/hooks/init_boss.sh",
            "statusMessage": "BOSSエージェントを初期化中..."
          }
        ]
      }
    ]
  }
}
```

## BOSS用必読ファイル

フックでは以下のファイルを確認するよう促します：

1. **PROJECT_CONTEXT.md** - プロジェクト全体の目的・構造
2. **.claude/guides/commander.md** - ボスの役割と判断フローチャート
3. **multi-agent-tmux/instructions/boss.md** - タスク振り分け方法

## テスト方法

### 手動テスト

```bash
bash .claude/hooks/init_boss.sh
```

### 実際のテスト

Claude Codeセッションを再起動してフックが自動実行されることを確認します：

1. `/clear` コマンドを実行
2. 新しいセッションを開始
3. フックメッセージが表示されることを確認

## トラブルシューティング

### フックが実行されない

- スクリプトに実行権限があることを確認: `ls -la .claude/hooks/init_boss.sh`
- settings.jsonの設定が正しいことを確認
- Claude Codeを再起動してみる

### エラーメッセージが表示される

- スクリプトの構文エラーを確認: `bash -n .claude/hooks/init_boss.sh`
- パスが正しいことを確認（相対パスで記述）

## 関連ドキュメント

- [CLAUDE.md](../../CLAUDE.md) - Claude Code設定の全体像
- [PROJECT_CONTEXT.md](../../PROJECT_CONTEXT.md) - プロジェクトコンテキスト
- [.claude/guides/commander.md](../guides/commander.md) - BOSSガイド
