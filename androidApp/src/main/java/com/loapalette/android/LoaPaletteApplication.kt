package com.loapalette.android

import android.app.Application
import com.google.firebase.FirebaseApp

class LoaPaletteApplication : Application() {
    override fun onCreate() {
        super.onCreate()
        // Firebase初期化
        FirebaseApp.initializeApp(this)
    }
}

