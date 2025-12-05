# Simple Test Workflow

動作確認用のシンプルなテストワークフロー

---

## AGENT1

現在の日時を表示し、システム情報を確認してください。

```bash
date
uname -a
```

完了後、完了フラグを作成してください。

---

## AGENT2

現在のディレクトリ構造を確認し、主要なファイルをリストアップしてください。

```bash
ls -la
```

完了後、完了フラグを作成してください。

---

## AGENT3

環境変数を確認し、PANE_INDEX と AI_SESSION の値を報告してください。

```bash
echo "PANE_INDEX: $PANE_INDEX"
echo "AI_SESSION: $AI_SESSION"
```

完了後、完了フラグを作成し、全員の完了を確認してボスに報告してください。
