package com.loapalette.android

import android.app.Application
import com.google.firebase.FirebaseApp
import com.google.firebase.crashlytics.FirebaseCrashlytics
import com.loapalette.shared.RemoteConfigManager
import com.loapalette.android.BuildConfig

class LoaPaletteApplication : Application() {
    override fun onCreate() {
        super.onCreate()
        // Firebase初期化
        FirebaseApp.initializeApp(this)
        
        // Firebase Crashlytics初期化
        // FirebaseApp.initializeApp()で自動的に初期化されるが、明示的に設定
        val crashlytics = FirebaseCrashlytics.getInstance()
        // 必要に応じてカスタムログやユーザー情報を設定可能
        
        // Remote Config初期化（sharedモジュールのRemoteConfigManagerを使用）
        val remoteConfigManager = RemoteConfigManager()
        // デバッグモードの場合はフェッチ間隔を0秒に設定
        if (BuildConfig.DEBUG) {
            remoteConfigManager.setMinimumFetchInterval(0L)
        }
        remoteConfigManager.fetchAndActivate()
    }
}

