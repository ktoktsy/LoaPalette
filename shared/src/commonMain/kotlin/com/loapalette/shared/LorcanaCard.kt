package com.loapalette.shared

import kotlinx.serialization.Serializable
import kotlinx.serialization.SerialName
import kotlin.experimental.ExperimentalObjCName
import kotlin.native.ObjCName

// カードデータモデル
// 参考: https://lorcana-api.com/docs/intro/
@OptIn(ExperimentalObjCName::class)
@ObjCName("LorcanaCard", exact = true)
@Serializable
data class LorcanaCard(
    val id: String? = null,
    @SerialName("Name")
    val name: String? = null,
    @SerialName("Cost")
    val cost: Int? = null,
    // API側は "Color": "Amber, Steel" のようなPascalCaseキー.
    @SerialName("Color")
    val color: String? = null,
    @SerialName("Inkable")
    val inkwell: Boolean? = null,
    @SerialName("Type")
    val type: String? = null,
    @SerialName("Rarity")
    val rarity: String? = null,
    // "Set_Name": "Archazia's Island".
    @SerialName("Set_Name")
    val set: String? = null,
    // "Set_Num": 7.
    @SerialName("Set_Num")
    val setNumber: Int? = null,
    @SerialName("Flavor_Text")
    val flavorText: String? = null,
    @SerialName("Artist")
    val illustrator: String? = null,
    // "Image": "https://lorcana-api.com/images/..."
    @SerialName("Image")
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

