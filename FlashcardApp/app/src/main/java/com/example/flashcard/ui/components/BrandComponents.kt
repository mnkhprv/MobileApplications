package com.example.flashcard.ui.components

import androidx.compose.animation.core.animateFloatAsState
import androidx.compose.foundation.Canvas
import androidx.compose.foundation.background
import androidx.compose.foundation.layout.Box
import androidx.compose.foundation.layout.Column
import androidx.compose.foundation.layout.ColumnScope
import androidx.compose.foundation.layout.Row
import androidx.compose.foundation.layout.RowScope
import androidx.compose.foundation.layout.Spacer
import androidx.compose.foundation.layout.fillMaxWidth
import androidx.compose.foundation.layout.heightIn
import androidx.compose.foundation.layout.padding
import androidx.compose.foundation.layout.size
import androidx.compose.foundation.layout.statusBarsPadding
import androidx.compose.foundation.layout.width
import androidx.compose.foundation.shape.CircleShape
import androidx.compose.foundation.shape.RoundedCornerShape
import androidx.compose.material.icons.Icons
import androidx.compose.material.icons.automirrored.filled.ArrowBack
import androidx.compose.material.icons.filled.Add
import androidx.compose.material.icons.filled.Clear
import androidx.compose.material.icons.filled.Search
import androidx.compose.material3.FloatingActionButton
import androidx.compose.material3.Icon
import androidx.compose.material3.IconButton
import androidx.compose.material3.MaterialTheme
import androidx.compose.material3.Surface
import androidx.compose.material3.Text
import androidx.compose.material3.TextField
import androidx.compose.material3.TextFieldDefaults
import androidx.compose.runtime.Composable
import androidx.compose.runtime.getValue
import androidx.compose.ui.Alignment
import androidx.compose.ui.Modifier
import androidx.compose.ui.draw.clip
import androidx.compose.ui.geometry.Offset
import androidx.compose.ui.geometry.Size
import androidx.compose.ui.graphics.Color
import androidx.compose.ui.graphics.StrokeCap
import androidx.compose.ui.graphics.drawscope.Stroke
import androidx.compose.ui.text.font.FontWeight
import androidx.compose.ui.text.style.TextOverflow
import androidx.compose.ui.unit.Dp
import androidx.compose.ui.unit.dp
import com.example.flashcard.data.CardStatus
import com.example.flashcard.ui.theme.Brand
import com.example.flashcard.ui.theme.MasteredGreen

/**
 * Зураг 1-ийн цэнхэр толгой хэсэг: дээр нь буцах/үйлдлийн товчнууд, доор нь том тод гарчиг,
 * хүсвэл гарчгийн доор хайлтын талбар зэрэг нэмэлт агуулга.
 */
@Composable
fun BrandHeader(
    title: String,
    modifier: Modifier = Modifier,
    onBack: (() -> Unit)? = null,
    actions: @Composable RowScope.() -> Unit = {},
    extra: (@Composable ColumnScope.() -> Unit)? = null,
) {
    val colors = Brand.colors
    Surface(
        modifier = modifier.fillMaxWidth(),
        color = colors.header,
        contentColor = colors.onHeader,
        shape = RoundedCornerShape(bottomStart = 28.dp, bottomEnd = 28.dp),
        shadowElevation = 2.dp,
    ) {
        Column(
            Modifier
                .statusBarsPadding()
                .padding(start = 4.dp, end = 4.dp, top = 4.dp, bottom = 20.dp),
        ) {
            Row(
                Modifier
                    .fillMaxWidth()
                    .heightIn(min = 48.dp),
                verticalAlignment = Alignment.CenterVertically,
            ) {
                if (onBack != null) {
                    IconButton(onClick = onBack) {
                        Icon(Icons.AutoMirrored.Filled.ArrowBack, contentDescription = "Буцах")
                    }
                }
                Spacer(Modifier.weight(1f))
                actions()
            }
            Text(
                title,
                style = MaterialTheme.typography.headlineLarge,
                fontWeight = FontWeight.ExtraBold,
                maxLines = 3,
                overflow = TextOverflow.Ellipsis,
                modifier = Modifier.padding(horizontal = 16.dp),
            )
            if (extra != null) {
                Column(
                    Modifier
                        .padding(horizontal = 16.dp)
                        .padding(top = 14.dp),
                    content = extra,
                )
            }
        }
    }
}

/** Толгой хэсэг дотор байрлах бөөрөнхий хайлтын талбар. */
@Composable
fun HeaderSearchField(
    value: String,
    onValueChange: (String) -> Unit,
    modifier: Modifier = Modifier,
    placeholder: String = "Хайх",
) {
    val colors = Brand.colors
    TextField(
        value = value,
        onValueChange = onValueChange,
        modifier = modifier.fillMaxWidth(),
        placeholder = { Text(placeholder) },
        leadingIcon = { Icon(Icons.Filled.Search, contentDescription = null) },
        trailingIcon = {
            if (value.isNotEmpty()) {
                IconButton(onClick = { onValueChange("") }) {
                    Icon(Icons.Filled.Clear, contentDescription = "Цэвэрлэх")
                }
            }
        },
        singleLine = true,
        shape = RoundedCornerShape(14.dp),
        colors = TextFieldDefaults.colors(
            focusedContainerColor = colors.headerField,
            unfocusedContainerColor = colors.headerField,
            focusedIndicatorColor = Color.Transparent,
            unfocusedIndicatorColor = Color.Transparent,
        ),
    )
}

