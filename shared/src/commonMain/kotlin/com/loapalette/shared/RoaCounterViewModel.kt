package com.loapalette.shared

import kotlinx.coroutines.flow.MutableStateFlow
import kotlinx.coroutines.flow.StateFlow
import kotlinx.coroutines.flow.asStateFlow
import kotlinx.coroutines.CoroutineScope
import kotlinx.coroutines.Dispatchers
import kotlinx.coroutines.SupervisorJob
import kotlinx.coroutines.Job
import kotlinx.coroutines.delay
import kotlinx.coroutines.launch
import kotlin.experimental.ExperimentalObjCName
import kotlin.native.ObjCName

@OptIn(ExperimentalObjCName::class)
@ObjCName("RoaCounterViewModel", exact = true)
class RoaCounterViewModel {
    private val viewModelScope = CoroutineScope(SupervisorJob() + Dispatchers.Main)
    
    private val _counterPairs = MutableStateFlow<List<CounterPair>>(listOf(CounterPair()))
    val counterPairs: StateFlow<List<CounterPair>> = _counterPairs.asStateFlow()
    
    private val _elapsedTime = MutableStateFlow(0.0)
    val elapsedTime: StateFlow<Double> = _elapsedTime.asStateFlow()
    
    private val _isTimerRunning = MutableStateFlow(false)
    val isTimerRunning: StateFlow<Boolean> = _isTimerRunning.asStateFlow()
    
    private val _showAddMenu = MutableStateFlow(false)
    val showAddMenu: StateFlow<Boolean> = _showAddMenu.asStateFlow()
    
    private var timerJob: Job? = null
    
    // MARK: - カウンター管理
    
    fun resetAllCounters() {
        _counterPairs.value = _counterPairs.value.map { pair ->
            pair.copy(opponentPoint = 0, myPoint = 0)
        }
    }
    
    fun addCounterPair(position: AddPosition) {
        val newPair = CounterPair(isOriginalColor = false)
        val currentPairs = _counterPairs.value.toMutableList()
        when (position) {
            AddPosition.LEFT -> currentPairs.add(0, newPair)
            AddPosition.RIGHT -> currentPairs.add(newPair)
        }
        _counterPairs.value = currentPairs
    }
    
    fun removeAddedPairs() {
        _counterPairs.value = _counterPairs.value.filter { it.isOriginalColor }
    }
    
    fun updateCounterPoint(pairId: String, isOpponent: Boolean, newValue: Int) {
        _counterPairs.value = _counterPairs.value.map { pair ->
            if (pair.id == pairId) {
                if (isOpponent) {
                    pair.copy(opponentPoint = newValue)
                } else {
                    pair.copy(myPoint = newValue)
                }
            } else {
                pair
            }
        }
    }
    
    // MARK: - タイマー管理
    
    fun toggleTimer() {
        if (_isTimerRunning.value) {
            stopTimer()
        } else {
            startTimer()
        }
    }
    
    fun startTimer() {
        if (_isTimerRunning.value) return
        
        _isTimerRunning.value = true
        timerJob = viewModelScope.launch {
            while (_isTimerRunning.value) {
                delay(100) // 0.1秒
                _elapsedTime.value += 0.1
            }
        }
    }
    
    fun stopTimer() {
        timerJob?.cancel()
        timerJob = null
        _isTimerRunning.value = false
    }
    
    fun resetTimer() {
        timerJob?.cancel()
        timerJob = null
        _elapsedTime.value = 0.0
        _isTimerRunning.value = false
    }
    
    // MARK: - メニュー管理
    
    fun showAddMenu() {
        _showAddMenu.value = true
    }
    
    fun hideAddMenu() {
        _showAddMenu.value = false
    }
    
    // MARK: - ユーティリティ
    
    fun formatTime(time: Double): String {
        val minutes = (time.toInt() / 60)
        val seconds = (time.toInt() % 60)
        val minStr = minutes.toString().padStart(2, '0')
        val secStr = seconds.toString().padStart(2, '0')
        return "$minStr:$secStr"
    }
    
    fun cleanup() {
        timerJob?.cancel()
        timerJob = null
    }
    
    // Swift側から値を取得するためのgetterメソッド
    fun getCounterPairs(): List<CounterPair> {
        return _counterPairs.value
    }
    
    fun getElapsedTime(): Double {
        return _elapsedTime.value
    }
    
    fun getIsTimerRunning(): Boolean {
        return _isTimerRunning.value
    }
    
    fun getShowAddMenu(): Boolean {
        return _showAddMenu.value
    }
}

