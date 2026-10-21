package com.example.flashcard.ui.decks

import androidx.lifecycle.ViewModel
import androidx.lifecycle.viewModelScope
import com.example.flashcard.data.DeckSummary
import com.example.flashcard.data.FlashcardRepository
import kotlinx.coroutines.flow.SharingStarted
import kotlinx.coroutines.flow.StateFlow
import kotlinx.coroutines.flow.map
import kotlinx.coroutines.flow.stateIn

data class DeckListUiState(
    val decks: List<DeckSummary> = emptyList(),
    val isLoading: Boolean = true,
)

class DeckListViewModel(repository: FlashcardRepository) : ViewModel() {
    // Room-ийн Flow тул карт/ахиц өөрчлөгдөхөд жагсаалт автоматаар шинэчлэгдэнэ.
    val uiState: StateFlow<DeckListUiState> = repository.observeDeckSummaries()
        .map { DeckListUiState(decks = it, isLoading = false) }
        .stateIn(viewModelScope, SharingStarted.WhileSubscribed(5_000), DeckListUiState())
}
