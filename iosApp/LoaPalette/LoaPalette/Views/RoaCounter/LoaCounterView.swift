//
//  LoaCounterView.swift
//  LoaPalette
//
//  Created by 片岡寿哉 on 2025/11/28.
//

import SwiftUI

struct LoaCounterView: View {
    var body: some View {
        Color.blue
            .ignoresSafeArea()
            .overlay {
                Text("ロアカウンター")
                    .font(.largeTitle)
                    .foregroundColor(.white)
            }
    }
}

#Preview {
    LoaCounterView()
}

