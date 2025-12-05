# tmux ペイン間メッセージ送信機能 設計書

## 概要

このドキュメントは、tmux セッション内の特定のペインにメッセージを送信し、AI CLI（Claude / Codex / Gemini）に処理させる機能の設計と実装方法を説明します。

## 目的

マルチエージェント構成の tmux セッションにおいて、あるペイン（ボスなど）から別のペイン（エージェント）にメッセージを送信し、自動的に AI CLI に処理させることを可能にします。

## システム構成

### 前提条件

- tmux がインストールされていること
- 使用する AI CLI がインストールされていること（claude / codex / gemini）
- マルチエージェント構成の tmux セッションが作成されていること（setup.sh で作成可能）

### セッション構造

```
セッション: <AI名>  (claude / codex / gemini)
  └─ ウィンドウ: <AI名>
      ├─ ペイン 0: ボス（タスク振り分け）
      ├─ ペイン 1: エージェント1（タスク実行）
      ├─ ペイン 2: エージェント2（タスク実行）
      └─ ペイン 3: エージェント3（タスク実行）
```

## メッセージ送信フロー

### 1. 基本的な送信フロー

```
[ユーザー/スクリプト]
    ↓
[tmux send-keys: メッセージ入力]
    ↓
[対象ペインにテキストが入力される]
    ↓
[tmux send-keys: Ctrl-D送信]
    ↓
[Claude Codeがメッセージを受信・処理]
    ↓
[Claude Codeが応答を返す]
```

### 2. 詳細な実行ステップ

#### ステップ 1: セッションとペインの確認

```bash
# セッションが存在するか確認
tmux has-session -t <SESSION_NAME>

# ペイン一覧を取得
tmux list-panes -t <SESSION_NAME>:<WINDOW_NAME> -F "#{pane_index}"
```

#### ステップ 2: メッセージの送信

```bash
# テキストをペインに入力
tmux send-keys -t <SESSION_NAME>:<WINDOW_NAME>.<PANE_NUMBER> "<MESSAGE>"

# Enterキーで入力を確定
tmux send-keys -t <SESSION_NAME>:<WINDOW_NAME>.<PANE_NUMBER> C-m
```

**重要ポイント:**

- メッセージはテキストとして入力した後、`C-m`（Enter キー）で確定する
- この時点ではまだ Claude にメッセージは送信されていない

#### ステップ 3: Claude Code への送信

```bash
# Ctrl-Dを送信してメッセージを送信
tmux send-keys -t <SESSION_NAME>:<WINDOW_NAME>.<PANE_NUMBER> C-d
```

**重要ポイント:**

- **Claude / Gemini**: `Ctrl-D`がメッセージ送信のトリガー。メッセージ入力 → Enter → Ctrl-D の順序で送信する
- **Codex**: `Ctrl-D` を受け取ると終了してしまうため、Enter のみで送信する
- `send-message.sh` はセッション名を見て自動で送信方式を切り替える

| AI CLI | 送信方式 |
|--------|----------|
| Claude | Enter + Ctrl-D |
| Gemini | Enter + Ctrl-D |
| Codex  | Enter のみ |

#### ステップ 4: 応答の確認

```bash
# ペインの内容をキャプチャ
tmux capture-pane -t <SESSION_NAME>:<WINDOW_NAME>.<PANE_NUMBER> -p

# 履歴を含めてキャプチャ（-S オプション）
tmux capture-pane -t <SESSION_NAME>:<WINDOW_NAME>.<PANE_NUMBER> -p -S -30
```

## スクリプト仕様

### send-message.sh

#### 概要

tmux セッション内の指定されたペインにメッセージを送信し、Claude Code に処理させるスクリプト。

#### 使用方法

```bash
# 形式1: セッション名 + ペイン番号を指定
./send-message.sh <セッション名> <ペイン番号> <メッセージ...>

# 形式2: 既定セッション(claude) + エイリアスだけで送信
./send-message.sh <エイリアス> <メッセージ...>
```

#### 引数

- `セッション名` (任意): 対象の tmux セッション名（例: `claude`）。省略すると `claude` が使用される
- `ペイン番号`: メッセージを送信するペインの番号（0, 1, 2 など）。エイリアス指定も可
- `エイリアス`: `ボス`, `エージェント1`, `エージェント2` など、ペイン番号に対応するラベル
- `メッセージ`: 送信するテキストメッセージ（空白を含む任意の文字列）

#### エイリアス対応

| エイリアス                                        | 対応ペイン |
| ------------------------------------------------- | ---------- |
| `ボス`, `コマンドセンター`, `command`, `ユーザー` | 0          |
| `エージェント1`, `agent1`                         | 1          |
| `エージェント2`, `agent2`                         | 2          |

`DEFAULT_SESSION_NAME` 環境変数を設定することで、既定のセッション名 (`claude`) を切り替えることもできる。

#### 実行例

```bash
# 従来形式
./send-message.sh claude 1 "こんにちわ"

# エイリアス形式（既定セッションに送信）
./send-message.sh エージェント1 "README.mdを要約してください"
```

#### 機能詳細

1. **引数チェック**

   - 必要な引数が揃っているか確認
   - 不足している場合は使用方法を表示して終了

2. **セッション存在確認**

   - 指定されたセッションが存在するか確認
   - 存在しない場合は、利用可能なセッション一覧を表示

3. **ペイン存在確認**

   - 指定されたペイン番号が存在するか確認
   - 存在しない場合は、利用可能なペイン一覧を表示

4. **メッセージ送信**

   - テキストを入力
   - Ctrl-D でメッセージを確定

5. **応答待機**

   - 5 秒間待機して Claude の応答を待つ

