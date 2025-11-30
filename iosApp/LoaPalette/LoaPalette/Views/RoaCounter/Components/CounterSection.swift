//
//  CounterSection.swift
//  LoaPalette
//
//  Created by 片岡寿哉 on 2025/11/28.
//

import SwiftUI

struct CounterSection: View {
    let pair: CounterPair
    let isOpponent: Bool
    @ObservedObject var viewModel: RoaCounterViewModel

    var body: some View {
        GeometryReader { geometry in
            ZStack {
                backgroundColor
                InkBlendView()
                    .frame(maxWidth: .infinity, maxHeight: .infinity)
                pointDisplay
                tapAreas
            }
        }
        .frame(maxWidth: .infinity, maxHeight: .infinity)
        .rotationEffect(.degrees(isOpponent ? 180 : 0))
    }

    private var backgroundColor: some View {
        Group {
            if pair.isOriginalColor {
                if isOpponent {
                    Color(red: 0.11, green: 0.11, blue: 0.12)
                } else {
                    Color(red: 0.0, green: 0.0, blue: 0.0)
                }
            } else {
                if isOpponent {
                    Color(red: 0.0, green: 0.0, blue: 0.0)
                } else {
                    Color(red: 0.11, green: 0.11, blue: 0.12)
                }
            }
        }
    }

    private var pointDisplay: some View {
        Text("\(isOpponent ? pair.opponentPoint : pair.myPoint)")
            .font(.system(size: 160, weight: .bold, design: .rounded))
            .foregroundColor(.white)
            .monospacedDigit()
            .zIndex(1)
    }

    private var tapAreas: some View {
        HStack(spacing: 0) {
            Color.clear
                .contentShape(Rectangle())
                .onTapGesture {
                    let currentValue = isOpponent ? pair.opponentPoint : pair.myPoint
                    if currentValue > 0 {
                        viewModel.updateCounterPoint(
                            pairId: pair.id,
                            isOpponent: isOpponent,
                            newValue: currentValue - 1
                        )
                    }
                }

            Color.clear
                .contentShape(Rectangle())
                .onTapGesture {
                    let currentValue = isOpponent ? pair.opponentPoint : pair.myPoint
                    viewModel.updateCounterPoint(
                        pairId: pair.id,
                        isOpponent: isOpponent,
                        newValue: currentValue + 1
                    )
                }
        }
    }
}
