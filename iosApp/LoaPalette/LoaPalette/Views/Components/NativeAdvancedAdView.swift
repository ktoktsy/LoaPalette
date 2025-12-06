//
//  NativeAdvancedAdView.swift
//  LoaPalette
//
//  Created by Auto on 2025/01/XX.
//

import GoogleMobileAds
import SwiftUI
import UIKit

struct NativeAdvancedAdView: UIViewRepresentable {
    let adUnitID: String
    let preloadedNativeAd: NativeAd?

    init(adUnitID: String, preloadedNativeAd: NativeAd? = nil) {
        self.adUnitID = adUnitID
        self.preloadedNativeAd = preloadedNativeAd
    }

    func makeUIView(context: Context) -> UIView {
        let containerView = UIView()
        containerView.backgroundColor = .clear

        // 事前読み込み済みの広告がある場合は表示
        if let nativeAd = preloadedNativeAd {
            let nativeAdView = context.coordinator.createNativeAdView(for: nativeAd, in: containerView)
            containerView.addSubview(nativeAdView)
            
            nativeAdView.translatesAutoresizingMaskIntoConstraints = false
            NSLayoutConstraint.activate([
                nativeAdView.topAnchor.constraint(equalTo: containerView.topAnchor),
                nativeAdView.leadingAnchor.constraint(equalTo: containerView.leadingAnchor),
                nativeAdView.trailingAnchor.constraint(equalTo: containerView.trailingAnchor),
                nativeAdView.bottomAnchor.constraint(equalTo: containerView.bottomAnchor)
            ])
            
            nativeAdView.nativeAd = nativeAd
            context.coordinator.nativeAdView = nativeAdView
            context.coordinator.containerView = containerView
            return containerView
        }

        // 事前読み込み済みの広告がない場合は通常の読み込み
        guard let windowScene = UIApplication.shared.connectedScenes.first as? UIWindowScene,
            let rootViewController = windowScene.windows.first?.rootViewController
        else {
            return containerView
        }

        // ネイティブアドバンス広告ローダーを作成
        let adLoader = AdLoader(
            adUnitID: adUnitID,
            rootViewController: rootViewController,
            adTypes: [.native],
            options: nil
        )
        adLoader.delegate = context.coordinator

        // 広告リクエストを作成してロード
        let request = Request()
        adLoader.load(request)

        // CoordinatorにadLoaderを保持
        context.coordinator.adLoader = adLoader
        context.coordinator.containerView = containerView

        return containerView
    }

    func updateUIView(_ uiView: UIView, context: Context) {
        // 事前読み込み済みの広告が更新された場合の処理
        if let nativeAd = preloadedNativeAd,
           context.coordinator.nativeAdView == nil {
            // 既存のビューを削除
            uiView.subviews.forEach { $0.removeFromSuperview() }
            
            // ネイティブアドバンス広告ビューを作成
            let nativeAdView = context.coordinator.createNativeAdView(for: nativeAd, in: uiView)
            uiView.addSubview(nativeAdView)
            
            nativeAdView.translatesAutoresizingMaskIntoConstraints = false
            NSLayoutConstraint.activate([
                nativeAdView.topAnchor.constraint(equalTo: uiView.topAnchor),
                nativeAdView.leadingAnchor.constraint(equalTo: uiView.leadingAnchor),
                nativeAdView.trailingAnchor.constraint(equalTo: uiView.trailingAnchor),
                nativeAdView.bottomAnchor.constraint(equalTo: uiView.bottomAnchor),
            ])
            
            nativeAdView.nativeAd = nativeAd
            context.coordinator.nativeAdView = nativeAdView
            context.coordinator.containerView = uiView
        }
    }

    func makeCoordinator() -> Coordinator {
        Coordinator()
    }

    class Coordinator: NSObject, NativeAdLoaderDelegate, AdLoaderDelegate {
        var adLoader: AdLoader?
        var containerView: UIView?
        var nativeAdView: NativeAdView?

        func adLoader(_ adLoader: AdLoader, didReceive nativeAd: NativeAd) {
            guard let containerView = containerView else { return }

            // 既存のビューを削除
            containerView.subviews.forEach { $0.removeFromSuperview() }

            // ネイティブアドバンス広告ビューを作成
            let nativeAdView = createNativeAdView(for: nativeAd, in: containerView)
            containerView.addSubview(nativeAdView)

            // レイアウト制約を設定
            nativeAdView.translatesAutoresizingMaskIntoConstraints = false
            NSLayoutConstraint.activate([
                nativeAdView.topAnchor.constraint(equalTo: containerView.topAnchor),
                nativeAdView.leadingAnchor.constraint(equalTo: containerView.leadingAnchor),
                nativeAdView.trailingAnchor.constraint(equalTo: containerView.trailingAnchor),
                nativeAdView.bottomAnchor.constraint(equalTo: containerView.bottomAnchor)
            ])

            // ネイティブ広告をビューに設定
            nativeAdView.nativeAd = nativeAd

            self.nativeAdView = nativeAdView
        }

        func adLoader(_ adLoader: AdLoader, didFailToReceiveAdWithError error: Error) {
            print("Native ad failed to load: \(error.localizedDescription)")
        }

