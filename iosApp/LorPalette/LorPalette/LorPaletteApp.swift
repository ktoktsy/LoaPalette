import FirebaseCore
import FirebaseCrashlytics
import SwiftUI

@main
struct LorPaletteApp: App {
    @UIApplicationDelegateAdaptor(AppDelegate.self) var delegate
    
    init() {
        FirebaseApp.configure()
        RemoteConfigManager.shared.fetchAndActivate()
    }

    var body: some Scene {
        WindowGroup {
            ContentView()
        }
    }
}

/// URLハンドリング用のAppDelegate
class AppDelegate: NSObject, UIApplicationDelegate {
    func application(_ application: UIApplication, didFinishLaunchingWithOptions launchOptions: [UIApplication.LaunchOptionsKey : Any]? = nil) -> Bool {
        return true
    }
}
