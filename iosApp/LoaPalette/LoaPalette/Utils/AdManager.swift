//
//  AdManager.swift
//  LoaPalette
//
//  Created by Auto on 2025/01/XX.
//

import GoogleMobileAds
import UIKit

/// 広告の管理とプリロードを行うマネージャー
/// 参考: https://developers.google.com/admob/ios/native/advanced
class AdManager {
    static let shared = AdManager()
    
    private var preloadedAds: [String: NativeAd] = [:]
    private var adLoaders: [String: AdLoader] = [:]
    private var isLoading: [String: Bool] = [:]
    
    private init() {}
    
    /// 広告をプリロードする
    /// - Parameters:
    ///   - adUnitID: 広告ユニットID
    ///   - completion: 読み込み完了時のコールバック（オプション）
    func preloadAd(adUnitID: String, completion: ((NativeAd?) -> Void)? = nil) {
        // 既に読み込み済みの場合は即座に返す
        if let cachedAd = preloadedAds[adUnitID] {
            completion?(cachedAd)
            return
        }
        
        // 既に読み込み中の場合はスキップ
        if isLoading[adUnitID] == true {
            return
        }
        
        isLoading[adUnitID] = true
        
        // rootViewControllerを取得
        guard let windowScene = UIApplication.shared.connectedScenes.first as? UIWindowScene,
              let rootViewController = windowScene.windows.first?.rootViewController
        else {
            isLoading[adUnitID] = false
            completion?(nil)
            return
        }
        
        // ネイティブアドバンス広告ローダーを作成
        let loader = AdLoader(
            adUnitID: adUnitID,
            rootViewController: rootViewController,
            adTypes: [.native],
            options: nil
        )
        
        // デリゲートを設定
        let delegate = AdManagerDelegate()
        loader.delegate = delegate
        
        // 広告読み込み完了時のコールバック
        delegate.onAdLoaded = { [weak self] nativeAd in
            DispatchQueue.main.async {
                self?.preloadedAds[adUnitID] = nativeAd
                self?.isLoading[adUnitID] = false
                completion?(nativeAd)
            }
        }
        
        delegate.onAdFailed = { [weak self] error in
            DispatchQueue.main.async {
                print("Native ad failed to load: \(error.localizedDescription)")
                self?.isLoading[adUnitID] = false
                completion?(nil)
            }
        }
        
        // 広告リクエストを作成してロード
        let request = Request()
        loader.load(request)
        
        // ローダーを保持
        adLoaders[adUnitID] = loader
    }
    
    /// プリロード済みの広告を取得する
    /// - Parameter adUnitID: 広告ユニットID
    /// - Returns: プリロード済みの広告（存在する場合）
    func getPreloadedAd(adUnitID: String) -> NativeAd? {
        return preloadedAds[adUnitID]
    }
    
    /// 広告を再読み込みする
    /// - Parameter adUnitID: 広告ユニットID
    func reloadAd(adUnitID: String) {
        preloadedAds.removeValue(forKey: adUnitID)
        adLoaders.removeValue(forKey: adUnitID)
        isLoading.removeValue(forKey: adUnitID)
        preloadAd(adUnitID: adUnitID)
    }
    
    /// すべての広告をクリアする
    func clearAllAds() {
        preloadedAds.removeAll()
        adLoaders.removeAll()
        isLoading.removeAll()
    }
}

// 広告読み込み用のデリゲート
private class AdManagerDelegate: NSObject, NativeAdLoaderDelegate, AdLoaderDelegate {
    var onAdLoaded: ((NativeAd) -> Void)?
    var onAdFailed: ((Error) -> Void)?
    
    func adLoader(_ adLoader: AdLoader, didReceive nativeAd: NativeAd) {
        onAdLoaded?(nativeAd)
    }
    
    func adLoader(_ adLoader: AdLoader, didFailToReceiveAdWithError error: Error) {
        onAdFailed?(error)
    }
}

