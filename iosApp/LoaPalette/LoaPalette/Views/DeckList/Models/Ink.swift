//
//  InkColor.swift
//  LoaPalette
//
//  Created by 片岡寿哉 on 2025/11/28.
//

import SwiftUI

// インクカラー定義（共通）
enum Ink: String, CaseIterable, Identifiable, Codable {
    case amber = "Amber"
    case amethyst = "Amethyst"
    case ruby = "Ruby"
    case sapphire = "Sapphire"
    case steel = "Steel"
    case emerald = "Emerald"

    var id: String { rawValue }

    var displayName: String {
        rawValue
    }
    
    // ローカライズされた表示名
    var japaneseName: String {
        switch self {
        case .amber: return String(localized: "アンバー")
        case .amethyst: return String(localized: "アメジスト")
        case .ruby: return String(localized: "ルビー")
        case .sapphire: return String(localized: "サファイア")
        case .steel: return String(localized: "スティール")
        case .emerald: return String(localized: "エメラルド")
        }
    }

    // カラー定義
    var color: Color {
        switch self {
        case .amber: return Color.orange
        case .amethyst: return Color.purple
        case .ruby: return Color.red
        case .sapphire: return Color.blue
        case .steel: return Color.gray
        case .emerald: return Color.green
        }
    }
    
    // インク色の組み合わせからデッキ名を生成（例：「アンバー/スティール」）
    static func generateDeckName(colors: [Ink]) -> String {
        guard !colors.isEmpty else { return "" }
        return colors.map { $0.japaneseName }.joined(separator: "/")
    }
}

