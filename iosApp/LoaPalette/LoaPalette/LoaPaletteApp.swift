import FirebaseCore
import FirebaseCrashlytics
import GoogleMobileAds
import SwiftUI

@main
struct LoaPaletteApp: App {
    init() {
        FirebaseApp.configure()
        RemoteConfigManager.shared.fetchAndActivate()
        MobileAds.shared.start { status in
            DispatchQueue.main.async {
                Self.preloadAds()
            }
        }
    }

    var body: some Scene {
        WindowGroup {
            ContentView()
        }
    }

    private static func preloadAds() {
        let settingsAdUnitID = "ca-app-pub-3940256099942544/3986624511"
        AdManager.shared.preloadAd(adUnitID: settingsAdUnitID)
    }
}
