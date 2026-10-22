package com.example.flashcard.ui.decks

import androidx.lifecycle.SavedStateHandle
import androidx.lifecycle.ViewModel
import androidx.lifecycle.viewModelScope
import com.example.flashcard.data.Card
import com.example.flashcard.data.Deck
import com.example.flashcard.data.DeckStats
import com.example.flashcard.data.FlashcardRepository
import com.example.flashcard.data.Leitner
import com.example.flashcard.data.PronunciationService
import com.example.flashcard.data.SpeechStatus
import com.example.flashcard.ui.navigation.Routes
import kotlinx.coroutines.flow.MutableStateFlow
import kotlinx.coroutines.flow.SharingStarted
import kotlinx.coroutines.flow.StateFlow
import kotlinx.coroutines.flow.combine
import kotlinx.coroutines.flow.stateIn

data class DeckDetailUiState(
    val isLoading: Boolean = true,
    val deck: Deck? = null,
    val cards: List<Card> = emptyList(),
    val visibleCards: List<Card> = emptyList(),
    val stats: DeckStats = DeckStats(),
    val dueCount: Int = 0,
    val query: String = "",
)

class DeckDetailViewModel(
    savedStateHandle: SavedStateHandle,
    repository: FlashcardRepository,
    private val pronunciation: PronunciationService,
) : ViewModel() {
    val deckId: Long = checkNotNull(savedStateHandle[Routes.ARG_DECK_ID])

    private val query = MutableStateFlow("")

    // Карт өөрчлөгдөх бүрт (Flashcards/Learn горимын дараа ч) статистик шууд дахин тооцоологдоно.
    val uiState: StateFlow<DeckDetailUiState> = combine(
        repository.observeDeck(deckId),
        repository.observeCards(deckId),
        query,
    ) { deck, cards, q ->
        val trimmed = q.trim()
        DeckDetailUiState(
            isLoading = false,
            deck = deck,
            cards = cards,
            visibleCards = if (trimmed.isEmpty()) cards else cards.filter {
                it.term.contains(trimmed, ignoreCase = true) || it.definition.contains(trimmed, ignoreCase = true)
            },
            stats = DeckStats.from(cards),
            dueCount = Leitner.dueCards(cards, System.currentTimeMillis()).size,
            query = q,
        )
    }.stateIn(viewModelScope, SharingStarted.WhileSubscribed(5_000), DeckDetailUiState())

    val speechStatus: StateFlow<SpeechStatus> = pronunciation.status

    fun onQueryChange(value: String) {
        query.value = value
    }

    fun speak(text: String) = pronunciation.speak(text)

    override fun onCleared() {
        pronunciation.stop()
    }
}
