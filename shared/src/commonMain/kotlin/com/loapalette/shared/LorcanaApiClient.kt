package com.loapalette.shared

import io.ktor.client.*
import io.ktor.client.call.*
import io.ktor.client.engine.*
import io.ktor.client.plugins.contentnegotiation.*
import io.ktor.client.request.*
import io.ktor.http.*
import io.ktor.serialization.kotlinx.json.*
import kotlinx.coroutines.Dispatchers
import kotlinx.coroutines.withContext
import kotlinx.serialization.json.Json

// APIクライアント
// 参考: https://api-lorcana.com/#/Cards/get%20cards
class LorcanaApiClient(private val httpClient: HttpClient) {
    companion object {
        private const val BASE_URL = "https://api-lorcana.com"
    }
    
    // 全カード取得
    suspend fun getAllCards(page: Int = 1, pageSize: Int = 20): Result<CardsResponse> {
        return withContext(Dispatchers.Default) {
            try {
                val response = httpClient.get("$BASE_URL/cards") {
                    parameter("limit", pageSize)
                    parameter("page", page)
                }
                val apiCards = response.body<List<LorcanaCardApiResponse>>()
                val cards = apiCards.map { it.toLorcanaCard() }
                Result.success(CardsResponse(cards = cards, page = page, pageSize = pageSize))
            } catch (e: Exception) {
                Result.failure(e)
            }
        }
    }
    
    // 検索条件でカード取得
    suspend fun searchCards(
        searchQuery: String? = null,
        strict: String? = null,
        page: Int = 1,
        pageSize: Int = 20
    ): Result<CardsResponse> {
        return withContext(Dispatchers.Default) {
            try {
                val response = httpClient.get("$BASE_URL/cards") {
                    parameter("limit", pageSize)
                    parameter("page", page)
                    searchQuery?.let { parameter("search", it) }
                }
                val apiCards = response.body<List<LorcanaCardApiResponse>>()
                val cards = apiCards.map { it.toLorcanaCard() }
                Result.success(CardsResponse(cards = cards, page = page, pageSize = pageSize))
            } catch (e: Exception) {
                Result.failure(e)
            }
        }
    }
}

// HttpClientファクトリー
expect fun createHttpClient(): HttpClient


