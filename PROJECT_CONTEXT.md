# マルチエージェント評価プロジェクト - プロジェクトコンテキスト

このドキュメントは、すべてのAIアシスタント（Claude、Cursor、Codex等）が参照する共通のプロジェクト情報です。

## プロジェクトの目的

このプロジェクトは、2つのマルチエージェントシステム（codex-auto-review、multi-agent-tmux）の動作を評価するためのプロジェクトです。

- マルチエージェントシステムの動作検証と評価
- 各システムの性能とタスク処理能力の測定
- 改善点の特定とフィードバックの収集

## 評価対象システム

### 1. codex-auto-review
GitHub Actions と Codex を使った自動コードレビューシステム

**詳細**: [codex-auto-review/AGENTS.md](codex-auto-review/AGENTS.md)

### 2. multi-agent-tmux
tmux上で複数のClaude Codeエージェントを協調動作させるシステム

**詳細**: [multi-agent-tmux/Claude.md](multi-agent-tmux/Claude.md)

## 成果物の保管場所

本プロジェクトでは、すべての評価成果物を `dist/` ディレクトリに集約します。

### ディレクトリ構造

```
dist/
├── outputs/          # マルチエージェントの生成物（コード、ドキュメント等）
├── evaluations/      # 評価結果とレポート
├── logs/             # 実行ログ
└── artifacts/        # その他の成果物（スクリーンショット等）
```

**詳細**: [dist/README.md](dist/README.md)

### 重要ルール

- **グローバルディレクトリには成果物を置かない**
- すべての評価関連ファイルは `dist/` に集約する
- 各評価実行ごとにタイムスタンプ付きのサブディレクトリを作成することを推奨
  ```
  例: dist/outputs/20250121-143022-codex-review-test/
  ```

## Git操作の重要事項

### サブモジュール構成

このプロジェクトは2つのサブモジュールを含んでいます：
- **codex-auto-review**: サブモジュール1
- **multi-agent-tmux**: サブモジュール2

### サブモジュール内で変更を行う場合の手順

**重要**: サブモジュール内で変更を行う場合は、必ず以下の手順に従ってください：

```bash
# 1. サブモジュールに移動
cd codex-auto-review  # または multi-agent-tmux

# 2. 変更を加える
# ... 編集 ...

# 3. サブモジュール内でコミット・プッシュ
git add .
git commit -m "変更内容の説明"
git push origin main

# 4. 親リポジトリに戻る
cd ..

# 5. 親リポジトリでサブモジュール参照を更新
git add codex-auto-review  # または multi-agent-tmux
git commit -m "Update codex-auto-review submodule"
git push origin main
```

### ブランチ保護

main ブランチへの直接プッシュを防ぐため、以下のワークフローを推奨：

```bash
# 1. ブランチを作成
git checkout -b feature/your-feature

# 2. 変更をコミット
git add .
git commit -m "変更内容"

# 3. ブランチをプッシュ
git push origin feature/your-feature

# 4. プルリクエストを作成
gh pr create --title "変更内容" --body "説明"
```

詳細は [README.md](README.md) を参照してください。

## 評価ワークフロー

### 基本的な流れ

1. **マルチエージェントシステムの起動**
   - codex-auto-review: GitHub Actions ワークフローを実行
   - multi-agent-tmux: `./setup.sh` で tmux セッションを作成

2. **タスクの実行**
   - 評価シナリオに基づいてタスクを投入
   - 各エージェントの動作を観察

3. **成果物の保存**
   - 生成物を `dist/outputs/` に保存
   - ログを `dist/logs/` に保存

4. **評価の実施**
   - 成果物の品質を評価
   - パフォーマンス測定
   - 評価結果を `dist/evaluations/` に保存

5. **レポート作成**
   - 評価結果をまとめたレポートを作成
   - 改善提案を含める

## すべてのAIが確認すべき観点

すべてのAIアシスタント（Claude、Cursor、Codex等）は、以下の観点を確認してください：

### 成果物の配置
- すべての評価成果物は `dist/` ディレクトリに配置されているか
- グローバルディレクトリに成果物が置かれていないか
- タイムスタンプ付きのサブディレクトリが適切に使用されているか（例: `20250121-143022-task-name`）

### サブモジュールの扱い
- サブモジュール内の変更は、サブモジュール内でコミット・プッシュされているか
- 親リポジトリでサブモジュール参照が適切に更新されているか
- サブモジュールの変更と親リポジトリの変更が混在していないか

### ブランチ保護
- main ブランチへの直接プッシュが行われていないか
- プルリクエスト経由での変更になっているか

### 評価ドキュメント
- 評価結果が適切にドキュメント化されているか
- 評価項目が下記の「評価項目例」をカバーしているか
- マルチエージェントシステムの動作ログが適切に保存されているか

## 評価項目例

### codex-auto-review の評価

- レビューコメントの精度
- P1/P2/P3 バッジの適切性
- 応答時間
- 見逃された問題の有無

### multi-agent-tmux の評価

- エージェント間の協調動作の効率性
- タスク振り分けの適切性
- メッセージ送受信の信頼性
- 複数エージェントによる処理の高速化効果

## プロジェクト構造

```
プロジェクトルート/
├── PROJECT_CONTEXT.md           # このファイル（全AI共通）
├── CLAUDE.md                    # Claude Code用設定
├── AGENTS.md                    # Codex用設定
├── .cursorrules                 # Cursor用設定
├── .github/
│   ├── hooks/                   # Git hooks
│   │   └── pre-push             # main直接プッシュ防止
│   └── workflows/               # GitHub Actions
│       ├── branch-protection.yml    # ブランチ保護チェック
│       └── codex-review.yml         # Codexレビュー（親リポジトリ用）
├── .claude/                     # Claude固有の設定
│   └── commands/                # スラッシュコマンド
│       └── evaluate.md          # 評価ワークフロー
├── dist/                        # 成果物保管場所
│   ├── outputs/
│   ├── evaluations/
│   ├── logs/
│   └── artifacts/
├── codex-auto-review/           # サブモジュール1
│   ├── AGENTS.md                # サブモジュール固有設定
│   └── .github/workflows/       # サブモジュール用ワークフロー
│       ├── pr-review.yml        # Codexレビュー依頼
│       └── comment-reply.yml    # Codexコメント返信
└── multi-agent-tmux/            # サブモジュール2
    └── Claude.md                # ツール使用ガイド
```

## リソース

### 各システムのドキュメント

- [codex-auto-review/AGENTS.md](codex-auto-review/AGENTS.md) - Codex レビューシステムの運用ガイド
- [multi-agent-tmux/Claude.md](multi-agent-tmux/Claude.md) - Multi-agent tmux の使用ガイド
- [multi-agent-tmux/docs/message-sending-design.md](multi-agent-tmux/docs/message-sending-design.md) - メッセージ送信の技術設計

### その他

- [README.md](README.md) - プロジェクト概要（人間向け）
- [dist/README.md](dist/README.md) - 成果物ディレクトリの詳細
