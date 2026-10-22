package com.example.flashcard.ui.study

import androidx.compose.animation.AnimatedVisibility
import androidx.compose.animation.expandVertically
import androidx.compose.animation.fadeIn
import androidx.compose.foundation.layout.Arrangement
import androidx.compose.foundation.layout.Box
import androidx.compose.foundation.layout.Column
import androidx.compose.foundation.layout.Row
import androidx.compose.foundation.layout.Spacer
import androidx.compose.foundation.layout.fillMaxSize
import androidx.compose.foundation.layout.fillMaxWidth
import androidx.compose.foundation.layout.height
import androidx.compose.foundation.layout.heightIn
import androidx.compose.foundation.layout.imePadding
import androidx.compose.foundation.layout.padding
import androidx.compose.foundation.rememberScrollState
import androidx.compose.foundation.text.KeyboardActions
import androidx.compose.foundation.text.KeyboardOptions
import androidx.compose.foundation.verticalScroll
import androidx.compose.material.icons.Icons
import androidx.compose.material.icons.filled.Close
import androidx.compose.material3.Button
import androidx.compose.material3.Card
import androidx.compose.material3.CardDefaults
import androidx.compose.material3.ElevatedCard
import androidx.compose.material3.ExperimentalMaterial3Api
import androidx.compose.material3.Icon
import androidx.compose.material3.IconButton
import androidx.compose.material3.MaterialTheme
import androidx.compose.material3.OutlinedTextField
import androidx.compose.material3.Scaffold
import androidx.compose.material3.Text
import androidx.compose.material3.TextButton
import androidx.compose.material3.TopAppBar
import androidx.compose.runtime.Composable
import androidx.compose.runtime.getValue
import androidx.compose.ui.Alignment
import androidx.compose.ui.Modifier
import androidx.compose.ui.graphics.Color
import androidx.compose.ui.text.font.FontWeight
import androidx.compose.ui.text.input.ImeAction
import androidx.compose.ui.text.style.TextAlign
import androidx.compose.ui.unit.dp
import androidx.lifecycle.compose.collectAsStateWithLifecycle
import androidx.lifecycle.viewmodel.compose.viewModel
import com.example.flashcard.data.StudyFilter
import com.example.flashcard.ui.AppViewModelProvider
import com.example.flashcard.ui.components.LoadingBox
import com.example.flashcard.ui.components.SlowSpeakButton
import com.example.flashcard.ui.components.SpeakButton
import com.example.flashcard.ui.components.VoiceMissingHint
import com.example.flashcard.data.SpeechStatus
import com.example.flashcard.ui.theme.MasteredGreen
import com.example.flashcard.ui.theme.ReviewRed

@OptIn(ExperimentalMaterial3Api::class)
@Composable
fun LearnScreen(
    onBack: () -> Unit,
    viewModel: LearnViewModel = viewModel(factory = AppViewModelProvider.Factory),
) {
    val state by viewModel.session.collectAsStateWithLifecycle()
    val answer by viewModel.answer.collectAsStateWithLifecycle()
    val feedback by viewModel.feedback.collectAsStateWithLifecycle()
    val speechStatus by viewModel.speechStatus.collectAsStateWithLifecycle()

    Scaffold(
        topBar = {
            TopAppBar(
                title = { Text("Learn · ${state.deckName}") },
                navigationIcon = {
                    IconButton(onClick = onBack) { Icon(Icons.Filled.Close, contentDescription = "Хаах") }
                },
            )
        },
    ) { padding ->
        Box(
            Modifier
                .padding(padding)
                .fillMaxSize(),
        ) {
            when {
                state.isLoading -> LoadingBox()
                state.isFinished -> SessionSummary(
                    state = state,
                    correctLabel = "Зөв хариулт",
                    onPracticeDifficult = { viewModel.restart(StudyFilter.REVIEW) },
                    onStudyAll = { viewModel.restart(StudyFilter.ALL) },
                    onBack = onBack,
                )
                state.cards.isEmpty() -> NothingToStudy(
                    state = state,
                    onStudyAll = { viewModel.restart(StudyFilter.ALL) },
                    onBack = onBack,
                )
                else -> LearnContent(
                    state = state,
                    speechStatus = speechStatus,
                    onSpeak = viewModel::speak,
                    answer = answer,
                    feedback = feedback,
                    onAnswerChange = viewModel::onAnswerChange,
                    onSubmit = viewModel::submit,
                    onDontKnow = viewModel::dontKnow,
                    onNext = viewModel::next,
                )
            }
        }
    }
}

