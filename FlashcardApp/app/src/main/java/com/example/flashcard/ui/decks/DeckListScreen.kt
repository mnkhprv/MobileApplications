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
import androidx.compose.material.icons.Icons
import androidx.compose.material.icons.automirrored.filled.KeyboardArrowRight
import androidx.compose.material.icons.filled.Close
import androidx.compose.material.icons.filled.Search
import androidx.compose.material3.Card
import androidx.compose.material3.CardDefaults
import androidx.compose.material3.Icon
import androidx.compose.material3.IconButton
import androidx.compose.material3.MaterialTheme
import androidx.compose.material3.Scaffold
import androidx.compose.material3.Text
import androidx.compose.runtime.Composable
import androidx.compose.runtime.getValue
import androidx.compose.runtime.mutableStateOf
import androidx.compose.runtime.saveable.rememberSaveable
import androidx.compose.runtime.setValue
import androidx.compose.ui.Alignment
import androidx.compose.ui.Modifier
import androidx.compose.ui.text.font.FontWeight
import androidx.compose.ui.text.style.TextOverflow
import androidx.compose.ui.unit.dp
import androidx.lifecycle.compose.collectAsStateWithLifecycle
import androidx.lifecycle.viewmodel.compose.viewModel
import com.example.flashcard.data.DeckSummary
import com.example.flashcard.ui.AppViewModelProvider
import com.example.flashcard.ui.components.BrandHeader
import com.example.flashcard.ui.components.DeckTile
import com.example.flashcard.ui.components.EmptyState
import com.example.flashcard.ui.components.HeaderSearchField
import com.example.flashcard.ui.components.LoadingBox
import com.example.flashcard.ui.components.MasteryGauge
import com.example.flashcard.ui.components.RoundAddFab
import com.example.flashcard.ui.components.SectionTitle
import com.example.flashcard.ui.components.formatDate
import com.example.flashcard.ui.theme.MasteredGreen
import com.example.flashcard.ui.theme.ReviewRed

@Composable
fun DeckListScreen(
    onDeckClick: (Long) -> Unit,
    onAddDeck: () -> Unit,
    viewModel: DeckListViewModel = viewModel(factory = AppViewModelProvider.Factory),
) {
    val uiState by viewModel.uiState.collectAsStateWithLifecycle()
    // Хайлт нь зөвхөн дэлгэцийн харагдах байдлын төлөв тул энд хадгална.
    var searching by rememberSaveable { mutableStateOf(false) }
    var query by rememberSaveable { mutableStateOf("") }
    val decks = if (query.isBlank()) uiState.decks
    else uiState.decks.filter { it.name.contains(query.trim(), ignoreCase = true) }

    Scaffold(
        topBar = {
            BrandHeader(
                title = "Deutsch\nFlashcards",
                actions = {
                    IconButton(onClick = {
                        searching = !searching
                        if (!searching) query = ""
                    }) {
                        Icon(
                            if (searching) Icons.Filled.Close else Icons.Filled.Search,
                            contentDescription = if (searching) "Хайлт хаах" else "Хайх",
                        )
                    }
                },
                extra = if (searching) {
                    { HeaderSearchField(query, { query = it }, placeholder = "Багц хайх") }
                } else {
                    null
                },
            )
        },
        floatingActionButton = { RoundAddFab(onClick = onAddDeck, contentDescription = "Шинэ багц") },
    ) { padding ->
        when {
            uiState.isLoading -> LoadingBox(Modifier.padding(padding))
            uiState.decks.isEmpty() -> EmptyState(
                title = "Багц алга байна",
                message = "Эхний багцаа үүсгээд герман үг цээжилж эхлээрэй.",
                modifier = Modifier.padding(padding),
                actionLabel = "Багц үүсгэх",
                onAction = onAddDeck,
            )
            else -> LazyColumn(
                contentPadding = PaddingValues(
                    start = 16.dp,
                    end = 16.dp,
                    top = padding.calculateTopPadding() + 16.dp,
                    bottom = padding.calculateBottomPadding() + 88.dp,
                ),
                verticalArrangement = Arrangement.spacedBy(12.dp),
            ) {
                item { SectionTitle("Миний багцууд") }
                if (decks.isEmpty()) {
                    item {
                        Text("Илэрц олдсонгүй.", color = MaterialTheme.colorScheme.onSurfaceVariant)
                    }
                }
                items(decks, key = { it.id }) { deck ->
                    DeckRow(deck = deck, onClick = { onDeckClick(deck.id) }, modifier = Modifier.animateItem())
                }
            }
        }
    }
}

@Composable
private fun DeckRow(deck: DeckSummary, onClick: () -> Unit, modifier: Modifier = Modifier) {
    Card(
        onClick = onClick,
        modifier = modifier.fillMaxWidth(),
        shape = MaterialTheme.shapes.large,
        colors = CardDefaults.cardColors(containerColor = MaterialTheme.colorScheme.surfaceContainerLowest),
        elevation = CardDefaults.cardElevation(defaultElevation = 2.dp),
    ) {
        Row(Modifier.padding(16.dp), verticalAlignment = Alignment.CenterVertically) {
            // Зүүн тал: дүрс + картын тоо (эсвэл "Шинэ!")
            Column(horizontalAlignment = Alignment.CenterHorizontally) {
                DeckTile(deck.name)
                Spacer(Modifier.height(6.dp))
                Text(
                    if (deck.lastStudied == null) "Шинэ!" else "${deck.cardCount} карт",
                    style = MaterialTheme.typography.labelMedium,
                    fontWeight = if (deck.lastStudied == null) FontWeight.Bold else FontWeight.Normal,
                    color = if (deck.lastStudied == null) MaterialTheme.colorScheme.primary
                    else MaterialTheme.colorScheme.onSurfaceVariant,
                )
            }
            Spacer(Modifier.width(16.dp))
            Column(Modifier.weight(1f)) {
                Text(
                    deck.name,
                    style = MaterialTheme.typography.titleMedium,
                    fontWeight = FontWeight.Bold,
                    maxLines = 2,
                    overflow = TextOverflow.Ellipsis,
                )
                if (deck.lastStudied == null) {
                    Text(
                        "${deck.cardCount} карт",
                        style = MaterialTheme.typography.bodySmall,
                        color = MaterialTheme.colorScheme.onSurfaceVariant,
                    )
                } else {
                    Text(
                        "Сүүлд: ${formatDate(deck.lastStudied)}",
                        style = MaterialTheme.typography.bodySmall,
                        color = MaterialTheme.colorScheme.onSurfaceVariant,
                    )
                }
                Spacer(Modifier.height(6.dp))
                // Basic stats: эзэмшсэн болон давтах картын тоо
                Row {
                    Text(
                        "✓ ${deck.masteredCount}",
                        style = MaterialTheme.typography.labelMedium,
                        fontWeight = FontWeight.SemiBold,
                        color = MasteredGreen,
                    )
                    Spacer(Modifier.width(12.dp))
                    Text(
                        "↻ ${deck.reviewCount} давтах",
                        style = MaterialTheme.typography.labelMedium,
                        fontWeight = FontWeight.SemiBold,
                        color = ReviewRed,
                    )
                }
            }
            if (deck.lastStudied != null || deck.cardCount > 0) {
                MasteryGauge(deck.masteryFraction)
            }
            Icon(
                Icons.AutoMirrored.Filled.KeyboardArrowRight,
                contentDescription = null,
                tint = MaterialTheme.colorScheme.onSurfaceVariant,
            )
        }
    }
}
