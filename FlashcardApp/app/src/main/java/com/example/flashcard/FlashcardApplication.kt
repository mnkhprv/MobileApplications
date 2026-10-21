package com.example.flashcard

import android.app.Application
import com.example.flashcard.data.FlashcardDatabase
import com.example.flashcard.data.FlashcardRepository
import com.example.flashcard.data.PronunciationService

/** Апп даяар ганц database/repository/дуудлагын үйлчилгээ үүсгэж хуваалцана (энгийн гар DI). */
class FlashcardApplication : Application() {
    val repository: FlashcardRepository by lazy {
        FlashcardRepository(FlashcardDatabase.getInstance(this))
    }
    val pronunciation: PronunciationService by lazy { PronunciationService(this) }
}
