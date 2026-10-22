package com.example.flashcard.data

import androidx.room.Entity
import androidx.room.ForeignKey
import androidx.room.Index
import androidx.room.PrimaryKey

/** Нэг багц (deck). lastStudied нь жагсаалтад харагдах сүүлд суралцсан огноо (millis). */
@Entity(tableName = "decks")
data class Deck(
    @PrimaryKey(autoGenerate = true) val id: Long = 0,
    val name: String,
    val description: String = "",
    val lastStudied: Long? = null,
    val createdAt: Long = System.currentTimeMillis(),
)

/**
 * Нэг карт. box нь Leitner хайрцгийн дугаар (1..5), needsReview нь давтах тэмдэглэгээ.
 * Багц устахад түүний картууд CASCADE-ээр хамт устна.
 */
@Entity(
    tableName = "cards",
    foreignKeys = [
        ForeignKey(
            entity = Deck::class,
            parentColumns = ["id"],
            childColumns = ["deckId"],
            onDelete = ForeignKey.CASCADE,
        ),
    ],
    indices = [Index("deckId")],
)
data class Card(
    @PrimaryKey(autoGenerate = true) val id: Long = 0,
    val deckId: Long,
    val term: String,
    val definition: String,
    val box: Int = Leitner.FIRST_BOX,
    val needsReview: Boolean = false,
    val lastReviewed: Long? = null,
)

/** Багцын жагсаалтад харуулах мэдээлэл: багц + картын тоо + статистик (SQL-ээр тооцоолно). */
data class DeckSummary(
    val id: Long,
    val name: String,
    val description: String,
    val lastStudied: Long?,
    val cardCount: Int,
    val masteredCount: Int,
    val reviewCount: Int,
) {
    val masteryFraction: Float
        get() = if (cardCount == 0) 0f else masteredCount.toFloat() / cardCount
}

/** Багц засах үед хадгалах картын ноорог. id == null бол шинэ карт. */
data class CardDraft(
    val id: Long?,
    val term: String,
    val definition: String,
)
