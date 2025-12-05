# Multi-Agent Tmux to GitHub Action

このリポジトリは、2 つのリポジトリの機能を融合したプロジェクトです。

## 構成

このリポジトリは以下の 2 つのディレクトリを含んでいます：

- **[codex-auto-review](./codex-auto-review/)**: GitHub Actions と Codex を使った自動コードレビューシステム
- **[multi-agent-tmux](./multi-agent-tmux/)**: Multi-agent tmux システム

## セットアップ

### クローン

```bash
git clone <repository-url>
cd malti-agent-tmux-to-github-acton
```

### マルチエージェントシステムの起動

```bash
# tmuxセッションを作成
./multi-agent-tmux/setup.sh

# エージェントにタスク送信
./multi-agent-tmux/send-message.sh エージェント1 "タスク内容"
```

詳細は [PROJECT_CONTEXT.md](PROJECT_CONTEXT.md) を参照してください。

## 各ディレクトリでの作業

各ディレクトリ内のファイルは通常のファイルとして直接編集できます。

```bash
# 例: multi-agent-tmux の設定を編集
vim multi-agent-tmux/setup.sh

# 変更をコミット
git add multi-agent-tmux/setup.sh
git commit -m "変更内容の説明"
git push origin main
```

## 融合機能の開発

融合した機能は、このリポジトリのルートディレクトリまたは `src/` ディレクトリに配置して開発します。

## ブランチ保護

main ブランチへの直接プッシュを防ぐため、以下の設定を推奨します。

### 方法 1: GitHub Pro を使用（推奨）

GitHub Pro アカウントをお持ちの場合、GitHub の Web インターフェースからブランチ保護を設定できます：

1. リポジトリの Settings → Branches
2. Branch protection rules → Add rule
3. Branch name pattern: `main`
4. 以下を有効化：
   - Require a pull request before merging
   - Require approvals: 1（必要に応じて）

### 方法 2: Git pre-push フック（ローカル設定）

各開発者のローカル環境で pre-push フックを設定：

```bash
# pre-pushフックをインストール
cp .github/hooks/pre-push .git/hooks/pre-push
chmod +x .git/hooks/pre-push
```

これにより、main ブランチへの直接プッシュがローカルでブロックされます。

### 推奨ワークフロー

main ブランチへの変更は、必ずプルリクエスト経由で行ってください：

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

## ライセンス

MIT
