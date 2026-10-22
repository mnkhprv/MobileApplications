package com.example.flashcard.ui.components

import androidx.compose.animation.core.animateFloatAsState
import androidx.compose.foundation.layout.Arrangement
import androidx.compose.foundation.layout.Box
import androidx.compose.foundation.layout.Column
import androidx.compose.foundation.layout.Spacer
import androidx.compose.foundation.layout.fillMaxSize
import androidx.compose.foundation.layout.height
import androidx.compose.foundation.layout.padding
import androidx.compose.foundation.layout.size
import androidx.compose.foundation.shape.RoundedCornerShape
import androidx.compose.material3.Button
import androidx.compose.material3.CircularProgressIndicator
import androidx.compose.material3.MaterialTheme
import androidx.compose.material3.Surface
import androidx.compose.material3.Text
import androidx.compose.runtime.Composable
import androidx.compose.runtime.getValue
import androidx.compose.ui.Alignment
import androidx.compose.ui.Modifier
import androidx.compose.ui.graphics.Color
import androidx.compose.ui.text.font.FontWeight
import androidx.compose.ui.text.style.TextAlign
import androidx.compose.ui.unit.Dp
import androidx.compose.ui.unit.dp
import com.example.flashcard.data.CardStatus
import com.example.flashcard.ui.theme.LearningAmber
import com.example.flashcard.ui.theme.MasteredGreen
import com.example.flashcard.ui.theme.NewGray
import com.example.flashcard.ui.theme.ReviewRed
import java.text.SimpleDateFormat
import java.util.Date
import java.util.Locale

fun CardStatus.color(): Color = when (this) {
    CardStatus.NEW -> NewGray
    CardStatus.LEARNING -> LearningAmber
    CardStatus.TO_REVIEW -> ReviewRed
    CardStatus.MASTERED -> MasteredGreen
}

@Composable
fun StatusChip(status: CardStatus, modifier: Modifier = Modifier) {
    val color = status.color()
    Surface(
        modifier = modifier,
        shape = RoundedCornerShape(50),
        color = color.copy(alpha = 0.15f),
        contentColor = color,
    ) {
        Text(
            text = status.label,
            modifier = Modifier.padding(horizontal = 10.dp, vertical = 4.dp),
            style = MaterialTheme.typography.labelMedium,
            fontWeight = FontWeight.SemiBold,
        )
    }
}

/** Эзэмшлийн хувийг харуулах дугуй (анимацтай). */
@Composable
fun MasteryRing(fraction: Float, modifier: Modifier = Modifier, size: Dp = 52.dp) {
    val animated by animateFloatAsState(fraction, label = "mastery")
    Box(modifier.size(size), contentAlignment = Alignment.Center) {
        CircularProgressIndicator(
            progress = { animated },
            modifier = Modifier.fillMaxSize(),
            color = MasteredGreen,
            trackColor = MaterialTheme.colorScheme.surfaceVariant,
            strokeWidth = 5.dp,
        )
        Text(
            "${(fraction * 100).toInt()}%",
            style = MaterialTheme.typography.labelMedium,
            fontWeight = FontWeight.Bold,
        )
    }
}

@Composable
fun EmptyState(
    title: String,
    message: String,
    modifier: Modifier = Modifier,
    actionLabel: String? = null,
    onAction: () -> Unit = {},
) {
    Column(
        modifier = modifier
            .fillMaxSize()
            .padding(32.dp),
        verticalArrangement = Arrangement.Center,
        horizontalAlignment = Alignment.CenterHorizontally,
    ) {
        Text("🗂️", style = MaterialTheme.typography.displayMedium)
        Spacer(Modifier.height(16.dp))
        Text(title, style = MaterialTheme.typography.titleLarge, textAlign = TextAlign.Center)
        Spacer(Modifier.height(8.dp))
        Text(
            message,
            style = MaterialTheme.typography.bodyMedium,
            color = MaterialTheme.colorScheme.onSurfaceVariant,
            textAlign = TextAlign.Center,
        )
        if (actionLabel != null) {
            Spacer(Modifier.height(24.dp))
            Button(onClick = onAction) { Text(actionLabel) }
        }
    }
}

@Composable
fun LoadingBox(modifier: Modifier = Modifier) {
    Box(modifier.fillMaxSize(), contentAlignment = Alignment.Center) { CircularProgressIndicator() }
}

/** TextField-ийн supportingText: алдаа байвал улаан тайлбар, үгүй бол null. */
fun errorText(message: String?): (@Composable () -> Unit)? {
    if (message == null) return null
    val content: @Composable () -> Unit = { Text(message) }
    return content
}

fun formatDate(millis: Long?): String =
    if (millis == null) "Хараахан суралцаагүй"
    else SimpleDateFormat("yyyy.MM.dd HH:mm", Locale.getDefault()).format(Date(millis))

fun formatDuration(millis: Long): String {
    val totalSec = (millis / 1000).coerceAtLeast(0)
    val min = totalSec / 60
    val sec = totalSec % 60
    return if (min > 0) "${min}мин ${sec}с" else "${sec}с"
}
