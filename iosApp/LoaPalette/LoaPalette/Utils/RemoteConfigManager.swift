//
//  RemoteConfigManager.swift
//  LoaPalette
//
//  Created by Auto on 2025/01/XX.
//

import Foundation
import FirebaseRemoteConfig

/// Firebase Remote Configの共通処理を管理するクラス
/// 参考: https://firebase.google.com/docs/remote-config/ios/start
class RemoteConfigManager {
    static let shared = RemoteConfigManager()
    
    private let remoteConfig: RemoteConfig
    
    private init() {
        remoteConfig = RemoteConfig.remoteConfig()
        
        // デフォルト値の設定
        // 注意: sharedモジュールのRemoteConfigDefaultsを使用することを推奨します
        // 現在は空のデフォルト値を設定しています
        let defaults: [String: NSObject] = [:
            // 例: "app_version": "1.0.0" as NSObject,
            // 例: "feature_enabled": true as NSObject,
        ]
        remoteConfig.setDefaults(defaults)
        
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
        return remoteConfig.configValue(forKey: key).stringValue ?? ""
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
        guard let jsonString = remoteConfig.configValue(forKey: key).stringValue,
              let data = jsonString.data(using: .utf8),
              let json = try? JSONSerialization.jsonObject(with: data) as? [String: Any] else {
            return nil
        }
        return json
    }
}

