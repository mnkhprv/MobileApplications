package com.example.flashcard.ui

import androidx.lifecycle.ViewModelProvider
import androidx.lifecycle.createSavedStateHandle
import androidx.lifecycle.viewmodel.CreationExtras
import androidx.lifecycle.viewmodel.initializer
import androidx.lifecycle.viewmodel.viewModelFactory
import com.example.flashcard.FlashcardApplication
import com.example.flashcard.ui.cards.CardEditViewModel
import com.example.flashcard.ui.decks.DeckDetailViewModel
import com.example.flashcard.ui.decks.DeckEditViewModel
import com.example.flashcard.ui.decks.DeckListViewModel
import com.example.flashcard.ui.study.FlashcardsViewModel
import com.example.flashcard.ui.study.LearnViewModel

/** Бүх ViewModel-ийг repository болон навигацын аргументтай (SavedStateHandle) үүсгэх factory. */
object AppViewModelProvider {
    val Factory = viewModelFactory {
        initializer { DeckListViewModel(app().repository) }
        initializer { DeckDetailViewModel(createSavedStateHandle(), app().repository, app().pronunciation) }
        initializer { DeckEditViewModel(createSavedStateHandle(), app().repository) }
        initializer { CardEditViewModel(createSavedStateHandle(), app().repository, app().pronunciation) }
        initializer { FlashcardsViewModel(createSavedStateHandle(), app().repository, app().pronunciation) }
        initializer { LearnViewModel(createSavedStateHandle(), app().repository, app().pronunciation) }
    }
}

private fun CreationExtras.app(): FlashcardApplication =
    this[ViewModelProvider.AndroidViewModelFactory.APPLICATION_KEY] as FlashcardApplication
