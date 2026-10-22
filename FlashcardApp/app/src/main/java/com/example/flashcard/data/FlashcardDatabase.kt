package com.example.flashcard.data

import android.content.Context
import androidx.room.Database
import androidx.room.Room
import androidx.room.RoomDatabase
import androidx.sqlite.db.SupportSQLiteDatabase

@Database(entities = [Deck::class, Card::class], version = 1, exportSchema = false)
abstract class FlashcardDatabase : RoomDatabase() {
    abstract fun deckDao(): DeckDao
    abstract fun cardDao(): CardDao

    companion object {
        @Volatile
        private var instance: FlashcardDatabase? = null

        fun getInstance(context: Context): FlashcardDatabase =
            instance ?: synchronized(this) {
                instance ?: Room.databaseBuilder(
                    context.applicationContext,
                    FlashcardDatabase::class.java,
                    "flashcards.db",
                )
                    .addCallback(SeedCallback)
                    .build()
                    .also { instance = it }
            }
    }

    /** Аппыг анх суулгахад герман хэлний жишээ багцууд үүсгэнэ (герман үг -> монгол орчуулга). */
    private object SeedCallback : RoomDatabase.Callback() {
        override fun onCreate(db: SupportSQLiteDatabase) {
            val now = System.currentTimeMillis()
            SAMPLE_DECKS.forEachIndexed { index, (name, description, words) ->
                val deckId = index + 1L
                db.execSQL(
                    "INSERT INTO decks (id, name, description, lastStudied, createdAt) VALUES (?, ?, ?, NULL, ?)",
                    arrayOf<Any?>(deckId, name, description, now - index),
                )
                words.forEach { (term, definition) ->
                    db.execSQL(
                        "INSERT INTO cards (deckId, term, definition, box, needsReview, lastReviewed) VALUES (?, ?, ?, 1, 0, NULL)",
                        arrayOf<Any?>(deckId, term, definition),
                    )
                }
            }
        }
    }
}

private val SAMPLE_DECKS = listOf(
    Triple(
        "Deutsch: Grundwortschatz",
        "Герман хэлний үндсэн үгс (нэр үг артикльтайгаа)",
        listOf(
            "der Apfel" to "алим",
            "der Hund" to "нохой",
            "die Katze" to "муур",
            "das Haus" to "байшин",
            "das Wasser" to "ус",
            "das Buch" to "ном",
            "die Schule" to "сургууль",
            "der Freund" to "найз",
            "die Stadt" to "хот",
            "das Brot" to "талх",
        ),
    ),
    Triple(
        "Deutsch: Verben",
        "Түгээмэл үйл үгс",
        listOf(
            "sein" to "байх",
            "haben" to "байх (эзэмших)",
            "gehen" to "явах",
            "essen" to "идэх",
            "trinken" to "уух",
            "lernen" to "сурах",
            "sprechen" to "ярих",
            "schlafen" to "унтах",
        ),
    ),
    Triple(
        "Deutsch: Begrüßungen",
        "Мэндчилгээ, энгийн хэллэг",
        listOf(
            "Hallo" to "сайн уу",
            "Guten Morgen" to "өглөөний мэнд",
            "Danke" to "баярлалаа",
            "Bitte" to "гуйя",
            "Tschüss" to "баяртай",
            "Entschuldigung" to "уучлаарай",
        ),
    ),
)
