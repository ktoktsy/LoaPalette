//
//  RoaCounterViewModel.swift
//  LoaPalette
//
//  Created by 片岡寿哉 on 2025/11/28.
//

import Combine
import SwiftUI

@MainActor
class RoaCounterViewModel: ObservableObject {
    @Published var counterPairs: [CounterPair] = [
        CounterPair(isOriginalColor: true)
    ]
    @Published var elapsedTime: Double = 0.0
    @Published var isTimerRunning: Bool = false
    @Published var showAddMenu: Bool = false

    private var updateTimer: Timer?

    func resetAllCounters() {
        AnalyticsManager.shared.logRoaCounterReset()
        counterPairs = counterPairs.map { pair in
            CounterPair(
                id: pair.id,
                opponentPoint: 0,
                myPoint: 0,
                isOriginalColor: pair.isOriginalColor
            )
        }
    }

    func addCounterPair(position: AddPosition) {
        let positionString = position == .LEFT ? "LEFT" : "RIGHT"
        AnalyticsManager.shared.logRoaCounterAddPerson(position: positionString)
        let newPair = CounterPair(isOriginalColor: false)
        var currentPairs = counterPairs
        switch position {
        case .LEFT:
            currentPairs.insert(newPair, at: 0)
        case .RIGHT:
            currentPairs.append(newPair)
        }
        counterPairs = currentPairs
    }

    func removeAddedPairs() {
        counterPairs = counterPairs.filter { $0.isOriginalColor }
    }

    func updateCounterPoint(pairId: String, isOpponent: Bool, newValue: Int) {
        counterPairs = counterPairs.map { pair in
            if pair.id == pairId {
                if isOpponent {
                    return CounterPair(
                        id: pair.id,
                        opponentPoint: newValue,
                        myPoint: pair.myPoint,
                        isOriginalColor: pair.isOriginalColor
                    )
                } else {
                    return CounterPair(
                        id: pair.id,
                        opponentPoint: pair.opponentPoint,
                        myPoint: newValue,
                        isOriginalColor: pair.isOriginalColor
                    )
                }
            } else {
                return pair
            }
        }
    }

    func toggleTimer() {
        if isTimerRunning {
            stopTimer()
        } else {
            startTimer()
        }
    }

    private func startTimer() {
        if isTimerRunning { return }
        AnalyticsManager.shared.logRoaCounterTimerStart()
        isTimerRunning = true
        updateTimer = Timer.scheduledTimer(withTimeInterval: 0.1, repeats: true) { [weak self] _ in
            guard let self = self else { return }
            Task { @MainActor in
                self.elapsedTime += 0.1
            }
        }
    }

    private func stopTimer() {
        updateTimer?.invalidate()
        updateTimer = nil
        isTimerRunning = false
    }

    func resetTimer() {
        updateTimer?.invalidate()
        updateTimer = nil
        elapsedTime = 0.0
        isTimerRunning = false
    }

    func showAddMenuDialog() {
        showAddMenu = true
    }

    func hideAddMenuDialog() {
        showAddMenu = false
    }

    func formatTime(_ time: Double) -> String {
        let minutes = Int(time) / 60
        let seconds = Int(time) % 60
        return String(format: "%02d:%02d", minutes, seconds)
    }

    func cleanup() {
        updateTimer?.invalidate()
        updateTimer = nil
    }

    deinit {
        updateTimer?.invalidate()
    }
}

