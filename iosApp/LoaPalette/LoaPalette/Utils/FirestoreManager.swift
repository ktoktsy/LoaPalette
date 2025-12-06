//
//  FirestoreManager.swift
//  LoaPalette
//
//  Created by Auto on 2025/01/XX.
//

import FirebaseFirestore
import FirebaseAuth
import Foundation

/// Firestoreの共通処理を管理するクラス
/// 参考: https://firebase.google.com/docs/firestore/ios/start
class FirestoreManager {
    static let shared = FirestoreManager()
    
    private let db: Firestore
    private var userId: String?
    private var authCompletionHandlers: [(String?) -> Void] = []
    
    private init() {
        db = Firestore.firestore()
        // 匿名認証でユーザーを識別
        authenticateAnonymously()
    }
    
    /// 匿名認証を実行してユーザーIDを取得
    /// 参考: https://firebase.google.com/docs/auth/ios/anonymous-auth
    private func authenticateAnonymously() {
        // 既に認証済みの場合はそのUIDを使用
        if let user = Auth.auth().currentUser {
            userId = user.uid
            print("既存の認証ユーザー: \(user.uid)")
            // 待機中のハンドラーを実行
            authCompletionHandlers.forEach { $0(user.uid) }
            authCompletionHandlers.removeAll()
            return
        }
        
        Auth.auth().signInAnonymously { [weak self] result, error in
            guard let self = self else { return }
            
            if let error = error {
                print("匿名認証エラー: \(error.localizedDescription)")
                // エラー時も待機中のハンドラーを実行（nilを渡す）
                self.authCompletionHandlers.forEach { $0(nil) }
                self.authCompletionHandlers.removeAll()
                return
            }
            
            if let user = result?.user {
                self.userId = user.uid
                print("匿名認証成功: \(user.uid)")
                // 待機中のハンドラーを実行
                self.authCompletionHandlers.forEach { $0(user.uid) }
                self.authCompletionHandlers.removeAll()
            }
        }
    }
    
    /// 認証完了を待つ
    /// - Parameter completion: 認証完了時のコールバック（ユーザーID、失敗時はnil）
    private func waitForAuthentication(completion: @escaping (String?) -> Void) {
        // 既に認証済みの場合は即座に実行
        if let userId = userId {
            completion(userId)
            return
        }
        
        if let user = Auth.auth().currentUser {
            userId = user.uid
            completion(user.uid)
            return
        }
        
        // 認証が完了していない場合は待機
        authCompletionHandlers.append(completion)
    }
    
    /// ユーザーIDを取得（認証が完了していない場合はnil）
    private func getUserId() -> String? {
        if let userId = userId {
            return userId
        }
        // 既に認証済みの場合はそのUIDを使用
        if let user = Auth.auth().currentUser {
            userId = user.uid
            return user.uid
        }
        return nil
    }
    
    /// デッキコレクションの参照を取得
    private func decksCollection() -> CollectionReference? {
        guard let userId = getUserId() else {
            print("ユーザーIDが取得できません")
            return nil
        }
        return db.collection("users").document(userId).collection("decks")
    }
    
