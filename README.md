# AryS

SwiftUI と Firebase を使った、コーヒー好き向け SNS / マッチング iOS アプリです。  
コーヒーログの投稿、プロフィール管理、ユーザー検索、マッチング、トーク画面などを備えています。

## 主な機能

- メールアドレスとパスワードによるログイン / 登録
- コーヒーログの作成、表示、編集、削除
- プロフィールの表示、編集、画像アップロード
- 条件によるユーザー検索
- おすすめプロフィールの表示とマッチング画面
- ホーム、検索、トーク、マッチ、プロフィールのタブ navigation

## 技術スタック

- Swift
- SwiftUI
- Observation / ObservableObject
- Firebase Authentication
- Cloud Firestore
- Firebase Storage
- Firebase Analytics
- Swift Package Manager

## 必要環境

- Xcode
- iOS Simulator または実機
- Firebase プロジェクト

このプロジェクトでは Firebase iOS SDK `12.14.0` 以上を Swift Package Manager 経由で利用しています。

## セットアップ

1. リポジトリをクローンします。

   ```sh
   git clone <repository-url>
   cd snsmvvm
   ```

2. Xcode でプロジェクトを開きます。

   ```sh
   open snsmvvm.xcodeproj
   ```

3. Firebase の設定を用意します。

   Firebase コンソールで iOS アプリを作成し、`GoogleService-Info.plist` を取得してください。  
   取得したファイルを `snsmvvm/GoogleService-Info.plist` として配置します。

4. Firebase の各サービスを有効化します。

   - Authentication
   - Cloud Firestore
   - Firebase Storage
   - Analytics

5. Xcode で `snsmvvm` scheme を選択し、Simulator または実機でビルド / 実行します。

## テスト

Xcode から `Product > Test` を実行してください。  
CLI で実行する場合は、利用する Simulator 名に合わせて destination を調整します。

```sh
xcodebuild test \
  -project snsmvvm.xcodeproj \
  -scheme snsmvvm \
  -destination 'platform=iOS Simulator,name=iPhone 16'
```

## ディレクトリ構成

```text
snsmvvm/
├── Arys/        # App entry point, shared models
├── Content/     # Home feed content views
├── Firebase/    # Auth and root view
├── Home/        # Main tab shell
├── Log/         # Coffee log screens and view models
├── Match/       # Matching screens and view models
├── Profile/     # Profile screens and view models
├── Search/      # Search screens and view models
├── Sub/         # Shared sub views
└── Talk/        # Talk screen
```

## 設計メモ

アーキテクチャの詳細は [docs/architecture.md](docs/architecture.md) を参照してください。

## 注意事項

- `GoogleService-Info.plist` は Firebase プロジェクトごとに異なります。開発環境に合わせて差し替えてください。
- Firestore / Storage のセキュリティルールは、開発用と本番用で適切に分けて管理してください。
