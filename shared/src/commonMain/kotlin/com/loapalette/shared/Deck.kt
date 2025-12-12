package com.loapalette.shared

import kotlin.experimental.ExperimentalObjCName
import kotlin.native.ObjCName
import kotlinx.serialization.SerialName
import kotlinx.serialization.Serializable

@OptIn(ExperimentalObjCName::class)
@ObjCName("Deck", exact = true)
@Serializable
data class Deck(
        val id: String = generateId(),
        var name: String = "",
        var entries: List<DeckEntry> = emptyList(),
        val inkColors: List<Ink> = emptyList(), // 最大2色
        @SerialName("createdAt") val createdAt: String = "", // ISO8601形式の文字列
        @SerialName("updatedAt") var updatedAt: String = "", // ISO8601形式の文字列
        val matchRecords: List<MatchRecord> = emptyList(), // 試合記録
        var memo: String = "" // メモ
) {
    companion object {
        private var idCounter = 0
        private fun generateId(): String {
            return "deck_${idCounter++}"
        }

        fun create(
                name: String = "",
                inkColors: List<Ink> = emptyList(),
                entries: List<DeckEntry> = emptyList(),
                matchRecords: List<MatchRecord> = emptyList(),
                memo: String = ""
        ): Deck {
            val deckName =
                    if (name.isEmpty() && inkColors.isNotEmpty()) {
                        Ink.generateDeckName(inkColors)
                    } else {
                        name
                    }
            return Deck(
                    name = deckName,
                    inkColors = inkColors,
                    entries = entries,
                    matchRecords = matchRecords,
                    memo = memo
            )
        }
    }

    val totalCardCount: Int
        get() = entries.sumOf { it.count }

    val wins: Int
        get() = matchRecords.count { it.isWin }

    val losses: Int
        get() = matchRecords.count { !it.isWin }

    val winRate: Double
        get() {
            val total = matchRecords.size
            if (total == 0) return 0.0
            return (wins.toDouble() / total) * 100.0
        }
}
