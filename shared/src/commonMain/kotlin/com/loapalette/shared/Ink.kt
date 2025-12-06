package com.loapalette.shared

import kotlinx.serialization.Serializable
import kotlin.experimental.ExperimentalObjCName
import kotlin.native.ObjCName

// インクカラー定義
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
    
    val id: String get() = rawValue
    
    val displayName: String get() = rawValue
    
    // ローカライズされた表示名
    val japaneseName: String
        get() = when (this) {
            Amber -> "アンバー"
            Amethyst -> "アメジスト"
            Ruby -> "ルビー"
            Sapphire -> "サファイア"
            Steel -> "スティール"
            Emerald -> "エメラルド"
        }
    
    companion object {
        // インク色の組み合わせからデッキ名を生成（例：「アンバー/スティール」）
        fun generateDeckName(colors: List<Ink>): String {
            if (colors.isEmpty()) return ""
            return colors.joinToString("/") { it.japaneseName }
        }
    }
}