6. **結果表示**
   - ペインの最新 30 行をキャプチャして表示

#### エラーハンドリング

- セッションが存在しない場合: エラーメッセージと利用可能なセッション一覧を表示
- ペインが存在しない場合: エラーメッセージと利用可能なペイン一覧を表示

## キーコマンド

### AI CLI で使用される主なキーボードショートカット

#### Claude / Gemini

| キー     | 機能                             |
| -------- | -------------------------------- |
| `Ctrl-D` | メッセージを送信                 |
| `Ctrl-C` | 現在の操作をキャンセル           |

#### Codex

| キー     | 機能                             |
| -------- | -------------------------------- |
| `Enter`  | メッセージを送信                 |
| `Ctrl-C` | 現在の操作をキャンセル           |

> **注意**: Codex では `Ctrl-D` を送信するとセッションが終了してしまうため、`send-message.sh` はセッション名を判定して自動的に送信方式を切り替えます。

## tmux コマンドリファレンス

### ペイン操作関連

```bash
# ペイン一覧を表示
tmux list-panes -t <session>:<window>

# ペイン情報を取得
tmux list-panes -t <session>:<window> -F "#{pane_index}: #{pane_current_command}"

# ペインにキーを送信
tmux send-keys -t <session>:<window>.<pane> "<text>" <key>

# ペインの内容をキャプチャ
tmux capture-pane -t <session>:<window>.<pane> -p

# ペインの履歴を含めてキャプチャ
tmux capture-pane -t <session>:<window>.<pane> -p -S <start_line>
```

### セッション操作関連

```bash
# セッション存在確認
tmux has-session -t <session>

# セッション一覧
tmux list-sessions

# ウィンドウ一覧
tmux list-windows -t <session>
```

## 実装時の注意事項

### 1. タイミングの考慮

- メッセージ送信後、Claude が応答するまでに時間がかかる場合がある
- スクリプトでは 5 秒の待機時間を設けているが、複雑な処理の場合はより長い時間が必要な場合がある

### 2. エラーハンドリング

- セッションやペインが存在しない場合の処理を必ず実装する
- ユーザーにわかりやすいエラーメッセージを表示する

### 3. セキュリティ

- メッセージに含まれる特殊文字のエスケープ処理に注意
- シェルインジェクションを防ぐため、引数を適切にクォートする

### 4. デバッグ

- 各ステップで適切なログメッセージを表示する
- `tmux capture-pane`を使用して実際の状態を確認できるようにする

## 使用例

### 例 1: 簡単な挨拶（エイリアス）

```bash
./send-message.sh エージェント1 "こんにちわ"
```

### 例 2: タスクの依頼（セッション + ペイン番号）

```bash
./send-message.sh claude 1 "README.mdファイルの内容を要約してください"
```

### 例 3: コードレビューの依頼（エイリアス）

```bash
./send-message.sh エージェント2 "setup.shのコードレビューをお願いします"
```

## トラブルシューティング

### 問題 1: メッセージが送信されない

**症状:** メッセージがプロンプトに表示されるが、Claude が応答しない

**原因:** Ctrl-D だけでは送信できない。Enter で確定してから Ctrl-D が必要

**解決策:**

```bash
# 誤った方法（送信されない）
tmux send-keys -t claude:claude.1 "こんにちわ"
tmux send-keys -t claude:claude.1 C-d

# 正しい方法（Enter → Ctrl-D）
tmux send-keys -t claude:claude.1 "こんにちわ"
tmux send-keys -t claude:claude.1 C-m
tmux send-keys -t claude:claude.1 C-d
```

### 問題 2: ペインが見つからない

**症状:** "can't find session" エラーが表示される

**原因:** セッション名またはペイン番号が間違っている

**解決策:**

```bash
# セッション一覧を確認
tmux list-sessions

# ペイン一覧を確認
tmux list-panes -t claude:claude
```

### 問題 3: 応答が表示されない

**症状:** スクリプトは完了するが、Claude の応答が見えない

**原因:** 待機時間が短すぎる、またはキャプチャ範囲が狭い

**解決策:**

```bash
# より長い待機時間を設定
sleep 10

# より広い範囲をキャプチャ
tmux capture-pane -t claude:claude.1 -p -S -100
```

## 今後の拡張案

### 1. 双方向通信

- エージェント間でメッセージを相互に送信できる仕組み
- レスポンスを自動的にパースして次のアクションを決定

### 2. バッチ処理

- 複数のメッセージを順次送信
- 前のメッセージの応答を待ってから次を送信

### 3. ログ機能

- すべてのやり取りをファイルに記録
- タイムスタンプ付きのログ

### 4. 応答のパース

- Claude の応答を構造化データとして取得
- 次のアクションを自動的に決定

## 関連ファイル

- `setup.sh`: tmux セッション作成スクリプト
- `send-message.sh`: メッセージ送信スクリプト
- `README.md`: プロジェクト全体の説明
- `instructions/`: 各エージェントの役割定義

## 参考資料

- [tmux 公式ドキュメント](https://github.com/tmux/tmux/wiki)
- [Claude Code 公式ドキュメント](https://docs.claude.com/en/docs/claude-code)

## バージョン履歴

- v1.1.0 (2025-12-05): Gemini CLI 対応
  - Claude / Codex / Gemini のマルチAI対応
  - 送信方式の差異を明記（Claude/Gemini: Enter+Ctrl-D、Codex: Enterのみ）
  - セッション構造を4ペイン構成に更新
- v1.0.0 (2025-11-12): 初版作成
  - 基本的なメッセージ送信機能
  - エラーハンドリング
  - 応答キャプチャ機能
