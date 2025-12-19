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
    @Binding var shouldHighlightLogin: Bool
    @State private var isSigningIn = false
    @State private var errorMessage: String?
    @State private var isAnimating = false
    
    private let items: [SettingsItem] = [
        .officialSite,
        .clearCache,
        .privacyPolicy,
        .termsOfService,
        .disclaimer,
        .contact,
    ]
    
    init(shouldHighlightLogin: Binding<Bool> = .constant(false)) {
        self._shouldHighlightLogin = shouldHighlightLogin
    }

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
                            .padding(.vertical, 8)
                            .padding(.horizontal, 12)
                            .background(
                                RoundedRectangle(cornerRadius: 8)
                                    .fill(isAnimating ? Color.accentColor.opacity(0.2) : Color.clear)
                            )
                            .scaleEffect(isAnimating ? 1.05 : 1.0)
                            .shadow(color: isAnimating ? Color.accentColor.opacity(0.5) : Color.clear, radius: 8, x: 0, y: 4)
                        }
                        .buttonStyle(.plain)
                        .disabled(isSigningIn)
                        .id("loginButton")
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
                // ログインボタンをハイライトする必要がある場合、アニメーションを開始
                if shouldHighlightLogin && !authManager.isSignedIn {
                    startHighlightAnimation()
                }
            }
            .onChange(of: shouldHighlightLogin) { oldValue, newValue in
                if newValue && !authManager.isSignedIn {
                    startHighlightAnimation()
                }
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
    
    /// ログインボタンのハイライトアニメーションを開始
    private func startHighlightAnimation() {
        // 少し遅延させてからアニメーション開始（画面遷移のアニメーションが完了してから）
        DispatchQueue.main.asyncAfter(deadline: .now() + 0.3) {
            withAnimation(.easeInOut(duration: 0.6).repeatCount(3, autoreverses: true)) {
                isAnimating = true
            }
            
            // アニメーション完了後にフラグをリセット
            DispatchQueue.main.asyncAfter(deadline: .now() + 2.0) {
                withAnimation {
                    isAnimating = false
                    shouldHighlightLogin = false
                }
            }
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


