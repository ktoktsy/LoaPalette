import SwiftUI

struct ContentView: View {
    var body: some View {
        TabView {
            Tab(String(localized: "ロアカウンター"), systemImage: "timer") {
                RoaCounterView()
            }

            Tab(String(localized: "デッキリスト"), systemImage: "list.bullet.rectangle") {
                DeckListView()
            }

            Tab(String(localized: "ニュース"), systemImage: "newspaper") {
                NewsView()
            }

            Tab(String(localized: "その他"), systemImage: "gearshape.fill") {
                SettingsView()
            }
            
            Tab(role: .search) {
                CardSearchView()
            }
        }
        .tint(.second)
    }
}

#Preview {
    ContentView()
}
