//
//  LorcanaCard.swift
//  LoaPalette
//
//  Created by 片岡寿哉 on 2025/11/28.
//

import Foundation

// カードデータモデル
// 参考: https://lorcana-api.com/docs/intro/
struct LorcanaCard: Codable, Identifiable {
    let cardId: String?
    let name: String?
    let cost: Int?
    let color: String?
    let inkwell: Bool?
    let type: String?
    let rarity: String?
    let set: String?
    let setNumber: Int?
    let flavorText: String?
    let illustrator: String?
    let imageUrl: String?
    let abilities: String?  // カンマ区切りの文字列
    let strength: Int?
    let willpower: Int?
    let lore: Int?

    enum CodingKeys: String, CodingKey {
        case cardId = "ID"
        case name = "Name"
        case cost = "Cost"
        case color = "Color"
        case inkwell = "Inkable"
        case type = "Type"
        case rarity = "Rarity"
        case set = "Set_Name"
        case setNumber = "Set_Num"
        case flavorText = "Flavor_Text"
        case illustrator = "Artist"
        case imageUrl = "Image"
        case abilities = "Classifications"
        case strength
        case willpower
        case lore = "Lore"
    }

    // Identifiableプロトコルに必要なidプロパティ
    var id: String {
        return cardId ?? name ?? UUID().uuidString
    }
}

// APIエラーレスポンス
struct APIError: Codable {
    let code: String
    let details: String
    let object: String
    let status: Int
}

// SearchState enum
enum SearchState: String {
    case idle = "IDLE"
    case loading = "LOADING"
    case success = "SUCCESS"
    case error = "ERROR"
}
