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
    var matchRecords: [MatchRecord]  // 試合記録
    var memo: String  // メモ

    enum CodingKeys: String, CodingKey {
        case id
        case name
        case entries
        case inkColors
        case createdAt
        case updatedAt
        case matchRecords
        case memo
        // 後方互換性のため
        case wins
        case losses
    }

    init(
        id: String = UUID().uuidString, name: String = "", entries: [DeckEntry] = [],
        inkColors: [Ink] = [], createdAt: Date = Date(), updatedAt: Date = Date(),
        matchRecords: [MatchRecord] = [], memo: String = ""
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
        self.matchRecords = matchRecords
        self.memo = memo
    }

    // 既存のJSONとの互換性のため、inkColorsが存在しない場合は空配列を使用
    // matchRecordsが存在しない場合は空配列を使用
    // 後方互換性: wins/lossesが存在する場合はmatchRecordsに変換
    init(from decoder: Decoder) throws {
        let container = try decoder.container(keyedBy: CodingKeys.self)
        id = try container.decode(String.self, forKey: .id)
        name = try container.decode(String.self, forKey: .name)
        entries = try container.decode([DeckEntry].self, forKey: .entries)
        inkColors = try container.decodeIfPresent([Ink].self, forKey: .inkColors) ?? []
        createdAt = try container.decode(Date.self, forKey: .createdAt)
        updatedAt = try container.decode(Date.self, forKey: .updatedAt)
        memo = try container.decodeIfPresent(String.self, forKey: .memo) ?? ""

        // matchRecordsが存在する場合はそれを使用、存在しない場合は空配列
        if let records = try? container.decode([MatchRecord].self, forKey: .matchRecords) {
            matchRecords = records
        } else {
            // 後方互換性: wins/lossesからmatchRecordsを生成
            let wins = try container.decodeIfPresent(Int.self, forKey: .wins) ?? 0
            let losses = try container.decodeIfPresent(Int.self, forKey: .losses) ?? 0
            var records: [MatchRecord] = []
            // 既存のwins/lossesを試合記録に変換（日時はupdatedAtを使用）
            for _ in 0..<wins {
                records.append(MatchRecord(opponentInkColors: [], isWin: true, playedAt: updatedAt))
            }
            for _ in 0..<losses {
                records.append(MatchRecord(opponentInkColors: [], isWin: false, playedAt: updatedAt))
            }
            matchRecords = records
        }
    }

    // Encodable準拠のため、matchRecordsをエンコード（wins/lossesは除外）
    func encode(to encoder: Encoder) throws {
        var container = encoder.container(keyedBy: CodingKeys.self)
        try container.encode(id, forKey: .id)
        try container.encode(name, forKey: .name)
        try container.encode(entries, forKey: .entries)
        try container.encode(inkColors, forKey: .inkColors)
        try container.encode(createdAt, forKey: .createdAt)
        try container.encode(updatedAt, forKey: .updatedAt)
        try container.encode(matchRecords, forKey: .matchRecords)
        try container.encode(memo, forKey: .memo)
        // wins/lossesはエンコードしない（matchRecordsから計算可能なため）
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

    // 勝利数を計算
    var wins: Int {
        matchRecords.filter { $0.isWin }.count
    }

    // 敗北数を計算
    var losses: Int {
        matchRecords.filter { !$0.isWin }.count
    }

    // 勝率を計算（勝敗が0の場合は0%）
    var winRate: Double {
        let total = matchRecords.count
        guard total > 0 else { return 0.0 }
        return Double(wins) / Double(total) * 100.0
    }

    // 試合記録を追加
    mutating func addMatchRecord(_ record: MatchRecord) {
        matchRecords.append(record)
        updatedAt = Date()
    }

    // 試合記録を削除
    mutating func removeMatchRecord(_ recordId: String) {
        matchRecords.removeAll { $0.id == recordId }
        updatedAt = Date()
    }

    // Equatable準拠のため
    static func == (lhs: Deck, rhs: Deck) -> Bool {
        lhs.id == rhs.id && lhs.name == rhs.name && lhs.entries == rhs.entries
            && lhs.inkColors == rhs.inkColors && lhs.createdAt == rhs.createdAt
            && lhs.updatedAt == rhs.updatedAt && lhs.matchRecords == rhs.matchRecords
            && lhs.memo == rhs.memo
    }
}
