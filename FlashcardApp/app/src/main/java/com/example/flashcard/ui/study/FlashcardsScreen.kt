package com.example.flashcard.ui.study

import androidx.compose.animation.AnimatedContent
import androidx.compose.animation.core.animateFloatAsState
import androidx.compose.animation.core.tween
import androidx.compose.animation.fadeIn
import androidx.compose.animation.fadeOut
import androidx.compose.animation.slideInHorizontally
import androidx.compose.animation.slideOutHorizontally
import androidx.compose.animation.togetherWith
import androidx.compose.foundation.layout.Arrangement
import androidx.compose.foundation.layout.Box
import androidx.compose.foundation.layout.Column
import androidx.compose.foundation.layout.Row
import androidx.compose.foundation.layout.Spacer
import androidx.compose.foundation.layout.fillMaxSize
import androidx.compose.foundation.layout.fillMaxWidth
import androidx.compose.foundation.layout.height
import androidx.compose.foundation.layout.padding
import androidx.compose.material.icons.Icons
import androidx.compose.material.icons.filled.Close
import androidx.compose.material3.Button
import androidx.compose.material3.ButtonDefaults
import androidx.compose.material3.CardDefaults
import androidx.compose.material3.ElevatedCard
import androidx.compose.material3.ExperimentalMaterial3Api
import androidx.compose.material3.Icon
import androidx.compose.material3.IconButton
import androidx.compose.material3.MaterialTheme
import androidx.compose.material3.OutlinedButton
import androidx.compose.material3.Scaffold
import androidx.compose.material3.Text
import androidx.compose.material3.TopAppBar
import androidx.compose.runtime.Composable
import androidx.compose.runtime.getValue
import androidx.compose.runtime.mutableStateOf
import androidx.compose.runtime.saveable.rememberSaveable
import androidx.compose.runtime.setValue
import androidx.compose.ui.Alignment
import androidx.compose.ui.Modifier
import androidx.compose.ui.graphics.graphicsLayer
import androidx.compose.ui.text.font.FontWeight
import androidx.compose.ui.text.style.TextAlign
import androidx.compose.ui.unit.dp
import androidx.lifecycle.compose.collectAsStateWithLifecycle
import androidx.lifecycle.viewmodel.compose.viewModel
import com.example.flashcard.data.Card
import com.example.flashcard.data.StudyFilter
import com.example.flashcard.ui.AppViewModelProvider
import com.example.flashcard.ui.components.LoadingBox
import com.example.flashcard.ui.components.SlowSpeakButton
import com.example.flashcard.ui.components.SpeakButton
import com.example.flashcard.ui.components.VoiceMissingHint
import com.example.flashcard.data.SpeechStatus
import androidx.compose.material3.Switch
import com.example.flashcard.ui.theme.MasteredGreen
import com.example.flashcard.ui.theme.ReviewRed

@OptIn(ExperimentalMaterial3Api::class)
@Composable
fun FlashcardsScreen(
    onBack: () -> Unit,
    viewModel: FlashcardsViewModel = viewModel(factory = AppViewModelProvider.Factory),
) {
    val state by viewModel.session.collectAsStateWithLifecycle()
    val speechStatus by viewModel.speechStatus.collectAsStateWithLifecycle()
    val autoPlay by viewModel.autoPlay.collectAsStateWithLifecycle()

    Scaffold(
        topBar = {
            TopAppBar(
                title = { Text("Flashcards · ${state.deckName}") },
                navigationIcon = {
                    IconButton(onClick = onBack) { Icon(Icons.Filled.Close, contentDescription = "Хаах") }
                },
                actions = {
                    Text("Авто 🔊", style = MaterialTheme.typography.labelMedium)
                    Switch(
                        checked = autoPlay,
                        onCheckedChange = viewModel::setAutoPlay,
                        modifier = Modifier.padding(horizontal = 8.dp),
                    )
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
                    correctLabel = "Мэдсэн карт",
                    onPracticeDifficult = { viewModel.restart(StudyFilter.REVIEW) },
                    onStudyAll = { viewModel.restart(StudyFilter.ALL) },
                    onBack = onBack,
                )
                state.cards.isEmpty() -> NothingToStudy(
                    state = state,
                    onStudyAll = { viewModel.restart(StudyFilter.ALL) },
                    onBack = onBack,
                )
                else -> FlashcardsContent(state, speechStatus, onSpeak = viewModel::speak, onAnswer = viewModel::answer)
            }
        }
    }
}

