package com.loapalette.shared

/**
 * Firebase Remote ConfigのiOS実装
 * 注意: iOS側はSwiftで実装されているため、Kotlin/NativeからSwiftのRemoteConfigManagerを呼び出す必要があります
 * 参考: https://firebase.google.com/docs/remote-config/ios/start
 * 
 * 現在は、iOS側のSwift実装（RemoteConfigManager.swift）を使用することを推奨します
 * 将来的にKotlin/Nativeから直接Firebaseを呼び出す場合は、この実装を更新してください
 */
actual class RemoteConfigManager {
    // iOS側はSwiftで実装されているため、ここではプレースホルダーとして実装
    // 実際の使用時は、iOS側のSwift実装（RemoteConfigManager.swift）を使用してください
    
    actual fun fetchAndActivate(onComplete: ((Boolean) -> Unit)?) {
        // iOS側のSwift実装を呼び出す必要があります
        // 現在は未実装のため、エラーを返します
        onComplete?.invoke(false)
    }
    
    actual fun getString(key: String): String {
        // iOS側のSwift実装を呼び出す必要があります
        return ""
    }
    
    actual fun getInt(key: String): Int {
        // iOS側のSwift実装を呼び出す必要があります
        return 0
    }
    
    actual fun getLong(key: String): Long {
        // iOS側のSwift実装を呼び出す必要があります
        return 0L
    }
    
    actual fun getBoolean(key: String): Boolean {
        // iOS側のSwift実装を呼び出す必要があります
        return false
    }
    
    actual fun getDouble(key: String): Double {
        // iOS側のSwift実装を呼び出す必要があります
        return 0.0
    }
    
    actual fun getJSON(key: String): Map<String, Any>? {
        // iOS側のSwift実装を呼び出す必要があります
        return null
    }
    
    actual fun setMinimumFetchInterval(seconds: Long) {
        // iOS側のSwift実装を呼び出す必要があります
        // 現在は未実装
    }
}

