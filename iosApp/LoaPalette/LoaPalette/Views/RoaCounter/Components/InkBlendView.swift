//
//  InkBlendView.swift
//  LoaPalette
//
//  Created by 片岡寿哉 on 2025/11/28.
//

import SwiftUI

struct InkBlendView: View {
    var body: some View {
        GeometryReader { geometry in
            ZStack {
                HStack(spacing: 0) {
                    LinearGradient(
                        gradient: Gradient(colors: [
                            Color.red.opacity(0.2),
                            Color.red.opacity(0.05),
                            Color.clear,
                        ]),
                        startPoint: .leading,
                        endPoint: .trailing
                    )
                    .frame(width: geometry.size.width * 0.6)

                    Spacer()
                }

                HStack(spacing: 0) {
                    Spacer()

                    LinearGradient(
                        gradient: Gradient(colors: [
                            Color.blue.opacity(0.2),
                            Color.blue.opacity(0.05),
                            Color.clear,
                        ]),
                        startPoint: .trailing,
                        endPoint: .leading
                    )
                    .frame(width: geometry.size.width * 0.6)
                }
            }
        }
    }
}

