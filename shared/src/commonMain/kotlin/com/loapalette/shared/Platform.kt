package com.loapalette.shared

import kotlinx.coroutines.Dispatchers
import kotlinx.coroutines.withContext

expect class Platform() {
    val name: String
}

expect fun getPlatformName(): String

fun createApplicationScreenMessage(): String {
    return "Kotlin Rocks on ${getPlatformName()}"
}

