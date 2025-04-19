//
//  README.md
//  WakuwakuTabiShiori
//
//  Created by 二渡和輝 on 2025/04/19.
//

# (仮称) わくわく旅しおりアプリ ✈️✨

## 1. 概要

このプロジェクトは、友人グループ（特に10～20代女性）が旅行などの予定を楽しく共同で計画・共有できるiOSアプリケーションです。単なる情報共有ツールではなく、「旅行のしおり」をわくわくしながら作る体験を提供し、計画段階から気分が高まるようなアプリを目指します。

* **ターゲットユーザー:** 10～20代女性、友人グループ
* **プラットフォーム:** iOS
* **主要技術:** SwiftUI, SwiftData, CloudKit

## 2. コンセプト・デザイン

### 2.1. コアコンセプト
**「旅行のしおり」を作るような、わくわくする計画体験**

### 2.2. デザインコンセプト
**ポップで元気な感じ！**
明るく、楽しく、使っていて気分が高揚するようなデザインを目指します。

### 2.3. デザイン要素
* **カラーパレット:**
    * メイン: 明るいビタミンカラー（オレンジ、イエロー、コーラルピンク、スカイブルー等）
    * アクセント: 補色、ラメ、ネオンカラー、美しいグラデーション
    * ベース: 白や明るいグレーで視認性とバランスを確保
    * テーマ機能: 選択したテーマに基づき配色が変化
* **タイポグラフィ:**
    * 見出し: 太めで丸みのあるゴシック体や手書き風フォント
    * 本文: 読みやすく親しみやすいフォント
    * 全体: 遊び心のあるフォントをアクセントに使用
* **形・レイアウト:**
    * 要素: 角丸で柔らかい印象
    * イラスト: 手書き風、デフォルメされた可愛いキャラクターやモチーフ（星、ハート、吹き出し等）
    * レイアウト: 動きや楽しさを感じさせる配置（少し斜め、重ねるなど）
* **アイコン:**
    * 基本: シンプルなフラットデザインに少し立体感や太いアウトライン
    * カテゴリー別: ポップで可愛いイラスト調
* **アニメーション・マイクロインタラクション:**
    * ボタンタップ時の弾む反応（ポンッ！）
    * スムーズで軽快な画面遷移（ページめくり風など）
    * 達成感を演出するポップなエフェクト（キラキラ✨）
    * ローディング中の楽しいアニメーション
    * 心地よい効果音

## 3. 主要機能

* **予定管理:**
    * **新規予定作成:** タイトル、期間、テーマ、メンバー、予算（任意）を入力して新しい旅行プランを作成。
    * **予定一覧表示:**
        * トップ画面で「これからの予定」「過去の予定」をタブ切り替え。
        * 予定をアルバム風カードで表示（タイトル、期間、テーマデザイン、メンバーアイコン、カウントダウン）。
    * **予定詳細表示:**
        * **表紙:** テーマデザイン、タイトル、期間、メンバー、予算概要を表示。
        * **日程リスト:** 日付ごとにタブまたはリストで表示。日程の追加・編集・削除。
        * **場所・予定情報:** 各日程に紐づく時間、場所/活動名、カテゴリー、メモ、費用、写真などをタイムライン/カード形式で表示・編集・追加・削除。
    * **予定編集・削除:** 作成済みの予定情報全般を編集、または予定自体を削除。
* **共同編集:**
    * **メンバー招待:** ユーザー検索や招待リンクで予定にメンバーを追加・削除。
    * **情報同期 (CloudKit):** メンバーによる編集内容が他のメンバーのデバイスにも反映される。
* **予算管理:**
    * **全体予算設定:** 目安となる全体の予算を任意で設定。
    * **項目別費用入力:** 各場所・予定に費用（交通費、食費等）を任意で入力。
    * **合計費用・予算比率表示:** 入力費用の合計を自動計算し、目安予算と共に表示。割合をグラフ等で可視化。
