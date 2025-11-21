# Multi-Agent Tmux to GitHub Action

このリポジトリは、2つのリポジトリの機能を融合したプロジェクトです。

## 構成

このリポジトリは以下の2つのサブモジュールを含んでいます：

- **[codex-auto-review](./codex-auto-review/)**: GitHub ActionsとCodexを使った自動コードレビューシステム
- **[multi-agent-tmux](./multi-agent-tmux/)**: Multi-agent tmuxシステム

## セットアップ

### 初回クローン時

```bash
git clone --recursive <repository-url>
```

または、通常のクローン後に：

```bash
git submodule update --init --recursive
```

### サブモジュールの更新

```bash
# すべてのサブモジュールを最新の状態に更新
git submodule update --remote

# 特定のサブモジュールを更新
git submodule update --remote codex-auto-review
git submodule update --remote multi-agent-tmux
```

## 各サブモジュールでの作業

### サブモジュール内で変更を加える

```bash
# codex-auto-review に変更を加える例
cd codex-auto-review

# 変更を加える
# ... 編集 ...

# 変更をコミット
git add .
git commit -m "変更内容の説明"

# フォーク先にプッシュ
git push origin main

# 親リポジトリに戻る
cd ..

# サブモジュールの更新を親リポジトリに記録
git add codex-auto-review
git commit -m "Update codex-auto-review submodule"
git push origin main
```

### multi-agent-tmux に変更を加える場合も同様

```bash
cd multi-agent-tmux
# 変更を加える
git add .
git commit -m "変更内容"
git push origin main
cd ..
git add multi-agent-tmux
git commit -m "Update multi-agent-tmux submodule"
git push origin main
```

## 融合機能の開発

融合した機能は、このリポジトリのルートディレクトリまたは `src/` ディレクトリに配置して開発します。

## ブランチ保護

mainブランチへの直接プッシュを防ぐため、以下の設定を推奨します。

### 方法1: GitHub Proを使用（推奨）

GitHub Proアカウントをお持ちの場合、GitHubのWebインターフェースからブランチ保護を設定できます：

1. リポジトリの Settings → Branches
2. Branch protection rules → Add rule
3. Branch name pattern: `main`
4. 以下を有効化：
   - Require a pull request before merging
   - Require approvals: 1（必要に応じて）

### 方法2: Git pre-pushフック（ローカル設定）

各開発者のローカル環境でpre-pushフックを設定：

```bash
# pre-pushフックをインストール
cp .github/hooks/pre-push .git/hooks/pre-push
chmod +x .git/hooks/pre-push
```

これにより、mainブランチへの直接プッシュがローカルでブロックされます。

### 推奨ワークフロー

mainブランチへの変更は、必ずプルリクエスト経由で行ってください：

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

各サブモジュールのライセンスに従います。

