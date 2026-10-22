package com.example.flashcard.data

import org.junit.Assert.assertEquals
import org.junit.Assert.assertFalse
import org.junit.Assert.assertTrue
import org.junit.Test
import java.util.concurrent.TimeUnit

class LeitnerTest {
    private val now = 1_700_000_000_000L
    private val day = TimeUnit.DAYS.toMillis(1)
    private fun card(box: Int = 1, needsReview: Boolean = false, lastReviewed: Long? = null, id: Long = 1) =
        Card(id = id, deckId = 1, term = "apple", definition = "алим", box = box, needsReview = needsReview, lastReviewed = lastReviewed)

    @Test
    fun newCardStartsInFirstBox() {
        assertEquals(1, Card(deckId = 1, term = "a", definition = "b").box)
    }

    @Test
    fun correctMovesToNextBoxAndClearsReview() {
        val result = Leitner.onCorrect(card(box = 2, needsReview = true), now)
        assertEquals(3, result.box)
        assertFalse(result.needsReview)
        assertEquals(now, result.lastReviewed)
    }

    @Test
    fun correctNeverExceedsLastBox() {
        assertEquals(5, Leitner.onCorrect(card(box = 5), now).box)
    }

    @Test
    fun incorrectReturnsToFirstBoxWithReviewFlag() {
        val result = Leitner.onIncorrect(card(box = 4), now)
        assertEquals(1, result.box)
        assertTrue(result.needsReview)
    }

    @Test
    fun lastBoxIsMastered() {
        assertTrue(Leitner.isMastered(card(box = 5)))
        assertFalse(Leitner.isMastered(card(box = 4)))
    }

    @Test
    fun dueDependsOnBoxInterval() {
        assertTrue(Leitner.isDue(card(box = 1, lastReviewed = now), now))
        assertFalse(Leitner.isDue(card(box = 3, lastReviewed = now - day), now))
        assertTrue(Leitner.isDue(card(box = 3, lastReviewed = now - 3 * day), now))
        assertTrue(Leitner.isDue(card(box = 4, needsReview = true, lastReviewed = now), now))
    }

    @Test
    fun needsReviewAndLowerBoxesComeFirst() {
        val cards = listOf(
            card(id = 1, box = 2, lastReviewed = now - 5 * day),
            card(id = 2, box = 1, needsReview = true, lastReviewed = now),
            card(id = 3, box = 1, lastReviewed = now - day),
        )
        assertEquals(listOf(2L, 3L, 1L), Leitner.dueCards(cards, now).map { it.id })
    }

    @Test
    fun answerCheckIgnoresCaseAndOuterSpaces() {
        assertTrue(Leitner.isAnswerCorrect("  АЛИМ ", "алим"))
        assertFalse(Leitner.isAnswerCorrect("алим ба", "алим"))
    }
}
