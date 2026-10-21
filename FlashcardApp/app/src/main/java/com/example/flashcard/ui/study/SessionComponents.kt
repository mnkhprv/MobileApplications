package com.example.flashcard.ui.study

import androidx.compose.animation.core.animateFloatAsState
import androidx.compose.foundation.layout.Arrangement
import androidx.compose.foundation.layout.Box
import androidx.compose.foundation.layout.Column
import androidx.compose.foundation.layout.Row
import androidx.compose.foundation.layout.Spacer
import androidx.compose.foundation.layout.fillMaxSize
import androidx.compose.foundation.layout.fillMaxWidth
import androidx.compose.foundation.layout.height
import androidx.compose.foundation.layout.padding
import androidx.compose.foundation.layout.size
import androidx.compose.foundation.rememberScrollState
import androidx.compose.foundation.verticalScroll
import androidx.compose.material3.Button
import androidx.compose.material3.CircularProgressIndicator
import androidx.compose.material3.ElevatedCard
import androidx.compose.material3.LinearProgressIndicator
import androidx.compose.material3.MaterialTheme
import androidx.compose.material3.OutlinedButton
import androidx.compose.material3.Text
import androidx.compose.runtime.Composable
import androidx.compose.runtime.getValue
import androidx.compose.ui.Alignment
import androidx.compose.ui.Modifier
import androidx.compose.ui.graphics.Color
import androidx.compose.ui.text.font.FontWeight
import androidx.compose.ui.text.style.TextAlign
import androidx.compose.ui.unit.dp
import com.example.flashcard.data.StudyFilter
import com.example.flashcard.ui.components.EmptyState
import com.example.flashcard.ui.components.formatDuration
import com.example.flashcard.ui.theme.MasteredGreen
import com.example.flashcard.ui.theme.ReviewRed

/** Явцын үзүүлэлт: "3 / 20" + анимацтай progress bar. */
@Composable
fun SessionProgress(state: SessionUiState, modifier: Modifier = Modifier) {
    val position = (state.index + 1).coerceAtMost(state.total)
    val progress by animateFloatAsState(
        if (state.total == 0) 0f else state.index.toFloat() / state.total,
        label = "progress",
    )
    Column(modifier.fillMaxWidth()) {
        Row(Modifier.fillMaxWidth(), horizontalArrangement = Arrangement.SpaceBetween) {
            Text("$position / ${state.total}", style = MaterialTheme.typography.titleMedium, fontWeight = FontWeight.SemiBold)
            Text(
                "✓ ${state.correct}   ✗ ${state.incorrect}",
                style = MaterialTheme.typography.titleSmall,
                color = MaterialTheme.colorScheme.onSurfaceVariant,
            )
        }
        Spacer(Modifier.height(8.dp))
        LinearProgressIndicator(progress = { progress }, modifier = Modifier.fillMaxWidth())
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
            .padding(24.dp),
        horizontalAlignment = Alignment.CenterHorizontally,
        verticalArrangement = Arrangement.spacedBy(16.dp),
    ) {
        Text("Сурах хэсэг дууслаа! 🎉", style = MaterialTheme.typography.headlineSmall, fontWeight = FontWeight.Bold)
        ElevatedCard(Modifier.fillMaxWidth()) {
            Column(
                Modifier
                    .fillMaxWidth()
                    .padding(24.dp),
                horizontalAlignment = Alignment.CenterHorizontally,
            ) {
                Box(Modifier.size(170.dp), contentAlignment = Alignment.Center) {
                    CircularProgressIndicator(
                        progress = { animated },
                        modifier = Modifier.fillMaxSize(),
                        strokeWidth = 12.dp,
                        trackColor = MaterialTheme.colorScheme.surfaceVariant,
                    )
                    Column(horizontalAlignment = Alignment.CenterHorizontally) {
                        Text(correctLabel, style = MaterialTheme.typography.labelMedium)
                        Text(
                            "${state.correct} / ${state.total}",
                            style = MaterialTheme.typography.headlineMedium,
                            fontWeight = FontWeight.Bold,
                        )
                        Text("(${(fraction * 100).toInt()}%)", style = MaterialTheme.typography.labelMedium)
                    }
                }
                Spacer(Modifier.height(16.dp))
                Row(Modifier.fillMaxWidth(), horizontalArrangement = Arrangement.SpaceAround) {
                    SummaryStat("Мэдсэн", "${state.correct}", MasteredGreen)
                    SummaryStat("Давтах", "${state.incorrect}", ReviewRed)
                    SummaryStat(
                        "Хугацаа",
                        formatDuration(state.finishedAt - state.startedAt),
                        MaterialTheme.colorScheme.onSurface,
                    )
                }
            }
        }
        if (state.incorrect > 0) {
            OutlinedButton(onClick = onPracticeDifficult, modifier = Modifier.fillMaxWidth()) {
                Text("Давтах картуудаа дахин үзэх")
            }
        }
        OutlinedButton(onClick = onStudyAll, modifier = Modifier.fillMaxWidth()) {
            Text("Бүх картыг дахин үзэх")
        }
        Button(onClick = onBack, modifier = Modifier.fillMaxWidth()) {
            Text("Багц руу буцах")
        }
    }
}

@Composable
private fun SummaryStat(label: String, value: String, color: Color) {
    Column(horizontalAlignment = Alignment.CenterHorizontally) {
        Text(value, style = MaterialTheme.typography.titleLarge, fontWeight = FontWeight.Bold, color = color, textAlign = TextAlign.Center)
        Text(label, style = MaterialTheme.typography.labelMedium)
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
