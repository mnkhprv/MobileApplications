package com.example.flashcard.ui.theme

import androidx.compose.foundation.isSystemInDarkTheme
import androidx.compose.foundation.shape.RoundedCornerShape
import androidx.compose.material3.MaterialTheme
import androidx.compose.material3.Shapes
import androidx.compose.material3.darkColorScheme
import androidx.compose.material3.lightColorScheme
import androidx.compose.runtime.Composable
import androidx.compose.runtime.CompositionLocalProvider
import androidx.compose.runtime.Immutable
import androidx.compose.runtime.staticCompositionLocalOf
import androidx.compose.ui.graphics.Color
import androidx.compose.ui.unit.dp

// Зураг 1-ийн загвар: цэнхэр толгой хэсэг, цайвар саарал дэвсгэр, цагаан бөөрөнхий картууд.
private val Blue = Color(0xFF3466D1)
private val BlueDark = Color(0xFFB0C6FF)

val MasteredGreen = Color(0xFF2E9D57)
val LearningAmber = Color(0xFFE0A100)
val ReviewRed = Color(0xFFD64545)
val NewGray = Color(0xFF8A8F98)

/** Загварын толгой хэсгийн (header) өнгө. Material-ийн primary-аас цайвар цэнхэр. */
@Immutable
data class BrandColors(
    val header: Color,
    val onHeader: Color,
    val headerField: Color,
)

private val LightBrand = BrandColors(
    header = Color(0xFF6B98EE),
    onHeader = Color(0xFF0E1F47),
    headerField = Color(0xFFE6EDFB),
)

private val DarkBrand = BrandColors(
    header = Color(0xFF233E73),
    onHeader = Color(0xFFE3EBFF),
    headerField = Color(0xFF16284D),
)

val LocalBrandColors = staticCompositionLocalOf { LightBrand }

/** Ашиглах: `Brand.colors.header` */
object Brand {
    val colors: BrandColors
        @Composable get() = LocalBrandColors.current
}

private val LightColors = lightColorScheme(
    primary = Blue,
    onPrimary = Color.White,
    primaryContainer = Color(0xFFDCE6FC),
    onPrimaryContainer = Color(0xFF0F2A66),
    secondaryContainer = Color(0xFFE6ECF8),
    background = Color(0xFFEFF2F8),
    surface = Color(0xFFEFF2F8),
    surfaceContainerLowest = Color.White,
    surfaceContainerLow = Color.White,
    surfaceContainer = Color.White,
    surfaceVariant = Color(0xFFE2E7F0),
    outlineVariant = Color(0xFFDCE1EA),
)

private val DarkColors = darkColorScheme(
    primary = BlueDark,
    onPrimary = Color(0xFF0F2A66),
    primaryContainer = Color(0xFF26467F),
    onPrimaryContainer = Color(0xFFDCE6FC),
)

private val AppShapes = Shapes(
    small = RoundedCornerShape(10.dp),
    medium = RoundedCornerShape(18.dp),
    large = RoundedCornerShape(24.dp),
)

@Composable
fun FlashcardTheme(darkTheme: Boolean = isSystemInDarkTheme(), content: @Composable () -> Unit) {
    CompositionLocalProvider(LocalBrandColors provides if (darkTheme) DarkBrand else LightBrand) {
        MaterialTheme(
            colorScheme = if (darkTheme) DarkColors else LightColors,
            shapes = AppShapes,
            content = content,
        )
    }
}
