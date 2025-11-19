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

## ライセンス

各サブモジュールのライセンスに従います。

