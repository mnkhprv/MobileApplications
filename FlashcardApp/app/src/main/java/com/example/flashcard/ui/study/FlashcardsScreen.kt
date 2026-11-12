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
import androidx.compose.foundation.layout.heightIn
import androidx.compose.foundation.layout.padding
import androidx.compose.foundation.shape.RoundedCornerShape
import androidx.compose.material3.AssistChip
import androidx.compose.material3.AssistChipDefaults
import androidx.compose.material3.ElevatedButton
import androidx.compose.material3.ButtonDefaults
import androidx.compose.material3.CardDefaults
import androidx.compose.material3.ElevatedCard
import androidx.compose.material3.IconButton
import androidx.compose.material3.MaterialTheme
import androidx.compose.material3.Scaffold
import androidx.compose.material3.Text
import androidx.compose.runtime.Composable
import androidx.compose.runtime.getValue
import androidx.compose.runtime.mutableStateOf
import androidx.compose.runtime.saveable.rememberSaveable
import androidx.compose.runtime.setValue
import androidx.compose.ui.Alignment
import androidx.compose.ui.Modifier
import androidx.compose.ui.graphics.Color
import androidx.compose.ui.graphics.graphicsLayer
import androidx.compose.ui.text.font.FontWeight
import androidx.compose.ui.text.style.TextAlign
import androidx.compose.ui.unit.dp
import androidx.lifecycle.compose.collectAsStateWithLifecycle
import androidx.lifecycle.viewmodel.compose.viewModel
import com.example.flashcard.data.Card
import com.example.flashcard.data.StudyFilter
import com.example.flashcard.ui.AppViewModelProvider
import com.example.flashcard.ui.components.CardImage
import com.example.flashcard.ui.components.LoadingBox
import com.example.flashcard.ui.components.SlowSpeakButton
import com.example.flashcard.ui.components.SpeakButton
import com.example.flashcard.ui.components.VoiceMissingHint
import com.example.flashcard.data.SpeechStatus
import com.example.flashcard.ui.theme.MasteredGreen
import com.example.flashcard.ui.theme.ReviewRed

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
            StudyHeader(
                title = state.deckName,
                onBack = onBack,
                state = state.takeIf { !it.isLoading && !it.isFinished },
                actions = {
                    // Авто дуудлага асаах/унтраах
                    IconButton(onClick = { viewModel.setAutoPlay(!autoPlay) }) {
                        Text(if (autoPlay) "🔊" else "🔇", style = MaterialTheme.typography.titleMedium)
                    }
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
    // Карт солигдох бүрт нүүрэн тал руу буцна. "Урд/Ар тал" товч ч энэ төлөвийг өөрчилнө.
    var flipped by rememberSaveable(state.index) { mutableStateOf(false) }
    Column(
        Modifier
            .fillMaxSize()
            .padding(horizontal = 20.dp, vertical = 16.dp),
        horizontalAlignment = Alignment.CenterHorizontally,
    ) {
        VoiceMissingHint(speechStatus, Modifier.padding(bottom = 8.dp))
        // Карт солигдоход баруун талаас гулсаж орж ирнэ.
        AnimatedContent(
            targetState = state.index,
            transitionSpec = {
                (slideInHorizontally { it } + fadeIn()) togetherWith (slideOutHorizontally { -it } + fadeOut())
            },
            modifier = Modifier.weight(1f),
            label = "cardSwap",
        ) { index ->
            state.cards.getOrNull(index)?.let {
                FlipCard(
                    card = it,
                    flipped = flipped && index == state.index,
                    onFlip = { flipped = !flipped },
                    speechReady = speechStatus == SpeechStatus.READY,
                    onSpeak = onSpeak,
                )
            }
        }
        Spacer(Modifier.height(12.dp))
        AssistChip(
            onClick = { flipped = !flipped },
            label = { Text("⇄  Урд / Ар тал") },
            shape = RoundedCornerShape(50),
            colors = AssistChipDefaults.assistChipColors(containerColor = MaterialTheme.colorScheme.surfaceContainerLowest),
        )
        Spacer(Modifier.height(12.dp))
        Row(horizontalArrangement = Arrangement.spacedBy(12.dp)) {
            AnswerButton("To review", ReviewRed, Modifier.weight(1f)) { onAnswer(false) }
            AnswerButton("I knew", MasteredGreen, Modifier.weight(1f)) { onAnswer(true) }
        }
    }
}

/** Зураг 1-ийн цагаан бөөрөнхий хариултын товч. */
@Composable
private fun AnswerButton(text: String, color: Color, modifier: Modifier = Modifier, onClick: () -> Unit) {
    ElevatedButton(
        onClick = onClick,
        modifier = modifier.height(54.dp),
        colors = ButtonDefaults.elevatedButtonColors(
            containerColor = MaterialTheme.colorScheme.surfaceContainerLowest,
            contentColor = color,
        ),
    ) { Text(text, fontWeight = FontWeight.Bold, style = MaterialTheme.typography.titleSmall) }
}

/** Тогшиход Y тэнхлэгээр 180° эргэх карт. Нүүрэн тал = term, ар тал = definition. */
@Composable
fun FlipCard(
    card: Card,
    flipped: Boolean,
    onFlip: () -> Unit,
    speechReady: Boolean,
    onSpeak: (text: String, slow: Boolean) -> Unit,
    modifier: Modifier = Modifier,
) {
    val rotation by animateFloatAsState(
        targetValue = if (flipped) 180f else 0f,
        animationSpec = tween(durationMillis = 450),
        label = "flip",
    )
    val showBack = rotation > 90f

    ElevatedCard(
        onClick = onFlip,
        modifier = modifier
            .fillMaxSize()
            .graphicsLayer {
                rotationY = rotation
                cameraDistance = 12f * density
            },
        shape = MaterialTheme.shapes.large,
        colors = CardDefaults.elevatedCardColors(
            containerColor = if (showBack) MaterialTheme.colorScheme.primaryContainer
            else MaterialTheme.colorScheme.surfaceContainerLowest,
        ),
        elevation = CardDefaults.elevatedCardElevation(defaultElevation = 6.dp),
    ) {
        Box(
            Modifier
                .fillMaxSize()
                .padding(24.dp)
                // Ар талын текст толин тусгал болохгүйн тулд дахин 180° эргүүлнэ.
                .graphicsLayer { rotationY = if (showBack) 180f else 0f },
            contentAlignment = Alignment.Center,
        ) {
            Text(
                if (showBack) "Монгол" else "Deutsch",
                style = MaterialTheme.typography.labelLarge,
                color = MaterialTheme.colorScheme.onSurfaceVariant,
                modifier = Modifier.align(Alignment.TopStart),
            )
            Text(
                "Тогшиж эргүүлнэ",
                style = MaterialTheme.typography.labelSmall,
                color = MaterialTheme.colorScheme.onSurfaceVariant,
                modifier = Modifier.align(Alignment.BottomCenter),
            )
            Column(horizontalAlignment = Alignment.CenterHorizontally) {
                // Зураг нүүрэн талд (term-тэй хамт) харагдана.
                if (!showBack && card.imagePath != null) {
                    CardImage(card.imagePath, Modifier.heightIn(max = 220.dp))
                    Spacer(Modifier.height(16.dp))
                }
                Row(verticalAlignment = Alignment.CenterVertically) {
                    Text(
                        if (showBack) card.definition else card.term,
                        style = if (showBack) MaterialTheme.typography.headlineMedium else MaterialTheme.typography.displaySmall,
                        fontWeight = FontWeight.ExtraBold,
                        textAlign = TextAlign.Center,
                        modifier = Modifier.weight(1f, fill = false),
                    )
                    // Нүүрэн талд (герман үг) дуудлагын товч. Товч дарахад карт эргэхгүй.
                    if (!showBack) {
                        SpeakButton(speechReady, onClick = { onSpeak(card.term, false) }, iconSize = 28.dp)
                    }
                }
                if (!showBack) {
                    SlowSpeakButton(speechReady, onClick = { onSpeak(card.term, true) })
                }
            }
        }
    }
}
