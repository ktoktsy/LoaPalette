import SwiftUI

struct ContentView: View {
    @State private var selectedTab: Int = 0
    @State private var shouldHighlightLogin: Bool = false
    
    var body: some View {
        TabView(selection: $selectedTab) {
            RoaCounterView()
                .tabItem {
                    Label(String(localized: "ロアカウンター"), systemImage: "timer")
                }
                .tag(0)

            DeckListView(selectedTab: $selectedTab, shouldHighlightLogin: $shouldHighlightLogin)
                .tabItem {
                    Label(String(localized: "デッキリスト"), systemImage: "list.bullet.rectangle")
                }
                .tag(1)

            NewsView()
                .tabItem {
                    Label(String(localized: "ニュース"), systemImage: "newspaper")
                }
                .tag(2)

            SettingsView(shouldHighlightLogin: $shouldHighlightLogin)
                .tabItem {
                    Label(String(localized: "その他"), systemImage: "gearshape.fill")
                }
                .tag(3)
            
            CardSearchView()
                .tabItem {
                    Label("検索", systemImage: "magnifyingglass")
                }
                .tag(4)
        }
        .tint(.second)
    }
}

#Preview {
    ContentView()
}
