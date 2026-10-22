package com.example.flashcard.ui.decks

import androidx.compose.foundation.layout.Arrangement
import androidx.compose.foundation.layout.Column
import androidx.compose.foundation.layout.PaddingValues
import androidx.compose.foundation.layout.Row
import androidx.compose.foundation.layout.Spacer
import androidx.compose.foundation.layout.fillMaxWidth
import androidx.compose.foundation.layout.height
import androidx.compose.foundation.layout.padding
import androidx.compose.foundation.layout.width
import androidx.compose.foundation.lazy.LazyColumn
import androidx.compose.foundation.lazy.items
import androidx.compose.foundation.shape.RoundedCornerShape
import androidx.compose.material.icons.Icons
import androidx.compose.material.icons.automirrored.filled.ArrowBack
import androidx.compose.material.icons.filled.Add
import androidx.compose.material.icons.filled.Clear
import androidx.compose.material.icons.filled.Edit
import androidx.compose.material.icons.filled.Search
import androidx.compose.material3.Button
import androidx.compose.material3.Card
import androidx.compose.material3.ElevatedCard
import androidx.compose.material3.ExperimentalMaterial3Api
import androidx.compose.material3.FilledTonalButton
import androidx.compose.material3.FloatingActionButton
import androidx.compose.material3.Icon
import androidx.compose.material3.IconButton
import androidx.compose.material3.LinearProgressIndicator
import androidx.compose.material3.MaterialTheme
import androidx.compose.material3.OutlinedCard
import androidx.compose.material3.OutlinedTextField
import androidx.compose.material3.Scaffold
import androidx.compose.material3.Text
import androidx.compose.material3.TopAppBar
import androidx.compose.runtime.Composable
import androidx.compose.runtime.getValue
import androidx.compose.ui.Alignment
import androidx.compose.ui.Modifier
import androidx.compose.ui.graphics.Color
import androidx.compose.ui.text.font.FontWeight
import androidx.compose.ui.text.style.TextOverflow
import androidx.compose.ui.unit.dp
import androidx.lifecycle.compose.collectAsStateWithLifecycle
import androidx.lifecycle.viewmodel.compose.viewModel
import com.example.flashcard.data.Card as FlashCard
import com.example.flashcard.data.DeckStats
import com.example.flashcard.data.Leitner
import com.example.flashcard.ui.AppViewModelProvider
import com.example.flashcard.ui.components.LoadingBox
import com.example.flashcard.ui.components.SpeakButton
import com.example.flashcard.ui.components.VoiceMissingHint
import com.example.flashcard.data.SpeechStatus
import com.example.flashcard.ui.components.StatusChip
import com.example.flashcard.ui.components.formatDate
import com.example.flashcard.ui.theme.LearningAmber
import com.example.flashcard.ui.theme.MasteredGreen
import com.example.flashcard.ui.theme.ReviewRed

