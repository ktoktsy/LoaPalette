
import Foundation
import shared

// カードデータモデル
// 参考: https://lorcana-api.com/docs/intro
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
        case name = "Name"
        case cost = "Cost"
        case type = "Type"
        case color = "Color"
        case inkable = "Inkable"
        case bodyText = "Body_Text"
        case flavorText = "Flavor_Text"
        case artist = "Artist"
        case rarity = "Rarity"
        case image = "Image"
        case setName = "Set_Name"
        case setId = "Set_ID"
        case setNum = "Set_Num"
        case strength = "Strength"
        case willpower = "Willpower"
        case lore = "Lore"
        case classifications = "Classifications"
    }

    // カスタムデコード処理
    init(from decoder: Decoder) throws {
        let container = try decoder.container(keyedBy: CodingKeys.self)

        name = try container.decodeIfPresent(String.self, forKey: .name)
        cost = try container.decodeIfPresent(Int.self, forKey: .cost)
        type = try container.decodeIfPresent(String.self, forKey: .type)
        color = try container.decodeIfPresent(String.self, forKey: .color)
        inkwell = try container.decodeIfPresent(Bool.self, forKey: .inkable)
        let bodyTextValue = try container.decodeIfPresent(String.self, forKey: .bodyText)
        flavorText = try container.decodeIfPresent(String.self, forKey: .flavorText)
        illustrator = try container.decodeIfPresent(String.self, forKey: .artist)
        rarity = try container.decodeIfPresent(String.self, forKey: .rarity)
        imageUrl = try container.decodeIfPresent(String.self, forKey: .image)
        let setNameValue = try container.decodeIfPresent(String.self, forKey: .setName)
        let setIdValue = try container.decodeIfPresent(String.self, forKey: .setId)
        setNumber = try container.decodeIfPresent(Int.self, forKey: .setNum)
        strength = try container.decodeIfPresent(Int.self, forKey: .strength)
        willpower = try container.decodeIfPresent(Int.self, forKey: .willpower)
        lore = try container.decodeIfPresent(Int.self, forKey: .lore)
        let classificationsValue = try container.decodeIfPresent(
            String.self, forKey: .classifications)

        // カードIDを生成（Set_IDとSet_Numから）
        if let setId = setIdValue, let setNum = setNumber {
            cardId = "\(setId)-\(setNum)"
        } else {
            cardId = nil
        }

        // セットIDを設定
        set = setIdValue

        // アビリティをBody_Textから設定
        abilities = bodyTextValue
    }

    // エンコード処理（必要に応じて実装）
    func encode(to encoder: Encoder) throws {
        var container = encoder.container(keyedBy: CodingKeys.self)
        try container.encodeIfPresent(name, forKey: .name)
        try container.encodeIfPresent(cost, forKey: .cost)
        try container.encodeIfPresent(type, forKey: .type)
        try container.encodeIfPresent(color, forKey: .color)
        try container.encodeIfPresent(inkwell, forKey: .inkable)
        try container.encodeIfPresent(abilities, forKey: .bodyText)
        try container.encodeIfPresent(flavorText, forKey: .flavorText)
        try container.encodeIfPresent(illustrator, forKey: .artist)
        try container.encodeIfPresent(rarity, forKey: .rarity)
        try container.encodeIfPresent(imageUrl, forKey: .image)
        try container.encodeIfPresent(set, forKey: .setName)
        try container.encodeIfPresent(set, forKey: .setId)
        try container.encodeIfPresent(setNumber, forKey: .setNum)
        try container.encodeIfPresent(strength, forKey: .strength)
        try container.encodeIfPresent(willpower, forKey: .willpower)
        try container.encodeIfPresent(lore, forKey: .lore)
    }

    var id: String {
        return "\(setNumber ?? 0)-\(lore ?? 0)-\(name ?? "")"
    }
}

struct APIError: Codable {
    let code: String
    let details: String
    let object: String
    let status: Int
}

enum SearchState: String {
    case idle = "IDLE"
    case loading = "LOADING"
    case success = "SUCCESS"
    case error = "ERROR"
}
