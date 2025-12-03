//
//  Deck.swift
//  LoaPalette
//
//  Created by 片岡寿哉 on 2025/11/28.
//

import Foundation

// デッキモデル
// 参考: https://developer.apple.com/documentation/foundation/codable
struct Deck: Codable, Identifiable, Equatable {
    let id: String
    var name: String
    var entries: [DeckEntry]
    var inkColors: [Ink]  // 最大2色
    var createdAt: Date
    var updatedAt: Date

    enum CodingKeys: String, CodingKey {
        case id
        case name
        case entries
        case inkColors
        case createdAt
        case updatedAt
    }

    init(
        id: String = UUID().uuidString, name: String = "", entries: [DeckEntry] = [],
        inkColors: [Ink] = [], createdAt: Date = Date(), updatedAt: Date = Date()
    ) {
        self.id = id
        // 名前が空でインク色が選択されている場合は、インク色からデッキ名を生成
        if name.isEmpty && !inkColors.isEmpty {
            self.name = Ink.generateDeckName(colors: inkColors)
        } else {
            self.name = name
        }
        self.entries = entries
        self.inkColors = inkColors
        self.createdAt = createdAt
        self.updatedAt = updatedAt
    }

    // 既存のJSONとの互換性のため、inkColorsが存在しない場合は空配列を使用
    init(from decoder: Decoder) throws {
        let container = try decoder.container(keyedBy: CodingKeys.self)
        id = try container.decode(String.self, forKey: .id)
        name = try container.decode(String.self, forKey: .name)
        entries = try container.decode([DeckEntry].self, forKey: .entries)
        inkColors = try container.decodeIfPresent([Ink].self, forKey: .inkColors) ?? []
        createdAt = try container.decode(Date.self, forKey: .createdAt)
        updatedAt = try container.decode(Date.self, forKey: .updatedAt)
    }

    // デッキの総カード枚数を計算
    var totalCardCount: Int {
        entries.reduce(0) { $0 + $1.count }
    }

    // デッキにカードを追加（最大4枚まで）
    mutating func addCard(_ card: LorcanaCard, count: Int = 1) {
        if let index = entries.firstIndex(where: { $0.card.id == card.id }) {
            // 既に存在するカードの場合、4枚を超えないように制限
            let newCount = min(entries[index].count + count, 4)
            entries[index].count = newCount
        } else {
            // 新規カードの場合、4枚を超えないように制限
            let newCount = min(count, 4)
            entries.append(DeckEntry(card: card, count: newCount))
        }
        updatedAt = Date()
    }

    // デッキからカードを削除
    mutating func removeCard(_ cardId: String) {
        entries.removeAll { $0.id == cardId }
        updatedAt = Date()
    }

    // カードの枚数を更新
    mutating func updateCardCount(_ cardId: String, count: Int) {
        if let index = entries.firstIndex(where: { $0.id == cardId }) {
            if count <= 0 {
                entries.remove(at: index)
            } else {
                entries[index].count = count
            }
            updatedAt = Date()
        }
    }

    // Equatable準拠のため
    static func == (lhs: Deck, rhs: Deck) -> Bool {
        lhs.id == rhs.id && lhs.name == rhs.name && lhs.entries == rhs.entries
            && lhs.inkColors == rhs.inkColors && lhs.createdAt == rhs.createdAt
            && lhs.updatedAt == rhs.updatedAt
    }
}
