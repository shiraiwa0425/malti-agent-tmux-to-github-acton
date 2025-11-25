# Claude Code フック - セッション自動初期化

## 概要

このディレクトリには、Claude Codeのセッション開始時に自動実行されるフックスクリプトが含まれています。

## フックの目的

マルチエージェントシステムで、ボスとエージェントに応じた適切な初期化を行い、必要なファイルの読み込みを促すためのものです。

## 実装内容

### 1. init_session.sh（統合版）

セッション開始時（startup/resume）に自動実行されるスクリプトです。
`CLAUDE_ROLE`環境変数を見て、ボス/エージェントで異なるメッセージを出力します。

**環境変数による分岐**:
- `CLAUDE_ROLE=boss` → ボス用の初期化（全ファイル読み込み指示）
- `CLAUDE_ROLE=agent` → エージェント用の初期化（最小限のファイル読み込み指示）
- 未設定 → 通常起動用のメッセージ

**実行タイミング**:
- 新規セッション開始時（startup）
- 既存セッション再開時（resume）

### 2. ボスによるエージェント自動初期化

ボス（ペイン0）は、ファイル読み込み後に**エージェント1,2,3を自動的に初期化**します。

**初期化フロー**:
```
1. ボス起動 → フックでファイル読み込み指示
2. ボスがファイルを読み込み
3. ボスがエージェント1,2,3に初期化メッセージを送信
4. 各エージェントがファイル読み込み → 準備完了報告
5. ボスがユーザーのリクエストを待機
```

**ボスが送信する初期化コマンド**:
```bash
cd multi-agent-tmux && ./send-message.sh エージェント1 "あなたはエージェント1です。以下のファイルを読み込んで役割を理解してください：
1. PROJECT_CONTEXT.md
2. multi-agent-tmux/instructions/agent.md
読み込み完了したら「エージェント1準備完了」と報告してください。"

# エージェント2, 3も同様
```

### 4. setup.shとの連携

`multi-agent-tmux/setup.sh`で各ペインに環境変数を設定してClaude Codeを起動：

```bash
# ペイン0（ボス）
CLAUDE_ROLE=boss claude

# ペイン1,2,3（エージェント）
CLAUDE_ROLE=agent claude
```

### 5. settings.json設定

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
            "command": ".claude/hooks/init_session.sh",
            "statusMessage": "セッションを初期化中..."
          }
        ]
      }
    ]
  }
}
```

## 読み込みファイル一覧

### ボス用（全8ファイル）

1. **PROJECT_CONTEXT.md** - プロジェクト全体の目的・構造
2. **CLAUDE.md** - Claude Code設定と役割定義
3. **.claude/guides/commander.md** - ボスの役割と判断フローチャート
4. **multi-agent-tmux/instructions/boss.md** - タスク振り分け方法
5. **multi-agent-tmux/Claude.md** - メッセージ送信方法・tmux操作
6. **.claude/commands/multi-agent-setup.md** - セットアップコマンド
7. **.claude/commands/evaluate.md** - 評価コマンド
8. **multi-agent-tmux/instructions/agent.md** - エージェントの役割定義

### エージェント用（2ファイル）

1. **PROJECT_CONTEXT.md** - プロジェクト全体の目的・構造（成果物配置ルール）
2. **multi-agent-tmux/instructions/agent.md** - エージェントの役割と完了報告方法

## テスト方法

### 手動テスト

```bash
# ボスとして
CLAUDE_ROLE=boss bash .claude/hooks/init_session.sh

# エージェントとして
CLAUDE_ROLE=agent bash .claude/hooks/init_session.sh

# 通常起動
bash .claude/hooks/init_session.sh
```

### 実際のテスト

1. `multi-agent-tmux/setup.sh`を実行
2. 各ペインで適切な初期化メッセージが表示されることを確認
3. ボス（ペイン0）とエージェント（ペイン1,2,3）で異なるメッセージが出ることを確認

## トラブルシューティング

### フックが実行されない

- スクリプトに実行権限があることを確認: `ls -la .claude/hooks/init_session.sh`
- settings.jsonの設定が正しいことを確認
- Claude Codeを再起動してみる

### 環境変数が反映されない

- setup.shが正しく環境変数を設定しているか確認
- tmuxペイン内で`echo $CLAUDE_ROLE`を実行して確認

### エラーメッセージが表示される

- スクリプトの構文エラーを確認: `bash -n .claude/hooks/init_session.sh`
- パスが正しいことを確認（相対パスで記述）

## 関連ドキュメント

- [CLAUDE.md](../../CLAUDE.md) - Claude Code設定の全体像
- [PROJECT_CONTEXT.md](../../PROJECT_CONTEXT.md) - プロジェクトコンテキスト
- [.claude/guides/commander.md](../guides/commander.md) - BOSSガイド
- [multi-agent-tmux/setup.sh](../../multi-agent-tmux/setup.sh) - セッション作成スクリプト

## ファイル構成

```
.claude/hooks/
├── README.md          # このファイル
├── init_session.sh    # 統合版初期化スクリプト（CLAUDE_ROLEで分岐）
├── init_boss.sh       # （旧）ボス専用スクリプト
└── init_agent.sh      # （旧）エージェント専用スクリプト
```
