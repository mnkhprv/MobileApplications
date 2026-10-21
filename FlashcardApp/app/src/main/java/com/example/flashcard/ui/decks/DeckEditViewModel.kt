package com.example.flashcard.ui.decks

import androidx.compose.runtime.getValue
import androidx.compose.runtime.mutableStateOf
import androidx.compose.runtime.setValue
import androidx.lifecycle.SavedStateHandle
import androidx.lifecycle.ViewModel
import androidx.lifecycle.viewModelScope
import com.example.flashcard.data.CardDraft
import com.example.flashcard.data.FlashcardRepository
import com.example.flashcard.ui.navigation.Routes
import kotlinx.coroutines.launch

/** Засварлаж буй нэг карт. key нь LazyColumn-д тогтвортой түлхүүр, id == null бол шинэ карт. */
data class DraftCardUi(
    val key: Long,
    val id: Long? = null,
    val term: String = "",
    val definition: String = "",
    val error: String? = null,
) {
    val isBlank get() = term.isBlank() && definition.isBlank()
}

data class DeckEditUiState(
    val isNew: Boolean = true,
    val isLoading: Boolean = true,
    val name: String = "",
    val description: String = "",
    val nameError: String? = null,
    val cards: List<DraftCardUi> = emptyList(),
    val showDeleteDialog: Boolean = false,
    val savedDeckId: Long? = null,
    val deleted: Boolean = false,
)

class DeckEditViewModel(
    savedStateHandle: SavedStateHandle,
    private val repository: FlashcardRepository,
) : ViewModel() {
    private val deckId: Long? = savedStateHandle.get<Long>(Routes.ARG_DECK_ID)?.takeIf { it > 0 }
    private var nextKey = 0L

    var uiState by mutableStateOf(DeckEditUiState(isNew = deckId == null))
        private set

    init {
        if (deckId == null) {
            uiState = uiState.copy(isLoading = false, cards = listOf(newDraft(), newDraft()))
        } else {
            viewModelScope.launch {
                val deck = repository.getDeck(deckId)
                val cards = repository.getCards(deckId)
                uiState = uiState.copy(
                    isLoading = false,
                    name = deck?.name.orEmpty(),
                    description = deck?.description.orEmpty(),
                    cards = cards.map { DraftCardUi(key = nextKey++, id = it.id, term = it.term, definition = it.definition) },
                )
            }
        }
    }

    private fun newDraft() = DraftCardUi(key = nextKey++)

    fun onNameChange(value: String) {
        uiState = uiState.copy(name = value, nameError = null)
    }

    fun onDescriptionChange(value: String) {
        uiState = uiState.copy(description = value)
    }

    fun onTermChange(key: Long, value: String) = updateCard(key) { it.copy(term = value, error = null) }

    fun onDefinitionChange(key: Long, value: String) = updateCard(key) { it.copy(definition = value, error = null) }

    fun addCard() {
        uiState = uiState.copy(cards = uiState.cards + newDraft())
    }

    fun removeCard(key: Long) {
        uiState = uiState.copy(cards = uiState.cards.filterNot { it.key == key })
    }

    private fun updateCard(key: Long, transform: (DraftCardUi) -> DraftCardUi) {
        uiState = uiState.copy(cards = uiState.cards.map { if (it.key == key) transform(it) else it })
    }

    fun save() {
        val name = uiState.name.trim()
        // Хоёулаа хоосон мөрийг үл тооно, зөвхөн нэг тал нь бөглөгдсөн бол алдаа.
        val cards = uiState.cards.map { card ->
            when {
                card.isBlank -> card
                card.term.isBlank() -> card.copy(error = "Герман үг (term) хоосон байна")
                card.definition.isBlank() -> card.copy(error = "Орчуулга (definition) хоосон байна")
                else -> card.copy(error = null)
            }
        }
        val nameError = if (name.isEmpty()) "Багцын нэр хоосон байж болохгүй" else null
        uiState = uiState.copy(nameError = nameError, cards = cards)
        if (nameError != null || cards.any { it.error != null }) return

        viewModelScope.launch {
            val id = repository.saveDeck(
                deckId = deckId,
                name = name,
                description = uiState.description.trim(),
                cards = cards.filterNot { it.isBlank }.map { CardDraft(it.id, it.term.trim(), it.definition.trim()) },
            )
            uiState = uiState.copy(savedDeckId = id)
        }
    }

    fun requestDelete() {
        uiState = uiState.copy(showDeleteDialog = true)
    }

    fun dismissDelete() {
        uiState = uiState.copy(showDeleteDialog = false)
    }

    fun confirmDelete() {
        val id = deckId ?: return
        viewModelScope.launch {
            repository.deleteDeck(id)
            uiState = uiState.copy(showDeleteDialog = false, deleted = true)
        }
    }
}
