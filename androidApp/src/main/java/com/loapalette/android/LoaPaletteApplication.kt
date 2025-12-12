package com.loapalette.android

import android.app.Application
import com.google.firebase.FirebaseApp
import com.google.firebase.crashlytics.FirebaseCrashlytics
import com.loapalette.shared.RemoteConfigManager

class LoaPaletteApplication : Application() {
    override fun onCreate() {
        super.onCreate()
        FirebaseApp.initializeApp(this)

        val crashlytics = FirebaseCrashlytics.getInstance()

        val remoteConfigManager = RemoteConfigManager()
        if (BuildConfig.DEBUG) {
            remoteConfigManager.setMinimumFetchInterval(0L)
        }
        remoteConfigManager.fetchAndActivate()
    }
}