        func createNativeAdView(for nativeAd: NativeAd, in containerView: UIView)
            -> NativeAdView
        {
            // カスタムネイティブアドバンス広告ビューを作成
            let adView = NativeAdView()
            adView.backgroundColor = .systemBackground
            adView.translatesAutoresizingMaskIntoConstraints = false

            // 広告のコンテンツを配置
            let mainStackView = UIStackView()
            mainStackView.axis = .vertical
            mainStackView.spacing = 8
            mainStackView.translatesAutoresizingMaskIntoConstraints = false

            // アイコンとヘッドラインを横並びにする
            let headerStackView = UIStackView()
            headerStackView.axis = .horizontal
            headerStackView.spacing = 12
            headerStackView.alignment = .top
            headerStackView.translatesAutoresizingMaskIntoConstraints = false

            // アイコン
            if let icon = nativeAd.icon {
                let iconView = UIImageView(image: icon.image)
                iconView.contentMode = .scaleAspectFit
                iconView.translatesAutoresizingMaskIntoConstraints = false
                // 高さ制約を優先度付きにして、制約競合を回避
                let iconHeightConstraint = iconView.heightAnchor.constraint(equalToConstant: 50)
                iconHeightConstraint.priority = .defaultHigh
                NSLayoutConstraint.activate([
                    iconView.widthAnchor.constraint(equalToConstant: 50),
                    iconView.heightAnchor.constraint(lessThanOrEqualToConstant: 50),
                    iconHeightConstraint
                ])
                adView.iconView = iconView
                headerStackView.addArrangedSubview(iconView)
            }

            // ヘッドライン
            let headlineLabel = UILabel()
            headlineLabel.text = nativeAd.headline
            headlineLabel.font = .systemFont(ofSize: 16, weight: .bold)
            headlineLabel.numberOfLines = 2
            headlineLabel.setContentHuggingPriority(.defaultLow, for: .horizontal)
            adView.headlineView = headlineLabel
            headerStackView.addArrangedSubview(headlineLabel)

            mainStackView.addArrangedSubview(headerStackView)

            // メディアビュー（ビデオ対応用）
            let mediaView = MediaView()
            mediaView.translatesAutoresizingMaskIntoConstraints = false
            adView.mediaView = mediaView
            mainStackView.addArrangedSubview(mediaView)
            // アスペクト比16:9を維持しつつ、最小高さを確保（優先度付きで柔軟に対応）
            let mediaHeightConstraint = mediaView.heightAnchor.constraint(equalTo: mediaView.widthAnchor, multiplier: 9.0/16.0)
            mediaHeightConstraint.priority = .defaultHigh
            let mediaMinHeightConstraint = mediaView.heightAnchor.constraint(greaterThanOrEqualToConstant: 120)
            mediaMinHeightConstraint.priority = .defaultHigh
            NSLayoutConstraint.activate([
                mediaMinHeightConstraint,
                mediaView.widthAnchor.constraint(equalTo: mainStackView.widthAnchor),
                mediaHeightConstraint
            ])

            // ボディ
            if let body = nativeAd.body {
                let bodyLabel = UILabel()
                bodyLabel.text = body
                bodyLabel.font = .systemFont(ofSize: 14)
                bodyLabel.numberOfLines = 3
                bodyLabel.textColor = .secondaryLabel
                adView.bodyView = bodyLabel
                mainStackView.addArrangedSubview(bodyLabel)
            }

            // コールトゥアクションボタン
            if let callToAction = nativeAd.callToAction {
                let ctaButton = UIButton(type: .system)
                // iOS 15.0以降ではUIButtonConfigurationを使用
                if #available(iOS 15.0, *) {
                    var config = UIButton.Configuration.filled()
                    config.title = callToAction
                    config.baseBackgroundColor = .systemBlue
                    config.baseForegroundColor = .white
                    config.titleTextAttributesTransformer = UIConfigurationTextAttributesTransformer { incoming in
                        var outgoing = incoming
                        outgoing.font = .systemFont(ofSize: 14, weight: .semibold)
                        return outgoing
                    }
                    config.contentInsets = NSDirectionalEdgeInsets(top: 8, leading: 16, bottom: 8, trailing: 16)
                    config.cornerStyle = .fixed
                    config.background.cornerRadius = 8
                    ctaButton.configuration = config
                } else {
                    // iOS 14以前のフォールバック
                    ctaButton.setTitle(callToAction, for: .normal)
                    ctaButton.backgroundColor = .systemBlue
                    ctaButton.setTitleColor(.white, for: .normal)
                    ctaButton.titleLabel?.font = .systemFont(ofSize: 14, weight: .semibold)
                    ctaButton.layer.cornerRadius = 8
                    ctaButton.contentEdgeInsets = UIEdgeInsets(top: 8, left: 16, bottom: 8, right: 16)
                }
                adView.callToActionView = ctaButton
                mainStackView.addArrangedSubview(ctaButton)
            }

            // 広告ラベル
            let adLabel = UILabel()
            adLabel.text = "広告"
            adLabel.font = .systemFont(ofSize: 10)
            adLabel.textColor = .secondaryLabel
            adView.advertiserView = adLabel
            mainStackView.addArrangedSubview(adLabel)

            // スタックビューをadViewに追加（すべてのアセットビューがadViewのサブビューになる）
            adView.addSubview(mainStackView)
            NSLayoutConstraint.activate([
                mainStackView.topAnchor.constraint(equalTo: adView.topAnchor, constant: 12),
                mainStackView.leadingAnchor.constraint(equalTo: adView.leadingAnchor, constant: 12),
                mainStackView.trailingAnchor.constraint(equalTo: adView.trailingAnchor, constant: -12),
                mainStackView.bottomAnchor.constraint(equalTo: adView.bottomAnchor, constant: -12),
            ])

            return adView
        }
    }
}
