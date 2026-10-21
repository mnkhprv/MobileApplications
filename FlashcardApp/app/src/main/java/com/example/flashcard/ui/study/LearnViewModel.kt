package com.example.flashcard.ui.study

import androidx.lifecycle.SavedStateHandle
import com.example.flashcard.data.FlashcardRepository
import com.example.flashcard.data.PronunciationService
import com.example.flashcard.data.Leitner
import com.example.flashcard.data.StudyFilter
import kotlinx.coroutines.flow.MutableStateFlow
import kotlinx.coroutines.flow.StateFlow
import kotlinx.coroutines.flow.asStateFlow

data class LearnFeedback(
    val isCorrect: Boolean,
    val correctAnswer: String,
    val userAnswer: String,
)

class LearnViewModel(
    savedStateHandle: SavedStateHandle,
    repository: FlashcardRepository,
    pronunciation: PronunciationService,
) : SessionViewModel(savedStateHandle, repository, pronunciation) {

    private val _answer = MutableStateFlow("")
    val answer: StateFlow<String> = _answer.asStateFlow()

    private val _feedback = MutableStateFlow<LearnFeedback?>(null)
    val feedback: StateFlow<LearnFeedback?> = _feedback.asStateFlow()

    fun onAnswerChange(value: String) {
        if (_feedback.value == null) _answer.value = value
    }

    /** Хариуг шалгана. Зөв -> дараагийн хайрцаг, буруу -> 1-р хайрцаг + needs review. */
    fun submit() {
        val card = session.value.current ?: return
        if (_feedback.value != null || _answer.value.isBlank()) return
        val correct = Leitner.isAnswerCorrect(_answer.value, card.definition)
        _feedback.value = LearnFeedback(correct, card.definition, _answer.value.trim())
        grade(card, correct)
    }

    /** "Мэдэхгүй" — буруу хариулттай адил тооцогдоно. */
    fun dontKnow() {
        val card = session.value.current ?: return
        if (_feedback.value != null) return
        _feedback.value = LearnFeedback(false, card.definition, "")
        grade(card, false)
    }

    fun next() {
        _feedback.value = null
        _answer.value = ""
        moveNext()
    }

    fun restart(filter: StudyFilter) {
        _feedback.value = null
        _answer.value = ""
        loadSession(filter)
    }
}
