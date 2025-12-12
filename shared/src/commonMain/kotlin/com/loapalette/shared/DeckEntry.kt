package com.loapalette.shared

import kotlin.experimental.ExperimentalObjCName
import kotlin.native.ObjCName
import kotlinx.serialization.Serializable

@OptIn(ExperimentalObjCName::class)
@ObjCName("DeckEntry", exact = true)
@Serializable
data class DeckEntry(val id: String, val card: LorcanaCard, var count: Int) {
    constructor(
            card: LorcanaCard,
            count: Int = 1
    ) : this(id = card.id ?: "", card = card, count = count)
}
