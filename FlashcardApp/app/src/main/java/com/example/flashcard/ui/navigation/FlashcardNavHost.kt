package com.example.flashcard.ui.navigation

import androidx.compose.animation.AnimatedContentTransitionScope.SlideDirection
import androidx.compose.animation.core.tween
import androidx.compose.runtime.Composable
import androidx.navigation.NavHostController
import androidx.navigation.NavType
import androidx.navigation.compose.NavHost
import androidx.navigation.compose.composable
import androidx.navigation.compose.rememberNavController
import androidx.navigation.navArgument
import com.example.flashcard.ui.cards.CardEditScreen
import com.example.flashcard.ui.decks.DeckDetailScreen
import com.example.flashcard.ui.decks.DeckEditScreen
import com.example.flashcard.ui.decks.DeckListScreen
import com.example.flashcard.ui.study.FlashcardsScreen
import com.example.flashcard.ui.study.LearnScreen

object Routes {
    const val ARG_DECK_ID = "deckId"
    const val ARG_CARD_ID = "cardId"

    const val DECKS = "decks"
    const val DECK_DETAIL = "deck/{$ARG_DECK_ID}"
    const val DECK_EDIT = "deck_edit?$ARG_DECK_ID={$ARG_DECK_ID}"
    const val CARD_EDIT = "card_edit/{$ARG_DECK_ID}?$ARG_CARD_ID={$ARG_CARD_ID}"
    const val FLASHCARDS = "flashcards/{$ARG_DECK_ID}"
    const val LEARN = "learn/{$ARG_DECK_ID}"

    fun deckDetail(deckId: Long) = "deck/$deckId"
    fun deckEdit(deckId: Long? = null) = if (deckId == null) "deck_edit" else "deck_edit?$ARG_DECK_ID=$deckId"
    fun cardEdit(deckId: Long, cardId: Long? = null) =
        if (cardId == null) "card_edit/$deckId" else "card_edit/$deckId?$ARG_CARD_ID=$cardId"
    fun flashcards(deckId: Long) = "flashcards/$deckId"
    fun learn(deckId: Long) = "learn/$deckId"
}

private val deckIdArg = navArgument(Routes.ARG_DECK_ID) { type = NavType.LongType }

/** -1 = утга дамжуулаагүй (шинэ багц / шинэ карт). */
private fun optionalIdArg(name: String) = navArgument(name) {
    type = NavType.LongType
    defaultValue = -1L
}

@Composable
fun FlashcardNavHost(navController: NavHostController = rememberNavController()) {
    val back: () -> Unit = { navController.navigateUp() }

    NavHost(
        navController = navController,
        startDestination = Routes.DECKS,
        enterTransition = { slideIntoContainer(SlideDirection.Start, tween(300)) },
        exitTransition = { slideOutOfContainer(SlideDirection.Start, tween(300)) },
        popEnterTransition = { slideIntoContainer(SlideDirection.End, tween(300)) },
        popExitTransition = { slideOutOfContainer(SlideDirection.End, tween(300)) },
    ) {
        composable(Routes.DECKS) {
            DeckListScreen(
                onDeckClick = { navController.navigate(Routes.deckDetail(it)) },
                onAddDeck = { navController.navigate(Routes.deckEdit()) },
            )
        }
        composable(Routes.DECK_DETAIL, arguments = listOf(deckIdArg)) {
            DeckDetailScreen(
                onBack = back,
                onEditDeck = { navController.navigate(Routes.deckEdit(it)) },
                onAddCard = { navController.navigate(Routes.cardEdit(it)) },
                onEditCard = { deckId, cardId -> navController.navigate(Routes.cardEdit(deckId, cardId)) },
                onFlashcards = { navController.navigate(Routes.flashcards(it)) },
                onLearn = { navController.navigate(Routes.learn(it)) },
            )
        }
        composable(Routes.DECK_EDIT, arguments = listOf(optionalIdArg(Routes.ARG_DECK_ID))) {
            DeckEditScreen(
                onBack = back,
                onSaved = { deckId, isNew ->
                    if (isNew) {
                        // Шинэ багц: засварын дэлгэцийг стекээс хасаад дэлгэрэнгүй рүү очно.
                        navController.navigate(Routes.deckDetail(deckId)) { popUpTo(Routes.DECKS) }
                    } else {
                        navController.popBackStack()
                    }
                },
                onDeleted = { navController.popBackStack(Routes.DECKS, inclusive = false) },
            )
        }
        composable(
            Routes.CARD_EDIT,
            arguments = listOf(deckIdArg, optionalIdArg(Routes.ARG_CARD_ID)),
        ) {
            CardEditScreen(onBack = back, onDone = back)
        }
        composable(Routes.FLASHCARDS, arguments = listOf(deckIdArg)) {
            FlashcardsScreen(onBack = back)
        }
        composable(Routes.LEARN, arguments = listOf(deckIdArg)) {
            LearnScreen(onBack = back)
        }
    }
}
