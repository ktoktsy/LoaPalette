//
//  DeckListViewModel.swift
//  LoaPalette
//
//  Created by 片岡寿哉 on 2025/11/28.
//

import Combine
import Foundation
import SwiftUI

// デッキリスト管理ViewModel
// JSON保存/読み込み機能を含む
// 参考: https://developer.apple.com/documentation/foundation/filemanager
@MainActor
class DeckListViewModel: ObservableObject {
    @Published var decks: [Deck] = []
    @Published var isLoading: Bool = false
    @Published var isSaving: Bool = false

    private let fileName = "decks.json"
    private var fileURL: URL {
        let documentsPath = FileManager.default.urls(for: .documentDirectory, in: .userDomainMask)[
            0]
        return documentsPath.appendingPathComponent(fileName)
    }

    private var loadTask: Task<Void, Never>?
    private var saveTask: Task<Void, Never>?

    init() {
        loadDecks()
    }

    // JSONファイルからデッキを読み込む（非同期）
    func loadDecks() {
        loadTask?.cancel()
        isLoading = true

        loadTask = Task { @MainActor in
            defer { isLoading = false }

            guard FileManager.default.fileExists(atPath: fileURL.path) else {
                decks = []
                return
            }

            do {
                let url = fileURL
                // ファイル読み込みをバックグラウンドスレッドで実行
                let data = try await Task.detached(priority: .userInitiated) {
                    try Data(contentsOf: url)
                }.value

                // デコード処理もバックグラウンドスレッドで実行
                let loadedDecks: [Deck] = try await Task.detached(priority: .userInitiated) {
                    let decoder = JSONDecoder()
                    decoder.dateDecodingStrategy = .iso8601
                    return try decoder.decode([Deck].self, from: data)
                }.value

                decks = loadedDecks
                print("デッキの読み込み成功: \(decks.count)個のデッキを読み込みました")
            } catch {
                print("デッキの読み込みに失敗しました: \(error.localizedDescription)")
                if let decodingError = error as? DecodingError {
                    print("デコードエラーの詳細: \(decodingError)")
                }
                decks = []
            }
        }
    }

    // JSONファイルにデッキを保存（非同期）
    func saveDecks() {
        saveTask?.cancel()
        isSaving = true

        saveTask = Task { @MainActor in
            defer { isSaving = false }

            do {
                let currentDecks = decks
                let url = fileURL
                // エンコード処理をバックグラウンドスレッドで実行
                let data = try await Task.detached(priority: .userInitiated) {
                    let encoder = JSONEncoder()
                    encoder.dateEncodingStrategy = .iso8601
                    encoder.outputFormatting = [.prettyPrinted, .sortedKeys]
                    return try encoder.encode(currentDecks)
                }.value

                // ファイル書き込みをバックグラウンドスレッドで実行
                try await Task.detached(priority: .userInitiated) {
                    try data.write(to: url, options: Data.WritingOptions.atomic)
                }.value

                print("デッキの保存成功: \(decks.count)個のデッキを保存しました（\(fileURL.path)）")
            } catch {
                print("デッキの保存に失敗しました: \(error.localizedDescription)")
                if let encodingError = error as? EncodingError {
                    print("エンコードエラーの詳細: \(encodingError)")
                }
            }
        }
    }

    // デッキを追加
    func addDeck(_ deck: Deck) {
        AnalyticsManager.shared.logDeckAdd()
        decks.append(deck)
        saveDecks()
    }

    // デッキを更新
    func updateDeck(_ deck: Deck) {
        if let index = decks.firstIndex(where: { $0.id == deck.id }) {
            decks[index] = deck
            saveDecks()
        }
    }

    // デッキを削除
    func deleteDeck(_ deckId: String) {
        decks.removeAll { $0.id == deckId }
        saveDecks()
    }

    // デッキにカードを追加
    func addCardToDeck(_ deckId: String, card: LorcanaCard, count: Int = 1) {
        if let index = decks.firstIndex(where: { $0.id == deckId }) {
            decks[index].addCard(card, count: count)
            saveDecks()
        }
    }

    // デッキからカードを削除
    func removeCardFromDeck(_ deckId: String, cardId: String) {
        if let index = decks.firstIndex(where: { $0.id == deckId }) {
            decks[index].removeCard(cardId)
            saveDecks()
        }
    }

    // デッキのカード枚数を更新
    func updateCardCountInDeck(_ deckId: String, cardId: String, count: Int) {
        if let index = decks.firstIndex(where: { $0.id == deckId }) {
            decks[index].updateCardCount(cardId, count: count)
            saveDecks()
        }
    }

    // 試合記録を追加
    func addMatchRecord(_ deckId: String, record: MatchRecord) {
        if let index = decks.firstIndex(where: { $0.id == deckId }) {
            decks[index].addMatchRecord(record)
            saveDecks()
        }
    }

    // 試合記録を削除
    func removeMatchRecord(_ deckId: String, recordId: String) {
        if let index = decks.firstIndex(where: { $0.id == deckId }) {
            decks[index].removeMatchRecord(recordId)
            saveDecks()
        }
    }

    // デッキのメモを更新
    func updateMemo(_ deckId: String, memo: String) {
        if let index = decks.firstIndex(where: { $0.id == deckId }) {
            decks[index].memo = memo
            decks[index].updatedAt = Date()
            saveDecks()
        }
    }

    deinit {
        loadTask?.cancel()
        saveTask?.cancel()
    }
}