    /// デッキを保存
    /// - Parameters:
    ///   - deck: 保存するデッキ
    ///   - completion: 完了時のコールバック（成功: nil, 失敗: Error）
    func saveDeck(_ deck: Deck, completion: ((Error?) -> Void)? = nil) {
        waitForAuthentication { [weak self] userId in
            guard let self = self, let userId = userId else {
                completion?(NSError(domain: "FirestoreManager", code: -1, userInfo: [NSLocalizedDescriptionKey: "ユーザーIDが取得できません"]))
                return
            }
            
            let collection = self.db.collection("users").document(userId).collection("decks")
            
            do {
                let encoder = JSONEncoder()
                encoder.dateEncodingStrategy = .iso8601
                let data = try encoder.encode(deck)
                guard var dictionary = try JSONSerialization.jsonObject(with: data) as? [String: Any] else {
                    completion?(NSError(domain: "FirestoreManager", code: -2, userInfo: [NSLocalizedDescriptionKey: "デッキのエンコードに失敗しました"]))
                    return
                }
                
                // Date型をTimestamp型に変換
                if let createdAtString = dictionary["createdAt"] as? String,
                   let createdAt = ISO8601DateFormatter().date(from: createdAtString) {
                    dictionary["createdAt"] = Timestamp(date: createdAt)
                }
                if let updatedAtString = dictionary["updatedAt"] as? String,
                   let updatedAt = ISO8601DateFormatter().date(from: updatedAtString) {
                    dictionary["updatedAt"] = Timestamp(date: updatedAt)
                }
                
                // matchRecords内のplayedAtも変換
                if var matchRecords = dictionary["matchRecords"] as? [[String: Any]] {
                    for i in 0..<matchRecords.count {
                        if let playedAtString = matchRecords[i]["playedAt"] as? String,
                           let playedAt = ISO8601DateFormatter().date(from: playedAtString) {
                            matchRecords[i]["playedAt"] = Timestamp(date: playedAt)
                        }
                    }
                    dictionary["matchRecords"] = matchRecords
                }
                
                collection.document(deck.id).setData(dictionary) { error in
                    if let error = error {
                        print("デッキの保存エラー: \(error.localizedDescription)")
                        completion?(error)
                    } else {
                        print("デッキの保存成功: \(deck.id)")
                        completion?(nil)
                    }
                }
            } catch {
                print("デッキのエンコードエラー: \(error.localizedDescription)")
                completion?(error)
            }
        }
    }
    
    /// すべてのデッキを読み込む
    /// - Parameter completion: 完了時のコールバック（成功: [Deck], 失敗: Error）
    func loadDecks(completion: @escaping (Result<[Deck], Error>) -> Void) {
        waitForAuthentication { [weak self] userId in
            guard let self = self, let userId = userId else {
                completion(.failure(NSError(domain: "FirestoreManager", code: -1, userInfo: [NSLocalizedDescriptionKey: "ユーザーIDが取得できません"])))
                return
            }
            
            let collection = self.db.collection("users").document(userId).collection("decks")
            
            collection.getDocuments { snapshot, error in
                if let error = error {
                    print("デッキの読み込みエラー: \(error.localizedDescription)")
                    completion(.failure(error))
                    return
                }
                
                guard let documents = snapshot?.documents else {
                    completion(.success([]))
                    return
                }
                
                var decks: [Deck] = []
                let decoder = JSONDecoder()
                decoder.dateDecodingStrategy = .iso8601
                
                for document in documents {
                    do {
                        var data = document.data()
                        // Timestamp型をISO8601文字列に変換
                        if let createdAt = data["createdAt"] as? Timestamp {
                            data["createdAt"] = ISO8601DateFormatter().string(from: createdAt.dateValue())
                        }
                        if let updatedAt = data["updatedAt"] as? Timestamp {
                            data["updatedAt"] = ISO8601DateFormatter().string(from: updatedAt.dateValue())
                        }
                        // matchRecords内のplayedAtも変換
                        if var matchRecords = data["matchRecords"] as? [[String: Any]] {
                            for i in 0..<matchRecords.count {
                                if let playedAt = matchRecords[i]["playedAt"] as? Timestamp {
                                    matchRecords[i]["playedAt"] = ISO8601DateFormatter().string(from: playedAt.dateValue())
                                }
                            }
                            data["matchRecords"] = matchRecords
                        }
                        
                        let jsonData = try JSONSerialization.data(withJSONObject: data)
                        let deck = try decoder.decode(Deck.self, from: jsonData)
                        decks.append(deck)
                    } catch {
                        print("デッキのデコードエラー (\(document.documentID): \(error.localizedDescription)")
                    }
                }
                
                print("デッキの読み込み成功: \(decks.count)個のデッキを読み込みました")
                completion(.success(decks))
            }
        }
    }
    
