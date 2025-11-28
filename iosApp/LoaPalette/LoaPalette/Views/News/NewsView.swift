//
//  NewsView.swift
//  LoaPalette
//
//  Created by 片岡寿哉 on 2025/11/28.
//

import SwiftUI

struct NewsView: View {
    var body: some View {
        Color(.accent)
            .ignoresSafeArea()
            .overlay {
                Text(String(localized: "ニュース"))
                    .font(.largeTitle)
                    .foregroundColor(.primary)
            }
            .toolbar(.visible, for: .tabBar)
    }
}

#Preview {
    NewsView()
}

