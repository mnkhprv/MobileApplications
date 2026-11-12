package com.example.flashcard.ui.study

import androidx.compose.animation.core.animateFloatAsState
import androidx.compose.foundation.layout.Arrangement
import androidx.compose.foundation.layout.Box
import androidx.compose.foundation.layout.Column
import androidx.compose.foundation.layout.IntrinsicSize
import androidx.compose.foundation.layout.Row
import androidx.compose.foundation.layout.RowScope
import androidx.compose.foundation.layout.Spacer
import androidx.compose.foundation.layout.fillMaxSize
import androidx.compose.foundation.layout.fillMaxWidth
import androidx.compose.foundation.layout.height
import androidx.compose.foundation.layout.heightIn
import androidx.compose.foundation.layout.padding
import androidx.compose.foundation.layout.size
import androidx.compose.foundation.layout.statusBarsPadding
import androidx.compose.foundation.layout.width
import androidx.compose.foundation.rememberScrollState
import androidx.compose.foundation.shape.CircleShape
import androidx.compose.foundation.shape.RoundedCornerShape
import androidx.compose.foundation.verticalScroll
import androidx.compose.material.icons.Icons
import androidx.compose.material.icons.automirrored.filled.ArrowBack
import androidx.compose.material.icons.filled.Close
import androidx.compose.material.icons.filled.Star
import androidx.compose.material3.Button
import androidx.compose.material3.Card
import androidx.compose.material3.CardDefaults
import androidx.compose.material3.CircularProgressIndicator
import androidx.compose.material3.HorizontalDivider
import androidx.compose.material3.Icon
import androidx.compose.material3.IconButton
import androidx.compose.material3.LinearProgressIndicator
import androidx.compose.material3.MaterialTheme
import androidx.compose.material3.OutlinedButton
import androidx.compose.material3.Surface
import androidx.compose.material3.Text
import androidx.compose.material3.TextButton
import androidx.compose.material3.VerticalDivider
import androidx.compose.runtime.Composable
import androidx.compose.runtime.getValue
import androidx.compose.ui.Alignment
import androidx.compose.ui.Modifier
import androidx.compose.ui.graphics.Color
import androidx.compose.ui.graphics.StrokeCap
import androidx.compose.ui.text.font.FontWeight
import androidx.compose.ui.text.style.TextAlign
import androidx.compose.ui.unit.dp
import com.example.flashcard.data.StudyFilter
import com.example.flashcard.ui.components.EmptyState
import com.example.flashcard.ui.components.formatDuration
import com.example.flashcard.ui.theme.Brand
import com.example.flashcard.ui.theme.LearningAmber
import com.example.flashcard.ui.theme.ReviewRed

/**
 * Сурах горимын цэнхэр толгой: "‹ Буцах", гарчиг, үйлдлүүд, доор нь явцын шугам (Зураг 1).
 * progress == null бол шугам харуулахгүй (ачаалж буй / дууссан үед).
 */
@Composable
fun StudyHeader(
    title: String,
    onBack: () -> Unit,
    state: SessionUiState?,
    actions: @Composable RowScope.() -> Unit = {},
) {
    val colors = Brand.colors
    Surface(
        modifier = Modifier.fillMaxWidth(),
        color = colors.header,
        contentColor = colors.onHeader,
        shape = RoundedCornerShape(bottomStart = 24.dp, bottomEnd = 24.dp),
        shadowElevation = 2.dp,
    ) {
        Column(
            Modifier
                .statusBarsPadding()
                .padding(start = 4.dp, end = 4.dp, top = 4.dp, bottom = 14.dp),
        ) {
            Row(
                Modifier
                    .fillMaxWidth()
                    .heightIn(min = 48.dp),
                verticalAlignment = Alignment.CenterVertically,
            ) {
                TextButton(onClick = onBack) {
                    Icon(Icons.AutoMirrored.Filled.ArrowBack, contentDescription = null, tint = colors.onHeader)
                    Spacer(Modifier.width(4.dp))
                    Text("Буцах", color = colors.onHeader)
                }
                Text(
                    title,
                    modifier = Modifier.weight(1f),
                    style = MaterialTheme.typography.titleMedium,
                    fontWeight = FontWeight.Bold,
                    textAlign = TextAlign.Center,
                    maxLines = 1,
                )
                actions()
                IconButton(onClick = onBack) { Icon(Icons.Filled.Close, contentDescription = "Хаах") }
            }
            if (state != null && state.total > 0) {
                SessionProgress(state, Modifier.padding(horizontal = 16.dp))
            }
        }
    }
}

