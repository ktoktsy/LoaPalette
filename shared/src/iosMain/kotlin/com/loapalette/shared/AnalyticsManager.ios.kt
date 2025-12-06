package com.loapalette.shared

/**
 * Firebase AnalyticsのiOS実装
 * 注意: iOS側はSwiftで実装されているため、Kotlin/NativeからSwiftのAnalyticsManagerを呼び出す必要があります
 * 参考: https://firebase.google.com/docs/analytics/ios/events
 * 
 * 現在は、iOS側のSwift実装（AnalyticsManager.swift）を使用することを推奨します
 * 将来的にKotlin/Nativeから直接Firebaseを呼び出す場合は、この実装を更新してください
 */
actual class AnalyticsManager {
    // iOS側はSwiftで実装されているため、ここではプレースホルダーとして実装
    // 実際の使用時は、iOS側のSwift実装（AnalyticsManager.swift）を使用してください
    
    actual fun logEvent(name: String, parameters: Map<String, Any>?) {
        // iOS側のSwift実装を呼び出す必要があります
        // 現在は未実装のため、何もしません
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

