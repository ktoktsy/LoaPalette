package com.loapalette.shared

import com.google.firebase.remoteconfig.FirebaseRemoteConfig
import com.google.firebase.remoteconfig.FirebaseRemoteConfigSettings
import com.google.firebase.ktx.Firebase

/**
 * Firebase Remote ConfigのAndroid実装
 * 参考: https://firebase.google.com/docs/remote-config/android/start
 */
actual class RemoteConfigManager {
    private val remoteConfig: FirebaseRemoteConfig = Firebase.remoteConfig
    
    init {
        // デフォルト値の設定
        val defaults = RemoteConfigDefaults.getDefaults()
        remoteConfig.setDefaultsAsync(defaults)
        
        // フェッチ間隔の設定（デバッグ用: 0秒、本番用: 3600秒）
        // 注意: デバッグモードの判定は、使用側のアプリで行う必要があります
        // ここではデフォルトで3600秒に設定し、使用側で必要に応じて変更してください
        val configSettings = FirebaseRemoteConfigSettings.Builder()
            .setMinimumFetchIntervalInSeconds(3600L)
            .build()
        remoteConfig.setConfigSettingsAsync(configSettings)
    }
    
    /**
     * フェッチ間隔を設定（デバッグ用に0秒に設定する場合に使用）
     */
    fun setMinimumFetchInterval(seconds: Long) {
        val configSettings = FirebaseRemoteConfigSettings.Builder()
            .setMinimumFetchIntervalInSeconds(seconds)
            .build()
        remoteConfig.setConfigSettingsAsync(configSettings)
    }
    
    actual fun fetchAndActivate(onComplete: ((Boolean) -> Unit)?) {
        remoteConfig.fetchAndActivate()
            .addOnCompleteListener { task ->
                if (task.isSuccessful) {
                    onComplete?.invoke(true)
                } else {
                    task.exception?.printStackTrace()
                    onComplete?.invoke(false)
                }
            }
    }
    
    actual fun getString(key: String): String {
        return remoteConfig.getString(key)
    }
    
    actual fun getInt(key: String): Int {
        return remoteConfig.getLong(key).toInt()
    }
    
    actual fun getLong(key: String): Long {
        return remoteConfig.getLong(key)
    }
    
    actual fun getBoolean(key: String): Boolean {
        return remoteConfig.getBoolean(key)
    }
    
    actual fun getDouble(key: String): Double {
        return remoteConfig.getDouble(key)
    }
    
    actual fun getJSON(key: String): Map<String, Any>? {
        val jsonString = remoteConfig.getString(key)
        if (jsonString.isEmpty()) {
            return null
        }
        // JSONのパースは使用側で実装（Gsonやkotlinx.serializationを使用）
        return null
    }
}

