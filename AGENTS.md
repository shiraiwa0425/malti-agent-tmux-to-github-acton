# Codex Agent 設定

## プロジェクトコンテキスト

**このプロジェクトの詳細は [PROJECT_CONTEXT.md](PROJECT_CONTEXT.md) を参照してください。**

すべての AI が確認すべき観点は、[PROJECT_CONTEXT.md](PROJECT_CONTEXT.md) の「すべての AI が確認すべき観点」セクションを参照してください。
作業開始前に、PROJECT_CONTEXT.md の「必読ファイル」セクションも必ず確認してください。

## あなたの役割

| 役割                       | 指示書                                                       |
| -------------------------- | ------------------------------------------------------------ |
| ボス（boss）               | [docs/instructions/boss.md](docs/instructions/boss.md)       |
| エージェント（agent1/2/3） | [docs/instructions/agent.md](docs/instructions/agent.md)     |

> 指示書はClaude/Codex共通です。

## スラッシュコマンド

| コマンド             | 説明                          |
| -------------------- | ----------------------------- |
| `/multi-agent-setup` | tmux セッションのセットアップ |
| `/evaluate`          | マルチエージェント評価の実行  |

## Codex 固有の設定

### 役割

GitHub Actions で Codex を実行し、プルリクエストに対して自動レビューコメントを投稿します。

### レビュー分類（Codex 固有）

Codex は以下のバッジを使用してレビューコメントを分類します：

- **P1 Badge（重大）**: 動作への影響が大きいもの、セキュリティ問題
- **P2 Badge（改善）**: テスト不足、パフォーマンス問題、改善提案
- **P3 Badge（軽微）**: スタイル、命名、ドキュメント

### レビューコメントの指針

- コメントは日本語で簡潔に記載
- 根拠となるファイル/行を明記
- この PR の変更パターンが他のファイルにも適用できないか確認
- 不要ファイルや生成物（`dist/`内の一時ファイル等）はレビュー対象から外す

### GitHub Actions での使用

このファイル（AGENTS.md）は、親リポジトリの GitHub Actions ワークフロー（[.github/workflows/codex-review.yml](.github/workflows/codex-review.yml)）で自動的に使用されます。

#### 動作タイミング

親リポジトリでプルリクエストが作成または更新されると：

1. `codex-review.yml` ワークフローが実行される
2. PROJECT_CONTEXT.md と AGENTS.md が読み込まれる
3. Codex へのレビュー依頼コメントが投稿される
4. Codex がプロジェクトコンテキストとレビュー観点に基づいてレビューを実行

#### サブモジュールでの動作

**注意**: サブモジュール（codex-auto-review、multi-agent-tmux）内の変更に対するレビューは、各サブモジュールのリポジトリ内の GitHub Actions で実行されます。親リポジトリのワークフローは、親リポジトリ自体のファイル変更のみをレビューします。

#### 必要な設定

- **PAT_TOKEN**: Personal Access Token（Classic、scope: `repo`）をリポジトリの Secrets に設定する必要があります
  - Settings → Secrets and variables → Actions → New repository secret
  - Name: `PAT_TOKEN`
  - Value: GitHub Personal Access Token

## 参考リソース

- [PROJECT_CONTEXT.md](PROJECT_CONTEXT.md) - プロジェクト全体の共通情報
- [codex-auto-review/AGENTS.md](codex-auto-review/AGENTS.md) - codex-auto-review サブモジュール固有の設定
- [README.md](README.md) - プロジェクト概要
