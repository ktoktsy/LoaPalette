//
//  CardSearchViewModel.swift
//  LoaPalette
//
//  Created by 片岡寿哉 on 2025/11/28.
//

import Combine
import SwiftUI

// 一時的な回避策: Kotlin側のクラスが認識されるまで、Swift側で完全に実装
// 参考: https://api-lorcana.com/#/Cards/get%20cards
@MainActor
class CardSearchViewModel: ObservableObject {
    @Published var cards: [LorcanaCard] = []
    @Published var searchState: SearchState = .idle
    @Published var errorMessage: String? = nil
    @Published var searchQuery: String = ""
    @Published var isLoadingMore: Bool = false
    @Published var hasMore: Bool = true

    private var searchTask: Task<Void, Never>?
    private var currentPage = 1
    private var currentSearchQuery: String? = nil
    private let pageSize = 20

    func search(query: String) {
        searchQuery = query
        searchTask?.cancel()

        // 新しい検索の場合はリセット
        if currentSearchQuery != query {
            currentPage = 1
            currentSearchQuery = query
            hasMore = true
        }

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

            await performSearch(query: query, page: currentPage)
        }
    }

    func loadAllCards() {
        // 新しい検索の場合はリセット
        currentPage = 1
        currentSearchQuery = nil
        hasMore = true

        searchState = .loading
        errorMessage = nil

        searchTask = Task { @MainActor in
            await performLoadAllCards(page: currentPage)
        }
    }

    func loadMore() {
        if isLoadingMore || !hasMore {
            return
        }

        currentPage += 1
        isLoadingMore = true

        Task { @MainActor in
            let query = currentSearchQuery ?? ""
            if query.isEmpty {
                await performLoadAllCards(page: currentPage)
            } else {
                await performSearch(query: query, page: currentPage)
            }
        }
    }

    func clear() {
        searchTask?.cancel()
        cards = []
        searchQuery = ""
        searchState = .idle
        errorMessage = nil
        currentPage = 1
        currentSearchQuery = nil
        hasMore = true
        isLoadingMore = false
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
    // API仕様: https://api-lorcana.com/#/Cards/get%20cards
    private func performSearch(query: String, page: Int) async {
        // api-lorcana.comのエンドポイントを使用
        guard var urlComponents = URLComponents(string: "https://api-lorcana.com/cards")
        else {
            errorMessage = "無効なURLです"
            searchState = .error
            if page == 1 {
                cards = []
            } else {
                isLoadingMore = false
                currentPage -= 1
            }
            return
        }

        // 検索パラメータを追加
        var queryItems: [URLQueryItem] = [
            URLQueryItem(name: "limit", value: "\(pageSize)"),
            URLQueryItem(name: "page", value: "\(page)"),
        ]

        // 検索クエリが空でない場合は追加
        if !query.isEmpty {
            queryItems.append(URLQueryItem(name: "search", value: query))
        }

        urlComponents.queryItems = queryItems

        guard let url = urlComponents.url else {
            errorMessage = "無効なURLです"
            searchState = .error
            if page == 1 {
                cards = []
            } else {
                isLoadingMore = false
                currentPage -= 1
            }
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
                    if page == 1 {
                        cards = []
                    } else {
                        isLoadingMore = false
                        currentPage -= 1
                    }
                    return
                }
            }

            let decoder = JSONDecoder()

            // エラーレスポンスかどうかを確認
            if let errorResponse = try? decoder.decode(APIError.self, from: data) {
                self.errorMessage = "APIエラー: \(errorResponse.details)"
                self.searchState = .error
                if page == 1 {
                    self.cards = []
                } else {
                    self.isLoadingMore = false
                    self.currentPage -= 1
                }
                return
            }

            // APIは直接カードの配列を返す
            let newCards = try decoder.decode([LorcanaCard].self, from: data)
            if page == 1 {
                self.cards = newCards
            } else {
                self.cards.append(contentsOf: newCards)
                self.isLoadingMore = false
            }
            self.hasMore = newCards.count >= pageSize
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
            if page == 1 {
                self.cards = []
            } else {
                self.isLoadingMore = false
                self.currentPage -= 1
            }
        } catch {
            self.errorMessage = "エラー: \(error.localizedDescription)"
            self.searchState = .error
            if page == 1 {
                self.cards = []
            } else {
                self.isLoadingMore = false
                self.currentPage -= 1
            }
        }
    }

    private func performLoadAllCards(page: Int) async {
        // api-lorcana.comのエンドポイントを使用
        guard var urlComponents = URLComponents(string: "https://api-lorcana.com/cards") else {
            errorMessage = "無効なURLです"
            searchState = .error
            if page == 1 {
                cards = []
            } else {
                isLoadingMore = false
                currentPage -= 1
            }
            return
        }

        urlComponents.queryItems = [
            URLQueryItem(name: "limit", value: "\(pageSize)"),
            URLQueryItem(name: "page", value: "\(page)"),
        ]

        guard let url = urlComponents.url else {
            errorMessage = "無効なURLです"
            searchState = .error
            if page == 1 {
                cards = []
            } else {
                isLoadingMore = false
                currentPage -= 1
            }
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
                    if page == 1 {
                        cards = []
                    } else {
                        isLoadingMore = false
                        currentPage -= 1
                    }
                    return
                }
            }

            let decoder = JSONDecoder()

            // エラーレスポンスかどうかを確認
            if let errorResponse = try? decoder.decode(APIError.self, from: data) {
                self.errorMessage = "APIエラー: \(errorResponse.details)"
                self.searchState = .error
                if page == 1 {
                    self.cards = []
                } else {
                    self.isLoadingMore = false
                    self.currentPage -= 1
                }
                return
            }

            // APIは直接カードの配列を返す
            let newCards = try decoder.decode([LorcanaCard].self, from: data)
            if page == 1 {
                self.cards = newCards
            } else {
                self.cards.append(contentsOf: newCards)
                self.isLoadingMore = false
            }
            self.hasMore = newCards.count >= pageSize
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
            if page == 1 {
                self.cards = []
            } else {
                self.isLoadingMore = false
                self.currentPage -= 1
            }
        } catch {
            self.errorMessage = "エラー: \(error.localizedDescription)"
            self.searchState = .error
            if page == 1 {
                self.cards = []
            } else {
                self.isLoadingMore = false
                self.currentPage -= 1
            }
        }
    }
}