* **テーマカスタマイズ:**
    * 予定ごとにデザインテーマ（配色、背景、アイコン等）を選択・適用。複数のポップなプリセットテーマを提供。

## 4. 画面遷移

```mermaid
graph LR
    subgraph App Start
        Splash[(スプラッシュ画面<br/>アニメーション)] --> Top[(トップページ<br/>予定一覧)]
    end

    subgraph Main Flow
        Top -- 予定カード タップ --> PlanDetailCover(予定詳細 - 表紙)
        Top -- "+" フローティングボタン --> NewPlan(新規予定作成)
        NewPlan -- 保存ボタン --> Top
        NewPlan -- キャンセルボタン --> Top
    end

    subgraph Plan Detail Flow
        PlanDetailCover -- "日程リストへ" or スワイプ --> PlanDetailSchedule(予定詳細 - 日程リスト/項目表示)
        PlanDetailSchedule -- 日付タブ/リスト選択 --> PlanDetailSchedule %% 同じ画面内で表示内容更新
        PlanDetailSchedule -- "+" 日程追加ボタン --> PlanDetailSchedule %% 再描画
        PlanDetailSchedule -- 場所・予定項目 タップ --> PlanItemEdit(場所・予定 編集/追加)
        PlanDetailSchedule -- "+" 場所・予定追加ボタン --> PlanItemEdit(場所・予定 編集/追加)
        PlanItemEdit -- 保存ボタン --> PlanDetailSchedule
        PlanItemEdit -- キャンセル/削除 --> PlanDetailSchedule
        PlanDetailSchedule -- ヘッダー 戻るボタン --> PlanDetailCover
        PlanDetailCover -- ヘッダー 編集ボタン --> PlanEdit(予定全体 編集)
        PlanEdit -- 保存ボタン --> PlanDetailCover
        PlanEdit -- キャンセルボタン --> PlanDetailCover
        Top -- 設定アイコン --> Settings(設定画面) %% オプション
        Settings -- 戻る --> Top %% オプション
    end

    classDef page fill:#E0FFFF,stroke:#87CEFA,stroke-width:2px,rx:8px,ry:8px;
    class Top,NewPlan,PlanDetailCover,PlanDetailSchedule,PlanItemEdit,PlanEdit,Settings,Splash page;
```

## 5. ディレクトリ構造

