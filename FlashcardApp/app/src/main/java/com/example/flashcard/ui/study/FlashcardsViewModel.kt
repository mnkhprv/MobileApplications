package com.example.flashcard.ui.study

import androidx.lifecycle.SavedStateHandle
import com.example.flashcard.data.FlashcardRepository
import com.example.flashcard.data.PronunciationService
import com.example.flashcard.data.StudyFilter

class FlashcardsViewModel(
    savedStateHandle: SavedStateHandle,
    repository: FlashcardRepository,
    pronunciation: PronunciationService,
) : SessionViewModel(savedStateHandle, repository, pronunciation) {

    /** "I knew" -> knew = true (дараагийн хайрцаг), "To review" -> knew = false (1-р хайрцаг). */
    fun answer(knew: Boolean) {
        val card = session.value.current ?: return
        grade(card, knew)
        moveNext()
    }

    fun restart(filter: StudyFilter) = loadSession(filter)
}
