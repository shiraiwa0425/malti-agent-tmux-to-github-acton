# 成果物ディレクトリ

このディレクトリには、マルチエージェントの動作評価に関連するすべての成果物を保管します。

## ディレクトリ構造

### outputs/
マルチエージェントによって生成された成果物を保存します。

例：
- 生成されたコード
- 設定ファイル
- ドキュメント

### evaluations/
評価結果とレポートを保存します。

例：
- 評価レポート（Markdown、JSON など）
- パフォーマンス測定結果
- 比較分析

### logs/
実行ログを保存します。

例：
- エージェント実行ログ
- エラーログ
- デバッグ情報

### artifacts/
その他の成果物を保存します。

例：
- スクリーンショット
- ビデオ録画
- データベースダンプ

## 命名規則

評価実行ごとにタイムスタンプ付きのサブディレクトリを作成することを推奨します：

```
outputs/YYYYMMDD-HHMMSS-task-name/
evaluations/YYYYMMDD-HHMMSS-task-name/
logs/YYYYMMDD-HHMMSS-task-name/
```

例：
```
outputs/20250121-143022-codex-review-test/
evaluations/20250121-143022-codex-review-test/
logs/20250121-143022-codex-review-test/
```
