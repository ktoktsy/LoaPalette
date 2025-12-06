//
//  LoaPaletteApp.swift
//  LoaPalette
//
//  Created by 片岡寿哉 on 2025/11/28.
//

import SwiftUI
import FirebaseCore
import FirebaseCrashlytics
import GoogleMobileAds

@main
struct LoaPaletteApp: App {
    init() {
        // Firebase初期化
        FirebaseApp.configure()
        
        // Remote Config初期化
        RemoteConfigManager.shared.fetchAndActivate()
        
        // AdMob初期化（完了を待つ）
        MobileAds.shared.start { status in
            // 初期化完了後、広告をプリロード
            DispatchQueue.main.async {
                Self.preloadAds()
            }
        }
    }
    
    var body: some Scene {
        WindowGroup {
            ContentView()
        }
    }
    
    /// 広告をプリロードする
    private static func preloadAds() {
        // Settings画面で使用する広告をプリロード
        let settingsAdUnitID = "ca-app-pub-3940256099942544/3986624511"
        AdManager.shared.preloadAd(adUnitID: settingsAdUnitID)
    }
}
