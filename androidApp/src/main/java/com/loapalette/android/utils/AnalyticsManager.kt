package com.loapalette.android.utils

import com.google.firebase.analytics.FirebaseAnalytics
import com.google.firebase.analytics.ktx.analytics
import com.google.firebase.ktx.Firebase
import com.loapalette.shared.AnalyticsEvents
import com.loapalette.shared.AnalyticsParameters

/**
 * Firebase Analyticsの共通処理を管理するオブジェクト
 * 参考: https://firebase.google.com/docs/analytics/android/events
 * 
 * 注意: sharedモジュールのAnalyticsManagerを使用することを推奨します
 * このオブジェクトは後方互換性のために残されています
 * 
 * Android側でRoaCounterViewModelを使う場合の使用例:
 * ```kotlin
 * val viewModel = RoaCounterViewModel()
 * viewModel.onResetCounters = { AnalyticsManager.logRoaCounterReset() }
 * viewModel.onTimerStart = { AnalyticsManager.logRoaCounterTimerStart() }
 * viewModel.onAddPerson = { position -> AnalyticsManager.logRoaCounterAddPerson(position) }
 * ```
 */
object AnalyticsManager {
    private val analytics: FirebaseAnalytics = Firebase.analytics
    
    /**
     * イベントを送信する共通メソッド
     * @param name イベント名
     * @param parameters イベントパラメータ（オプション）
     */
    fun logEvent(name: String, parameters: Map<String, Any>? = null) {
        val bundle = parameters?.let { params ->
            android.os.Bundle().apply {
                params.forEach { (key, value) ->
                    when (value) {
                        is String -> putString(key, value)
                        is Int -> putInt(key, value)
                        is Long -> putLong(key, value)
                        is Double -> putDouble(key, value)
                        is Boolean -> putBoolean(key, value)
                        else -> putString(key, value.toString())
                    }
                }
            }
        }
        analytics.logEvent(name, bundle)
    }
    
    /**
     * ロアカウンターのリセットボタン押下イベント
     */
    fun logRoaCounterReset() {
        logEvent(AnalyticsEvents.ROA_COUNTER_RESET)
    }
    
    /**
     * ロアカウンターのタイマー開始イベント
     */
    fun logRoaCounterTimerStart() {
        logEvent(AnalyticsEvents.ROA_COUNTER_TIMER_START)
    }
    
    /**
     * ロアカウンターの人数追加イベント
     * @param position 追加位置（LEFT or RIGHT）
     */
    fun logRoaCounterAddPerson(position: String) {
        logEvent(AnalyticsEvents.ROA_COUNTER_ADD_PERSON, mapOf(AnalyticsParameters.POSITION to position))
    }
    
    /**
     * デッキ追加イベント
     */
    fun logDeckAdd() {
        logEvent(AnalyticsEvents.DECK_ADD)
    }
    
    /**
     * デッキ選択イベント
     * @param deckName デッキ名
     */
    fun logDeckSelect(deckName: String) {
        logEvent(AnalyticsEvents.DECK_SELECT, mapOf(AnalyticsParameters.DECK_NAME to deckName))
    }
    
    /**
     * 勝敗記録追加ボタン押下イベント
     */
    fun logMatchRecordAddButtonClick() {
        logEvent(AnalyticsEvents.MATCH_RECORD_ADD_BUTTON_CLICK)
    }
    
    /**
     * 勝敗記録追加完了イベント
     * @param isWin 勝敗結果（true: 勝利, false: 敗北）
     * @param deckName デッキ名
     * @param opponentInkColors 相手のインク色（カンマ区切りの文字列）
     * @param playedAt 試合日時（ISO8601形式の文字列）
     */
    fun logMatchRecordAddComplete(isWin: Boolean, deckName: String, opponentInkColors: String, playedAt: String) {
        logEvent(AnalyticsEvents.MATCH_RECORD_ADD_COMPLETE, mapOf(
            AnalyticsParameters.IS_WIN to isWin,
            AnalyticsParameters.DECK_NAME to deckName,
            AnalyticsParameters.OPPONENT_INK_COLORS to opponentInkColors,
            AnalyticsParameters.PLAYED_AT to playedAt
        ))
    }
    
    /**
     * デッキカード表示モード切替イベント
     * @param displayMode 表示モード（"list" or "grid"）
     */
    fun logDeckCardDisplayModeChange(displayMode: String) {
        logEvent(AnalyticsEvents.DECK_CARD_DISPLAY_MODE_CHANGE, mapOf(AnalyticsParameters.DISPLAY_MODE to displayMode))
    }
    
    /**
     * デッキ詳細画面のもっと見るボタン押下イベント
     */
    fun logDeckDetailMoreButtonClick() {
        logEvent(AnalyticsEvents.DECK_DETAIL_MORE_BUTTON_CLICK)
    }
    
    /**
     * 勝敗記録一覧で勝利で絞り込みイベント
     */
    fun logMatchRecordFilterWins() {
        logEvent(AnalyticsEvents.MATCH_RECORD_FILTER_WINS)
    }
    
    /**
     * 勝敗記録一覧で敗北で絞り込みイベント
     */
    fun logMatchRecordFilterLosses() {
        logEvent(AnalyticsEvents.MATCH_RECORD_FILTER_LOSSES)
    }
    
    /**
     * その他画面の公式サイトタップイベント
     */
    fun logSettingsOfficialSiteClick() {
        logEvent(AnalyticsEvents.SETTINGS_OFFICIAL_SITE_CLICK)
    }
    
    /**
     * その他画面の要望/お問い合わせタップイベント
     */
    fun logSettingsContactClick() {
        logEvent(AnalyticsEvents.SETTINGS_CONTACT_CLICK)
    }
    
    /**
     * 検索画面の詳細検索ボタン押下イベント
     */
    fun logCardSearchDetailButtonClick() {
        logEvent(AnalyticsEvents.CARD_SEARCH_DETAIL_BUTTON_CLICK)
    }
    
    /**
     * 検索画面の検索欄タップイベント
     */
    fun logCardSearchFieldTap() {
        logEvent(AnalyticsEvents.CARD_SEARCH_FIELD_TAP)
    }
    
    /**
     * 検索画面の検索ボタン押下イベント
     * @param parameters デフォルト値を除いた検索パラメータ
     */
    fun logCardSearchExecute(parameters: Map<String, Any>?) {
        logEvent(AnalyticsEvents.CARD_SEARCH_EXECUTE, parameters)
    }
}

