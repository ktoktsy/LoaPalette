import Combine
import FirebaseAuth
import FirebaseCore
import GoogleSignIn
import SwiftUI
import UIKit

/// Firebase Authenticationを管理するマネージャー
/// GoogleSignIn 9.0.0以降では、GIDSignInDelegateとGIDSignInUIDelegateが削除され、コールバックベースのAPIを使用
/// 参考: https://developers.google.com/identity/sign-in/ios/release
class AuthenticationManager: NSObject, ObservableObject {
    static let shared = AuthenticationManager()
    
    @Published var isSignedIn: Bool = false
    @Published var currentUser: User?
    @Published var displayName: String?
    @Published var email: String?
    
    private override init() {
        super.init()
        // 既存の認証状態を確認
        checkAuthState()
    }
    
    /// 認証状態を確認
    func checkAuthState() {
        if let user = Auth.auth().currentUser {
            self.currentUser = user
            self.isSignedIn = true
            self.displayName = user.displayName
            self.email = user.email
        } else {
            self.currentUser = nil
            self.isSignedIn = false
            self.displayName = nil
            self.email = nil
        }
    }
    
    /// Googleログインを実行.
    /// GoogleSignIn 9.0.0以降の新しいAPIを使用
    /// 参考: https://developers.google.com/identity/sign-in/ios/sign-in
    func signInWithGoogle() async throws {
        // FirebaseのclientID取得.
        guard let clientID = FirebaseApp.app()?.options.clientID else {
            throw AuthError.missingClientID
        }

        // 表示に使用するrootViewController取得.
        let rootViewController = await MainActor.run { () -> UIViewController? in
            guard
                let windowScene = UIApplication.shared.connectedScenes
                    .compactMap({ $0 as? UIWindowScene })
                    .first,
                let rootViewController = windowScene.windows
                    .first(where: { $0.isKeyWindow })?
                    .rootViewController
            else {
                return nil
            }
            return rootViewController
        }

        guard let rootViewController else {
            throw AuthError.noRootViewController
        }

        // GoogleSignIn設定.
        let config = GIDConfiguration(clientID: clientID)
        GIDSignIn.sharedInstance.configuration = config
        
        // 新しいAPIを使用してGoogleアカウントでログイン.
        return try await withCheckedThrowingContinuation { continuation in
            GIDSignIn.sharedInstance.signIn(withPresenting: rootViewController) { signInResult, error in
                if let error = error {
                    continuation.resume(throwing: AuthError.signInFailed)
                    return
                }
                
                guard let result = signInResult else {
                    continuation.resume(throwing: AuthError.signInFailed)
                    return
                }
                
                let user = result.user
                
                // IDトークン取得.
                guard let idToken = user.idToken?.tokenString else {
                    continuation.resume(throwing: AuthError.noIDToken)
                    return
                }
                
                let accessToken = user.accessToken.tokenString
                
                // Firebase用Credential生成.
                let credential = GoogleAuthProvider.credential(
                    withIDToken: idToken,
                    accessToken: accessToken
                )
                
                // Firebase Authにサインイン.
                Task {
                    do {
                        let authResult = try await Auth.auth().signIn(with: credential)
                        let firebaseUser = authResult.user
                        
                        // 認証状態更新.
                        await MainActor.run {
                            self.currentUser = firebaseUser
                            self.isSignedIn = true
                            self.displayName = firebaseUser.displayName
                            self.email = firebaseUser.email
                        }
                        
                        continuation.resume()
                    } catch {
                        continuation.resume(throwing: AuthError.signInFailed)
                    }
                }
            }
        }
    }
    
    /// ログアウトを実行
    func signOut() async throws {
        // Firebaseからログアウト
        try Auth.auth().signOut()
        
        // 状態を更新
        await MainActor.run {
            self.currentUser = nil
            self.isSignedIn = false
            self.displayName = nil
            self.email = nil
        }
    }
    
    /// 認証エラー
    enum AuthError: LocalizedError {
        case missingClientID
        case noRootViewController
        case noIDToken
        case signInFailed
        
        var errorDescription: String? {
            switch self {
            case .missingClientID:
                return "Client IDが見つかりません"
            case .noRootViewController:
                return "Root ViewControllerが見つかりません"
            case .noIDToken:
                return "ID Tokenを取得できませんでした"
            case .signInFailed:
                return "ログインに失敗しました"
            }
        }
    }
}


