
import Foundation

struct ResourceManager {
    private static let defaultNewsURL = "https://www.takaratomy.co.jp/products/disneylorcana/news/"

    static func newsURL() -> String {
        if let urlString = Bundle.main.infoDictionary?["NewsURL"] as? String,
            !urlString.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty
        {
            return urlString.trimmingCharacters(in: .whitespacesAndNewlines)
        }
        return defaultNewsURL
    }
}