/** Явцын үзүүлэлт: "3 / 20" + анимацтай progress bar. */
@Composable
fun SessionProgress(state: SessionUiState, modifier: Modifier = Modifier) {
    val position = (state.index + 1).coerceAtMost(state.total)
    val progress by animateFloatAsState(
        if (state.total == 0) 0f else state.index.toFloat() / state.total,
        label = "progress",
    )
    Column(modifier.fillMaxWidth()) {
        LinearProgressIndicator(
            progress = { progress },
            modifier = Modifier
                .fillMaxWidth()
                .height(8.dp),
            color = LearningAmber,
            trackColor = Brand.colors.headerField,
            strokeCap = StrokeCap.Round,
            drawStopIndicator = {},
        )
        Spacer(Modifier.height(6.dp))
        Row(Modifier.fillMaxWidth(), horizontalArrangement = Arrangement.SpaceBetween) {
            Text("$position / ${state.total}", style = MaterialTheme.typography.labelLarge, fontWeight = FontWeight.Bold)
            Text("✓ ${state.correct}   ✗ ${state.incorrect}", style = MaterialTheme.typography.labelLarge)
        }
    }
}

/** Сурах хэсэг дууссаны хураангуй (Зураг 1-ийн "Study Session Complete"). */
@Composable
fun SessionSummary(
    state: SessionUiState,
    correctLabel: String,
    onPracticeDifficult: () -> Unit,
    onStudyAll: () -> Unit,
    onBack: () -> Unit,
) {
    val fraction = if (state.total == 0) 0f else state.correct.toFloat() / state.total
    val animated by animateFloatAsState(fraction, label = "summary")
    Column(
        Modifier
            .fillMaxSize()
            .verticalScroll(rememberScrollState())
            .padding(20.dp),
        horizontalAlignment = Alignment.CenterHorizontally,
        verticalArrangement = Arrangement.spacedBy(16.dp),
    ) {
        Text(
            "Сурах хэсэг\nдууслаа!",
            style = MaterialTheme.typography.headlineMedium,
            fontWeight = FontWeight.ExtraBold,
            textAlign = TextAlign.Center,
        )
        Card(
            modifier = Modifier.fillMaxWidth(),
            shape = MaterialTheme.shapes.large,
            colors = CardDefaults.cardColors(containerColor = MaterialTheme.colorScheme.surfaceContainerLowest),
            elevation = CardDefaults.cardElevation(defaultElevation = 2.dp),
        ) {
            Column(
                Modifier
                    .fillMaxWidth()
                    .padding(20.dp),
                horizontalAlignment = Alignment.CenterHorizontally,
            ) {
                Box(Modifier.size(170.dp), contentAlignment = Alignment.Center) {
                    CircularProgressIndicator(
                        progress = { animated },
                        modifier = Modifier.fillMaxSize(),
                        strokeWidth = 14.dp,
                        trackColor = MaterialTheme.colorScheme.surfaceVariant,
                        strokeCap = StrokeCap.Round,
                        gapSize = 0.dp,
                    )
                    Column(horizontalAlignment = Alignment.CenterHorizontally) {
                        Text(correctLabel, style = MaterialTheme.typography.labelMedium)
                        Text(
                            "${state.correct} / ${state.total}",
                            style = MaterialTheme.typography.headlineMedium,
                            fontWeight = FontWeight.ExtraBold,
                        )
                        Text("(${(fraction * 100).toInt()}%)", style = MaterialTheme.typography.labelMedium)
                    }
                }
                Spacer(Modifier.height(16.dp))
                HorizontalDivider()
                Row(
                    Modifier
                        .fillMaxWidth()
                        .padding(vertical = 12.dp)
                        .height(IntrinsicSize.Min),
                    horizontalArrangement = Arrangement.SpaceEvenly,
                    verticalAlignment = Alignment.CenterVertically,
                ) {
                    SummaryStat("Зарцуулсан хугацаа", formatDuration(state.finishedAt - state.startedAt), MaterialTheme.colorScheme.onSurface)
                    VerticalDivider(Modifier.height(40.dp))
                    SummaryStat("Давтах карт", "❗ ${state.incorrect}", ReviewRed)
                }
                if (state.correct > 0) {
                    Surface(
                        shape = RoundedCornerShape(12.dp),
                        color = MaterialTheme.colorScheme.primaryContainer,
                        contentColor = MaterialTheme.colorScheme.onPrimaryContainer,
                        modifier = Modifier.fillMaxWidth(),
                    ) {
                        Row(Modifier.padding(12.dp), verticalAlignment = Alignment.CenterVertically) {
                            Surface(shape = CircleShape, color = MaterialTheme.colorScheme.primary) {
                                Icon(
                                    Icons.Filled.Star,
                                    contentDescription = null,
                                    tint = MaterialTheme.colorScheme.onPrimary,
                                    modifier = Modifier
                                        .padding(6.dp)
                                        .size(18.dp),
                                )
                            }
                            Spacer(Modifier.width(10.dp))
                            Column {
                                Text("Ахиц гарлаа!", style = MaterialTheme.typography.labelLarge, fontWeight = FontWeight.Bold)
                                Text(
                                    "${state.correct} карт дараагийн Leitner хайрцаг руу шилжлээ",
                                    style = MaterialTheme.typography.bodySmall,
                                )
                            }
                        }
                    }
                }
            }
        }
        if (state.incorrect > 0) {
            OutlinedButton(
                onClick = onPracticeDifficult,
                modifier = Modifier
                    .fillMaxWidth()
                    .height(50.dp),
            ) { Text("Давтах картуудаа дахин үзэх") }
        }
        OutlinedButton(
            onClick = onStudyAll,
            modifier = Modifier
                .fillMaxWidth()
                .height(50.dp),
        ) { Text("Бүх картыг дахин үзэх") }
        Button(
            onClick = onBack,
            modifier = Modifier
                .fillMaxWidth()
                .height(52.dp),
        ) { Text("Багц руу буцах", fontWeight = FontWeight.SemiBold) }
    }
}

