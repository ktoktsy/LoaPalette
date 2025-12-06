package com.loapalette.shared

import kotlinx.serialization.Serializable
import kotlinx.serialization.SerialName
import kotlin.experimental.ExperimentalObjCName
import kotlin.native.ObjCName

// 試合記録モデル
@OptIn(ExperimentalObjCName::class)
@ObjCName("MatchRecord", exact = true)
@Serializable
data class MatchRecord(
    val id: String = generateId(),
    val opponentInkColors: List<Ink> = emptyList(),
    val opponentDeckName: String = "",
    val isWin: Boolean = true,
    @SerialName("playedAt")
    val playedAt: String = "" // ISO8601形式の文字列
) {
    companion object {
        private var idCounter = 0
        private fun generateId(): String {
            return "match_record_${idCounter++}"
        }
        
        // デッキ名を自動生成するヘルパー関数
        fun create(
            opponentInkColors: List<Ink> = emptyList(),
            opponentDeckName: String = "",
            isWin: Boolean = true,
            playedAt: String = ""
        ): MatchRecord {
            val deckName = if (opponentDeckName.isEmpty() && opponentInkColors.isNotEmpty()) {
                Ink.generateDeckName(opponentInkColors)
            } else {
                opponentDeckName
            }
            return MatchRecord(
                opponentInkColors = opponentInkColors,
                opponentDeckName = deckName,
                isWin = isWin,
                playedAt = playedAt
            )
        }
    }
}

