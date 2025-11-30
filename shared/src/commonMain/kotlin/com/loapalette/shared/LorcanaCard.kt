package com.loapalette.shared

import kotlinx.serialization.Serializable
import kotlin.experimental.ExperimentalObjCName
import kotlin.native.ObjCName

// カードデータモデル
// 参考: https://lorcana-api.com/docs/intro/
@OptIn(ExperimentalObjCName::class)
@ObjCName("LorcanaCard", exact = true)
@Serializable
data class LorcanaCard(
    val id: String? = null,
    val name: String? = null,
    val cost: Int? = null,
    val color: String? = null,
    val inkwell: Boolean? = null,
    val type: String? = null,
    val rarity: String? = null,
    val set: String? = null,
    val setNumber: Int? = null,
    val flavorText: String? = null,
    val illustrator: String? = null,
    val imageUrl: String? = null,
    val abilities: List<String>? = null,
    val strength: Int? = null,
    val willpower: Int? = null,
    val lore: Int? = null
)

// APIレスポンスモデル
@Serializable
data class CardsResponse(
    val cards: List<LorcanaCard> = emptyList(),
    val total: Int? = null,
    val page: Int? = null,
    val pageSize: Int? = null
)

