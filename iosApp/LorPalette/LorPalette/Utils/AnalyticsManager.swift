
import Foundation
import FirebaseAnalytics

/// Firebase Analyticsの共通処理を管理するクラス
/// 参考: https://firebase.google.com/docs/analytics/ios/events
/// 
/// 注意: sharedモジュールのAnalyticsEventsとAnalyticsParametersを参照してイベント名とパラメータ名を統一してください
class AnalyticsManager {
    static let shared = AnalyticsManager()
    
    private init() {}
    
    /// イベントを送信する共通メソッド
    /// - Parameters:
    ///   - name: イベント名（sharedモジュールのAnalyticsEventsを参照）
    ///   - parameters: イベントパラメータ（オプション、sharedモジュールのAnalyticsParametersを参照）
    func logEvent(_ name: String, parameters: [String: Any]? = nil) {
        Analytics.logEvent(name, parameters: parameters)
    }
    
    /// ロアカウンターのリセットボタン押下イベント
    func logRoaCounterReset() {
        logEvent("roa_counter_reset")
    }
    
    /// ロアカウンターのタイマー開始イベント
    func logRoaCounterTimerStart() {
        logEvent("roa_counter_timer_start")
    }
    
    /// ロアカウンターの人数追加イベント
    /// - Parameter position: 追加位置（LEFT or RIGHT）
    func logRoaCounterAddPerson(position: String) {
        logEvent("roa_counter_add_person", parameters: ["position": position])
    }
    
    /// デッキ追加イベント
    func logDeckAdd() {
        logEvent("deck_add")
    }
    
    /// デッキ選択イベント
    /// - Parameter deckName: デッキ名
    func logDeckSelect(deckName: String) {
        logEvent("deck_select", parameters: ["deck_name": deckName])
    }
    
    /// 勝敗記録追加ボタン押下イベント
    func logMatchRecordAddButtonClick() {
        logEvent("match_record_add_button_click")
    }
    
    /// 勝敗記録追加完了イベント
    /// - Parameters:
    ///   - isWin: 勝敗結果（true: 勝利, false: 敗北）
    ///   - deckName: デッキ名
    ///   - opponentInkColors: 相手のインク色（配列）
    ///   - playedAt: 試合日時（ISO8601形式の文字列）
    func logMatchRecordAddComplete(isWin: Bool, deckName: String, opponentInkColors: [String], playedAt: String) {
        logEvent("match_record_add_complete", parameters: [
            "is_win": isWin,
            "deck_name": deckName,
            "opponent_ink_colors": opponentInkColors.joined(separator: ","),
            "played_at": playedAt
        ])
    }
    
    /// デッキカード表示モード切替イベント
    /// - Parameter displayMode: 表示モード（"list" or "grid"）
    func logDeckCardDisplayModeChange(displayMode: String) {
        logEvent("deck_card_display_mode_change", parameters: ["display_mode": displayMode])
    }
    
    /// デッキ詳細画面のもっと見るボタン押下イベント
    func logDeckDetailMoreButtonClick() {
        logEvent("deck_detail_more_button_click")
    }
    
    /// 勝敗記録一覧で勝利で絞り込みイベント
    func logMatchRecordFilterWins() {
        logEvent("match_record_filter_wins")
    }
    
    /// 勝敗記録一覧で敗北で絞り込みイベント
    func logMatchRecordFilterLosses() {
        logEvent("match_record_filter_losses")
    }
    
    /// その他画面の公式サイトタップイベント
    func logSettingsOfficialSiteClick() {
        logEvent("settings_official_site_click")
    }
    
    /// その他画面の要望/お問い合わせタップイベント
    func logSettingsContactClick() {
        logEvent("settings_contact_click")
    }
    
    /// 検索画面の詳細検索ボタン押下イベント
    func logCardSearchDetailButtonClick() {
        logEvent("card_search_detail_button_click")
    }
    
    /// 検索画面の検索欄タップイベント
    func logCardSearchFieldTap() {
        logEvent("card_search_field_tap")
    }
    
    /// 検索画面の検索ボタン押下イベント
    /// - Parameter parameters: デフォルト値を除いた検索パラメータ
    func logCardSearchExecute(parameters: [String: Any]) {
        logEvent("card_search_execute", parameters: parameters)
    }
}

