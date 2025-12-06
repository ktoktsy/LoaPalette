//
//  SettingsView.swift
//  LoaPalette
//
//  Created by 片岡寿哉 on 2025/11/28.
//

import SwiftUI
import UIKit
import GoogleMobileAds

private enum SettingsItem: Identifiable {
    case officialSite
    case contact

    var id: String {
        switch self {
        case .officialSite:
            return "officialSite"
        case .contact:
            return "contact"
        }
    }
}

struct SettingsView: View {
    @State private var preloadedNativeAd: NativeAd?
    
    private let items: [SettingsItem] = [
        .officialSite,
        .contact,
    ]
    
    private let adUnitID = "ca-app-pub-3940256099942544/3986624511"

    var body: some View {
        NavigationStack {
            Form {
                // ネイティブアドバンス広告
                Section {
                    NativeAdvancedAdView(adUnitID: adUnitID, preloadedNativeAd: preloadedNativeAd)
                        .frame(minHeight: 200)
                        .frame(maxWidth: .infinity)
                }

                Section {
                    ForEach(items) { item in
                        switch item {
                        case .officialSite:
                            officialSite()
                        case .contact:
                            contact()
                        }
                    }
                }
            }
            .scrollContentBackground(.hidden)
            .navigationTitle(String(localized: "設定"))
            .onAppear {
                loadAd()
            }
        }
    }
    
    /// 広告を読み込む（キャッシュから取得、なければプリロード）
    private func loadAd() {
        // キャッシュから取得を試みる
        if let cachedAd = AdManager.shared.getPreloadedAd(adUnitID: adUnitID) {
            preloadedNativeAd = cachedAd
            return
        }
        
        // キャッシュにない場合はプリロードを開始
        AdManager.shared.preloadAd(adUnitID: adUnitID) { nativeAd in
            self.preloadedNativeAd = nativeAd
        }
    }
    
    private func officialSite() -> some View {
        Button {
            AnalyticsManager.shared.logSettingsOfficialSiteClick()
            if let url = URL(string: "https://www.takaratomy.co.jp/products/disneylorcana/") {
                UIApplication.shared.open(url)
            }
        } label: {
            cell(
                title: String(localized: "公式サイト"),
                systemName: "chevron.right"
            )
        }
        .buttonStyle(.plain)
    }

    private func contact() -> some View {
        Button {
            AnalyticsManager.shared.logSettingsContactClick()
            if let url = URL(string: "https://docs.google.com/forms/d/e/1FAIpQLSemPSvKx63Czk_3nwdpOyrou943bHQ27JXbsZxqoiyeP3Skdg/viewform?usp=sharing&ouid=112820201528893412570") {
                UIApplication.shared.open(url)
            }
        } label: {
            cell(
                title: String(localized: "要望/お問い合わせ"),
                systemName: "chevron.right"
            )
        }
        .buttonStyle(.plain)
    }

    private func cell(title: String, systemName: String?) -> some View {
        HStack {
            Text(title)
                .foregroundColor(.white)
            Spacer()
            if let systemName {
                Image(systemName: systemName)
                    .foregroundColor(.white)
            }
        }
    }
}

#Preview {
    SettingsView()
}
