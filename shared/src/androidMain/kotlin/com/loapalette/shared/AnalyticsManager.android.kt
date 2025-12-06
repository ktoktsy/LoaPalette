package com.loapalette.shared

import com.google.firebase.analytics.FirebaseAnalytics
import com.google.firebase.analytics.ktx.analytics
import com.google.firebase.ktx.Firebase

/**
 * Firebase AnalyticsのAndroid実装
 * 参考: https://firebase.google.com/docs/analytics/android/events
 */
actual class AnalyticsManager {
    private val analytics: FirebaseAnalytics = Firebase.analytics
    
    actual fun logEvent(name: String, parameters: Map<String, Any>?) {
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
    
    actual fun logRoaCounterReset() {
        logEvent(AnalyticsEvents.ROA_COUNTER_RESET)
    }
    
    actual fun logRoaCounterTimerStart() {
        logEvent(AnalyticsEvents.ROA_COUNTER_TIMER_START)
    }
    
    actual fun logRoaCounterAddPerson(position: String) {
        logEvent(AnalyticsEvents.ROA_COUNTER_ADD_PERSON, mapOf(AnalyticsParameters.POSITION to position))
    }
    
    actual fun logDeckAdd() {
        logEvent(AnalyticsEvents.DECK_ADD)
    }
    
    actual fun logDeckSelect(deckName: String) {
        logEvent(AnalyticsEvents.DECK_SELECT, mapOf(AnalyticsParameters.DECK_NAME to deckName))
    }
    
    actual fun logMatchRecordAddButtonClick() {
        logEvent(AnalyticsEvents.MATCH_RECORD_ADD_BUTTON_CLICK)
    }
    
    actual fun logMatchRecordAddComplete(isWin: Boolean, deckName: String, opponentInkColors: String, playedAt: String) {
        logEvent(AnalyticsEvents.MATCH_RECORD_ADD_COMPLETE, mapOf(
            AnalyticsParameters.IS_WIN to isWin,
            AnalyticsParameters.DECK_NAME to deckName,
            AnalyticsParameters.OPPONENT_INK_COLORS to opponentInkColors,
            AnalyticsParameters.PLAYED_AT to playedAt
        ))
    }
    
    actual fun logDeckCardDisplayModeChange(displayMode: String) {
        logEvent(AnalyticsEvents.DECK_CARD_DISPLAY_MODE_CHANGE, mapOf(AnalyticsParameters.DISPLAY_MODE to displayMode))
    }
    
    actual fun logDeckDetailMoreButtonClick() {
        logEvent(AnalyticsEvents.DECK_DETAIL_MORE_BUTTON_CLICK)
    }
    
    actual fun logMatchRecordFilterWins() {
        logEvent(AnalyticsEvents.MATCH_RECORD_FILTER_WINS)
    }
    
    actual fun logMatchRecordFilterLosses() {
        logEvent(AnalyticsEvents.MATCH_RECORD_FILTER_LOSSES)
    }
    
    actual fun logSettingsOfficialSiteClick() {
        logEvent(AnalyticsEvents.SETTINGS_OFFICIAL_SITE_CLICK)
    }
    
    actual fun logSettingsContactClick() {
        logEvent(AnalyticsEvents.SETTINGS_CONTACT_CLICK)
    }
    
    actual fun logCardSearchDetailButtonClick() {
        logEvent(AnalyticsEvents.CARD_SEARCH_DETAIL_BUTTON_CLICK)
    }
    
    actual fun logCardSearchFieldTap() {
        logEvent(AnalyticsEvents.CARD_SEARCH_FIELD_TAP)
    }
    
    actual fun logCardSearchExecute(parameters: Map<String, Any>?) {
        logEvent(AnalyticsEvents.CARD_SEARCH_EXECUTE, parameters)
    }
}

