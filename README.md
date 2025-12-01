# LoaPalette

Kotlin Multiplatform (KMP) プロジェクト

## プロジェクト構造

```
LoaPalette/
├── shared/              # 共有モジュール
│   ├── commonMain/     # 共通コード
│   ├── androidMain/    # Android固有コード
│   └── iosMain/        # iOS固有コード
├── androidApp/         # Androidアプリ
└── iosApp/             # iOSアプリ
```

## セットアップ

### 前提条件

- Android Studio Hedgehog (2023.1.1) 以降
- Xcode 15.0 以降
- JDK 11 以降
- Kotlin 2.0.21

### Android側のビルド

```bash
./gradlew :androidApp:assembleDebug
```

### iOS側のビルド

1. Xcodeで `iosApp/iosApp.xcodeproj` を開く
2. または、コマンドラインから：
```bash
cd iosApp
xcodebuild -workspace iosApp.xcworkspace -scheme iosApp -configuration Debug
```

## ガラスエフェクト

### iOS側
- SwiftUIの `.ultraThinMaterial` を使用
- ネイティブのUIVisualEffectView相当の効果

### Android側
- Composeの半透明背景とグラデーションを使用
- Material 3のテーマシステムと統合

## 参考リンク

- [Kotlin Multiplatform Mobile](https://kotlinlang.org/docs/multiplatform-mobile-getting-started.html)
- [Jetpack Compose](https://developer.android.com/jetpack/compose)
- [SwiftUI](https://developer.apple.com/xcode/swiftui/)


