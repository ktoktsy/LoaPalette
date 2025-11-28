# LoaPalette セットアップガイド

## 初回セットアップ

### 1. Gradle Wrapperの準備

```bash
# Gradle Wrapperを生成（Gradleがインストールされている場合）
gradle wrapper

# または、既存のプロジェクトからコピー
```

### 2. iOS側のセットアップ

#### Xcodeプロジェクトの作成

1. Xcodeを開く
2. "Create a new Xcode project" を選択
3. iOS > App を選択
4. プロジェクト名: `iosApp`
5. Interface: SwiftUI
6. Language: Swift
7. 保存先: `LoaPalette/iosApp/` ディレクトリ

#### CocoaPodsの設定

`iosApp` ディレクトリに `Podfile` を作成：

```ruby
platform :ios, '15.0'
use_frameworks!

target 'iosApp' do
  pod 'shared', :path => '../shared'
end
```

その後、以下を実行：

```bash
cd iosApp
pod install
```

#### Xcodeプロジェクトの設定

1. Xcodeで `LoaPalette.xcworkspace` を開く（`.xcodeproj`ではなく）
2. プロジェクト設定で以下を確認：
   - Deployment Target: iOS 15.0
   - Swift Language Version: Swift 5

#### Xcodeからのビルド

Xcodeから直接ビルドする場合、環境変数を設定する必要があります：

1. Xcodeで `Product` > `Scheme` > `Edit Scheme...` を選択
2. `Run`（または`Build`）を選択
3. `Arguments`タブを開く
4. `Environment Variables`セクションで以下を追加：
   - Name: `OVERRIDE_KOTLIN_BUILD_IDE_SUPPORTED`
   - Value: `YES`
5. `Close`をクリック

これにより、既存のフレームワークを使用してビルドできます。

**注意**: Kotlin/Nativeのフレームワークを再ビルドする場合は、以下のコマンドを実行してください：

```bash
./gradlew :shared:podInstall
```

### 3. Android側のセットアップ

#### Android Studioでの開き方

1. Android Studioを開く
2. "Open an Existing Project" を選択
3. `LoaPalette` ディレクトリを選択
4. Gradle Syncを実行

#### ビルド

```bash
./gradlew :androidApp:assembleDebug
```

### 4. 共有モジュールのビルド

```bash
# 全プラットフォーム向けにビルド
./gradlew :shared:build

# iOS向けフレームワーク生成
./gradlew :shared:podInstall
```

## ガラスエフェクトの実装

### iOS側（SwiftUI）

```swift
.background(.ultraThinMaterial)
```

iOS標準のガラスエフェクトを使用。以下のMaterialスタイルが利用可能：

- `.ultraThinMaterial`
- `.thinMaterial`
- `.regularMaterial`
- `.thickMaterial`
- `.ultraThickMaterial`

### Android側（Jetpack Compose）

```kotlin
.background(
    color = Color.White.copy(alpha = 0.3f),
    shape = RoundedCornerShape(20.dp)
)
```

半透明背景とグラデーションを組み合わせて実装。

## トラブルシューティング

### iOS側

- **CocoaPodsエラー**: `pod deintegrate && pod install` を実行
- **フレームワークが見つからない**: `./gradlew :shared:podInstall` を実行

### Android側

- **Gradle Syncエラー**: `./gradlew clean` を実行してから再同期
- **依存関係エラー**: `./gradlew :shared:build` を先に実行

## 参考リンク

- [Kotlin Multiplatform Mobile 公式ドキュメント](https://kotlinlang.org/docs/multiplatform-mobile-getting-started.html)
- [CocoaPods 公式ドキュメント](https://cocoapods.org/)
- [Jetpack Compose 公式ドキュメント](https://developer.android.com/jetpack/compose)
