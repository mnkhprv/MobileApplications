package com.example.flashcard.data

import android.content.Context
import android.speech.tts.TextToSpeech
import kotlinx.coroutines.flow.MutableStateFlow
import kotlinx.coroutines.flow.StateFlow
import kotlinx.coroutines.flow.asStateFlow
import java.util.Locale

enum class SpeechStatus {
    INITIALIZING,
    READY,

    /** Төхөөрөмж дээр герман хоолой суулгаагүй. */
    LANGUAGE_MISSING,
    ERROR,
}

/**
 * Герман үгийн дуудлага. Android-ийн суурилагдсан TextToSpeech (үнэгүй, интернетгүй ажиллана).
 * Repository-тэй адил FlashcardApplication дотор ганц удаа үүсгэгдэж, ViewModel-уудад дамжина.
 * UI энэ классыг шууд мэдэхгүй, зөвхөн ViewModel-ийн speak() болон speechStatus-ийг ашиглана.
 */
class PronunciationService(context: Context) : TextToSpeech.OnInitListener {
    private val _status = MutableStateFlow(SpeechStatus.INITIALIZING)
    val status: StateFlow<SpeechStatus> = _status.asStateFlow()

    private val tts = TextToSpeech(context.applicationContext, this)

    override fun onInit(initStatus: Int) {
        if (initStatus != TextToSpeech.SUCCESS) {
            _status.value = SpeechStatus.ERROR
            return
        }
        val result = tts.setLanguage(Locale.GERMAN)
        _status.value = if (result == TextToSpeech.LANG_MISSING_DATA || result == TextToSpeech.LANG_NOT_SUPPORTED) {
            SpeechStatus.LANGUAGE_MISSING
        } else {
            SpeechStatus.READY
        }
    }

    /** slow = true бол удаан дуудна. Өмнөх дуудлагыг тасалж шинээр эхэлнэ (QUEUE_FLUSH). */
    fun speak(text: String, slow: Boolean = false) {
        if (_status.value != SpeechStatus.READY || text.isBlank()) return
        tts.setSpeechRate(if (slow) 0.5f else 0.9f)
        tts.speak(text.trim(), TextToSpeech.QUEUE_FLUSH, null, text)
    }

    fun stop() {
        tts.stop()
    }
}
