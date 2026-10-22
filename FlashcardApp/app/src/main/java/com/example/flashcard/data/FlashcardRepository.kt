package com.example.flashcard.data

import androidx.room.withTransaction
import kotlinx.coroutines.flow.Flow

/** Сурах хэсэгт аль картуудыг авах вэ. */
enum class StudyFilter {
    /** Leitner-ийн дагуу одоо давтах ёстой картууд. */
    DUE,

    /** Багцын бүх карт (Leitner дарааллаар). */
    ALL,

    /** Зөвхөн needs review тэмдэглэгээтэй картууд. */
    REVIEW,
}

/** UI давхарга өгөгдлийн сантай зөвхөн энэ классаар дамжиж харьцана. */
class FlashcardRepository(private val db: FlashcardDatabase) {
    private val deckDao = db.deckDao()
    private val cardDao = db.cardDao()

    fun observeDeckSummaries(): Flow<List<DeckSummary>> = deckDao.observeSummaries()
    fun observeDeck(id: Long): Flow<Deck?> = deckDao.observeDeck(id)
    fun observeCards(deckId: Long): Flow<List<Card>> = cardDao.observeCards(deckId)

    suspend fun getDeck(id: Long): Deck? = deckDao.getDeck(id)
    suspend fun getCards(deckId: Long): List<Card> = cardDao.getCards(deckId)
    suspend fun getCard(id: Long): Card? = cardDao.getCard(id)

    /**
     * Багц болон түүний картуудыг нэг transaction-д хадгална.
     * Хуучин картын term/definition шинэчлэгдэж, ахиц (box, needsReview) нь хэвээр үлдэнэ.
     * Жагсаалтаас хасагдсан карт устна, шинэ карт 1-р хайрцагт орно.
     */
    suspend fun saveDeck(deckId: Long?, name: String, description: String, cards: List<CardDraft>): Long =
        db.withTransaction {
            val id = if (deckId == null) {
                deckDao.insert(Deck(name = name, description = description))
            } else {
                deckDao.updateInfo(deckId, name, description)
                deckId
            }
            cardDao.deleteOthers(id, cards.mapNotNull { it.id })
            cards.forEach { draft ->
                if (draft.id == null) {
                    cardDao.insert(Card(deckId = id, term = draft.term, definition = draft.definition))
                } else {
                    cardDao.updateContent(draft.id, draft.term, draft.definition)
                }
            }
            id
        }

    suspend fun deleteDeck(id: Long) = deckDao.deleteById(id)

    suspend fun saveCard(deckId: Long, cardId: Long?, term: String, definition: String) {
        if (cardId == null) {
            cardDao.insert(Card(deckId = deckId, term = term, definition = definition))
        } else {
            cardDao.updateContent(cardId, term, definition)
        }
    }

    suspend fun deleteCard(id: Long) = cardDao.deleteById(id)

    suspend fun loadSession(deckId: Long, filter: StudyFilter, now: Long = System.currentTimeMillis()): List<Card> {
        val cards = cardDao.getCards(deckId)
        return when (filter) {
            StudyFilter.DUE -> Leitner.dueCards(cards, now)
            StudyFilter.ALL -> cards.sortedWith(Leitner.studyOrder)
            StudyFilter.REVIEW -> cards.filter { it.needsReview }.sortedWith(Leitner.studyOrder)
        }
    }

    /** Хариултыг Leitner дүрмээр бүртгэж, картын ахиц болон багцын lastStudied-ийг хадгална. */
    suspend fun recordAnswer(card: Card, correct: Boolean, now: Long = System.currentTimeMillis()) {
        val updated = if (correct) Leitner.onCorrect(card, now) else Leitner.onIncorrect(card, now)
        db.withTransaction {
            cardDao.updateProgress(updated.id, updated.box, updated.needsReview, updated.lastReviewed)
            deckDao.updateLastStudied(card.deckId, now)
        }
    }
}
