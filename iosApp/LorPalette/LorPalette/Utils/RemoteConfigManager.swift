
import FirebaseRemoteConfig
import Foundation
import shared

/// Firebase Remote Configの共通処理を管理するクラス
/// 参考: https://firebase.google.com/docs/remote-config/ios/start
class RemoteConfigManager {
    static let shared = RemoteConfigManager()

    private let remoteConfig: RemoteConfig

    private init() {
        remoteConfig = RemoteConfig.remoteConfig()

        // デフォルト値の設定
        // sharedモジュールのRemoteConfigDefaultsから取得
        let defaults = RemoteConfigDefaults.getDefaults()
        // KotlinのMapをSwiftのDictionaryに変換し、NSObjectにキャスト
        var swiftDefaults: [String: NSObject] = [:]
        for (key, value) in defaults {
            if let stringValue = value as? String {
                swiftDefaults[key] = stringValue as NSObject
            }
        }
        remoteConfig.setDefaults(swiftDefaults)

        // フェッチ間隔の設定（デバッグ用: 0秒、本番用: 3600秒）
        #if DEBUG
            let settings = RemoteConfigSettings()
            settings.minimumFetchInterval = 0
            remoteConfig.configSettings = settings
        #else
            let settings = RemoteConfigSettings()
            settings.minimumFetchInterval = 3600
            remoteConfig.configSettings = settings
        #endif
    }

    /// Remote Configをフェッチしてアクティベート
    /// - Parameter completion: 完了時のコールバック（成功: true, 失敗: false）
    func fetchAndActivate(completion: ((Bool) -> Void)? = nil) {
        remoteConfig.fetch { [weak self] status, error in
            guard let self = self else {
                completion?(false)
                return
            }

            if let error = error {
                print("Remote Config fetch error: \(error.localizedDescription)")
                completion?(false)
                return
            }

            if status == .success {
                self.remoteConfig.activate { changed, error in
                    if let error = error {
                        print("Remote Config activate error: \(error.localizedDescription)")
                        completion?(false)
                    } else {
                        completion?(true)
                    }
                }
            } else {
                completion?(false)
            }
        }
    }

    /// String値を取得
    /// - Parameter key: キー名
    /// - Returns: 値（存在しない場合は空文字列）
    func getString(forKey key: String) -> String {
        return remoteConfig.configValue(forKey: key).stringValue
    }

    /// Int値を取得
    /// - Parameter key: キー名
    /// - Returns: 値（存在しない場合は0）
    func getInt(forKey key: String) -> Int {
        return remoteConfig.configValue(forKey: key).numberValue.intValue
    }

    /// Bool値を取得
    /// - Parameter key: キー名
    /// - Returns: 値（存在しない場合はfalse）
    func getBool(forKey key: String) -> Bool {
        return remoteConfig.configValue(forKey: key).boolValue
    }

    /// Double値を取得
    /// - Parameter key: キー名
    /// - Returns: 値（存在しない場合は0.0）
    func getDouble(forKey key: String) -> Double {
        return remoteConfig.configValue(forKey: key).numberValue.doubleValue
    }

    /// JSON値を取得
    /// - Parameter key: キー名
    /// - Returns: 値（存在しない場合はnil）
    func getJSON(forKey key: String) -> [String: Any]? {
        let jsonString = remoteConfig.configValue(forKey: key).stringValue
        guard !jsonString.isEmpty,
            let data = jsonString.data(using: .utf8),
            let json = try? JSONSerialization.jsonObject(with: data) as? [String: Any]
        else {
            return nil
        }
        return json
    }

    /// デフォルト値を取得（sharedモジュールのRemoteConfigDefaultsから取得）
    /// - Parameter key: キー名
    /// - Returns: デフォルト値（存在しない場合は空文字列）
    func getDefaultValue(forKey key: String) -> String {
        // sharedモジュールのRemoteConfigDefaultsから取得
        let defaults = RemoteConfigDefaults.getDefaults()
        return defaults[key] as? String ?? ""
    }
}
