//
//  RoaCounterView.swift
//  LoaPalette
//
//  Created by 片岡寿哉 on 2025/11/28.
//

import SwiftUI

struct RoaCounterView: View {
    @StateObject private var viewModel = RoaCounterViewModel()

    var body: some View {
        GeometryReader { geometry in
            ZStack {
                counterLayout(geometry: geometry)
                ControlButtonsView(viewModel: viewModel)
                    .frame(maxWidth: .infinity, maxHeight: .infinity)
            }
        }
        .ignoresSafeArea(.all)
        #if os(iOS)
            .toolbar(.visible, for: .tabBar)
        #endif
        .onDisappear {
            viewModel.cleanup()
        }
    }

    @ViewBuilder
    private func counterLayout(geometry: GeometryProxy) -> some View {
        if viewModel.counterPairs.count == 1 {
            singlePairLayout(geometry: geometry)
        } else {
            doublePairLayout(geometry: geometry)
        }
    }

    private func singlePairLayout(geometry: GeometryProxy) -> some View {
        VStack(spacing: 0) {
            CounterSection(
                pair: viewModel.counterPairs[0],
                isOpponent: true,
                viewModel: viewModel
            )
            .frame(height: geometry.size.height / 2)

            Divider()
                .background(Color.white.opacity(0.3))

            CounterSection(
                pair: viewModel.counterPairs[0],
                isOpponent: false,
                viewModel: viewModel
            )
            .frame(height: geometry.size.height / 2)
        }
    }

    private func doublePairLayout(geometry: GeometryProxy) -> some View {
        VStack(spacing: 0) {
            HStack(spacing: 0) {
                CounterSection(
                    pair: viewModel.counterPairs[0],
                    isOpponent: true,
                    viewModel: viewModel
                )
                .frame(
                    width: geometry.size.width / 2, height: geometry.size.height / 2
                )

                Divider()
                    .background(Color.white.opacity(0.3))
                    .frame(width: 1)

                CounterSection(
                    pair: viewModel.counterPairs[1],
                    isOpponent: true,
                    viewModel: viewModel
                )
                .frame(
                    width: geometry.size.width / 2, height: geometry.size.height / 2
                )
            }

            Divider()
                .background(Color.white.opacity(0.3))
                .frame(height: 1)

            HStack(spacing: 0) {
                CounterSection(
                    pair: viewModel.counterPairs[0],
                    isOpponent: false,
                    viewModel: viewModel
                )
                .frame(
                    width: geometry.size.width / 2, height: geometry.size.height / 2
                )

                Divider()
                    .background(Color.white.opacity(0.3))
                    .frame(width: 1)

                CounterSection(
                    pair: viewModel.counterPairs[1],
                    isOpponent: false,
                    viewModel: viewModel
                )
                .frame(
                    width: geometry.size.width / 2, height: geometry.size.height / 2
                )
            }
        }
    }
}

#Preview {
    RoaCounterView()
}
