import Foundation

struct LegalSection: Codable {
    let title: String
    let content: String
}

struct LegalContent: Codable {
    let title: String
    let introduction: String?
    let sections: [LegalSection]
    let lastUpdated: String
    
    static func fromJSON(_ jsonString: String) -> LegalContent? {
        guard let data = jsonString.data(using: .utf8) else {
            return nil
        }
        let decoder = JSONDecoder()
        return try? decoder.decode(LegalContent.self, from: data)
    }
}