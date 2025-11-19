# プロジェクト記録

## プロジェクト概要

このプロジェクトは、2つのリポジトリの機能を融合したマルチエージェントシステムです。

- **codex-auto-review**: GitHub ActionsとCodexを使った自動コードレビューシステム
- **multi-agent-tmux**: Multi-agent tmuxシステム（司令塔1体 + エージェント3体）

## プロジェクト構成

```
malti-agent-tmux-to-github-acton/
├── codex-auto-review/      (submodule)
├── multi-agent-tmux/       (submodule)
├── src/                    (融合機能の開発予定)
├── .gitmodules
└── README.md
```

## 進捗状況

### 完了した作業

- [x] Git Submoduleのセットアップ
- [x] GitHubリポジトリの作成（プライベート）
- [x] エージェント数を2体から3体に拡張
  - setup.shの更新
  - send-message.shのエイリアス追加
  - instructions/agent.mdの更新
  - instructions/boss.mdの更新

### 今後の予定

- [ ] 融合機能の設計
- [ ] 融合機能の実装
- [ ] GitHub Actionsとの統合
- [ ] ドキュメントの整備

## 変更履歴

### 2024-11-19
- エージェント3を追加
- マルチエージェント構成を拡張（司令塔1体 + エージェント3体）

## 関連リポジトリ

- [codex-auto-review](https://github.com/shiraiwa0425/codex-auto-review)
- [multi-agent-tmux](https://github.com/shiraiwa0425/multi-agent-tmux)

