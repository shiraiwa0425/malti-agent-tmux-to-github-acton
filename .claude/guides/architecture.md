# アーキテクチャ構成ガイド

このドキュメントは、本プロジェクトで作成するアプリケーションの技術スタック・アーキテクチャ構成を定義します。

## JavaScript ランタイム

### 採用: Bun

**Node.js ではなく Bun を使用してください。**

| 項目 | 内容 |
|------|------|
| ランタイム | **Bun** (https://bun.sh) |
| 理由 | Anthropic による正式買収、高速性、Node.js互換性 |
| 変更日 | 2024年12月 |

### Bun の特徴

- **高速**: Node.js より大幅に高速なパッケージインストール・実行
- **オールインワン**: ランタイム、パッケージマネージャー、バンドラー、テストランナーを統合
- **Node.js互換**: 既存のNode.jsプロジェクトとの互換性
- **TypeScript対応**: ネイティブでTypeScriptをサポート

### コマンド対応表

| npm/Node.js | Bun |
|-------------|-----|
| `npm install` | `bun install` |
| `npm run dev` | `bun run dev` |
| `npm run build` | `bun run build` |
| `npx create-next-app` | `bunx create-next-app` |
| `node script.js` | `bun script.js` |

### プロジェクト作成時の注意

Next.js プロジェクト作成時:
```bash
# Bun を使用
bunx create-next-app@latest . --typescript --tailwind --eslint --app

# --use-npm フラグは使用しない
```

パッケージインストール時:
```bash
# Bun を使用
bun install
bun add <package-name>
```

## 推奨技術スタック

### フロントエンド

| カテゴリ | 技術 |
|----------|------|
| フレームワーク | Next.js 14+ (App Router) |
| 言語 | TypeScript |
| スタイリング | Tailwind CSS |
| UIライブラリ | shadcn/ui（必要に応じて） |

### バックエンド（必要な場合）

バックエンドは要件に応じて **Next.js** または **Python** を選択してください。

#### オプション1: Next.js API Routes（推奨：フルスタック統合時）

| カテゴリ | 技術 |
|----------|------|
| API | Next.js API Routes / Route Handlers |
| ORM | Prisma |
| データベース | PostgreSQL / SQLite |

**適したケース**:
- フロントエンドとバックエンドを統合したい
- シンプルなCRUD API
- サーバーサイドレンダリングが必要

#### オプション2: Python（推奨：データ処理・ML・複雑なロジック）

| カテゴリ | 技術 |
|----------|------|
| フレームワーク | FastAPI / Flask |
| ORM | SQLAlchemy / Prisma (Python) |
| データベース | PostgreSQL / SQLite |
| パッケージ管理 | uv / pip |

**適したケース**:
- 機械学習・AI機能が必要
- 複雑なデータ処理・分析
- 既存のPythonライブラリを活用したい
- バックエンドを独立して管理したい

#### 選択の目安

| 要件 | 推奨 |
|------|------|
| シンプルなWebアプリ | Next.js API Routes |
| AI/ML機能あり | Python (FastAPI) |
| データ分析・処理重視 | Python |
| フルスタック統合 | Next.js |
| マイクロサービス構成 | Python + Next.js (フロント) |

### 開発ツール

| カテゴリ | 技術 |
|----------|------|
| パッケージマネージャー | **Bun** |
| リンター | ESLint |
| フォーマッター | Prettier（オプション） |
| テスト | Bun Test / Vitest |

## 更新履歴

| 日付 | 変更内容 |
|------|----------|
| 2024-12-02 | 初版作成、Bun採用を決定 |
