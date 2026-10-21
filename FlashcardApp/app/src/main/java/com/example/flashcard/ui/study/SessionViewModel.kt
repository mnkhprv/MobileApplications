package com.example.flashcard.ui.study

import androidx.lifecycle.SavedStateHandle
import androidx.lifecycle.ViewModel
import androidx.lifecycle.viewModelScope
import com.example.flashcard.data.Card
import com.example.flashcard.data.FlashcardRepository
import com.example.flashcard.data.PronunciationService
import com.example.flashcard.data.SpeechStatus
import com.example.flashcard.data.StudyFilter
import com.example.flashcard.ui.navigation.Routes
import kotlinx.coroutines.flow.MutableStateFlow
import kotlinx.coroutines.flow.StateFlow
import kotlinx.coroutines.flow.asStateFlow
import kotlinx.coroutines.flow.combine
import kotlinx.coroutines.flow.distinctUntilChanged
import kotlinx.coroutines.flow.map
import kotlinx.coroutines.flow.update
import kotlinx.coroutines.launch

data class SessionUiState(
    val isLoading: Boolean = true,
    val deckName: String = "",
    val filter: StudyFilter = StudyFilter.DUE,
    /** Сурах хэсгийн эхэнд Leitner дарааллаар авсан картууд (хэсгийн турш өөрчлөгдөхгүй). */
    val cards: List<Card> = emptyList(),
    val deckCardCount: Int = 0,
    val index: Int = 0,
    val correct: Int = 0,
    val incorrect: Int = 0,
    val startedAt: Long = 0L,
    val finishedAt: Long = 0L,
) {
    val current: Card? get() = cards.getOrNull(index)
    val total: Int get() = cards.size
    val isFinished: Boolean get() = !isLoading && cards.isNotEmpty() && index >= cards.size
}

/** Flashcards ба Learn горимын нийтлэг логик: картуудыг ачаалах, үнэлэх, дараагийнх руу шилжих. */
abstract class SessionViewModel(
    savedStateHandle: SavedStateHandle,
    protected val repository: FlashcardRepository,
    private val pronunciation: PronunciationService,
) : ViewModel() {
    private val deckId: Long = checkNotNull(savedStateHandle[Routes.ARG_DECK_ID])

    private val _session = MutableStateFlow(SessionUiState())
    val session: StateFlow<SessionUiState> = _session.asStateFlow()

    val speechStatus: StateFlow<SpeechStatus> = pronunciation.status

    private val _autoPlay = MutableStateFlow(true)
    val autoPlay: StateFlow<Boolean> = _autoPlay.asStateFlow()

    init {
        loadSession(StudyFilter.DUE)
        // Шинэ карт гарч ирэх бүрт (TTS бэлэн, авто асаалттай бол) герман үгийг дуудна.
        viewModelScope.launch {
            combine(
                _session.map { it.current }.distinctUntilChanged(),
                pronunciation.status,
                _autoPlay,
            ) { card, status, auto -> if (auto && status == SpeechStatus.READY) card else null }
                .collect { card -> card?.let { pronunciation.speak(it.term) } }
        }
    }

    fun speak(text: String, slow: Boolean = false) = pronunciation.speak(text, slow)

    fun setAutoPlay(enabled: Boolean) {
        _autoPlay.value = enabled
    }

    override fun onCleared() {
        pronunciation.stop()
    }

    protected fun loadSession(filter: StudyFilter) {
        _session.value = SessionUiState(isLoading = true, filter = filter)
        viewModelScope.launch {
            val deck = repository.getDeck(deckId)
            val cards = repository.loadSession(deckId, filter)
            _session.value = SessionUiState(
                isLoading = false,
                deckName = deck?.name.orEmpty(),
                filter = filter,
                cards = cards,
                deckCardCount = repository.getCards(deckId).size,
                startedAt = System.currentTimeMillis(),
            )
        }
    }

    /** Одоогийн картыг Leitner дүрмээр үнэлж өгөгдлийн санд хадгална. */
    protected fun grade(card: Card, correct: Boolean) {
        _session.update {
            if (correct) it.copy(correct = it.correct + 1) else it.copy(incorrect = it.incorrect + 1)
        }
        viewModelScope.launch { repository.recordAnswer(card, correct) }
    }

    protected fun moveNext() {
        _session.update {
            val next = it.index + 1
            it.copy(index = next, finishedAt = if (next >= it.cards.size) System.currentTimeMillis() else 0L)
        }
    }
}
