import FirebaseCore
import FirebaseCrashlytics
import SwiftUI

@main
struct LoaPaletteApp: App {
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
