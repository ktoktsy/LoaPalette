//
//  RoaCounterModels.swift
//  LoaPalette
//
//  Created by 片岡寿哉 on 2025/11/28.
//

import Foundation

struct CounterPair: Identifiable {
    let id: String
    var opponentPoint: Int
    var myPoint: Int
    let isOriginalColor: Bool

    init(
        id: String = UUID().uuidString, opponentPoint: Int = 0, myPoint: Int = 0,
        isOriginalColor: Bool = true
    ) {
        self.id = id
        self.opponentPoint = opponentPoint
        self.myPoint = myPoint
        self.isOriginalColor = isOriginalColor
    }
}

enum AddPosition {
    case LEFT
    case RIGHT
}

