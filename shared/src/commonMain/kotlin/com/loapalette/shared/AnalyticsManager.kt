package com.loapalette.shared

/**
 * Firebase Analyticsの共通インターフェース
 * 参考: https://firebase.google.com/docs/analytics
 */
expect class AnalyticsManager {
    /**
     * イベントを送信する共通メソッド
     * @param name イベント名
     * @param parameters イベントパラメータ（オプション）
     */
    fun logEvent(name: String, parameters: Map<String, Any>? = null)
    
    /**
     * ロアカウンターのリセットボタン押下イベント
     */
    fun logRoaCounterReset()
    
    /**
     * ロアカウンターのタイマー開始イベント
     */
    fun logRoaCounterTimerStart()
    
    /**
     * ロアカウンターの人数追加イベント
     * @param position 追加位置（LEFT or RIGHT）
     */
    fun logRoaCounterAddPerson(position: String)
    
    /**
     * デッキ追加イベント
     */
    fun logDeckAdd()
    
    /**
     * デッキ選択イベント
     * @param deckName デッキ名
     */
    fun logDeckSelect(deckName: String)
    
    /**
     * 勝敗記録追加ボタン押下イベント
     */
    fun logMatchRecordAddButtonClick()
    
    /**
     * 勝敗記録追加完了イベント
     * @param isWin 勝敗結果（true: 勝利, false: 敗北）
     * @param deckName デッキ名
     * @param opponentInkColors 相手のインク色（カンマ区切りの文字列）
     * @param playedAt 試合日時（ISO8601形式の文字列）
     */
    fun logMatchRecordAddComplete(isWin: Boolean, deckName: String, opponentInkColors: String, playedAt: String)
    
    /**
     * デッキカード表示モード切替イベント
     * @param displayMode 表示モード（"list" or "grid"）
     */
    fun logDeckCardDisplayModeChange(displayMode: String)
    
    /**
     * デッキ詳細画面のもっと見るボタン押下イベント
     */
    fun logDeckDetailMoreButtonClick()
    
    /**
     * 勝敗記録一覧で勝利で絞り込みイベント
     */
    fun logMatchRecordFilterWins()
    
    /**
     * 勝敗記録一覧で敗北で絞り込みイベント
     */
    fun logMatchRecordFilterLosses()
    
    /**
     * その他画面の公式サイトタップイベント
     */
    fun logSettingsOfficialSiteClick()
    
    /**
     * その他画面の要望/お問い合わせタップイベント
     */
    fun logSettingsContactClick()
    
    /**
     * 検索画面の詳細検索ボタン押下イベント
     */
    fun logCardSearchDetailButtonClick()
    
    /**
     * 検索画面の検索欄タップイベント
     */
    fun logCardSearchFieldTap()
    
    /**
     * 検索画面の検索ボタン押下イベント
     * @param parameters デフォルト値を除いた検索パラメータ
     */
    fun logCardSearchExecute(parameters: Map<String, Any>?)
}

