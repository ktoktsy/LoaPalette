//
//  CardSearchView.swift
//  LoaPalette
//
//  Created by 片岡寿哉 on 2025/11/28.
//

import SwiftUI

struct CardSearchView: View {
    @State var searchText = ""

    var body: some View {
        NavigationStack {
            ScrollView(.vertical, showsIndicators: false) {
                Grid {
                    ForEach(1..<100) { item in
                       GridRow {
                           Text(String(item))
                               .font(.largeTitle)
                               .frame(maxWidth: .infinity)
                        }

                    }
                }
                .searchable(text: $searchText)
            }
        }
        .tabBarMinimizeBehavior(.onScrollDown)
    }
}

#Preview {
    CardSearchView()
}