@Composable
private fun FlashcardsContent(
    state: SessionUiState,
    speechStatus: SpeechStatus,
    onSpeak: (text: String, slow: Boolean) -> Unit,
    onAnswer: (Boolean) -> Unit,
) {
    Column(
        Modifier
            .fillMaxSize()
            .padding(16.dp),
    ) {
        SessionProgress(state)
        VoiceMissingHint(speechStatus, Modifier.padding(top = 8.dp))
        Spacer(Modifier.height(16.dp))
        // Карт солигдоход баруун талаас гулсаж орж ирнэ.
        AnimatedContent(
            targetState = state.index,
            transitionSpec = {
                (slideInHorizontally { it } + fadeIn()) togetherWith (slideOutHorizontally { -it } + fadeOut())
            },
            modifier = Modifier.weight(1f),
            label = "cardSwap",
        ) { index ->
            state.cards.getOrNull(index)?.let { FlipCard(it, speechReady = speechStatus == SpeechStatus.READY, onSpeak = onSpeak) }
        }
        Text(
            "Картыг тогшиж эргүүлнэ үү",
            style = MaterialTheme.typography.bodySmall,
            color = MaterialTheme.colorScheme.onSurfaceVariant,
            modifier = Modifier
                .fillMaxWidth()
                .padding(vertical = 8.dp),
            textAlign = TextAlign.Center,
        )
        Row(horizontalArrangement = Arrangement.spacedBy(12.dp)) {
            OutlinedButton(
                onClick = { onAnswer(false) },
                modifier = Modifier
                    .weight(1f)
                    .height(52.dp),
                colors = ButtonDefaults.outlinedButtonColors(contentColor = ReviewRed),
            ) { Text("To review") }
            Button(
                onClick = { onAnswer(true) },
                modifier = Modifier
                    .weight(1f)
                    .height(52.dp),
                colors = ButtonDefaults.buttonColors(containerColor = MasteredGreen),
            ) { Text("I knew") }
        }
    }
}

/** Тогшиход Y тэнхлэгээр 180° эргэх карт. Нүүрэн тал = term, ар тал = definition. */
@Composable
fun FlipCard(
    card: Card,
    speechReady: Boolean,
    onSpeak: (text: String, slow: Boolean) -> Unit,
    modifier: Modifier = Modifier,
) {
    var flipped by rememberSaveable(card.id) { mutableStateOf(false) }
    val rotation by animateFloatAsState(
        targetValue = if (flipped) 180f else 0f,
        animationSpec = tween(durationMillis = 450),
        label = "flip",
    )
    val showBack = rotation > 90f

    ElevatedCard(
        onClick = { flipped = !flipped },
        modifier = modifier
            .fillMaxSize()
            .graphicsLayer {
                rotationY = rotation
                cameraDistance = 12f * density
            },
        colors = CardDefaults.elevatedCardColors(
            containerColor = if (showBack) MaterialTheme.colorScheme.primaryContainer else MaterialTheme.colorScheme.surfaceContainerLow,
        ),
    ) {
        Box(
            Modifier
                .fillMaxSize()
                .padding(24.dp)
                // Ар талын текст толин тусгал болохгүйн тулд дахин 180° эргүүлнэ.
                .graphicsLayer { rotationY = if (showBack) 180f else 0f },
            contentAlignment = Alignment.Center,
        ) {
            Column(horizontalAlignment = Alignment.CenterHorizontally) {
                Text(
                    if (showBack) "Монгол" else "Deutsch",
                    style = MaterialTheme.typography.labelLarge,
                    color = MaterialTheme.colorScheme.onSurfaceVariant,
                )
                Spacer(Modifier.height(12.dp))
                Text(
                    if (showBack) card.definition else card.term,
                    style = if (showBack) MaterialTheme.typography.headlineSmall else MaterialTheme.typography.displaySmall,
                    fontWeight = FontWeight.SemiBold,
                    textAlign = TextAlign.Center,
                )
                // Нүүрэн талд (герман үг) дуудлагын товчнууд. Товч дарахад карт эргэхгүй.
                if (!showBack) {
                    Spacer(Modifier.height(16.dp))
                    Row(verticalAlignment = Alignment.CenterVertically) {
                        SpeakButton(speechReady, onClick = { onSpeak(card.term, false) }, iconSize = 32.dp)
                        SlowSpeakButton(speechReady, onClick = { onSpeak(card.term, true) })
                    }
                }
            }
        }
    }
}
