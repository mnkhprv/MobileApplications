package com.example.flashcard.data

import android.net.Uri
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
class FlashcardRepository(
    private val db: FlashcardDatabase,
    private val images: ImageStorage,
) {
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
     * Хуучин картын term/definition/зураг шинэчлэгдэж, ахиц (box, needsReview) нь хэвээр үлдэнэ.
     * Жагсаалтаас хасагдсан карт (зурагтайгаа) устна, шинэ карт 1-р хайрцагт орно.
     * Солигдсон/хасагдсан хуучин зургийн файлыг хадгалсны дараа устгана.
     */
    suspend fun saveDeck(deckId: Long?, name: String, description: String, cards: List<CardDraft>): Long {
        val keepIds = cards.mapNotNull { it.id }.toSet()
        val existing = if (deckId == null) emptyList() else cardDao.getCards(deckId)
        val draftImages = cards.associate { it.id to it.imagePath }
        val obsoleteImages = existing.mapNotNull { card ->
            val stillUsed = card.id in keepIds && draftImages[card.id] == card.imagePath
            card.imagePath.takeUnless { stillUsed }
        }
        val savedId = db.withTransaction {
            val id = if (deckId == null) {
                deckDao.insert(Deck(name = name, description = description))
            } else {
                deckDao.updateInfo(deckId, name, description)
                deckId
            }
            cardDao.deleteOthers(id, keepIds.toList())
            cards.forEach { draft ->
                if (draft.id == null) {
                    cardDao.insert(
                        Card(deckId = id, term = draft.term, definition = draft.definition, imagePath = draft.imagePath),
                    )
                } else {
                    cardDao.updateContent(draft.id, draft.term, draft.definition)
                    cardDao.updateImage(draft.id, draft.imagePath)
                }
            }
            id
        }
        obsoleteImages.forEach(images::delete)
        return savedId
    }

    suspend fun deleteDeck(id: Long) {
        val imagePaths = cardDao.getCards(id).mapNotNull { it.imagePath }
        deckDao.deleteById(id)
        imagePaths.forEach(images::delete)
    }

    /** imagePath == null бол зураггүй карт. Зураг солигдсон бол хуучин файлыг устгана. */
    suspend fun saveCard(deckId: Long, cardId: Long?, term: String, definition: String, imagePath: String?) {
        if (cardId == null) {
            cardDao.insert(Card(deckId = deckId, term = term, definition = definition, imagePath = imagePath))
        } else {
            val oldImage = cardDao.getCard(cardId)?.imagePath
            cardDao.updateContent(cardId, term, definition)
            cardDao.updateImage(cardId, imagePath)
            if (oldImage != imagePath) images.delete(oldImage)
        }
    }

    suspend fun deleteCard(id: Long) {
        val imagePath = cardDao.getCard(id)?.imagePath
        cardDao.deleteById(id)
        images.delete(imagePath)
    }

    suspend fun saveImage(uri: Uri): String? = images.save(uri)

    fun deleteImage(path: String?) = images.delete(path)

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