@Composable
private fun LearnContent(
    state: SessionUiState,
    speechStatus: SpeechStatus,
    onSpeak: (text: String, slow: Boolean) -> Unit,
    answer: String,
    feedback: LearnFeedback?,
    onAnswerChange: (String) -> Unit,
    onSubmit: () -> Unit,
    onDontKnow: () -> Unit,
    onNext: () -> Unit,
) {
    val card = state.current ?: return
    Column(
        Modifier
            .fillMaxSize()
            .imePadding()
            .verticalScroll(rememberScrollState())
            .padding(16.dp),
        verticalArrangement = Arrangement.spacedBy(16.dp),
    ) {
        SessionProgress(state)
        ElevatedCard(Modifier.fillMaxWidth()) {
            Column(
                Modifier
                    .fillMaxWidth()
                    .heightIn(min = 180.dp)
                    .padding(24.dp),
                horizontalAlignment = Alignment.CenterHorizontally,
                verticalArrangement = Arrangement.Center,
            ) {
                Text("Deutsch", style = MaterialTheme.typography.labelLarge, color = MaterialTheme.colorScheme.onSurfaceVariant)
                Spacer(Modifier.height(12.dp))
                Text(card.term, style = MaterialTheme.typography.displaySmall, fontWeight = FontWeight.SemiBold, textAlign = TextAlign.Center)
                Row(verticalAlignment = Alignment.CenterVertically) {
                    val ready = speechStatus == SpeechStatus.READY
                    SpeakButton(ready, onClick = { onSpeak(card.term, false) }, iconSize = 32.dp)
                    SlowSpeakButton(ready, onClick = { onSpeak(card.term, true) })
                }
                VoiceMissingHint(speechStatus)
            }
        }
        OutlinedTextField(
            value = answer,
            onValueChange = onAnswerChange,
            modifier = Modifier.fillMaxWidth(),
            label = { Text("Монгол орчуулгыг бичнэ үү") },
            enabled = feedback == null,
            singleLine = true,
            keyboardOptions = KeyboardOptions(imeAction = ImeAction.Done),
            keyboardActions = KeyboardActions(onDone = { if (feedback == null) onSubmit() else onNext() }),
        )

        AnimatedVisibility(visible = feedback != null, enter = fadeIn() + expandVertically()) {
            feedback?.let { FeedbackCard(it) }
        }

        if (feedback == null) {
            Row(horizontalArrangement = Arrangement.spacedBy(12.dp)) {
                TextButton(onClick = onDontKnow, modifier = Modifier.weight(1f)) { Text("Мэдэхгүй") }
                Button(onClick = onSubmit, enabled = answer.isNotBlank(), modifier = Modifier.weight(1f)) { Text("Шалгах") }
            }
        } else {
            Button(onClick = onNext, modifier = Modifier.fillMaxWidth()) {
                Text(if (state.index + 1 >= state.total) "Дуусгах" else "Дараах")
            }
        }
    }
}

@Composable
private fun FeedbackCard(feedback: LearnFeedback) {
    val color: Color = if (feedback.isCorrect) MasteredGreen else ReviewRed
    Card(
        modifier = Modifier.fillMaxWidth(),
        colors = CardDefaults.cardColors(containerColor = color.copy(alpha = 0.12f)),
    ) {
        Column(Modifier.padding(16.dp)) {
            Text(
                if (feedback.isCorrect) "✓ Зөв!" else "✗ Буруу",
                style = MaterialTheme.typography.titleLarge,
                color = color,
                fontWeight = FontWeight.Bold,
            )
            if (!feedback.isCorrect) {
                if (feedback.userAnswer.isNotEmpty()) {
                    Text("Таны хариулт: ${feedback.userAnswer}", style = MaterialTheme.typography.bodyMedium)
                }
                Text(
                    "Зөв хариулт: ${feedback.correctAnswer}",
                    style = MaterialTheme.typography.bodyLarge,
                    fontWeight = FontWeight.SemiBold,
                )
                Text(
                    "Карт 1-р хайрцаг руу буцаж, давтах тэмдэглэгээ авлаа.",
                    style = MaterialTheme.typography.bodySmall,
                    color = MaterialTheme.colorScheme.onSurfaceVariant,
                )
            }
        }
    }
}
