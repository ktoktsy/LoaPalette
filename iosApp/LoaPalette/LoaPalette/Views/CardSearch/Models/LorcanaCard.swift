//
//  LorcanaCard.swift
//  LoaPalette
//
//  Created by 片岡寿哉 on 2025/11/28.
//

import Foundation
import shared

// 画像URI群（Lorcast API）
struct ImageUris: Codable {
    let digital: DigitalImageUris?
}

// デジタル画像URI群
struct DigitalImageUris: Codable {
    let small: String?
    let normal: String?
    let large: String?
}

// カードデータモデル
// 参考: https://api-lorcana.com/#/Cards/get%20cards
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

    // 新しいAPI構造のフィールド
    let attack: Int?
    let defence: Int?
    let variants: [CardVariant]?
    let languages: CardLanguages?
    let classifications: [CardClassification]?
    let abilitiesArray: [CardAbility]?
    let imageUris: ImageUris?

    enum CodingKeys: String, CodingKey {
        case cost
        case inkwell
        case color
        case type
        case lore
        case attack
        case defence
        case variants
        case languages
        case classifications
        case abilitiesArray = "abilities"
        case illustrator
        case imageUris = "image_uris"
    }

    // カスタムデコード処理
    init(from decoder: Decoder) throws {
        let container = try decoder.container(keyedBy: CodingKeys.self)

        cost = try container.decodeIfPresent(Int.self, forKey: .cost)
        inkwell = try container.decodeIfPresent(Bool.self, forKey: .inkwell)
        color = try container.decodeIfPresent(String.self, forKey: .color)
        type = try container.decodeIfPresent(String.self, forKey: .type)
        lore = try container.decodeIfPresent(Int.self, forKey: .lore)
        attack = try container.decodeIfPresent(Int.self, forKey: .attack)
        defence = try container.decodeIfPresent(Int.self, forKey: .defence)
        variants = try container.decodeIfPresent([CardVariant].self, forKey: .variants)
        languages = try container.decodeIfPresent(CardLanguages.self, forKey: .languages)
        classifications = try container.decodeIfPresent(
            [CardClassification].self, forKey: .classifications)
        abilitiesArray = try container.decodeIfPresent([CardAbility].self, forKey: .abilitiesArray)
        illustrator = try container.decodeIfPresent(String.self, forKey: .illustrator)
        imageUris = try container.decodeIfPresent(ImageUris.self, forKey: .imageUris)

        // 日本語データを優先的に使用
        if let jaData = languages?.ja {
            name = jaData.name
            flavorText = jaData.flavour ?? ""
        } else if let enData = languages?.en {
            name = enData.name
            flavorText = enData.flavour ?? ""
        } else {
            name = nil
            flavorText = nil
        }

        // バリアントから情報を取得（最初のバリアントを使用）
        if let firstVariant = variants?.first,
            let variantId = firstVariant.id
        {
            cardId = String(variantId)
            // レアリティを大文字始まりに変換（Common, Uncommon, Rare, Super Rare, Legendary）
            if let variantRarity = firstVariant.rarity {
                let rarityMap: [String: String] = [
                    "common": "Common",
                    "uncommon": "Uncommon",
                    "rare": "Rare",
                    "super_rare": "Super Rare",
                    "legendary": "Legendary",
                ]
                rarity =
                    rarityMap[variantRarity] ?? variantRarity.prefix(1).uppercased()
                    + variantRarity.dropFirst()
            } else {
                rarity = nil
            }
            set = firstVariant.set?.uppercased()
            // セット番号を取得（例: "1/204 JA 1" から "1" を取得）
            if let jaString = firstVariant.ravensburger?.ja,
                let firstPart = jaString.split(separator: "/").first,
                let number = Int(firstPart)
            {
                setNumber = number
            } else {
                setNumber = nil
            }
        } else {
            cardId = nil
            rarity = nil
            set = nil
            setNumber = nil
        }

        // 画像URLを構築（Lorcast APIのimage_uris.digital.largeを優先、なければフォールバック）
        // 優先順位: image_uris.digital.large > 手動構築URL
        if let largeImageUrl = imageUris?.digital?.large {
            // Lorcast APIから提供される画像URLを使用
            imageUrl = largeImageUrl
        } else if let en = languages?.en {
            // Kotlin側の共通実装を使用
            let kotlinLanguageData = shared.LanguageData(
                name: en.name,
                title: en.title,
                flavour: en.flavour
            )
            imageUrl = shared.ImageUrlGenerator.shared.generateFallbackImageUrl(
                enLanguage: kotlinLanguageData)
        } else {
            #if DEBUG
                print("⚠️ Missing name for image URL generation")
            #endif
            imageUrl = nil
        }

        // 攻撃力・防御力のマッピング
        strength = attack
        willpower = defence

        // アビリティを文字列に変換
        if let abilitiesArray = abilitiesArray, !abilitiesArray.isEmpty {
            abilities = abilitiesArray.compactMap {
                $0.title?.en ?? $0.ability ?? $0.type
            }.filter { !$0.isEmpty }.joined(separator: ", ")
        } else {
            abilities = nil
        }
    }

    // エンコード処理（必要に応じて実装）
    func encode(to encoder: Encoder) throws {
        var container = encoder.container(keyedBy: CodingKeys.self)
        try container.encodeIfPresent(cost, forKey: .cost)
        try container.encodeIfPresent(inkwell, forKey: .inkwell)
        try container.encodeIfPresent(color, forKey: .color)
        try container.encodeIfPresent(type, forKey: .type)
        try container.encodeIfPresent(lore, forKey: .lore)
        try container.encodeIfPresent(attack, forKey: .attack)
        try container.encodeIfPresent(defence, forKey: .defence)
        try container.encodeIfPresent(variants, forKey: .variants)
        try container.encodeIfPresent(languages, forKey: .languages)
        try container.encodeIfPresent(classifications, forKey: .classifications)
        try container.encodeIfPresent(abilitiesArray, forKey: .abilitiesArray)
        try container.encodeIfPresent(illustrator, forKey: .illustrator)
    }

    // Identifiableプロトコルに必要なidプロパティ
    var id: String {
        return cardId ?? name ?? UUID().uuidString
    }
}

// カードバリアント
struct CardVariant: Codable {
    let set: String?
    let id: Int?
    let dreamborn: String?
    let ravensburger: RavensburgerInfo?
    let rarity: String?
    let illustrator: String?
}

// Ravensburger情報
struct RavensburgerInfo: Codable {
    let en: String?
    let fr: String?
    let de: String?
    let it: String?
    let zh: String?
    let ja: String?
    let cultureInvariantId: Int?
    let sortNumber: Int?

    enum CodingKeys: String, CodingKey {
        case en, fr, de, it, zh, ja
        case cultureInvariantId = "culture_invariant_id"
        case sortNumber = "sort_number"
    }
}

// カード言語情報
struct CardLanguages: Codable {
    let en: LanguageData?
    let fr: LanguageData?
    let de: LanguageData?
    let zh: LanguageData?
    let ja: LanguageData?
}

// 言語データ
struct LanguageData: Codable {
    let name: String
    let title: String
    let flavour: String?
}

// カード分類
struct CardClassification: Codable {
    let slug: String
    let en: String
    let fr: String?
}

// カードアビリティ
struct CardAbility: Codable {
    let type: String?
    let title: AbilityTitle?
    let text: AbilityText?
    let ability: String?
}

// アビリティタイトル
struct AbilityTitle: Codable {
    let en: String?
}

// アビリティテキスト
struct AbilityText: Codable {
    let en: String?
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
