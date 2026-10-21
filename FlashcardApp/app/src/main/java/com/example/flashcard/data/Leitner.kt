package com.example.flashcard.data

import java.util.concurrent.TimeUnit

/**
 * Leitner систем (Зураг 2): 5 хайрцаг.
 *  - Шинэ карт 1-р хайрцагт.
 *  - Зөв ("I knew" / Learn-д зөв) -> дараагийн хайрцаг (5-аас дээш гарахгүй).
 *  - Буруу ("To review" / Learn-д буруу) -> 1-р хайрцаг + needsReview.
 *  - 5-р хайрцагт хүрсэн карт = mastered.
 *  - Хайрцгийн дугаар өсөх тусам давтах завсар уртасна, тиймээс доод хайрцгийн карт ойр ойрхон гарна.
 */
object Leitner {
    const val FIRST_BOX = 1
    const val MAX_BOX = 5

    /** Хайрцаг бүрийн давтах завсар (өдрөөр). 1-р хайрцаг = суралцах бүрд. */
    private val INTERVAL_DAYS = intArrayOf(0, 1, 3, 7, 14)

    fun intervalDays(box: Int): Int = INTERVAL_DAYS[box.coerceIn(FIRST_BOX, MAX_BOX) - 1]

    fun onCorrect(card: Card, now: Long): Card = card.copy(
        box = (card.box + 1).coerceAtMost(MAX_BOX),
        needsReview = false,
        lastReviewed = now,
    )

    fun onIncorrect(card: Card, now: Long): Card = card.copy(
        box = FIRST_BOX,
        needsReview = true,
        lastReviewed = now,
    )

    fun isMastered(card: Card): Boolean = card.box >= MAX_BOX

    /** Карт одоо давтагдах ёстой юу: needsReview, хэзээ ч давтаагүй, эсвэл хайрцгийн завсар өнгөрсөн. */
    fun isDue(card: Card, now: Long): Boolean {
        val last = card.lastReviewed ?: return true
        if (card.needsReview) return true
        return now - last >= TimeUnit.DAYS.toMillis(intervalDays(card.box).toLong())
    }

    /** Харуулах дараалал: needsReview эхэнд, дараа нь бага дугаартай хайрцаг, дараа нь удаан давтаагүй нь. */
    val studyOrder: Comparator<Card> =
        compareByDescending<Card> { it.needsReview }
            .thenBy { it.box }
            .thenBy { it.lastReviewed ?: 0L }

    /** Одоо давтах ёстой картууд Leitner дарааллаар. */
    fun dueCards(cards: List<Card>, now: Long): List<Card> =
        cards.filter { isDue(it, now) }.sortedWith(studyOrder)

    /** Learn горимд хариуг шалгах: том/жижиг үсэг болон эхэн/төгсгөлийн хоосон зайг үл тооно. */
    fun isAnswerCorrect(answer: String, definition: String): Boolean =
        answer.trim().lowercase() == definition.trim().lowercase()

    fun status(card: Card): CardStatus = when {
        card.needsReview -> CardStatus.TO_REVIEW
        isMastered(card) -> CardStatus.MASTERED
        card.lastReviewed == null -> CardStatus.NEW
        else -> CardStatus.LEARNING
    }
}

enum class CardStatus(val label: String) {
    NEW("Шинэ"),
    LEARNING("Суралцаж буй"),
    TO_REVIEW("Давтах"),
    MASTERED("Эзэмшсэн"),
}

/** Нэг багцын статистик (Basic stats). */
data class DeckStats(
    val total: Int = 0,
    val mastered: Int = 0,
    val toReview: Int = 0,
    val learning: Int = 0,
    val newCount: Int = 0,
    val boxCounts: List<Int> = List(Leitner.MAX_BOX) { 0 },
) {
    val masteryFraction: Float get() = if (total == 0) 0f else mastered.toFloat() / total

    companion object {
        fun from(cards: List<Card>): DeckStats {
            val statuses = cards.map(Leitner::status)
            return DeckStats(
                total = cards.size,
                mastered = statuses.count { it == CardStatus.MASTERED },
                toReview = statuses.count { it == CardStatus.TO_REVIEW },
                learning = statuses.count { it == CardStatus.LEARNING },
                newCount = statuses.count { it == CardStatus.NEW },
                boxCounts = (Leitner.FIRST_BOX..Leitner.MAX_BOX).map { box -> cards.count { it.box == box } },
            )
        }
    }
}
