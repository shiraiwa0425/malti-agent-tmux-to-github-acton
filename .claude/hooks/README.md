# Claude Code フック - セッション自動初期化

## 概要

このディレクトリには、Claude Codeのセッション開始時に自動実行されるフックスクリプトが含まれています。

## フックの目的

マルチエージェントシステムで、ボスとエージェントに応じた適切な初期化を行い、必要なファイルの読み込みを促すためのものです。

## 実装内容

### 1. session_log.sh（メインスクリプト）

セッション開始時（startup）に自動実行されるスクリプトです。
`AGENT_ROLE`環境変数を見て、ボス/エージェントで異なるコンテキストを出力します。

**主な機能**:

1. **セッションログ記録** - 起動情報をJSONL形式で保存
2. **エラーログ記録** - スクリプトエラー時にログを残す（`trap ERR`）
3. **環境変数読み込み** - `.env`ファイルがあれば読み込み
4. **コンテキスト出力** - `.claude/context/`配下のマークダウンを出力

**環境変数による分岐**:
- `AGENT_ROLE=boss` → ボス用コンテキスト（`context/boss.md`）
- `AGENT_ROLE=agent` → エージェント用コンテキスト（`context/agent.md`）
- 未設定 → デフォルトコンテキスト（`context/default.md`）

### 2. ログファイル

ログは `.claude/hooks/logs/` ディレクトリに保存されます：

| ファイル | 内容 |
|---------|------|
| `session_log.jsonl` | セッション開始ログ（JSON Lines形式） |
| `error.log` | エラー発生時のログ（行番号・コマンド付き） |

**ログ例**:

```
# session_log.jsonl
[20251125-230000] {"type":"SessionStart","trigger":"startup",...}
[20251125-230000] Session started - AGENT_ROLE=boss, PWD=/path/to/project

# error.log（エラー発生時のみ）
[20251125-230000] ERROR: Script failed at line 25: cat "$context_dir/boss.md"
```

### 3. コンテキストファイル

`.claude/context/` ディレクトリにマークダウンファイルを配置することで、セッション開始時に自動読み込みされます：

```
.claude/context/
├── 00-common.md    # 共通コンテキスト（全員に表示）
├── boss.md         # ボス用コンテキスト
├── agent.md        # エージェント用コンテキスト
└── default.md      # 通常起動時のコンテキスト
```

- `00-`で始まるファイルは全員に表示されます
- `AGENT_ROLE`に応じて対応するファイルが追加で表示されます

### 4. settings.json設定

`.claude/settings.json`で以下のように設定されています：

```json
{
  "hooks": {
    "SessionStart": [
      {
        "matcher": "startup",
        "hooks": [
          {
            "type": "command",
            "command": "./.claude/hooks/session_log.sh"
          }
        ]
      }
    ]
  }
}
```

### 5. setup.shとの連携

`multi-agent-tmux/setup.sh`で各ペインに環境変数を設定してClaude Codeを起動：

```bash
# ペイン0（ボス）
AGENT_ROLE=boss claude

# ペイン1,2,3（エージェント）
AGENT_ROLE=agent claude
```

## テスト方法

### 手動テスト

```bash
# ボスとして（入力をシミュレート）
echo '{"type":"SessionStart"}' | AGENT_ROLE=boss ./.claude/hooks/session_log.sh

# エージェントとして
echo '{"type":"SessionStart"}' | AGENT_ROLE=agent ./.claude/hooks/session_log.sh

# 通常起動
echo '{"type":"SessionStart"}' | ./.claude/hooks/session_log.sh
```

### ログ確認

```bash
# セッションログ確認
cat .claude/hooks/logs/session_log.jsonl

# エラーログ確認（あれば）
cat .claude/hooks/logs/error.log
```

### 実際のテスト

1. `multi-agent-tmux/setup.sh`を実行
2. 各ペインで適切な初期化メッセージが表示されることを確認
3. ボス（ペイン0）とエージェント（ペイン1,2,3）で異なるメッセージが出ることを確認

## トラブルシューティング

### フックが実行されない / hook error が出る

1. **実行権限を確認**:
   ```bash
   ls -la .claude/hooks/session_log.sh
   # -rwxr-xr-x であること

   # 権限がなければ付与
   chmod +x .claude/hooks/session_log.sh
   ```

2. **settings.jsonの設定を確認**

3. **エラーログを確認**:
   ```bash
   cat .claude/hooks/logs/error.log
   ```

### 環境変数が反映されない

- setup.shが正しく環境変数を設定しているか確認
- tmuxペイン内で`echo $AGENT_ROLE`を実行して確認

### スクリプトの構文エラー

```bash
# 構文チェック
bash -n .claude/hooks/session_log.sh
```

## ファイル構成

```
.claude/hooks/
├── README.md          # このファイル
├── session_log.sh     # メイン初期化スクリプト（AGENT_ROLEで分岐）
└── logs/              # ログディレクトリ（自動作成）
    ├── session_log.jsonl  # セッションログ
    └── error.log          # エラーログ
```

## 関連ドキュメント

- [CLAUDE.md](../../CLAUDE.md) - Claude Code設定の全体像
- [PROJECT_CONTEXT.md](../../PROJECT_CONTEXT.md) - プロジェクトコンテキスト
- [.claude/guides/commander.md](../guides/commander.md) - BOSSガイド
- [multi-agent-tmux/setup.sh](../../multi-agent-tmux/setup.sh) - セッション作成スクリプト
