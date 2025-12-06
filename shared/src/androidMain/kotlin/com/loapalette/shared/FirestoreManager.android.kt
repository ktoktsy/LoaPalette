package com.loapalette.shared

import com.google.firebase.auth.FirebaseAuth
import com.google.firebase.firestore.FirebaseFirestore
import com.google.firebase.firestore.ListenerRegistration
import kotlinx.coroutines.channels.awaitClose
import kotlinx.coroutines.flow.Flow
import kotlinx.coroutines.flow.callbackFlow
import kotlinx.serialization.encodeToString
import kotlinx.serialization.json.Json
import kotlinx.serialization.json.JsonObject
import kotlinx.serialization.json.buildJsonObject
import kotlinx.serialization.json.put
import java.util.UUID

/**
 * FirestoreのAndroid実装
 * 参考: https://firebase.google.com/docs/firestore/android/start
 */
actual class FirestoreManager private constructor() {
    private val db: FirebaseFirestore = FirebaseFirestore.getInstance()
    private var userId: String? = null
    private val authCompletionHandlers = mutableListOf<(String?) -> Unit>()
    
    actual companion object {
        @Volatile
        private var INSTANCE: FirestoreManager? = null
        
        actual val shared: FirestoreManager
            get() {
                return INSTANCE ?: synchronized(this) {
                    INSTANCE ?: FirestoreManager().also {
                        INSTANCE = it
                        it.authenticateAnonymously()
                    }
                }
            }
    }
    
    init {
        authenticateAnonymously()
    }
    
    /**
     * 匿名認証を実行してユーザーIDを取得
     * 参考: https://firebase.google.com/docs/auth/android/anonymous-auth
     */
    private fun authenticateAnonymously() {
        val auth = FirebaseAuth.getInstance()
        val currentUser = auth.currentUser
        
        // 既に認証済みの場合はそのUIDを使用
        if (currentUser != null) {
            userId = currentUser.uid
            println("既存の認証ユーザー: ${currentUser.uid}")
            // 待機中のハンドラーを実行
            authCompletionHandlers.forEach { it(currentUser.uid) }
            authCompletionHandlers.clear()
            return
        }
        
        auth.signInAnonymously()
            .addOnCompleteListener { task ->
                if (task.isSuccessful) {
                    val user = task.result?.user
                    userId = user?.uid
                    println("匿名認証成功: ${user?.uid}")
                    // 待機中のハンドラーを実行
                    authCompletionHandlers.forEach { it(user?.uid) }
                    authCompletionHandlers.clear()
                } else {
                    val error = task.exception
                    println("匿名認証エラー: ${error?.message}")
                    // エラー時も待機中のハンドラーを実行（nullを渡す）
                    authCompletionHandlers.forEach { it(null) }
                    authCompletionHandlers.clear()
                }
            }
    }
    
    /**
     * 認証完了を待つ
     */
    private fun waitForAuthentication(completion: (String?) -> Unit) {
        // 既に認証済みの場合は即座に実行
        if (userId != null) {
            completion(userId)
            return
        }
        
        val currentUser = FirebaseAuth.getInstance().currentUser
        if (currentUser != null) {
            userId = currentUser.uid
            completion(currentUser.uid)
            return
        }
        
        // 認証が完了していない場合は待機
        authCompletionHandlers.add(completion)
    }
    
    /**
     * ユーザーIDを取得（認証が完了していない場合はnull）
     */
    private fun getUserId(): String? {
        if (userId != null) {
            return userId
        }
        // 既に認証済みの場合はそのUIDを使用
        val currentUser = FirebaseAuth.getInstance().currentUser
        if (currentUser != null) {
            userId = currentUser.uid
            return currentUser.uid
        }
        return null
    }
    
    /**
     * デッキコレクションの参照を取得
     */
    private fun decksCollection(): com.google.firebase.firestore.CollectionReference? {
        val userId = getUserId() ?: run {
            println("ユーザーIDが取得できません")
            return null
        }
        return db.collection("users").document(userId).collection("decks")
    }
    
    /**
     * デッキを保存
     */
    actual fun saveDeck(deck: Deck, onComplete: ((Throwable?) -> Unit)?) {
        waitForAuthentication { userId ->
            if (userId == null) {
                onComplete?.invoke(Exception("ユーザーIDが取得できません"))
                return@waitForAuthentication
            }
            
            val collection = db.collection("users").document(userId).collection("decks")
            
            try {
                // DeckをJSONに変換
                val json = Json { ignoreUnknownKeys = true }
                val jsonString = json.encodeToString(deck)
                val jsonObject = json.parseToJsonElement(jsonString) as JsonObject
                
                // JSONObjectをMapに変換
                val data = jsonObjectToMap(jsonObject)
                
                // Date型をTimestamp型に変換（ISO8601文字列から）
                val createdAt = if (deck.createdAt.isNotEmpty()) {
                    com.google.firebase.Timestamp(parseISO8601(deck.createdAt))
                } else {
                    com.google.firebase.Timestamp.now()
                }
                val updatedAt = if (deck.updatedAt.isNotEmpty()) {
                    com.google.firebase.Timestamp(parseISO8601(deck.updatedAt))
                } else {
                    com.google.firebase.Timestamp.now()
                }
                
                val deckData = data.toMutableMap()
                deckData["createdAt"] = createdAt
                deckData["updatedAt"] = updatedAt
                
                // matchRecords内のplayedAtも変換
                if (deckData["matchRecords"] is List<*>) {
                    val matchRecords = (deckData["matchRecords"] as List<*>).map { record ->
                        if (record is Map<*, *>) {
                            val recordMap = record.toMutableMap()
                            if (recordMap["playedAt"] is String) {
                                val playedAtString = recordMap["playedAt"] as String
                                if (playedAtString.isNotEmpty()) {
                                    recordMap["playedAt"] = com.google.firebase.Timestamp(parseISO8601(playedAtString))
                                }
                            }
                            recordMap
                        } else {
                            record
                        }
                    }
                    deckData["matchRecords"] = matchRecords
                }
                
                collection.document(deck.id).set(deckData)
                    .addOnSuccessListener {
                        println("デッキの保存成功: ${deck.id}")
                        onComplete?.invoke(null)
                    }
                    .addOnFailureListener { error ->
                        println("デッキの保存エラー: ${error.message}")
                        onComplete?.invoke(error)
                    }
            } catch (e: Exception) {
                println("デッキのエンコードエラー: ${e.message}")
                onComplete?.invoke(e)
            }
        }
    }
    
    /**
     * すべてのデッキを読み込む
     */
    actual fun loadDecks(onComplete: (Result<List<Deck>>) -> Unit) {
        waitForAuthentication { userId ->
            if (userId == null) {
                onComplete(Result.failure(Exception("ユーザーIDが取得できません")))
                return@waitForAuthentication
            }
            
            val collection = db.collection("users").document(userId).collection("decks")
            
            collection.get()
                .addOnSuccessListener { snapshot ->
                    val decks = mutableListOf<Deck>()
                    val json = Json { ignoreUnknownKeys = true }
                    
                    for (document in snapshot.documents) {
                        try {
                            val data = document.data ?: continue
                            val deckData = convertFirestoreDataToJson(data)
                            val jsonString = json.encodeToString(deckData)
                            val deck = json.decodeFromString<Deck>(jsonString)
                            decks.add(deck)
                        } catch (e: Exception) {
                            println("デッキのデコードエラー (${document.id}): ${e.message}")
                        }
                    }
                    
                    println("デッキの読み込み成功: ${decks.size}個のデッキを読み込みました")
                    onComplete(Result.success(decks))
                }
                .addOnFailureListener { error ->
                    println("デッキの読み込みエラー: ${error.message}")
                    onComplete(Result.failure(error))
                }
        }
    }
    
    /**
     * デッキを削除
     */
    actual fun deleteDeck(deckId: String, onComplete: ((Throwable?) -> Unit)?) {
        waitForAuthentication { userId ->
            if (userId == null) {
                onComplete?.invoke(Exception("ユーザーIDが取得できません"))
                return@waitForAuthentication
            }
            
            val collection = db.collection("users").document(userId).collection("decks")
            
            collection.document(deckId).delete()
                .addOnSuccessListener {
                    println("デッキの削除成功: $deckId")
                    onComplete?.invoke(null)
                }
                .addOnFailureListener { error ->
                    println("デッキの削除エラー: ${error.message}")
                    onComplete?.invoke(error)
                }
        }
    }
    
    /**
     * デッキの変更を監視（リアルタイム更新）
     */
    actual fun observeDecks(): Flow<Result<List<Deck>>> = callbackFlow {
        val userId = getUserId()
        if (userId == null) {
            // 認証が完了していない場合は待機
            waitForAuthentication { authenticatedUserId ->
                if (authenticatedUserId == null) {
                    trySend(Result.failure(Exception("ユーザーIDが取得できません")))
                    close()
                    return@waitForAuthentication
                }
                
                val collection = db.collection("users").document(authenticatedUserId).collection("decks")
                val listener = setupSnapshotListener(collection) { result ->
                    trySend(result)
                }
                
                awaitClose { listener.remove() }
            }
        } else {
            val collection = db.collection("users").document(userId).collection("decks")
            val listener = setupSnapshotListener(collection) { result ->
                trySend(result)
            }
            
            awaitClose { listener.remove() }
        }
    }
    
    /**
     * スナップショットリスナーを設定
     */
    private fun setupSnapshotListener(
        collection: com.google.firebase.firestore.CollectionReference,
        onUpdate: (Result<List<Deck>>) -> Unit
    ): ListenerRegistration {
        return collection.addSnapshotListener { snapshot, error ->
            if (error != null) {
                println("デッキの監視エラー: ${error.message}")
                onUpdate(Result.failure(error))
                return@addSnapshotListener
            }
            
            if (snapshot == null) {
                onUpdate(Result.success(emptyList()))
                return@addSnapshotListener
            }
            
            val decks = mutableListOf<Deck>()
            val json = Json { ignoreUnknownKeys = true }
            
            for (document in snapshot.documents) {
                try {
                    val data = document.data ?: continue
                    val deckData = convertFirestoreDataToJson(data)
                    val jsonString = json.encodeToString(deckData)
                    val deck = json.decodeFromString<Deck>(jsonString)
                    decks.add(deck)
                } catch (e: Exception) {
                    println("デッキのデコードエラー (${document.id}): ${e.message}")
                }
            }
            
            println("デッキの更新を検知: ${decks.size}個のデッキ")
            onUpdate(Result.success(decks))
        }
    }
    
    /**
     * FirestoreのデータをJSONに変換（TimestampをISO8601文字列に変換）
     */
    private fun convertFirestoreDataToJson(data: Map<String, Any?>): JsonObject {
        return buildJsonObject {
            data.forEach { (key, value) ->
                when (value) {
                    is com.google.firebase.Timestamp -> {
                        put(key, timestampToISO8601(value))
                    }
                    is Map<*, *> -> {
                        put(key, convertMapToJsonObject(value as Map<String, Any?>))
                    }
                    is List<*> -> {
                        put(key, convertListToJsonArray(value))
                    }
                    else -> {
                        when (value) {
                            is String -> put(key, value)
                            is Int -> put(key, value)
                            is Long -> put(key, value)
                            is Double -> put(key, value)
                            is Boolean -> put(key, value)
                            null -> put(key, kotlinx.serialization.json.JsonNull)
                            else -> put(key, value.toString())
                        }
                    }
                }
            }
        }
    }
    
    private fun convertMapToJsonObject(map: Map<String, Any?>): JsonObject {
        return buildJsonObject {
            map.forEach { (key, value) ->
                when (value) {
                    is com.google.firebase.Timestamp -> {
                        put(key, timestampToISO8601(value))
                    }
                    is Map<*, *> -> {
                        put(key, convertMapToJsonObject(value as Map<String, Any?>))
                    }
                    is List<*> -> {
                        put(key, convertListToJsonArray(value))
                    }
                    else -> {
                        when (value) {
                            is String -> put(key, value)
                            is Int -> put(key, value)
                            is Long -> put(key, value)
                            is Double -> put(key, value)
                            is Boolean -> put(key, value)
                            null -> put(key, kotlinx.serialization.json.JsonNull)
                            else -> put(key, value.toString())
                        }
                    }
                }
            }
        }
    }
    
    private fun convertListToJsonArray(list: List<*>): kotlinx.serialization.json.JsonArray {
        return kotlinx.serialization.json.buildJsonArray {
            list.forEach { item ->
                when (item) {
                    is com.google.firebase.Timestamp -> {
                        add(timestampToISO8601(item))
                    }
                    is Map<*, *> -> {
                        add(convertMapToJsonObject(item as Map<String, Any?>))
                    }
                    is List<*> -> {
                        add(convertListToJsonArray(item))
                    }
                    else -> {
                        when (item) {
                            is String -> add(item)
                            is Int -> add(item)
                            is Long -> add(item)
                            is Double -> add(item)
                            is Boolean -> add(item)
                            null -> add(kotlinx.serialization.json.JsonNull)
                            else -> add(item.toString())
                        }
                    }
                }
            }
        }
    }
    
    /**
     * TimestampをISO8601文字列に変換
     */
    private fun timestampToISO8601(timestamp: com.google.firebase.Timestamp): String {
        val date = timestamp.toDate()
        return java.text.SimpleDateFormat("yyyy-MM-dd'T'HH:mm:ss.SSS'Z'", java.util.Locale.US).apply {
            timeZone = java.util.TimeZone.getTimeZone("UTC")
        }.format(date)
    }
    
    /**
     * ISO8601文字列をDateに変換
     */
    private fun parseISO8601(iso8601: String): java.util.Date {
        return java.text.SimpleDateFormat("yyyy-MM-dd'T'HH:mm:ss.SSS'Z'", java.util.Locale.US).apply {
            timeZone = java.util.TimeZone.getTimeZone("UTC")
        }.parse(iso8601) ?: java.util.Date()
    }
    
    /**
     * JsonObjectをMapに変換
     */
    private fun jsonObjectToMap(jsonObject: JsonObject): Map<String, Any?> {
        return jsonObject.entries.associate { (key, value) ->
            key to when (value) {
                is kotlinx.serialization.json.JsonPrimitive -> {
                    when {
                        value.isString -> value.content
                        value.booleanOrNull != null -> value.boolean
                        value.intOrNull != null -> value.int
                        value.longOrNull != null -> value.long
                        value.doubleOrNull != null -> value.double
                        else -> value.content
                    }
                }
                is JsonObject -> jsonObjectToMap(value)
                is kotlinx.serialization.json.JsonArray -> {
                    value.map { element ->
                        when (element) {
                            is kotlinx.serialization.json.JsonPrimitive -> {
                                when {
                                    element.isString -> element.content
                                    element.booleanOrNull != null -> element.boolean
                                    element.intOrNull != null -> element.int
                                    element.longOrNull != null -> element.long
                                    element.doubleOrNull != null -> element.double
                                    else -> element.content
                                }
                            }
                            is JsonObject -> jsonObjectToMap(element)
                            else -> element.toString()
                        }
                    }
                }
                else -> value.toString()
            }
        }
    }
}

