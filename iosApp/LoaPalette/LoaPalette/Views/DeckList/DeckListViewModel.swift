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

    private let fileName = "decks.json"
    private var fileURL: URL {
        let documentsPath = FileManager.default.urls(for: .documentDirectory, in: .userDomainMask)[
            0]
        return documentsPath.appendingPathComponent(fileName)
    }

    init() {
        loadDecks()
    }

    // JSONファイルからデッキを読み込む
    func loadDecks() {
        guard FileManager.default.fileExists(atPath: fileURL.path) else {
            decks = []
            return
        }

        do {
            let data = try Data(contentsOf: fileURL)
            let decoder = JSONDecoder()
            decoder.dateDecodingStrategy = .iso8601
            let loadedDecks = try decoder.decode([Deck].self, from: data)
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

    // JSONファイルにデッキを保存
    func saveDecks() {
        do {
            let encoder = JSONEncoder()
            encoder.dateEncodingStrategy = .iso8601
            encoder.outputFormatting = [.prettyPrinted, .sortedKeys]
            let data = try encoder.encode(decks)
            try data.write(to: fileURL, options: .atomic)
            print("デッキの保存成功: \(decks.count)個のデッキを保存しました（\(fileURL.path)）")
        } catch {
            print("デッキの保存に失敗しました: \(error.localizedDescription)")
            if let encodingError = error as? EncodingError {
                print("エンコードエラーの詳細: \(encodingError)")
            }
        }
    }

    // デッキを追加
    func addDeck(_ deck: Deck) {
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
}
