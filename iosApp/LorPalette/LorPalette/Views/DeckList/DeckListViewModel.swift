
import Combine
import FirebaseFirestore
import Foundation
import SwiftUI

@MainActor
class DeckListViewModel: ObservableObject {
    @Published var decks: [Deck] = []
    @Published var isLoading: Bool = false
    @Published var isSaving: Bool = false

    private let firestoreManager = FirestoreManager.shared
    private var listenerRegistration: ListenerRegistration?
    private let migrationKey = "hasMigratedToFirestore"
    private let fileName = "decks.json"

    private var fileURL: URL {
        let documentsPath = FileManager.default.urls(for: .documentDirectory, in: .userDomainMask)[
            0]
        return documentsPath.appendingPathComponent(fileName)
    }

    init() {
        // 初回読み込みを先に実行
        loadInitialDecks()
        setupFirestoreListener()
        migrateLocalDataIfNeeded()
    }

    private func loadInitialDecks() {
        isLoading = true

        Task { @MainActor in
            await loadDecksOnce()
        }
    }

    private func setupFirestoreListener() {
        listenerRegistration?.remove()
        listenerRegistration = nil

        listenerRegistration = firestoreManager.observeDecks { [weak self] result in
            Task { @MainActor in
                guard let self = self else { return }

                switch result {
                case .success(let loadedDecks):
                    self.decks = loadedDecks
                    self.isLoading = false
                    print("デッキの読み込み成功: \(loadedDecks.count)個のデッキを読み込みました")
                case .failure(let error):
                    print("デッキの読み込みに失敗しました: \(error.localizedDescription)")
                    // エラー時は既存のデータを保持し、読み込み状態を解除
                    self.isLoading = false
                    // 認証エラーの場合は再試行
                    if (error as NSError).code == -1 {
                        // 少し待ってから再試行
                        try? await Task.sleep(nanoseconds: 1_000_000_000)  // 1秒待機
                        self.setupFirestoreListener()
                    }
                }
            }
        }

        // リスナーが設定されなかった場合（認証待ち）、少し待ってから再試行
        if listenerRegistration == nil {
            Task { @MainActor in
                try? await Task.sleep(nanoseconds: 1_000_000_000)  // 1秒待機
                if self.listenerRegistration == nil {
                    print("リスナーの再試行中...")
                    self.setupFirestoreListener()
                }
            }
        }
    }

    // 初回読み込み（リスナーが設定できない場合のフォールバック）
    private func loadDecksOnce() async {
        await withCheckedContinuation { continuation in
            firestoreManager.loadDecks { [weak self] result in
                Task { @MainActor in
                    guard let self = self else {
                        continuation.resume()
                        return
                    }

                    switch result {
                    case .success(let loadedDecks):
                        self.decks = loadedDecks
                        self.isLoading = false
                        print("初回読み込み成功: \(loadedDecks.count)個のデッキを読み込みました")
                    case .failure(let error):
                        print("初回読み込みに失敗しました: \(error.localizedDescription)")
                        self.isLoading = false
                    }
                    continuation.resume()
                }
            }
        }
    }

    // ローカルJSONからFirestoreへの初回移行
    private func migrateLocalDataIfNeeded() {
        // 既に移行済みの場合はスキップ
        if UserDefaults.standard.bool(forKey: migrationKey) {
            return
        }

        // ローカルJSONファイルが存在する場合のみ移行
        guard FileManager.default.fileExists(atPath: fileURL.path) else {
            UserDefaults.standard.set(true, forKey: migrationKey)
            return
        }

        Task { @MainActor in
            do {
                // ローカルJSONファイルを読み込む
                let data = try Data(contentsOf: fileURL)
                let decoder = JSONDecoder()
                decoder.dateDecodingStrategy = .iso8601
                let localDecks = try decoder.decode([Deck].self, from: data)

                print("ローカルデータの移行を開始: \(localDecks.count)個のデッキを移行します")

                // 各デッキをFirestoreに保存
                var successCount = 0
                for deck in localDecks {
                    await withCheckedContinuation { continuation in
                        firestoreManager.saveDeck(deck) { error in
                            if error == nil {
                                successCount += 1
                            }
                            continuation.resume()
                        }
                    }
                }

                print("ローカルデータの移行完了: \(successCount)/\(localDecks.count)個のデッキを移行しました")

                // 移行完了フラグを設定
                UserDefaults.standard.set(true, forKey: migrationKey)
            } catch {
                print("ローカルデータの移行に失敗しました: \(error.localizedDescription)")
            }
        }
    }

