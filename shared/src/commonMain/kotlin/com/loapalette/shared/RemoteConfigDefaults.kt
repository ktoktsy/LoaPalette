package com.loapalette.shared

/**
 * Firebase Remote Configのデフォルト値を定義するオブジェクト
 * 参考: https://firebase.google.com/docs/remote-config
 */
object RemoteConfigDefaults {
    /**
     * デフォルト値のマップを取得
     * @return キーとデフォルト値のマップ
     */
    fun getDefaults(): Map<String, Any> {
        return mapOf(
            // ここにデフォルト値を追加
            // 例: RemoteConfigKeys.APP_VERSION to "1.0.0",
            // 例: RemoteConfigKeys.FEATURE_ENABLED to true,
        )
    }
}