/** Загварын дугуй цэнхэр "+" товч. */
@Composable
fun RoundAddFab(onClick: () -> Unit, contentDescription: String, modifier: Modifier = Modifier) {
    FloatingActionButton(
        onClick = onClick,
        modifier = modifier,
        shape = CircleShape,
        containerColor = MaterialTheme.colorScheme.primary,
        contentColor = MaterialTheme.colorScheme.onPrimary,
    ) {
        Icon(Icons.Filled.Add, contentDescription = contentDescription)
    }
}

/** Хагас дугуй эзэмшлийн хэмжүүр (Зураг 1-ийн "15% Mastery"). */
@Composable
fun MasteryGauge(
    fraction: Float,
    modifier: Modifier = Modifier,
    width: Dp = 64.dp,
    label: String = "Эзэмшилт",
) {
    val animated by animateFloatAsState(fraction.coerceIn(0f, 1f), label = "gauge")
    val track = MaterialTheme.colorScheme.surfaceVariant
    Column(modifier, horizontalAlignment = Alignment.CenterHorizontally) {
        Box(Modifier.size(width = width, height = width / 2 + 6.dp), contentAlignment = Alignment.BottomCenter) {
            Canvas(Modifier.size(width = width, height = width / 2 + 6.dp)) {
                val stroke = 6.dp.toPx()
                val diameter = size.width - stroke
                val topLeft = Offset(stroke / 2, stroke / 2)
                val arcSize = Size(diameter, diameter)
                drawArc(track, 180f, 180f, false, topLeft, arcSize, style = Stroke(stroke, cap = StrokeCap.Round))
                drawArc(
                    MasteredGreen, 180f, 180f * animated, false, topLeft, arcSize,
                    style = Stroke(stroke, cap = StrokeCap.Round),
                )
            }
            Text(
                "${(fraction * 100).toInt()}%",
                style = MaterialTheme.typography.labelLarge,
                fontWeight = FontWeight.Bold,
            )
        }
        Text(label, style = MaterialTheme.typography.labelSmall, color = MaterialTheme.colorScheme.onSurfaceVariant)
    }
}

/** Өнгөт цэг + шошго (Зураг 1-ийн "● Mastered"). */
@Composable
fun StatusDot(status: CardStatus, modifier: Modifier = Modifier) {
    Row(modifier, verticalAlignment = Alignment.CenterVertically) {
        Box(
            Modifier
                .size(10.dp)
                .clip(CircleShape)
                .background(status.color()),
        )
        Spacer(Modifier.width(6.dp))
        Text(status.label, style = MaterialTheme.typography.labelLarge)
    }
}

/** Багцын дүрс: нэрийн эхний үсэгтэй өнгөт дөрвөлжин. Өнгө нь нэрээс хамаарч тогтвортой. */
@Composable
fun DeckTile(name: String, modifier: Modifier = Modifier, size: Dp = 56.dp) {
    val palette = listOf(
        Color(0xFFFFE1D6) to Color(0xFFB4441C),
        Color(0xFFDCE6FC) to Color(0xFF2753B5),
        Color(0xFFD8F1E2) to Color(0xFF1E7A45),
        Color(0xFFF1E1FA) to Color(0xFF7A3AA0),
        Color(0xFFFFF0C7) to Color(0xFF8A6200),
    )
    // "Deutsch: Verben" гэх мэт нэрийн хувьд хоёр цэгийн дараах үгийг ашиглана.
    val key = name.substringAfter(':').trim().ifEmpty { name.trim() }
    val (bg, fg) = palette[Math.floorMod(key.lowercase().hashCode(), palette.size)]
    Box(
        modifier
            .size(size)
            .clip(RoundedCornerShape(14.dp))
            .background(bg),
        contentAlignment = Alignment.Center,
    ) {
        Text(
            key.take(1).uppercase().ifEmpty { "?" },
            style = MaterialTheme.typography.headlineSmall,
            fontWeight = FontWeight.ExtraBold,
            color = fg,
        )
    }
}

/** Гарчиг + жижиг тайлбар бүхий хэсгийн гарчиг. */
@Composable
fun SectionTitle(text: String, modifier: Modifier = Modifier) {
    Text(
        text,
        style = MaterialTheme.typography.titleMedium,
        fontWeight = FontWeight.Bold,
        modifier = modifier.padding(top = 4.dp, bottom = 2.dp),
    )
}