@Composable
private fun SummaryStat(label: String, value: String, color: Color) {
    Column(horizontalAlignment = Alignment.CenterHorizontally) {
        Text(label, style = MaterialTheme.typography.labelMedium, color = MaterialTheme.colorScheme.onSurfaceVariant)
        Text(value, style = MaterialTheme.typography.titleLarge, fontWeight = FontWeight.Bold, color = color, textAlign = TextAlign.Center)
    }
}

/** Сонгосон шүүлтүүрээр карт олдоогүй үед. */
@Composable
fun NothingToStudy(state: SessionUiState, onStudyAll: () -> Unit, onBack: () -> Unit) {
    when {
        state.deckCardCount == 0 -> EmptyState(
            title = "Багцад карт алга",
            message = "Эхлээд багцдаа карт нэмнэ үү.",
            actionLabel = "Буцах",
            onAction = onBack,
        )
        state.filter == StudyFilter.DUE -> EmptyState(
            title = "Одоогоор давтах карт алга",
            message = "Leitner системийн дагуу бүх карт дараагийн давталтаа хүлээж байна. Хүсвэл бүх картыг давтаж болно.",
            actionLabel = "Бүх картыг үзэх",
            onAction = onStudyAll,
        )
        else -> EmptyState(
            title = "Давтах карт алга",
            message = "Needs review тэмдэглэгээтэй карт үлдсэнгүй.",
            actionLabel = "Бүх картыг үзэх",
            onAction = onStudyAll,
        )
    }
}