@OptIn(ExperimentalMaterial3Api::class)
@Composable
fun DeckDetailScreen(
    onBack: () -> Unit,
    onEditDeck: (Long) -> Unit,
    onAddCard: (Long) -> Unit,
    onEditCard: (deckId: Long, cardId: Long) -> Unit,
    onFlashcards: (Long) -> Unit,
    onLearn: (Long) -> Unit,
    viewModel: DeckDetailViewModel = viewModel(factory = AppViewModelProvider.Factory),
) {
    val uiState by viewModel.uiState.collectAsStateWithLifecycle()
    val deckId = viewModel.deckId
    val speechStatus by viewModel.speechStatus.collectAsStateWithLifecycle()

    Scaffold(
        topBar = {
            TopAppBar(
                title = {
                    Text(uiState.deck?.name.orEmpty(), maxLines = 1, overflow = TextOverflow.Ellipsis)
                },
                navigationIcon = {
                    IconButton(onClick = onBack) {
                        Icon(Icons.AutoMirrored.Filled.ArrowBack, contentDescription = "Буцах")
                    }
                },
                actions = {
                    IconButton(onClick = { onEditDeck(deckId) }) {
                        Icon(Icons.Filled.Edit, contentDescription = "Багц засах")
                    }
                },
            )
        },
        floatingActionButton = {
            FloatingActionButton(onClick = { onAddCard(deckId) }) {
                Icon(Icons.Filled.Add, contentDescription = "Карт нэмэх")
            }
        },
    ) { padding ->
        if (uiState.isLoading) {
            LoadingBox(Modifier.padding(padding))
            return@Scaffold
        }
        LazyColumn(
            contentPadding = PaddingValues(
                start = 16.dp,
                end = 16.dp,
                top = padding.calculateTopPadding() + 8.dp,
                bottom = padding.calculateBottomPadding() + 88.dp,
            ),
            verticalArrangement = Arrangement.spacedBy(12.dp),
        ) {
            uiState.deck?.let { deck ->
                item {
                    Column {
                        if (deck.description.isNotBlank()) {
                            Text(deck.description, style = MaterialTheme.typography.bodyLarge)
                        }
                        Text(
                            "Сүүлд суралцсан: ${formatDate(deck.lastStudied)}",
                            style = MaterialTheme.typography.bodySmall,
                            color = MaterialTheme.colorScheme.onSurfaceVariant,
                        )
                    }
                }
            }
            item { StatsCard(uiState.stats) }
            item {
                StudyModes(
                    enabled = uiState.cards.isNotEmpty(),
                    dueCount = uiState.dueCount,
                    onFlashcards = { onFlashcards(deckId) },
                    onLearn = { onLearn(deckId) },
                )
            }
            item { LeitnerBoxes(uiState.stats.boxCounts) }
            item {
                Column {
                Text(
                    "Картууд (${uiState.cards.size})",
                    style = MaterialTheme.typography.titleMedium,
                    fontWeight = FontWeight.SemiBold,
                )
                VoiceMissingHint(speechStatus)
                if (uiState.cards.isNotEmpty()) {
                    Spacer(Modifier.height(8.dp))
                    OutlinedTextField(
                        value = uiState.query,
                        onValueChange = viewModel::onQueryChange,
                        modifier = Modifier.fillMaxWidth(),
                        placeholder = { Text("Хайх") },
                        leadingIcon = { Icon(Icons.Filled.Search, contentDescription = null) },
                        trailingIcon = {
                            if (uiState.query.isNotEmpty()) {
                                IconButton(onClick = { viewModel.onQueryChange("") }) {
                                    Icon(Icons.Filled.Clear, contentDescription = "Цэвэрлэх")
                                }
                            }
                        },
                        singleLine = true,
                        shape = RoundedCornerShape(50),
                    )
                }
                }
            }
            when {
                uiState.cards.isEmpty() -> item {
                    Text(
                        "Энэ багцад карт алга. + товчоор карт нэмнэ үү.",
                        color = MaterialTheme.colorScheme.onSurfaceVariant,
                    )
                }
                uiState.visibleCards.isEmpty() -> item {
                    Text("Илэрц олдсонгүй.", color = MaterialTheme.colorScheme.onSurfaceVariant)
                }
                else -> items(uiState.visibleCards, key = { it.id }) { card ->
                    CardRow(
                        card = card,
                        speechReady = speechStatus == SpeechStatus.READY,
                        onSpeak = { viewModel.speak(card.term) },
                        onClick = { onEditCard(deckId, card.id) },
                        modifier = Modifier.animateItem(),
                    )
                }
            }
        }
    }
}

@Composable
private fun StatsCard(stats: DeckStats) {
    ElevatedCard(Modifier.fillMaxWidth()) {
        Column(Modifier.padding(16.dp)) {
            Row(Modifier.fillMaxWidth(), horizontalArrangement = Arrangement.SpaceAround) {
                StatItem("Эзэмшсэн", stats.mastered, MasteredGreen)
                StatItem("Суралцаж буй", stats.learning + stats.newCount, LearningAmber)
                StatItem("Давтах", stats.toReview, ReviewRed)
            }
            Spacer(Modifier.height(12.dp))
            LinearProgressIndicator(
                progress = { stats.masteryFraction },
                modifier = Modifier.fillMaxWidth(),
                color = MasteredGreen,
            )
            Spacer(Modifier.height(4.dp))
            Text(
                "Эзэмшилт ${(stats.masteryFraction * 100).toInt()}% · нийт ${stats.total} карт",
                style = MaterialTheme.typography.bodySmall,
                color = MaterialTheme.colorScheme.onSurfaceVariant,
            )
        }
    }
}