    // デッキを保存（Firestoreに保存）
    private func saveDeck(_ deck: Deck) {
        isSaving = true

        firestoreManager.saveDeck(deck) { [weak self] error in
            Task { @MainActor in
                guard let self = self else { return }
                self.isSaving = false

                if let error = error {
                    print("デッキの保存に失敗しました: \(error.localizedDescription)")
                } else {
                    print("デッキの保存成功: \(deck.id)")
                }
            }
        }
    }

    // デッキを追加
    func addDeck(_ deck: Deck) {
        AnalyticsManager.shared.logDeckAdd()
        saveDeck(deck)
    }

    // デッキを更新
    func updateDeck(_ deck: Deck) {
        saveDeck(deck)
    }

    // デッキを削除
    func deleteDeck(_ deckId: String) {
        isSaving = true

        firestoreManager.deleteDeck(deckId) { [weak self] error in
            Task { @MainActor in
                guard let self = self else { return }
                self.isSaving = false

                if let error = error {
                    print("デッキの削除に失敗しました: \(error.localizedDescription)")
                } else {
                    print("デッキの削除成功: \(deckId)")
                }
            }
        }
    }

    // デッキにカードを追加
    func addCardToDeck(_ deckId: String, card: LorcanaCard, count: Int = 1) {
        guard var deck = decks.first(where: { $0.id == deckId }) else { return }
        deck.addCard(card, count: count)
        saveDeck(deck)
    }

    // デッキからカードを削除
    func removeCardFromDeck(_ deckId: String, cardId: String) {
        guard var deck = decks.first(where: { $0.id == deckId }) else { return }
        deck.removeCard(cardId)
        saveDeck(deck)
    }

    // デッキのカード枚数を更新
    func updateCardCountInDeck(_ deckId: String, cardId: String, count: Int) {
        guard var deck = decks.first(where: { $0.id == deckId }) else { return }
        deck.updateCardCount(cardId, count: count)
        saveDeck(deck)
    }

    // 試合記録を追加
    func addMatchRecord(_ deckId: String, record: MatchRecord) {
        guard var deck = decks.first(where: { $0.id == deckId }) else { return }
        deck.addMatchRecord(record)
        saveDeck(deck)
    }

    // 試合記録を削除
    func removeMatchRecord(_ deckId: String, recordId: String) {
        guard var deck = decks.first(where: { $0.id == deckId }) else { return }
        deck.removeMatchRecord(recordId)
        saveDeck(deck)
    }

    // デッキのメモを更新
    func updateMemo(_ deckId: String, memo: String) {
        guard var deck = decks.first(where: { $0.id == deckId }) else { return }
        deck.memo = memo
        deck.updatedAt = Date()
        saveDeck(deck)
    }

    // デッキリストを手動でリフレッシュ
    func refreshDecks() async {
        isLoading = true

        await withCheckedContinuation { continuation in
            firestoreManager.loadDecks { [weak self] result in
                Task { @MainActor in
                    guard let self = self else {
                        continuation.resume()
                        return
                    }
                    self.isLoading = false

                    switch result {
                    case .success(let loadedDecks):
                        self.decks = loadedDecks
                        print("デッキのリフレッシュ成功: \(loadedDecks.count)個のデッキを読み込みました")
                    case .failure(let error):
                        print("デッキのリフレッシュに失敗しました: \(error.localizedDescription)")
                    }
                    continuation.resume()
                }
            }
        }
    }

    deinit {
        listenerRegistration?.remove()
    }
}
