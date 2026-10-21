package com.example.flashcard.ui.theme

import androidx.compose.foundation.isSystemInDarkTheme
import androidx.compose.material3.MaterialTheme
import androidx.compose.material3.darkColorScheme
import androidx.compose.material3.lightColorScheme
import androidx.compose.runtime.Composable
import androidx.compose.ui.graphics.Color

// Зураг 1-ийн загвар шиг цэнхэр өнгө.
private val Blue = Color(0xFF3E6FD8)
private val BlueDark = Color(0xFFB0C6FF)

val MasteredGreen = Color(0xFF2E9D57)
val LearningAmber = Color(0xFFE0A100)
val ReviewRed = Color(0xFFD64545)
val NewGray = Color(0xFF8A8F98)

private val LightColors = lightColorScheme(
    primary = Blue,
    onPrimary = Color.White,
    primaryContainer = Color(0xFFDCE6FC),
    onPrimaryContainer = Color(0xFF0F2A66),
    secondaryContainer = Color(0xFFE6ECF8),
    background = Color(0xFFF4F6FB),
    surface = Color(0xFFF4F6FB),
    surfaceContainerLow = Color.White,
)

private val DarkColors = darkColorScheme(
    primary = BlueDark,
    onPrimary = Color(0xFF0F2A66),
    primaryContainer = Color(0xFF26467F),
    onPrimaryContainer = Color(0xFFDCE6FC),
)

@Composable
fun FlashcardTheme(darkTheme: Boolean = isSystemInDarkTheme(), content: @Composable () -> Unit) {
    MaterialTheme(
        colorScheme = if (darkTheme) DarkColors else LightColors,
        content = content,
    )
}
