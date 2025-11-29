package com.loapalette.shared

import kotlin.experimental.ExperimentalObjCName
import kotlin.native.ObjCName

@OptIn(ExperimentalObjCName::class)
@ObjCName("CounterPair", exact = true)
data class CounterPair(
    val id: String = generateId(),
    var opponentPoint: Int = 0,
    var myPoint: Int = 0,
    val isOriginalColor: Boolean = true  // 最初のペアはtrue、追加ペアはfalse（対角の色）
) {
    companion object {
        private var idCounter = 0
        private fun generateId(): String {
            return "counter_pair_${idCounter++}"
        }
    }
}

@OptIn(ExperimentalObjCName::class)
@ObjCName("AddPosition", exact = true)
enum class AddPosition {
    LEFT,
    RIGHT
}

