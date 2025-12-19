import SwiftUI

struct ContentView: View {
    @State private var shouldHighlightLogin: Bool = false
    
    var body: some View {
        TabView {
            Tab(String(localized: "ロアカウンター"), systemImage: "timer") {
                RoaCounterView()
            }

            Tab(String(localized: "デッキリスト"), systemImage: "list.bullet.rectangle") {
                DeckListView(shouldHighlightLogin: $shouldHighlightLogin)
            }

            Tab(String(localized: "ニュース"), systemImage: "newspaper") {
                NewsView()
            }

            Tab(String(localized: "その他"), systemImage: "gearshape.fill") {
                SettingsView(shouldHighlightLogin: $shouldHighlightLogin)
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
