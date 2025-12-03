//
//  DeckEntry.swift
//  LoaPalette
//
//  Created by 片岡寿哉 on 2025/11/28.
//

import Foundation

// デッキエントリモデル（カードと枚数）
// 参考: https://developer.apple.com/documentation/foundation/codable
struct DeckEntry: Codable, Identifiable, Hashable {
    let id: String
    let card: LorcanaCard
    var count: Int

    init(card: LorcanaCard, count: Int = 1) {
        self.id = card.id
        self.card = card
        self.count = count
    }

    // Hashable準拠のため
    func hash(into hasher: inout Hasher) {
        hasher.combine(id)
    }

    static func == (lhs: DeckEntry, rhs: DeckEntry) -> Bool {
        lhs.id == rhs.id
    }
}