```
WakuwakuTabiShori/                      <-- ⭐️ プロジェクトルート
│
├── 📂 WakuwakuTabiShori/                 <-- アプリケーションターゲットフォルダ
│   │
│   ├── 📱 WakuwakuTabiShoriApp.swift     <-- アプリ起動点 (@main), SwiftData/CloudKit設定
│   │
│   ├── 🖼️ Assets.xcassets                <-- 画像, アイコン, カスタムカラー等のリソース
│   │
│   ├── 💾 Models/                        <-- データモデル定義 (SwiftData @Model クラス)
│   │   ├── Plan.swift                   <-- 予定全体のデータ定義
│   │   ├── Schedule.swift               <-- 日程データ定義
│   │   ├── PlanItem.swift               <-- 場所・予定項目のデータ定義
│   │   └── User.swift                   <-- (必要なら)ユーザー情報モデル
│   │
│   ├── ✨ Views/                         <-- 画面UI定義 (SwiftUI View 構造体)
│   │   ├── 🏠 Main/                     <-- 主要基盤画面
│   │   │   ├── TopView.swift            <-- トップページ (予定一覧)
│   │   │   └── SettingsView.swift       <-- 設定画面
│   │   │
│   │   ├── ➕ PlanCreation/             <-- 新規予定作成関連画面
│   │   │   ├── NewPlanView.swift        <-- 新規予定入力フォーム
│   │   │   └── ThemeSelectionView.swift <-- テーマ選択UI
│   │   │
│   │   ├── 📖 PlanDetail/               <-- 予定詳細関連画面
│   │   │   ├── PlanDetailContainerView.swift <-- 詳細画面全体のコンテナ
│   │   │   ├── PlanDetailCoverView.swift <-- 詳細画面の「表紙」
│   │   │   ├── PlanDetailScheduleListView.swift <-- 日程リストと項目表示
│   │   │   ├── PlanItemRowView.swift     <-- 各予定項目の行表示
│   │   │   ├── PlanItemEditView.swift    <-- 項目追加/編集フォーム
│   │   │   └── PlanEditView.swift        <-- 予定全体の編集フォーム
│   │   │
│   │   └── 🧩 Components/               <-- 再利用可能なUI部品
│   │       ├── PlanCardView.swift       <-- 予定カードUI
│   │       ├── PopButton.swift          <-- カスタムボタンUI
│   │       └── LoadingIndicator.swift   <-- ローディング表示UI
│   │
│   ├── 🧠 ViewModels/                    <-- (MVVM採用時) Viewの状態とロジック管理クラス (@Observable)
│   │   ├── TopViewModel.swift           <-- トップ画面用ViewModel
│   │   ├── PlanDetailViewModel.swift    <-- 予定詳細画面用ViewModel
│   │   └── NewPlanViewModel.swift       <-- 新規予定作成画面用ViewModel
│   │
│   ├── 🛠️ Utilities/                    <-- ヘルパー関数、拡張機能
│   │   ├── DateFormatter+Extensions.swift <-- 日付フォーマット共通処理
│   │   ├── Color+Themes.swift           <-- テーマカラー関連処理
│   │   └── CloudKitHelper.swift         <-- (CloudKit共有処理のヘルパー等)
│   │
│   └── 📄 Info.plist                    <-- アプリ構成情報 (パーミッション等)
│
├── 📂 WakuwakuTabiShoriTests/            <-- Unitテストコード
├── 📂 WakuwakuTabiShoriUITests/          <-- UIテストコード
└── 📦 Products/                         <-- (Xcode管理) ビルド生成物
```

## 6. 技術スタック

* **言語:** Swift (最新版推奨)
* **UIフレームワーク:** SwiftUI
* **データ永続化:** SwiftData
* **クラウド同期・共有:** CloudKit (SwiftData CloudKit integration)
* **バージョン管理:** Git

## 7. 開発手順概要

1.  **プロジェクト作成:** XcodeでSwiftUI Appテンプレートを選択し、SwiftDataを有効にしてプロジェクトを作成。
2.  **モデル定義:** `Models/` にSwiftDataの`@Model`クラスを定義。
3.  **ビュー実装:** `Views/` にSwiftUIで各画面のUIを実装。デザインコンセプトに基づき、モディファイアやカスタムコンポーネントを活用。
4.  **ロジック実装:** (MVVMの場合) `ViewModels/` に`@Observable`クラスを作成し、Viewの状態とビジネスロジックを実装。SwiftDataの操作（CRUD）もここで行うことが多い。
5.  **データ永続化:** `ModelContainer` を設定し、`ModelContext` を使ってデータの保存・読み込みを行う。
6.  **CloudKit連携:** プロジェクト設定でiCloudとCloudKitを有効化。`ModelConfiguration` でCloudKit同期を設定。共有機能は別途実装。
7.  **画面遷移:** `NavigationStack` / `NavigationView`, `NavigationLink`, `.sheet`, `.fullScreenCover` などで画面遷移を実装。
8.  **テスト:** Unitテスト、UIテスト、実機テストを実施。
9.  **デバッグ・最適化:** Xcodeデバッガ、Instrumentsで問題解決とパフォーマンス改善。
10. **ビルド・配布:** Archive作成後、TestFlightでのテストを経てApp Store Connectからリリース。

## 8. 今後の拡張候補

* 思い出マップ機能 (地図連携)
* やることリスト / 持ち物チェックリスト機能
* コメント機能、メンション機能
* 詳細なメンバー権限管理
* SNS連携（予定共有、写真インポート）
* プッシュ通知（リマインダー、更新通知）

---

このREADMEはプロジェクトの進行に合わせて適宜更新してください。
