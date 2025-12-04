//
//  MatchRecord.swift
//  LoaPalette
//
//  Created by 片岡寿哉 on 2025/11/28.
//

import Foundation

// 試合記録モデル
// 参考: https://developer.apple.com/documentation/foundation/codable
struct MatchRecord: Codable, Identifiable, Equatable {
    let id: String
    var opponentInkColors: [Ink]  // 相手のインク色（最大2色）
    var opponentDeckName: String  // 相手のデッキ名
    var isWin: Bool  // true: 勝利, false: 敗北
    var playedAt: Date  // 試合日時

    enum CodingKeys: String, CodingKey {
        case id
        case opponentInkColors
        case opponentDeckName
        case isWin
        case playedAt
    }

    init(
        id: String = UUID().uuidString,
        opponentInkColors: [Ink] = [],
        opponentDeckName: String = "",
        isWin: Bool = true,
        playedAt: Date = Date()
    ) {
        self.id = id
        self.opponentInkColors = opponentInkColors
        // デッキ名が空でインク色が選択されている場合は、インク色からデッキ名を生成
        if opponentDeckName.isEmpty && !opponentInkColors.isEmpty {
            self.opponentDeckName = Ink.generateDeckName(colors: opponentInkColors)
        } else {
            self.opponentDeckName = opponentDeckName
        }
        self.isWin = isWin
        self.playedAt = playedAt
    }

    // 既存のJSONとの互換性のため、opponentDeckNameが存在しない場合は空文字列を使用
    init(from decoder: Decoder) throws {
        let container = try decoder.container(keyedBy: CodingKeys.self)
        id = try container.decode(String.self, forKey: .id)
        opponentInkColors = try container.decode([Ink].self, forKey: .opponentInkColors)
        opponentDeckName = try container.decodeIfPresent(String.self, forKey: .opponentDeckName) ?? ""
        isWin = try container.decode(Bool.self, forKey: .isWin)
        playedAt = try container.decode(Date.self, forKey: .playedAt)
        
        // デッキ名が空でインク色が選択されている場合は、インク色からデッキ名を生成
        if opponentDeckName.isEmpty && !opponentInkColors.isEmpty {
            opponentDeckName = Ink.generateDeckName(colors: opponentInkColors)
        }
    }

    // Equatable準拠のため
    static func == (lhs: MatchRecord, rhs: MatchRecord) -> Bool {
        lhs.id == rhs.id && lhs.opponentInkColors == rhs.opponentInkColors
            && lhs.opponentDeckName == rhs.opponentDeckName
            && lhs.isWin == rhs.isWin && lhs.playedAt == rhs.playedAt
    }
}

