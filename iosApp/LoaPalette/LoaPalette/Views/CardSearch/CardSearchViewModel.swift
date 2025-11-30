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
    private var updateTimer: Timer?
    
    init() {
        startPolling()
    }
    
    // 状態を定期的にポーリング（将来的にKotlin側のViewModelと同期するため）
    private func startPolling() {
        // 現在は不要だが、将来的にKotlin側のViewModelと同期する際に使用
    }
    
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
        updateTimer?.invalidate()
        updateTimer = nil
        searchTask?.cancel()
        searchTask = nil
    }
    
    deinit {
        updateTimer?.invalidate()
        updateTimer = nil
        searchTask?.cancel()
        searchTask = nil
    }
    
    // API呼び出し
    // 参考: https://lorcana-api.com/docs/cards/fetching-cards/
    private func performSearch(query: String) async {
        // 全カードを取得してクライアント側でフィルタリング
        await performLoadAllCards()
        // クライアント側でフィルタリング
        let filteredCards = cards.filter { card in
            guard let name = card.name?.lowercased() else { return false }
            return name.contains(query.lowercased())
        }
        self.cards = filteredCards
        self.searchState = .success
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
            
            // デバッグ用: レスポンスの最初の部分を確認
            if let responseString = String(data: data, encoding: .utf8) {
                print("API Response (first 500 chars): \(String(responseString.prefix(500)))")
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
    
    static func fromString(_ string: String) -> SearchState {
        return SearchState(rawValue: string) ?? .idle
    }
}
