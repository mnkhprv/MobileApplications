package com.example.flashcard.ui.cards

import android.net.Uri
import androidx.compose.runtime.getValue
import androidx.compose.runtime.mutableStateOf
import androidx.compose.runtime.setValue
import androidx.lifecycle.SavedStateHandle
import androidx.lifecycle.ViewModel
import androidx.lifecycle.viewModelScope
import com.example.flashcard.data.Card
import com.example.flashcard.data.FlashcardRepository
import com.example.flashcard.data.PronunciationService
import com.example.flashcard.data.SpeechStatus
import kotlinx.coroutines.flow.StateFlow
import com.example.flashcard.ui.navigation.Routes
import kotlinx.coroutines.launch

data class CardEditUiState(
    val isNew: Boolean = true,
    val isLoading: Boolean = true,
    val term: String = "",
    val definition: String = "",
    val termError: String? = null,
    val definitionError: String? = null,
    /** Заавал биш зураг. null бол зураггүй. */
    val imagePath: String? = null,
    val imageError: String? = null,
    /** Засварлаж буй картын одоогийн ахиц (зөвхөн харуулах). */
    val card: Card? = null,
    val savedCount: Int = 0,
    val showDeleteDialog: Boolean = false,
    val done: Boolean = false,
)

class CardEditViewModel(
    savedStateHandle: SavedStateHandle,
    private val repository: FlashcardRepository,
    private val pronunciation: PronunciationService,
) : ViewModel() {
    private val deckId: Long = checkNotNull(savedStateHandle[Routes.ARG_DECK_ID])
    private val cardId: Long? = savedStateHandle.get<Long>(Routes.ARG_CARD_ID)?.takeIf { it > 0 }

    var uiState by mutableStateOf(CardEditUiState(isNew = cardId == null, isLoading = cardId != null))
        private set

    /** Өгөгдлийн санд хадгалагдсан зураг. Хадгалаагүй шинэ зургийг дэлгэцээс гарахад устгахад хэрэглэнэ. */
    private var savedImagePath: String? = null

    init {
        if (cardId != null) {
            viewModelScope.launch {
                val card = repository.getCard(cardId)
                uiState = uiState.copy(
                    isLoading = false,
                    term = card?.term.orEmpty(),
                    definition = card?.definition.orEmpty(),
                    imagePath = card?.imagePath,
                    card = card,
                )
                savedImagePath = card?.imagePath
            }
        }
    }

    val speechStatus: StateFlow<SpeechStatus> = pronunciation.status

    /** Бичиж буй герман үгийн дуудлагыг шалгах. */
    fun speakTerm() = pronunciation.speak(uiState.term)

    override fun onCleared() {
        pronunciation.stop()
        discardUnsavedImage()
    }

    /** Галерейгаас сонгосон зургийг аппын хавтсанд хуулна. */
    fun onImagePicked(uri: Uri) {
        viewModelScope.launch {
            val path = repository.saveImage(uri)
            if (path == null) {
                uiState = uiState.copy(imageError = "Зургийг уншиж чадсангүй")
                return@launch
            }
            discardUnsavedImage()
            uiState = uiState.copy(imagePath = path, imageError = null)
        }
    }

    fun removeImage() {
        discardUnsavedImage()
        uiState = uiState.copy(imagePath = null, imageError = null)
    }

    // Сонгосон боловч хадгалаагүй зургийн файлыг устгана (хадгалсан зургийг repository устгадаг).
    private fun discardUnsavedImage() {
        val path = uiState.imagePath
        if (path != savedImagePath) repository.deleteImage(path)
    }

    fun onTermChange(value: String) {
        uiState = uiState.copy(term = value, termError = null)
    }

    fun onDefinitionChange(value: String) {
        uiState = uiState.copy(definition = value, definitionError = null)
    }

    /** Хадгална. addAnother = true бол талбаруудыг цэвэрлээд дараагийн картыг нэмэх боломж үлдээнэ. */
    fun save(addAnother: Boolean = false) {
        val term = uiState.term.trim()
        val definition = uiState.definition.trim()
        val termError = if (term.isEmpty()) "Герман үг хоосон байж болохгүй" else null
        val definitionError = if (definition.isEmpty()) "Орчуулга хоосон байж болохгүй" else null
        if (termError != null || definitionError != null) {
            uiState = uiState.copy(termError = termError, definitionError = definitionError)
            return
        }
        viewModelScope.launch {
            repository.saveCard(deckId, cardId, term, definition, uiState.imagePath)
            savedImagePath = uiState.imagePath
            uiState = if (addAnother && cardId == null) {
                savedImagePath = null
                uiState.copy(term = "", definition = "", imagePath = null, savedCount = uiState.savedCount + 1)
            } else {
                uiState.copy(done = true)
            }
        }
    }

    fun requestDelete() {
        uiState = uiState.copy(showDeleteDialog = true)
    }

    fun dismissDelete() {
        uiState = uiState.copy(showDeleteDialog = false)
    }

    fun confirmDelete() {
        val id = cardId ?: return
        viewModelScope.launch {
            discardUnsavedImage()
            repository.deleteCard(id)
            savedImagePath = null
            uiState = uiState.copy(imagePath = null)
            uiState = uiState.copy(showDeleteDialog = false, done = true)
        }
    }
}
