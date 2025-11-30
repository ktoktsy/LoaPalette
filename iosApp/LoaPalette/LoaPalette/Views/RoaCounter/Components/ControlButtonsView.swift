//
//  ControlButtonsView.swift
//  LoaPalette
//
//  Created by 片岡寿哉 on 2025/11/28.
//

import SwiftUI

#if canImport(UIKit)
    import UIKit
#endif

struct ControlButtonsView: View {
    @ObservedObject var viewModel: RoaCounterViewModel

    var body: some View {
        HStack(spacing: 30) {
            resetButton
            timerButton
            addRemoveButton
        }
    }

    private var resetButton: some View {
        Button(action: {
            #if os(iOS)
                let generator = UIImpactFeedbackGenerator(style: .medium)
                generator.impactOccurred()
            #endif
            viewModel.resetAllCounters()
        }) {
            Image(systemName: "arrow.counterclockwise.circle.fill")
                .font(.system(size: 40))
                .foregroundColor(.white.opacity(0.6))
                .background(Color.clear)
                .clipShape(Circle())
                .frame(width: 40, height: 40)
        }
    }

    private var timerButton: some View {
        Button(action: {
            #if os(iOS)
                let generator = UIImpactFeedbackGenerator(style: .medium)
                generator.impactOccurred()
            #endif
            viewModel.toggleTimer()
        }) {
            ZStack {
                if viewModel.elapsedTime == 0 && !viewModel.isTimerRunning {
                    Image(systemName: "play.circle.fill")
                        .font(.system(size: 40))
                        .foregroundColor(.white.opacity(0.6))
                        .background(Color.clear)
                        .clipShape(Circle())
                        .frame(width: 40, height: 40)
                } else {
                    Text(viewModel.formatTime(viewModel.elapsedTime))
                        .font(.system(size: 16, weight: .medium, design: .monospaced))
                        .foregroundColor(.black)
                        .padding(.horizontal, 12)
                        .padding(.vertical, 8)
                        .background(Color.white.opacity(0.6))
                        .clipShape(Capsule())
                        .onLongPressGesture {
                            #if os(iOS)
                                let generator = UIImpactFeedbackGenerator(style: .medium)
                                generator.impactOccurred()
                            #endif
                            viewModel.resetTimer()
                        }
                }
            }
            .frame(minWidth: 40, minHeight: 40)
        }
        .animation(
            .spring(response: 0.3, dampingFraction: 0.7),
            value: viewModel.elapsedTime == 0 && !viewModel.isTimerRunning
        )
    }

    @ViewBuilder
    private var addRemoveButton: some View {
        if viewModel.counterPairs.count == 1 {
            addButton
        } else {
            removeButton
        }
    }

    private var addButton: some View {
        Button(action: {
            #if os(iOS)
                let generator = UIImpactFeedbackGenerator(style: .medium)
                generator.impactOccurred()
            #endif
            viewModel.addCounterPair(position: .RIGHT)
        }) {
            Image(systemName: "plus.circle.fill")
                .font(.system(size: 40))
                .foregroundColor(.white.opacity(0.6))
                .background(Color.clear)
                .clipShape(Circle())
                .frame(width: 40, height: 40)
        }
        .onLongPressGesture {
            #if os(iOS)
                let generator = UIImpactFeedbackGenerator(style: .medium)
                generator.impactOccurred()
            #endif
            viewModel.showAddMenuDialog()
        }
        .confirmationDialog(
            "追加位置を選択",
            isPresented: Binding(
                get: { viewModel.showAddMenu },
                set: { if !$0 { viewModel.hideAddMenuDialog() } }
            ),
            titleVisibility: .visible
        ) {
            Button("左側に追加") {
                viewModel.addCounterPair(position: .LEFT)
            }

            Button("右側に追加") {
                viewModel.addCounterPair(position: .RIGHT)
            }

            Button("キャンセル", role: .cancel) {
                viewModel.hideAddMenuDialog()
            }
        }
    }

    private var removeButton: some View {
        Button(action: {
            #if os(iOS)
                let generator = UIImpactFeedbackGenerator(style: .medium)
                generator.impactOccurred()
            #endif
            viewModel.removeAddedPairs()
        }) {
            Image(systemName: "minus.circle.fill")
                .font(.system(size: 40))
                .foregroundColor(.white.opacity(0.6))
                .background(Color.clear)
                .clipShape(Circle())
                .frame(width: 40, height: 40)
        }
    }
}
