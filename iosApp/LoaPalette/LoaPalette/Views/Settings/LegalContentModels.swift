//
//  LegalContentModels.swift
//  LoaPalette
//
//  Created by Auto on 2025/01/XX.
//

import Foundation

// セクションモデル
struct LegalSection: Codable {
    let title: String
    let content: String
}

// 免責事項・プライバシーポリシー・利用規約のコンテンツモデル
struct LegalContent: Codable {
    let title: String
    let introduction: String?
    let sections: [LegalSection]
    let lastUpdated: String
    
    // デフォルト値から初期化
    static func fromJSON(_ jsonString: String) -> LegalContent? {
        guard let data = jsonString.data(using: .utf8) else {
            return nil
        }
        let decoder = JSONDecoder()
        return try? decoder.decode(LegalContent.self, from: data)
    }
}

