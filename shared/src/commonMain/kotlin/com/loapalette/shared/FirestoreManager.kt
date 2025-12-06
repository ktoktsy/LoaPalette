package com.loapalette.shared

import kotlinx.coroutines.flow.Flow

/**
 * Firestoreの共通処理を管理するクラス
 * 参考: https://firebase.google.com/docs/firestore
 */
expect class FirestoreManager {
    companion object {
        val shared: FirestoreManager
    }
    
    /**
     * デッキを保存
     * @param deck 保存するデッキ
     * @param onComplete 完了時のコールバック（成功: null, 失敗: Throwable）
     */
    fun saveDeck(deck: Deck, onComplete: ((Throwable?) -> Unit)? = null)
    
    /**
     * すべてのデッキを読み込む
     * @param onComplete 完了時のコールバック（成功: List<Deck>, 失敗: Throwable）
     */
    fun loadDecks(onComplete: (Result<List<Deck>>) -> Unit)
    
    /**
     * デッキを削除
     * @param deckId 削除するデッキのID
     * @param onComplete 完了時のコールバック（成功: null, 失敗: Throwable）
     */
    fun deleteDeck(deckId: String, onComplete: ((Throwable?) -> Unit)? = null)
    
    /**
     * デッキの変更を監視（リアルタイム更新）
     * @return デッキリストのFlow
     */
    fun observeDecks(): Flow<Result<List<Deck>>>
}

