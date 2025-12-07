package com.loapalette.shared

/**
 * Firebase Remote Configの設定キーを定義するオブジェクト
 * 参考: https://firebase.google.com/docs/remote-config
 */
object RemoteConfigKeys {
    // フォームURL
    const val FORM_URL = "form_url"
    
    // 免責事項の内容（JSON形式）
    const val DISCLAIMER_CONTENT = "disclaimer_content"
    
    // プライバシーポリシーの内容（JSON形式）
    const val PRIVACY_POLICY_CONTENT = "privacy_policy_content"
    
    // 利用規約の内容（JSON形式）
    const val TERMS_OF_SERVICE_CONTENT = "terms_of_service_content"
}

