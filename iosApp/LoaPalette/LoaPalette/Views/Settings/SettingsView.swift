import GoogleMobileAds
import SwiftUI
import UIKit

private enum SettingsItem: Identifiable {
    case officialSite
    case contact
    case privacyPolicy
    case termsOfService
    case disclaimer
    case clearCache

    var id: String {
        switch self {
        case .officialSite:
            return "officialSite"
        case .contact:
            return "contact"
        case .privacyPolicy:
            return "privacyPolicy"
        case .termsOfService:
            return "termsOfService"
        case .disclaimer:
            return "disclaimer"
        case .clearCache:
            return "clearCache"
        }
    }
}

struct SettingsView: View {
    @State private var preloadedNativeAd: NativeAd?

    private let items: [SettingsItem] = [
        .officialSite,
        .clearCache,
        .privacyPolicy,
        .termsOfService,
        .disclaimer,
        .contact,
    ]

    private let adUnitID = "ca-app-pub-3940256099942544/3986624511"

    var body: some View {
        NavigationStack {
            Form {
                Section {
                    NativeAdvancedAdView(adUnitID: adUnitID, preloadedNativeAd: preloadedNativeAd)
                        .frame(minHeight: 250)
                        .frame(maxWidth: .infinity)
                }

                Section {
                    ForEach(items) { item in
                        switch item {
                        case .officialSite:
                            officialSite()
                        case .privacyPolicy:
                            NavigationLink(destination: PrivacyPolicyView()) {
                                cell(
                                    title: String(localized: "プライバシーポリシー"),
                                    systemName: nil
                                )
                            }
                        case .termsOfService:
                            NavigationLink(destination: TermsOfServiceView()) {
                                cell(
                                    title: String(localized: "利用規約"),
                                    systemName: nil
                                )
                            }
                        case .disclaimer:
                            NavigationLink(destination: DisclaimerView()) {
                                cell(
                                    title: String(localized: "免責事項"),
                                    systemName: nil
                                )
                            }
                        case .contact:
                            contact()
                        case .clearCache:
                            clearCache()
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

    private func loadAd() {
        if let cachedAd = AdManager.shared.getPreloadedAd(adUnitID: adUnitID) {
            preloadedNativeAd = cachedAd
            return
        }

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
            let formUrl = RemoteConfigManager.shared.getString(forKey: "form_url")
            if !formUrl.isEmpty, let url = URL(string: formUrl) {
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

    private func clearCache() -> some View {
        Button {
            clearAllCache()
        } label: {
            cell(
                title: String(localized: "キャッシュを削除"),
                systemName: "trash"
            )
        }
        .buttonStyle(.plain)
    }

    private func clearAllCache() {
        URLCache.shared.removeAllCachedResponses()
        AdManager.shared.clearAllAds()

        if let windowScene = UIApplication.shared.connectedScenes.first as? UIWindowScene,
            let rootViewController = windowScene.windows.first?.rootViewController
        {
            let alert = UIAlertController(
                title: String(localized: "キャッシュを削除しました"),
                message: nil,
                preferredStyle: .alert
            )
            alert.addAction(UIAlertAction(title: String(localized: "OK"), style: .default))
            rootViewController.present(alert, animated: true)
        }
    }

    private func cell(title: String, systemName: String?) -> some View {
        HStack {
            Text(title)
                .foregroundColor(.primary)
            Spacer()
            if let systemName {
                Image(systemName: systemName)
                    .foregroundColor(.primary)
            }
        }
    }
}

#Preview {
    SettingsView()
}
