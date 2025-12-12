package com.loapalette.shared

import kotlin.experimental.ExperimentalObjCName
import kotlin.native.ObjCName
import kotlinx.serialization.SerialName
import kotlinx.serialization.Serializable

@Serializable
data class LorcanaCardApiResponse(
        @SerialName("Name") val name: String? = null,
        @SerialName("Cost") val cost: Int? = null,
        @SerialName("Type") val type: String? = null,
        @SerialName("Color") val color: String? = null,
        @SerialName("Inkable") val inkable: Boolean? = null,
        @SerialName("Body_Text") val bodyText: String? = null,
        @SerialName("Flavor_Text") val flavorText: String? = null,
        @SerialName("Artist") val artist: String? = null,
        @SerialName("Rarity") val rarity: String? = null,
        @SerialName("Image") val image: String? = null,
        @SerialName("Set_Name") val setName: String? = null,
        @SerialName("Set_ID") val setId: String? = null,
        @SerialName("Set_Num") val setNum: Int? = null,
        @SerialName("Strength") val strength: Int? = null,
        @SerialName("Willpower") val willpower: Int? = null,
        @SerialName("Lore") val lore: Int? = null,
        @SerialName("Classifications") val classifications: String? = null
) {
    fun toLorcanaCard(): LorcanaCard {
        val abilitiesList =
                bodyText?.let {
                    if (it.isNotBlank()) {
                        listOf(it)
                    } else {
                        null
                    }
                }

        val classificationsList =
                classifications?.split(",")?.map { it.trim() }?.filter { it.isNotBlank() }

        return LorcanaCard(
                id = setId?.let { "$it-${setNum ?: ""}" },
                name = name,
                cost = cost,
                color = color,
                inkwell = inkable,
                type = type,
                rarity = rarity,
                set = setId,
                setNumber = setNum,
                flavorText = flavorText ?: "",
                illustrator = artist,
                imageUrl = image,
                abilities = abilitiesList,
                strength = strength,
                willpower = willpower,
                lore = lore
        )
    }
}

// 既存のLorcanaCardモデル（互換性のため維持）
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

// カードバリアント
@Serializable
data class CardVariant(
        val set: String? = null,
        val id: Int? = null,
        val dreamborn: String? = null,
        val ravensburger: RavensburgerInfo? = null,
        val rarity: String? = null,
        val illustrator: String? = null
)

// Ravensburger情報
@Serializable
data class RavensburgerInfo(
        val en: String? = null,
        val fr: String? = null,
        val de: String? = null,
        val it: String? = null,
        val zh: String? = null,
        val ja: String? = null,
        @SerialName("culture_invariant_id") val cultureInvariantId: Int? = null,
        @SerialName("sort_number") val sortNumber: Int? = null
)

@Serializable
data class CardLanguages(
        val en: LanguageData? = null,
        val fr: LanguageData? = null,
        val de: LanguageData? = null,
        val zh: LanguageData? = null,
        val ja: LanguageData? = null
)

// 言語データ
@Serializable
data class LanguageData(val name: String, val title: String, val flavour: String? = null)

@Serializable
data class CardClassification(val slug: String, val en: String, val fr: String? = null)

@Serializable
data class CardAbility(
        val type: String? = null,
        val title: AbilityTitle? = null,
        val text: AbilityText? = null,
        val ability: String? = null
)

@Serializable data class AbilityTitle(val en: String? = null)

@Serializable data class AbilityText(val en: String? = null)

@Serializable data class ImageUris(val digital: DigitalImageUris? = null)

@Serializable
data class DigitalImageUris(
        val small: String? = null,
        val normal: String? = null,
        val large: String? = null
)

@Serializable
data class CardsResponse(
        val cards: List<LorcanaCard> = emptyList(),
        val total: Int? = null,
        val page: Int? = null,
        val pageSize: Int? = null
)

public object ImageUrlGenerator {
    private const val BASE_URL = "https://lorcana-api.com/images"
    private const val APOSTROPHE = "\u0027"

    private val nameShortenMap = mapOf("tramp" to "tram")

    private fun sanitizeForUrl(text: String): String {
        return text.lowercase()
                .replace("\u2019", APOSTROPHE)
                .replace("\u2018", APOSTROPHE)
                .replace("\u0060", APOSTROPHE)
                .replace("\u02BC", APOSTROPHE)
                .replace("\u02BB", APOSTROPHE)
                .replace("\u02C8", APOSTROPHE)
                .replace(",", "")
    }

    private fun toSnakeCase(text: String): String {
        return sanitizeForUrl(text).replace(" ", "_").replace("-", "_")
    }

    private fun titleToUrlPath(title: String): String {
        return sanitizeForUrl(title).replace(" ", "_")
    }

    fun generateFallbackImageUrl(enLanguage: LanguageData?): String? {
        val enName = enLanguage?.name ?: return null

        val rawTitle = enLanguage.title.trim()
        val enTitle = if (rawTitle.isBlank()) "" else rawTitle

        var characterName = toSnakeCase(enName)
        characterName = nameShortenMap[characterName] ?: characterName

        val fileName = toSnakeCase(enName)

        return if (enTitle.isEmpty()) {
            "$BASE_URL/$characterName/$fileName-large.png"
        } else {
            val cardTitle = titleToUrlPath(enTitle)
            val fileTitle = titleToUrlPath(enTitle)
            "$BASE_URL/$characterName/$cardTitle/$fileName-$fileTitle-large.png"
        }
    }
}
