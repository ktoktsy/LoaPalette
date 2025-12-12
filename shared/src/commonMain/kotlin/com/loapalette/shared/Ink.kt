package com.loapalette.shared

import kotlin.experimental.ExperimentalObjCName
import kotlin.native.ObjCName
import kotlinx.serialization.Serializable

@OptIn(ExperimentalObjCName::class)
@ObjCName("Ink", exact = true)
@Serializable
enum class Ink(val rawValue: String) {
    Amber("Amber"),
    Amethyst("Amethyst"),
    Ruby("Ruby"),
    Sapphire("Sapphire"),
    Steel("Steel"),
    Emerald("Emerald");

    val id: String
        get() = rawValue

    val displayName: String
        get() = rawValue

    val japaneseName: String
        get() =
                when (this) {
                    Amber -> "アンバー"
                    Amethyst -> "アメジスト"
                    Ruby -> "ルビー"
                    Sapphire -> "サファイア"
                    Steel -> "スティール"
                    Emerald -> "エメラルド"
                }

    companion object {
        fun generateDeckName(colors: List<Ink>): String {
            if (colors.isEmpty()) return ""
            return colors.joinToString("/") { it.japaneseName }
        }
    }
}
