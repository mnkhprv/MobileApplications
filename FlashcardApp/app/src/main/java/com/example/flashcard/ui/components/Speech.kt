package com.example.flashcard.ui.components

import androidx.compose.foundation.layout.size
import androidx.compose.material3.Icon
import androidx.compose.material3.IconButton
import androidx.compose.material3.MaterialTheme
import androidx.compose.material3.Text
import androidx.compose.material3.TextButton
import androidx.compose.runtime.Composable
import androidx.compose.ui.Modifier
import androidx.compose.ui.res.painterResource
import androidx.compose.ui.unit.Dp
import androidx.compose.ui.unit.dp
import com.example.flashcard.R
import com.example.flashcard.data.SpeechStatus

// Зөвхөн харагдах байдал: дуудлагын логик ViewModel -> PronunciationService-д байна.

@Composable
fun SpeakButton(
    enabled: Boolean,
    onClick: () -> Unit,
    modifier: Modifier = Modifier,
    iconSize: Dp = 24.dp,
) {
    IconButton(onClick = onClick, enabled = enabled, modifier = modifier) {
        Icon(
            painterResource(R.drawable.ic_volume_up),
            contentDescription = "Дуудлага сонсох",
            modifier = Modifier.size(iconSize),
        )
    }
}

@Composable
fun SlowSpeakButton(enabled: Boolean, onClick: () -> Unit, modifier: Modifier = Modifier) {
    TextButton(onClick = onClick, enabled = enabled, modifier = modifier) {
        Text("🐢 Удаан")
    }
}

@Composable
fun VoiceMissingHint(status: SpeechStatus, modifier: Modifier = Modifier) {
    val message = when (status) {
        SpeechStatus.LANGUAGE_MISSING ->
            "Герман хоолой суулгаагүй байна: Settings → Text-to-speech → Google TTS → Deutsch татна уу."
        SpeechStatus.ERROR -> "Text-to-speech ажиллахгүй байна."
        else -> return
    }
    Text(
        message,
        style = MaterialTheme.typography.bodySmall,
        color = MaterialTheme.colorScheme.error,
        modifier = modifier,
    )
}
