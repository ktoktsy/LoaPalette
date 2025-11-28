//
//  ContentView.swift
//  LoaPalette
//
//  Created by 片岡寿哉 on 2025/11/28.
//

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

            Tab(String(localized: "カード検索"), systemImage: "magnifyingglass") {
                CardSearchView()
            }

            Tab(String(localized: "ニュース"), systemImage: "newspaper") {
                NewsView()
            }

            Tab(String(localized: "設定"), systemImage: "gearshape.fill") {
                SettingsView()
            }
        }
        .tint(.second)
    }
}

#Preview {
    ContentView()
}
