# Multi-Agent Tmux - 使用ガイド

## 概要

このツールは、tmux セッション内で複数の AI エージェント（Claude / Codex / Gemini）を起動し、エージェント間でメッセージを送受信してタスクを協調実行するマルチエージェントシステムです。

## セッション構造

```
セッション: <AI名>  (claude / codex / gemini)
  └─ ウィンドウ: <AI名>
      ├─ ペイン 0: ボス（タスク振り分け）
      ├─ ペイン 1: エージェント1（タスク実行）
      ├─ ペイン 2: エージェント2（タスク実行）
      └─ ペイン 3: エージェント3（タスク実行）
```

## セットアップ

### 前提条件

- tmux がインストールされていること
- 使用するAI CLIがインストールされていること（claude / codex / gemini）

### セッション作成

```bash
# Claude用セッション（デフォルト）
./setup.sh

# Codex用セッション
./setup.sh codex

# Gemini用セッション
./setup.sh gemini
```

このコマンドで、4つのAIエージェントインスタンスが起動した tmux セッションが作成されます。

## メッセージ送信

### 基本的な使い方

```bash
# エイリアス形式（推奨）
./send-message.sh <エイリアス> <メッセージ>

# セッション名+ペイン番号形式
./send-message.sh <セッション名> <ペイン番号> <メッセージ>
```

### エイリアス一覧

**[PROJECT_CONTEXT.md](../PROJECT_CONTEXT.md) のエイリアス一覧を参照してください。**

### 使用例

```bash
# エージェント1にREADME要約を依頼
./send-message.sh エージェント1 "README.mdを要約してください"

# エージェント2にコードレビューを依頼
./send-message.sh エージェント2 "setup.shのコードレビューをお願いします"

# ボスに全体タスクを依頼
./send-message.sh ボス "プロジェクト全体の構造を説明してください"
```

## メッセージ送信の仕組み

### 送信フロー

```
[スクリプト実行]
    ↓
[tmux: メッセージ入力]
    ↓
[tmux: Enter で確定]
    ↓
[tmux: Ctrl-D で送信]
    ↓
[Claude Code がメッセージ受信・処理]
    ↓
[Claude Code が応答]
```

### 重要なポイント

1. **Ctrl-D がメッセージ送信トリガー**: Claude / Gemini では`Ctrl-D`でメッセージが送信されます
2. **Codexは例外**: Codexは`Enter`のみでメッセージが送信されます（Ctrl-Dで終了してしまうため）
3. **Enter → Ctrl-D の順序**: メッセージ入力後、Enter で確定してから Ctrl-D で送信
4. **応答待機**: スクリプトは 5 秒間待機してから結果を表示します

## AI CLI キーボードショートカット

### Claude / Gemini
| キー     | 機能                             |
| -------- | -------------------------------- |
| `Ctrl-D` | メッセージを送信                 |
| `Ctrl-C` | 現在の操作をキャンセル           |

### Codex
| キー     | 機能                             |
| -------- | -------------------------------- |
| `Enter`  | メッセージを送信                 |
| `Ctrl-C` | 現在の操作をキャンセル           |

## tmux 基本操作

### セッション管理

```bash
# セッション一覧
tmux list-sessions

# セッション存在確認
tmux has-session -t claude

# セッションにアタッチ
tmux attach -t claude

# セッションからデタッチ（tmux内で）
Ctrl-b d
```

### ペイン操作

```bash
# ペイン一覧
tmux list-panes -t claude:claude

# ペイン情報を詳細表示
tmux list-panes -t claude:claude -F "#{pane_index}: #{pane_current_command}"

# ペインの内容をキャプチャ
tmux capture-pane -t claude:claude.1 -p

# 履歴を含めてキャプチャ（過去30行）
tmux capture-pane -t claude:claude.1 -p -S -30
```

### ペイン間移動（tmux 内で）

| キー              | 機能                   |
| ----------------- | ---------------------- |
| `Ctrl-b o`        | 次のペインに移動       |
| `Ctrl-b ↑↓←→`     | 方向キーでペイン移動   |
| `Ctrl-b q`        | ペイン番号を表示       |
| `Ctrl-b q <数字>` | 指定番号のペインに移動 |

## トラブルシューティング

### メッセージが送信されない

**症状**: メッセージがプロンプトに表示されるが、AI が応答しない

**解決策**:

- Claude / Gemini: Enter で確定してから Ctrl-D を送信しているか確認
- Codex: Enter のみで送信（Ctrl-Dは送信しない）
- スクリプトを使用する場合、この処理は自動的に実行されます

### ペインが見つからない

**症状**: "can't find session" エラーが表示される

**解決策**:

```bash
# セッション一覧を確認
tmux list-sessions

# ペイン一覧を確認
tmux list-panes -t claude:claude
```

### 応答が表示されない

**症状**: スクリプトは完了するが、AI の応答が見えない

**解決策**:

- 待機時間を長くする（複雑な処理の場合）
- より広い範囲をキャプチャする（-S -100 など）

## マルチエージェント活用例

### 例 1: 分散タスク処理

```bash
# エージェント1にドキュメント作成を依頼
./send-message.sh エージェント1 "READMEを作成してください"

# エージェント2に同時並行でテスト作成を依頼
./send-message.sh エージェント2 "ユニットテストを作成してください"
```

### 例 2: レビューワークフロー

```bash
# エージェント1にコード実装を依頼
./send-message.sh エージェント1 "新機能を実装してください"

# エージェント2に実装結果のレビューを依頼
./send-message.sh エージェント2 "エージェント1の実装をレビューしてください"
```

### 例 3: ボスパターン

```bash
# ボスにタスク振り分けを依頼
./send-message.sh ボス "プロジェクトのタスクをエージェント1と2に振り分けてください"
```

## エージェントの役割定義

各エージェントの役割は `instructions/` ディレクトリで定義されます。詳細は各ファイルを参照してください。

## 技術詳細

詳細な技術仕様やメッセージ送信の内部動作については、[docs/message-sending-design.md](docs/message-sending-design.md) を参照してください。

## 関連ファイル

- `setup.sh`: tmux セッション作成スクリプト
- `send-message.sh`: メッセージ送信スクリプト
- `instructions/`: 各エージェントの役割定義
- `docs/message-sending-design.md`: 技術設計書
