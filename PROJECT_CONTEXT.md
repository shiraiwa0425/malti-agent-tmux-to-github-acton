# マルチエージェント評価プロジェクト - プロジェクトコンテキスト

このドキュメントは、すべてのAIアシスタント（Claude、Cursor、Codex等）が参照する共通のプロジェクト情報です。

**最終更新**: 2025年11月26日

## クイックスタート

### multi-agent-tmux を使う場合

```bash
# 1. セッション作成
./multi-agent-tmux/setup.sh

# 2. エージェントにメッセージ送信
./multi-agent-tmux/send-message.sh エージェント1 "タスク内容"
./multi-agent-tmux/send-message.sh エージェント2 "タスク内容"
./multi-agent-tmux/send-message.sh エージェント3 "タスク内容"

# 3. 完了フラグクリア（新タスク前）
./multi-agent-tmux/clear-flags.sh
```

### エイリアス一覧

| エイリアス | ペイン | 役割 |
|-----------|--------|------|
| `ボス` / `command` | 0 | タスク振り分け |
| `エージェント1` / `agent1` | 1 | タスク実行 |
| `エージェント2` / `agent2` | 2 | タスク実行 |
| `エージェント3` / `agent3` | 3 | タスク実行 |

## プロジェクトの目的

- マルチエージェントシステムの動作検証と評価
- 各システムの性能とタスク処理能力の測定
- 実際のWebアプリケーション開発を通じた評価

## 評価対象システム

### 1. codex-auto-review
GitHub Actions + Codex による自動コードレビューシステム

**詳細**: [codex-auto-review/AGENTS.md](codex-auto-review/AGENTS.md)

### 2. multi-agent-tmux
tmux上で複数のClaude Codeエージェントを協調動作させるシステム

**詳細**: [multi-agent-tmux/Claude.md](multi-agent-tmux/Claude.md)

```
┌──────────────────────────────────────────────────┐
│              tmuxセッション: claude               │
├──────────┬──────────┬──────────┬──────────┤
│  ペイン0  │  ペイン1  │  ペイン2  │  ペイン3  │
│   ボス   │エージェント1│エージェント2│エージェント3│
└──────────┴──────────┴──────────┴──────────┘
```

| スクリプト | 機能 |
|-----------|------|
| `setup.sh` | tmuxセッション作成 |
| `send-message.sh` | メッセージ送信 |
| `orchestrate.sh` | 自動タスク振り分け |
| `clear-flags.sh` | 完了フラグクリア |

**環境変数**: `CLAUDE_ROLE`（boss/agent）、`PANE_INDEX`（0-3）

## 成果物

すべての成果物は `dist/` ディレクトリに集約します。

```
dist/
├── outputs/      # 生成物（コード、アプリ等）
├── evaluations/  # 評価レポート
├── logs/         # 実行ログ
├── artifacts/    # スクリーンショット等
└── tmp/          # 完了フラグ（一時ファイル）
```

**命名規則**: `YYYYMMDD-HHMMSS-プロジェクト名`（例: `20251124-190104-ai-news-page`）

### 成果物について

`dist/outputs/`はGitで管理されていません（`.gitignore`で除外）。成果物はローカル環境でのみ存在します。

#### 過去に作成した成果物（参考）
- AI News Page（Next.js 16 / React 19 / Tailwind CSS 4）
- 松葉蟹紹介ページ（Three.js使用）
- レストラン経費アプリ
- 松葉蟹メニューシステム

## マルチエージェントの使用判断

**[.claude/guides/commander.md](.claude/guides/commander.md) の判断フローチャートを参照してください。**

簡易基準: 並行処理可能な独立タスクが3つ以上あり、各5分以上かかる場合

## プロジェクト構造（主要ファイル）

```
プロジェクトルート/
├── PROJECT_CONTEXT.md      # このファイル
├── CLAUDE.md               # Claude Code設定
├── AGENTS.md               # Codex設定
├── .claude/
│   ├── commands/           # スラッシュコマンド
│   ├── context/            # ボス・エージェント用コンテキスト
│   ├── guides/             # commander.md等
│   ├── workflows/          # タスク別ワークフロー
│   ├── hooks/              # セッションフック
│   └── settings.json
├── dist/                   # 成果物
├── codex-auto-review/      # サブモジュール
└── multi-agent-tmux/       # サブモジュール
    ├── setup.sh
    ├── send-message.sh
    ├── orchestrate.sh
    └── instructions/       # boss.md, agent.md
```

## Git操作

- **サブモジュール**: codex-auto-review、multi-agent-tmux
- **ブランチ保護**: mainへの直接プッシュは避け、PR経由で変更

**詳細**: [README.md](README.md)

## すべてのAIが確認すべき観点

レビューやコード変更時に確認すべき共通チェックリスト：

- **成果物配置**: すべての生成物は `dist/` ディレクトリに配置されているか
- **サブモジュール**: codex-auto-review、multi-agent-tmuxへの変更は適切に管理されているか
- **ブランチルール**: mainへの直接プッシュを避け、PR経由で変更しているか
- **命名規則**: 成果物は `YYYYMMDD-HHMMSS-プロジェクト名` 形式に従っているか
- **ドキュメント**: 重要な変更はPROJECT_CONTEXT.mdに反映されているか

## トラブルシューティング

| 問題 | 解決策 |
|------|--------|
| メッセージが送信されない | `tmux list-sessions`でセッション確認 |
| エージェントが応答しない | 5秒以上待つ、またはペイン内容を手動確認 |
| 完了フラグが残っている | `./clear-flags.sh`を実行 |
| セッションが見つからない | `./setup.sh`で再作成 |

## リソース

### 必読ドキュメント
- [multi-agent-tmux/Claude.md](multi-agent-tmux/Claude.md) - 使用ガイド
- [.claude/guides/commander.md](.claude/guides/commander.md) - ボスの役割定義
- [multi-agent-tmux/instructions/boss.md](multi-agent-tmux/instructions/boss.md) - ボス指示書
- [multi-agent-tmux/instructions/agent.md](multi-agent-tmux/instructions/agent.md) - エージェント指示書

### 参考ドキュメント
- [.claude/workflows/](.claude/workflows/) - ワークフロー定義
- [dist/README.md](dist/README.md) - 成果物ディレクトリ詳細
- [multi-agent-tmux/docs/](multi-agent-tmux/docs/) - 技術設計書

## 最近の変更点（2025年11月）

- `PANE_INDEX`環境変数追加
- `orchestrate.sh`実装（自動タスク振り分け）
- 完了フラグ機構（`dist/tmp/`）
- `.claude/context/`追加（ボス・エージェント用コンテキスト）
- `.claude/hooks/`追加（セッションログ）
- AI News Page作成