@Composable
private fun StatItem(label: String, value: Int, color: Color) {
    Column(horizontalAlignment = Alignment.CenterHorizontally) {
        Text("$value", style = MaterialTheme.typography.headlineMedium, color = color, fontWeight = FontWeight.Bold)
        Text(label, style = MaterialTheme.typography.labelMedium)
    }
}

@Composable
private fun StudyModes(enabled: Boolean, dueCount: Int, onFlashcards: () -> Unit, onLearn: () -> Unit) {
    Column {
        Row(horizontalArrangement = Arrangement.spacedBy(12.dp)) {
            Button(onClick = onFlashcards, enabled = enabled, modifier = Modifier.weight(1f)) {
                Text("Flashcards")
            }
            FilledTonalButton(onClick = onLearn, enabled = enabled, modifier = Modifier.weight(1f)) {
                Text("Learn")
            }
        }
        if (enabled) {
            Text(
                "Одоо давтах карт: $dueCount",
                style = MaterialTheme.typography.bodySmall,
                color = MaterialTheme.colorScheme.onSurfaceVariant,
                modifier = Modifier.padding(top = 4.dp),
            )
        }
    }
}

/** Leitner хайрцаг бүрт хэдэн карт байгааг харуулна (Зураг 2). */
@Composable
private fun LeitnerBoxes(boxCounts: List<Int>) {
    Column {
        Text("Leitner хайрцаг", style = MaterialTheme.typography.titleSmall, fontWeight = FontWeight.SemiBold)
        Spacer(Modifier.height(8.dp))
        Row(horizontalArrangement = Arrangement.spacedBy(8.dp)) {
            boxCounts.forEachIndexed { index, count ->
                val box = index + 1
                Card(Modifier.weight(1f)) {
                    Column(
                        Modifier
                            .fillMaxWidth()
                            .padding(vertical = 8.dp),
                        horizontalAlignment = Alignment.CenterHorizontally,
                    ) {
                        Text("$box", style = MaterialTheme.typography.labelSmall)
                        Text("$count", style = MaterialTheme.typography.titleMedium, fontWeight = FontWeight.Bold)
                        Text(
                            Leitner.intervalDays(box).let { if (it == 0) "үргэлж" else "${it}өдөр" },
                            style = MaterialTheme.typography.labelSmall,
                            color = MaterialTheme.colorScheme.onSurfaceVariant,
                        )
                    }
                }
            }
        }
    }
}

@Composable
private fun CardRow(
    card: FlashCard,
    speechReady: Boolean,
    onSpeak: () -> Unit,
    onClick: () -> Unit,
    modifier: Modifier = Modifier,
) {
    OutlinedCard(onClick = onClick, modifier = modifier.fillMaxWidth()) {
        Row(Modifier.padding(start = 4.dp, end = 16.dp, top = 12.dp, bottom = 12.dp), verticalAlignment = Alignment.CenterVertically) {
            SpeakButton(speechReady, onClick = onSpeak)
            Column(Modifier.weight(1f)) {
                Text(card.term, style = MaterialTheme.typography.titleMedium, fontWeight = FontWeight.SemiBold)
                Text(
                    card.definition,
                    style = MaterialTheme.typography.bodyMedium,
                    color = MaterialTheme.colorScheme.onSurfaceVariant,
                    maxLines = 2,
                    overflow = TextOverflow.Ellipsis,
                )
            }
            Spacer(Modifier.width(8.dp))
            Column(horizontalAlignment = Alignment.End) {
                StatusChip(Leitner.status(card))
                Text(
                    "Хайрцаг ${card.box}",
                    style = MaterialTheme.typography.labelSmall,
                    color = MaterialTheme.colorScheme.onSurfaceVariant,
                    modifier = Modifier.padding(top = 4.dp),
                )
            }
        }
    }
}
