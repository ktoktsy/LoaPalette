package com.loapalette.shared

import android.os.Build

actual class Platform actual constructor() {
    actual val name: String
        get() = "Android ${Build.VERSION.SDK_INT}"
}

actual fun getPlatformName(): String = "Android"

