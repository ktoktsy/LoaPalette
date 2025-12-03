//
//  CardSearchViewModel.swift
//  LoaPalette
//
//  Created by 片岡寿哉 on 2025/11/28.
//

import Combine
import SwiftUI

// 一時的な回避策: Kotlin側のクラスが認識されるまで、Swift側で完全に実装
// 参考: https://lorcana-api.com/docs/intro/
@MainActor
class CardSearchViewModel: ObservableObject {
    @Published var cards: [LorcanaCard] = []
    @Published var searchState: SearchState = .idle
    @Published var errorMessage: String? = nil
    @Published var searchQuery: String = ""

    private var searchTask: Task<Void, Never>?

    func search(query: String) {
        searchQuery = query
        searchTask?.cancel()

        if query.isEmpty {
            cards = []
            searchState = .idle
            return
        }

        searchState = .loading
        errorMessage = nil

        searchTask = Task { @MainActor in
            // デバウンス処理（500ms待機）
            try? await Task.sleep(nanoseconds: 500_000_000)

            await performSearch(query: query)
        }
    }

    func loadAllCards() {
        searchState = .loading
        errorMessage = nil

        searchTask = Task { @MainActor in
            await performLoadAllCards()
        }
    }

    func clear() {
        searchTask?.cancel()
        cards = []
        searchQuery = ""
        searchState = .idle
        errorMessage = nil
    }

    func cleanup() {
        searchTask?.cancel()
        searchTask = nil
    }

    deinit {
        searchTask?.cancel()
        searchTask = nil
    }

    // API呼び出し
    // API仕様: https://lorcana-api.com/docs/cards/parameters/search-parameter
    private func performSearch(query: String) async {
        // APIのsearchパラメータを使用してサーバー側でフィルタリング.
        // クエリは既にAPI仕様に従った形式（例: name~text;cost>=3;color~amber）で構築されている.
        guard var urlComponents = URLComponents(string: "https://api.lorcana-api.com/cards/fetch")
        else {
            errorMessage = "無効なURLです"
            searchState = .error
            return
        }

        // searchパラメータを追加
        urlComponents.queryItems = [
            URLQueryItem(name: "search", value: query)
        ]

        guard let url = urlComponents.url else {
            errorMessage = "無効なURLです"
            searchState = .error
            return
        }

        do {
            var request = URLRequest(url: url)
            request.setValue("application/json", forHTTPHeaderField: "Accept")
            request.setValue("UTF-8", forHTTPHeaderField: "Accept-Charset")

            let (data, response) = try await URLSession.shared.data(for: request)

            // HTTPステータスコードを確認
            if let httpResponse = response as? HTTPURLResponse {
                guard (200...299).contains(httpResponse.statusCode) else {
                    errorMessage = "サーバーエラー: \(httpResponse.statusCode)"
                    searchState = .error
                    return
                }
            }

            let decoder = JSONDecoder()

            // エラーレスポンスかどうかを確認
            if let errorResponse = try? decoder.decode(APIError.self, from: data) {
                self.errorMessage = "APIエラー: \(errorResponse.details)"
                self.searchState = .error
                self.cards = []
                return
            }

            // APIは直接カードの配列を返す
            let cards = try decoder.decode([LorcanaCard].self, from: data)
            self.cards = cards
            self.searchState = .success
        } catch let decodingError as DecodingError {
            // デコードエラーの詳細を表示
            var errorDescription = "データのフォーマットが正しくありません"
            switch decodingError {
            case .typeMismatch(let type, let context):
                errorDescription = "型の不一致: \(type) - \(context.debugDescription)"
            case .valueNotFound(let type, let context):
                errorDescription = "値が見つかりません: \(type) - \(context.debugDescription)"
            case .keyNotFound(let key, let context):
                errorDescription = "キーが見つかりません: \(key.stringValue) - \(context.debugDescription)"
            case .dataCorrupted(let context):
                errorDescription = "データが破損しています: \(context.debugDescription)"
            @unknown default:
                errorDescription = "デコードエラー: \(decodingError.localizedDescription)"
            }
            self.errorMessage = errorDescription
            self.searchState = .error
            self.cards = []
        } catch {
            self.errorMessage = "エラー: \(error.localizedDescription)"
            self.searchState = .error
            self.cards = []
        }
    }

    private func performLoadAllCards() async {
        guard let url = URL(string: "https://api.lorcana-api.com/cards/all") else {
            errorMessage = "無効なURLです"
            searchState = .error
            return
        }

        do {
            var request = URLRequest(url: url)
            request.setValue("application/json", forHTTPHeaderField: "Accept")
            request.setValue("UTF-8", forHTTPHeaderField: "Accept-Charset")

            let (data, response) = try await URLSession.shared.data(for: request)

            // HTTPステータスコードを確認
            if let httpResponse = response as? HTTPURLResponse {
                guard (200...299).contains(httpResponse.statusCode) else {
                    errorMessage = "サーバーエラー: \(httpResponse.statusCode)"
                    searchState = .error
                    return
                }
            }

            let decoder = JSONDecoder()

            // エラーレスポンスかどうかを確認
            if let errorResponse = try? decoder.decode(APIError.self, from: data) {
                self.errorMessage = "APIエラー: \(errorResponse.details)"
                self.searchState = .error
                self.cards = []
                return
            }

            // APIは直接カードの配列を返す
            let cards = try decoder.decode([LorcanaCard].self, from: data)
            self.cards = cards
            self.searchState = .success
        } catch let decodingError as DecodingError {
            // デコードエラーの詳細を表示
            var errorDescription = "データのフォーマットが正しくありません"
            switch decodingError {
            case .typeMismatch(let type, let context):
                errorDescription = "型の不一致: \(type) - \(context.debugDescription)"
            case .valueNotFound(let type, let context):
                errorDescription = "値が見つかりません: \(type) - \(context.debugDescription)"
            case .keyNotFound(let key, let context):
                errorDescription = "キーが見つかりません: \(key.stringValue) - \(context.debugDescription)"
            case .dataCorrupted(let context):
                errorDescription = "データが破損しています: \(context.debugDescription)"
            @unknown default:
                errorDescription = "デコードエラー: \(decodingError.localizedDescription)"
            }
            self.errorMessage = errorDescription
            self.searchState = .error
            self.cards = []
        } catch {
            self.errorMessage = "エラー: \(error.localizedDescription)"
            self.searchState = .error
            self.cards = []
        }
    }
}

// カードデータモデル
// 参考: https://lorcana-api.com/docs/intro/
struct LorcanaCard: Codable, Identifiable {
    private let cardId: String?
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
