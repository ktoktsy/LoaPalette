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
    @StateObject private var authManager = AuthenticationManager.shared
    @State private var isSigningIn = false
    @State private var errorMessage: String?
    
    private let items: [SettingsItem] = [
        .officialSite,
        .clearCache,
        .privacyPolicy,
        .termsOfService,
        .disclaimer,
        .contact,
    ]

    var body: some View {
        NavigationStack {
            Form {
                // 認証セクション
                Section {
                    if authManager.isSignedIn {
                        // ログイン済みの場合
                        if let displayName = authManager.displayName {
                            HStack {
                                Text(String(localized: "ログイン中"))
                                    .foregroundColor(.primary)
                                Spacer()
                                Text(displayName)
                                    .foregroundColor(.secondary)
                            }
                        }
                        if let email = authManager.email {
                            HStack {
                                Text(String(localized: "メールアドレス"))
                                    .foregroundColor(.primary)
                                Spacer()
                                Text(email)
                                    .foregroundColor(.secondary)
                                    .font(.caption)
                            }
                        }
                        Button {
                            Task {
                                await signOut()
                            }
                        } label: {
                            HStack {
                                Text(String(localized: "ログアウト"))
                                    .foregroundColor(.red)
                                Spacer()
                            }
                        }
                        .buttonStyle(.plain)
                    } else {
                        // 未ログインの場合
                        Button {
                            Task {
                                await signInWithGoogle()
                            }
                        } label: {
                            HStack {
                                if isSigningIn {
                                    ProgressView()
                                        .progressViewStyle(CircularProgressViewStyle())
                                } else {
                                    Image(systemName: "person.circle")
                                }
                                Text(String(localized: "Googleでログイン"))
                                    .foregroundColor(.primary)
                                Spacer()
                            }
                        }
                        .buttonStyle(.plain)
                        .disabled(isSigningIn)
                    }
                    
                    if let errorMessage = errorMessage {
                        Text(errorMessage)
                            .foregroundColor(.red)
                            .font(.caption)
                    }
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
                authManager.checkAuthState()
            }
        }
    }
    
    /// Googleログインを実行
    private func signInWithGoogle() async {
        isSigningIn = true
        errorMessage = nil
        
        do {
            try await authManager.signInWithGoogle()
        } catch {
            errorMessage = error.localizedDescription
        }
        
        isSigningIn = false
    }
    
    /// ログアウトを実行
    private func signOut() async {
        errorMessage = nil
        
        do {
            try await authManager.signOut()
        } catch {
            errorMessage = error.localizedDescription
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
        .frame(maxWidth: .infinity, alignment: .leading)
        .contentShape(Rectangle())
    }
}

#Preview {
    SettingsView()
}


