package com.loapalette.shared

/**
 * Firebase Remote Configの共通インターフェース
 * 参考: https://firebase.google.com/docs/remote-config
 */
expect class RemoteConfigManager {
    /**
     * Remote Configをフェッチしてアクティベート
     * @param onComplete 完了時のコールバック（成功: true, 失敗: false）
     */
    fun fetchAndActivate(onComplete: ((Boolean) -> Unit)? = null)
    
    /**
     * String値を取得
     * @param key キー名
     * @return 値（存在しない場合は空文字列）
     */
    fun getString(key: String): String
    
    /**
     * Int値を取得
     * @param key キー名
     * @return 値（存在しない場合は0）
     */
    fun getInt(key: String): Int
    
    /**
     * Long値を取得
     * @param key キー名
     * @return 値（存在しない場合は0L）
     */
    fun getLong(key: String): Long
    
    /**
     * Bool値を取得
     * @param key キー名
     * @return 値（存在しない場合はfalse）
     */
    fun getBoolean(key: String): Boolean
    
    /**
     * Double値を取得
     * @param key キー名
     * @return 値（存在しない場合は0.0）
     */
    fun getDouble(key: String): Double
    
    /**
     * JSON値を取得
     * @param key キー名
     * @return 値（存在しない場合はnull）
     */
    fun getJSON(key: String): Map<String, Any>?
    
    /**
     * フェッチ間隔を設定（デバッグ用に0秒に設定する場合に使用）
     * @param seconds フェッチ間隔（秒）
     */
    fun setMinimumFetchInterval(seconds: Long)
}