    /// デッキを削除
    /// - Parameters:
    ///   - deckId: 削除するデッキのID
    ///   - completion: 完了時のコールバック（成功: nil, 失敗: Error）
    func deleteDeck(_ deckId: String, completion: ((Error?) -> Void)? = nil) {
        waitForAuthentication { [weak self] userId in
            guard let self = self, let userId = userId else {
                completion?(NSError(domain: "FirestoreManager", code: -1, userInfo: [NSLocalizedDescriptionKey: "ユーザーIDが取得できません"]))
                return
            }
            
            let collection = self.db.collection("users").document(userId).collection("decks")
            
            collection.document(deckId).delete { error in
                if let error = error {
                    print("デッキの削除エラー: \(error.localizedDescription)")
                    completion?(error)
                } else {
                    print("デッキの削除成功: \(deckId)")
                    completion?(nil)
                }
            }
        }
    }
    
    /// デッキの変更を監視（リアルタイム更新）
    /// - Parameter completion: 変更時のコールバック（成功: [Deck], 失敗: Error）
    /// - Returns: リスナーの登録解除用のリスナー
    func observeDecks(completion: @escaping (Result<[Deck], Error>) -> Void) -> ListenerRegistration? {
        // 既に認証済みの場合は即座にリスナーを設定
        if let userId = userId ?? Auth.auth().currentUser?.uid {
            let collection = db.collection("users").document(userId).collection("decks")
            return setupSnapshotListener(collection: collection, completion: completion)
        }
        
        // 認証が完了していない場合は、認証完了後にリスナーを設定
        // 注意: この場合、リスナーは非同期で設定されるため、nilが返される可能性がある
        // DeckListViewModel側で再試行する必要がある
        waitForAuthentication { [weak self] userId in
            guard let self = self, let userId = userId else {
                completion(.failure(NSError(domain: "FirestoreManager", code: -1, userInfo: [NSLocalizedDescriptionKey: "ユーザーIDが取得できません"])))
                return
            }
            
            let collection = self.db.collection("users").document(userId).collection("decks")
            _ = self.setupSnapshotListener(collection: collection, completion: completion)
        }
        
        // 認証待ちの場合はnilを返す（DeckListViewModel側で再試行）
        return nil
    }
    
    /// スナップショットリスナーを設定
    private func setupSnapshotListener(collection: CollectionReference, completion: @escaping (Result<[Deck], Error>) -> Void) -> ListenerRegistration {
        return collection.addSnapshotListener { snapshot, error in
            if let error = error {
                print("デッキの監視エラー: \(error.localizedDescription)")
                completion(.failure(error))
                return
            }
            
            guard let documents = snapshot?.documents else {
                completion(.success([]))
                return
            }
            
            var decks: [Deck] = []
            let decoder = JSONDecoder()
            decoder.dateDecodingStrategy = .iso8601
            
            for document in documents {
                do {
                    var data = document.data()
                    // Timestamp型をISO8601文字列に変換
                    if let createdAt = data["createdAt"] as? Timestamp {
                        data["createdAt"] = ISO8601DateFormatter().string(from: createdAt.dateValue())
                    }
                    if let updatedAt = data["updatedAt"] as? Timestamp {
                        data["updatedAt"] = ISO8601DateFormatter().string(from: updatedAt.dateValue())
                    }
                    // matchRecords内のplayedAtも変換
                    if var matchRecords = data["matchRecords"] as? [[String: Any]] {
                        for i in 0..<matchRecords.count {
                            if let playedAt = matchRecords[i]["playedAt"] as? Timestamp {
                                matchRecords[i]["playedAt"] = ISO8601DateFormatter().string(from: playedAt.dateValue())
                            }
                        }
                        data["matchRecords"] = matchRecords
                    }
                    
                    let jsonData = try JSONSerialization.data(withJSONObject: data)
                    let deck = try decoder.decode(Deck.self, from: jsonData)
                    decks.append(deck)
                } catch {
                    print("デッキのデコードエラー (\(document.documentID): \(error.localizedDescription)")
                }
            }
            
            print("デッキの更新を検知: \(decks.count)個のデッキ")
            completion(.success(decks))
        }
    }
}
