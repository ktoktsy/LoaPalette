package com.loapalette.shared

/**
 * Firebase Analyticsのイベント名を定義するオブジェクト
 * 参考: https://firebase.google.com/docs/analytics
 */
object AnalyticsEvents {
    // ロアカウンター関連
    const val ROA_COUNTER_RESET = "roa_counter_reset"
    const val ROA_COUNTER_TIMER_START = "roa_counter_timer_start"
    const val ROA_COUNTER_ADD_PERSON = "roa_counter_add_person"
    
    // デッキ関連
    const val DECK_ADD = "deck_add"
    const val DECK_SELECT = "deck_select"
    const val DECK_CARD_DISPLAY_MODE_CHANGE = "deck_card_display_mode_change"
    const val DECK_DETAIL_MORE_BUTTON_CLICK = "deck_detail_more_button_click"
    
    // 勝敗記録関連
    const val MATCH_RECORD_ADD_BUTTON_CLICK = "match_record_add_button_click"
    const val MATCH_RECORD_ADD_COMPLETE = "match_record_add_complete"
    const val MATCH_RECORD_FILTER_WINS = "match_record_filter_wins"
    const val MATCH_RECORD_FILTER_LOSSES = "match_record_filter_losses"
    
    // 設定関連
    const val SETTINGS_OFFICIAL_SITE_CLICK = "settings_official_site_click"
    const val SETTINGS_CONTACT_CLICK = "settings_contact_click"
    
    // カード検索関連
    const val CARD_SEARCH_DETAIL_BUTTON_CLICK = "card_search_detail_button_click"
    const val CARD_SEARCH_FIELD_TAP = "card_search_field_tap"
    const val CARD_SEARCH_EXECUTE = "card_search_execute"
}

/**
 * Firebase Analyticsのパラメータ名を定義するオブジェクト
 */
object AnalyticsParameters {
    const val POSITION = "position"
    const val DECK_NAME = "deck_name"
    const val IS_WIN = "is_win"
    const val OPPONENT_INK_COLORS = "opponent_ink_colors"
    const val PLAYED_AT = "played_at"
    const val DISPLAY_MODE = "display_mode"
}

