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
// 参考: https://lorcana-api.com/docs/intro/
class LorcanaApiClient(private val httpClient: HttpClient) {
    companion object {
        private const val BASE_URL = "https://api.lorcana-api.com"
    }
    
    // 全カード取得
    suspend fun getAllCards(page: Int = 1, pageSize: Int = 1000): Result<CardsResponse> {
        return withContext(Dispatchers.Default) {
            try {
                val response = httpClient.get("$BASE_URL/cards/all") {
                    parameter("page", page)
                    parameter("pagesize", pageSize)
                }
                val cards = response.body<List<LorcanaCard>>()
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
        pageSize: Int = 1000
    ): Result<CardsResponse> {
        return withContext(Dispatchers.Default) {
            try {
                val response = httpClient.get("$BASE_URL/cards/fetch") {
                    searchQuery?.let { parameter("search", it) }
                    strict?.let { parameter("strict", it) }
                    parameter("page", page)
                    parameter("pagesize", pageSize)
                }
                val cards = response.body<List<LorcanaCard>>()
                Result.success(CardsResponse(cards = cards, page = page, pageSize = pageSize))
            } catch (e: Exception) {
                Result.failure(e)
            }
        }
    }
}

// HttpClientファクトリー
expect fun createHttpClient(): HttpClient


