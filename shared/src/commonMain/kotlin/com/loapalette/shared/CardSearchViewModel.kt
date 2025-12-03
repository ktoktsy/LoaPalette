package com.loapalette.shared

import kotlinx.coroutines.flow.MutableStateFlow
import kotlinx.coroutines.flow.StateFlow
import kotlinx.coroutines.flow.asStateFlow
import kotlinx.coroutines.CoroutineScope
import kotlinx.coroutines.Dispatchers
import kotlinx.coroutines.SupervisorJob
import kotlinx.coroutines.launch
import kotlinx.coroutines.delay
import kotlin.experimental.ExperimentalObjCName
import kotlin.native.ObjCName

// 検索状態
@OptIn(ExperimentalObjCName::class)
@ObjCName("SearchState", exact = true)
enum class SearchState {
    IDLE,
    LOADING,
    SUCCESS,
    ERROR
}

@OptIn(ExperimentalObjCName::class)
@ObjCName("CardSearchViewModel", exact = true)
class CardSearchViewModel {
    private val viewModelScope = CoroutineScope(SupervisorJob() + Dispatchers.Main)
    private val apiClient = LorcanaApiClient(createHttpClient())
    
    private val _cards = MutableStateFlow<List<LorcanaCard>>(emptyList())
    val cards: StateFlow<List<LorcanaCard>> = _cards.asStateFlow()
    
    private val _searchState = MutableStateFlow(SearchState.IDLE)
    val searchState: StateFlow<SearchState> = _searchState.asStateFlow()
    
    private val _errorMessage = MutableStateFlow<String?>(null)
    val errorMessage: StateFlow<String?> = _errorMessage.asStateFlow()
    
    private val _searchQuery = MutableStateFlow("")
    val searchQuery: StateFlow<String> = _searchQuery.asStateFlow()
    
    private var searchJob: kotlinx.coroutines.Job? = null
    
    // 検索実行
    // API仕様: https://lorcana-api.com/docs/cards/parameters/search-parameter
    fun search(query: String) {
        _searchQuery.value = query
        searchJob?.cancel()
        
        if (query.isBlank()) {
            // クエリが空のときは全件取得にフォールバック.
            loadAllCards()
            return
        }
        
        searchJob = viewModelScope.launch {
            _searchState.value = SearchState.LOADING
            _errorMessage.value = null
            
            // デバウンス処理（500ms待機）
            delay(500)
            
            // APIのsearchパラメータを使用してサーバー側でフィルタリング.
            // クエリは既にAPI仕様に従った形式（例: name~text;cost>=3;color~amber）で構築されている.
            val result = apiClient.searchCards(searchQuery = query)
            result.fold(
                onSuccess = { response ->
                    _cards.value = response.cards
                    _searchState.value = SearchState.SUCCESS
                },
                onFailure = { error ->
                    _errorMessage.value = error.message ?: "検索に失敗しました"
                    _searchState.value = SearchState.ERROR
                    _cards.value = emptyList()
                }
            )
        }
    }
    
    // 全カード取得
    fun loadAllCards() {
        viewModelScope.launch {
            _searchState.value = SearchState.LOADING
            _errorMessage.value = null
            
            val result = apiClient.getAllCards()
            result.fold(
                onSuccess = { response ->
                    _cards.value = response.cards
                    _searchState.value = SearchState.SUCCESS
                },
                onFailure = { error ->
                    _errorMessage.value = error.message ?: "カードの取得に失敗しました"
                    _searchState.value = SearchState.ERROR
                    _cards.value = emptyList()
                }
            )
        }
    }
    
    // クリア
    fun clear() {
        searchJob?.cancel()
        _cards.value = emptyList()
        _searchQuery.value = ""
        _searchState.value = SearchState.IDLE
        _errorMessage.value = null
    }
    
    // Swift側から値を取得するためのgetterメソッド
    fun getCards(): List<LorcanaCard> {
        return _cards.value
    }
    
    fun getSearchState(): String {
        return _searchState.value.name
    }
    
    fun getErrorMessage(): String? {
        return _errorMessage.value
    }
    
    fun getSearchQuery(): String {
        return _searchQuery.value
    }
    
    fun cleanup() {
        searchJob?.cancel()
        searchJob = null
    }
}

