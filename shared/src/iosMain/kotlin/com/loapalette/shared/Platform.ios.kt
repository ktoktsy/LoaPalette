package com.loapalette.shared

import platform.UIKit.UIDevice

actual class Platform actual constructor() {
    actual val name: String
        get() = UIDevice.currentDevice.systemName() +
                " " +
                UIDevice.currentDevice.systemVersion
}

actual fun getPlatformName(): String = "iOS"

