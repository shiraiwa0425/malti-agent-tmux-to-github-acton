# Three.js 3D可視化ページ作成ワークフロー

## 概要

Three.jsを使った3Dビジュアライゼーションページを作成するための並行処理ワークフロー。

**想定時間**: 各エージェント 15-30分

## 推奨技術スタック（汎用・堅牢）

あらゆるプロジェクトに対応できる、汎用性と堅牢性を重視した技術スタックを採用します。

| カテゴリ | ライブラリ | 特徴・選定理由 |
|---|---|---|
| **Core** | **Next.js** | Reactフレームワークのデファクトスタンダード。 |
| **3D** | **Three.js**<br>**@react-three/fiber**<br>**@react-three/drei** | React宣言的UIと親和性の高い3Dエコシステム。<br>コンポーネント単位で3Dオブジェクトを管理可能。 |
| **UI** | **shadcn/ui** | **Radix UI** ベースのヘッドレスコンポーネント集。<br>npmパッケージではなくコードとして導入するため、カスタマイズ性が高くブラックボックス化しない。<br>アクセシビリティ（a11y）が標準で担保されている。 |
| **Styling** | **Tailwind CSS** | ユーティリティファーストCSS。デザインの一貫性を保ちやすい。 |
| **Animation** | **Framer Motion** | Reactにおける標準的なアニメーションライブラリ。<br>宣言的な記述で複雑なアニメーションを堅牢に実装可能。 |
| **Font** | **Google Fonts**<br>(`next/font/google`) | パフォーマンス最適化されたフォント読み込み。 |
| **Dev** | **Leva** | 3Dパラメータ調整用GUI。開発効率向上のため採用。 |

## デザインシステム方針

本ワークフローでは、特定のテイストに依存しない「ミニマルで機能的な」デザインシステムを初期状態として構築します。

### 1. UIコンポーネント設計
- **shadcn/ui** をベースとし、プロジェクト固有の変更は `components/ui` 配下のコードを直接編集することで行う。
- **Atomic Design** 等の厳密な構成は強制しないが、`components/ui`（汎用）と `components/features`（機能特化）の分離を推奨。

### 2. タイポグラフィ & カラー
- **Font**: デフォルトは `Inter` (英数) + `Noto Sans JP` (和文) のような癖のないサンセリフ体を採用。
- **Color**: Tailwindのデフォルトカラーパレットを使用し、セマンティックな命名（`primary`, `secondary`, `destructive` 等）で管理する。

### 3. 3Dと2Dの融合
- 3Dキャンバス（Canvas）は背景または独立したコンポーネントとして配置。
- UIレイヤーはHTML/CSS（z-index上位）で実装し、3D空間内のテキスト描画は極力避ける（アクセシビリティと翻訳容易性のため）。

## タスク分割

### エージェント1: プロジェクトセットアップとデータモデル設計

**タスク内容**:
```
Next.jsプロジェクトのセットアップとデータモデル設計を行ってください。

【作業ディレクトリ】
dist/outputs/{timestamp}-three-js-visualization/

【具体的なタスク】
1. Next.js + TypeScriptプロジェクトを作成
2. 必要な依存関係をインストール:
   - three, @types/three
   - @react-three/fiber, @react-three/drei
   - tailwindcss
   - framer-motion
   - leva
   - shadcn/ui (npx shadcn@latest init)
3. データモデルの型定義を作成 (types/index.ts)
4. サンプルデータを作成 (data/sampleData.ts)
5. プロジェクト構造とセットアップ手順をREADME.mdに記載

【重要】
- エラーが出ないようにすべての設定を完了
- 他のエージェントが参照できるようにREADME.mdを詳しく記載
```

**成果物**:
- Next.jsプロジェクトの基本構造
- types/index.ts
- data/sampleData.ts
- README.md

---

### エージェント2: 3Dビジュアライゼーション実装

**タスク内容**:
```
Three.jsを使った3Dビジュアライゼーション機能を実装してください。

【作業ディレクトリ】
dist/outputs/{timestamp}-three-js-visualization/

【具体的なタスク】
1. エージェント1のセットアップ完了を待つ（10秒待機）
2. Three.jsコンポーネントを作成:
   - 3D棒グラフまたは3D散布図
   - インタラクティブ機能（マウスホバー、ドラッグ回転）
3. カメラコントロールとライティングの設定
4. レスポンシブ対応
5. アニメーション効果

【技術仕様】
- @react-three/fiber と @react-three/drei を使用
- components/3d/ ディレクトリに配置
- propsでデータを受け取る設計

【重要】
- かっこいい3Dエフェクトを追加
```

**成果物**:
- components/3d/Visualization3D.tsx
- components/3d/Scene.tsx
- components/3d/Controls.tsx

---

### エージェント3: UI実装と統合

**タスク内容**:
```
UI実装とコンポーネント統合を行ってください。

【作業ディレクトリ】
dist/outputs/{timestamp}-three-js-visualization/

【具体的なタスク】
1. エージェント1のセットアップ完了を待つ（10秒待機）
2. メインページ (app/page.tsx) の実装:
   - ヘッダー: タイトル、説明
   - コントロールパネル: データ選択、表示設定
   - 3Dグラフ表示エリア（エージェント2のコンポーネント使用）
   - サマリー表示
3. UIデザイン:
   - shadcn/uiコンポーネントを使用（Button, Card, Dialog等）
   - Framer Motionで滑らかなアニメーション（リスト表示、モーダル等）
   - Tailwind CSSでモダンかつクリーンなデザイン
   - ダークモード対応
   - レスポンシブデザイン
4. データ連携とstate管理

【重要】
- 使いやすいUIデザイン
- エージェント2のコンポーネントを適切に統合
```

**成果物**:
- app/page.tsx
- components/ui/ControlPanel.tsx
- components/ui/Header.tsx
- styles/

---

## 依存関係

```mermaid
graph TD
    A[エージェント1: セットアップ] --> B[エージェント2: 3D実装]
    A --> C[エージェント3: UI実装]
    B --> D[統合・テスト]
    C --> D
```

- エージェント2、3はエージェント1のセットアップ完了後に開始
- エージェント2、3は並行処理可能

## 期待される成果

**最終成果物**:
- 完全に動作するThree.js 3D可視化Webアプリケーション
- インタラクティブな3Dグラフ
- レスポンシブ対応UI
- ダークモード対応

**品質基準**:
- TypeScriptエラーなし
- ビルド成功
- 3Dレンダリングが正常に動作
- UI/UXが直感的

## 実行例

```bash
# ボスとして実行する場合
./send-message.sh エージェント1 "上記エージェント1のタスク内容をコピー"
./send-message.sh エージェント2 "上記エージェント2のタスク内容をコピー"
./send-message.sh エージェント3 "上記エージェント3のタスク内容をコピー"
```

## 完了確認

各エージェントから完了報告を受けたら、以下を確認:
- [ ] プロジェクトがビルドできる
- [ ] 3Dグラフが正しく表示される
- [ ] インタラクション（回転、ズーム）が動作する
- [ ] UIが適切に表示される
- [ ] README.mdが完備されている
