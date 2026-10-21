package com.example.flashcard.data

import androidx.room.Dao
import androidx.room.Insert
import androidx.room.Query
import kotlinx.coroutines.flow.Flow

@Dao
interface DeckDao {
    // box >= 5 (Leitner.MAX_BOX) бол mastered.
    @Query(
        """
        SELECT d.id, d.name, d.description, d.lastStudied,
               COUNT(c.id) AS cardCount,
               COALESCE(SUM(CASE WHEN c.box >= 5 THEN 1 ELSE 0 END), 0) AS masteredCount,
               COALESCE(SUM(CASE WHEN c.needsReview = 1 THEN 1 ELSE 0 END), 0) AS reviewCount
        FROM decks d LEFT JOIN cards c ON c.deckId = d.id
        GROUP BY d.id
        ORDER BY COALESCE(d.lastStudied, d.createdAt) DESC
        """
    )
    fun observeSummaries(): Flow<List<DeckSummary>>

    @Query("SELECT * FROM decks WHERE id = :id")
    fun observeDeck(id: Long): Flow<Deck?>

    @Query("SELECT * FROM decks WHERE id = :id")
    suspend fun getDeck(id: Long): Deck?

    @Insert
    suspend fun insert(deck: Deck): Long

    @Query("UPDATE decks SET name = :name, description = :description WHERE id = :id")
    suspend fun updateInfo(id: Long, name: String, description: String)

    @Query("UPDATE decks SET lastStudied = :time WHERE id = :id")
    suspend fun updateLastStudied(id: Long, time: Long)

    @Query("DELETE FROM decks WHERE id = :id")
    suspend fun deleteById(id: Long)
}

@Dao
interface CardDao {
    @Query("SELECT * FROM cards WHERE deckId = :deckId ORDER BY id")
    fun observeCards(deckId: Long): Flow<List<Card>>

    @Query("SELECT * FROM cards WHERE deckId = :deckId ORDER BY id")
    suspend fun getCards(deckId: Long): List<Card>

    @Query("SELECT * FROM cards WHERE id = :id")
    suspend fun getCard(id: Long): Card?

    @Insert
    suspend fun insert(card: Card): Long

    @Query("UPDATE cards SET term = :term, definition = :definition WHERE id = :id")
    suspend fun updateContent(id: Long, term: String, definition: String)

    @Query("UPDATE cards SET box = :box, needsReview = :needsReview, lastReviewed = :lastReviewed WHERE id = :id")
    suspend fun updateProgress(id: Long, box: Int, needsReview: Boolean, lastReviewed: Long?)

    @Query("DELETE FROM cards WHERE id = :id")
    suspend fun deleteById(id: Long)

    /** Багцаас keepIds-д ороогүй бүх картыг устгана (багц засварлах үед хасагдсан картууд). */
    @Query("DELETE FROM cards WHERE deckId = :deckId AND id NOT IN (:keepIds)")
    suspend fun deleteOthers(deckId: Long, keepIds: List<Long>)
}
