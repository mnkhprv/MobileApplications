package com.example.flashcard.ui.cards

import androidx.compose.foundation.layout.Arrangement
import androidx.compose.foundation.layout.Column
import androidx.compose.foundation.layout.fillMaxSize
import androidx.compose.foundation.layout.fillMaxWidth
import androidx.compose.foundation.layout.imePadding
import androidx.compose.foundation.layout.padding
import androidx.compose.foundation.rememberScrollState
import androidx.compose.foundation.verticalScroll
import androidx.compose.material.icons.Icons
import androidx.compose.material.icons.automirrored.filled.ArrowBack
import androidx.compose.material.icons.filled.Delete
import androidx.compose.material3.AlertDialog
import androidx.compose.material3.Button
import androidx.compose.material3.ExperimentalMaterial3Api
import androidx.compose.material3.Icon
import androidx.compose.material3.IconButton
import androidx.compose.material3.MaterialTheme
import androidx.compose.material3.OutlinedButton
import androidx.compose.material3.OutlinedTextField
import androidx.compose.material3.Scaffold
import androidx.compose.material3.Text
import androidx.compose.material3.TextButton
import androidx.compose.material3.TopAppBar
import androidx.compose.runtime.Composable
import androidx.compose.runtime.LaunchedEffect
import androidx.compose.ui.Modifier
import androidx.compose.ui.unit.dp
import androidx.lifecycle.viewmodel.compose.viewModel
import com.example.flashcard.data.Leitner
import com.example.flashcard.ui.AppViewModelProvider
import com.example.flashcard.ui.components.LoadingBox
import com.example.flashcard.ui.components.SpeakButton
import com.example.flashcard.data.SpeechStatus
import androidx.compose.runtime.getValue
import androidx.lifecycle.compose.collectAsStateWithLifecycle
import com.example.flashcard.ui.components.errorText
import com.example.flashcard.ui.components.StatusChip
import com.example.flashcard.ui.components.formatDate

@OptIn(ExperimentalMaterial3Api::class)
@Composable
fun CardEditScreen(
    onBack: () -> Unit,
    onDone: () -> Unit,
    viewModel: CardEditViewModel = viewModel(factory = AppViewModelProvider.Factory),
) {
    val uiState = viewModel.uiState
    val speechStatus by viewModel.speechStatus.collectAsStateWithLifecycle()

    LaunchedEffect(uiState.done) {
        if (uiState.done) onDone()
    }

    Scaffold(
        topBar = {
            TopAppBar(
                title = { Text(if (uiState.isNew) "Шинэ карт" else "Карт засах") },
                navigationIcon = {
                    IconButton(onClick = onBack) {
                        Icon(Icons.AutoMirrored.Filled.ArrowBack, contentDescription = "Буцах")
                    }
                },
                actions = {
                    if (!uiState.isNew) {
                        IconButton(onClick = viewModel::requestDelete) {
                            Icon(Icons.Filled.Delete, contentDescription = "Карт устгах")
                        }
                    }
                },
            )
        },
    ) { padding ->
        if (uiState.isLoading) {
            LoadingBox(Modifier.padding(padding))
            return@Scaffold
        }
        Column(
            modifier = Modifier
                .fillMaxSize()
                .padding(padding)
                .imePadding()
                .verticalScroll(rememberScrollState())
                .padding(16.dp),
            verticalArrangement = Arrangement.spacedBy(12.dp),
        ) {
            OutlinedTextField(
                value = uiState.term,
                onValueChange = viewModel::onTermChange,
                modifier = Modifier.fillMaxWidth(),
                label = { Text("Герман үг (term) *") },
                isError = uiState.termError != null,
                supportingText = errorText(uiState.termError),
                trailingIcon = { SpeakButton(speechStatus == SpeechStatus.READY && uiState.term.isNotBlank(), onClick = viewModel::speakTerm) },
            )
            OutlinedTextField(
                value = uiState.definition,
                onValueChange = viewModel::onDefinitionChange,
                modifier = Modifier.fillMaxWidth(),
                label = { Text("Монгол орчуулга (definition) *") },
                isError = uiState.definitionError != null,
                supportingText = errorText(uiState.definitionError),
                minLines = 3,
            )

            uiState.card?.let { card ->
                StatusChip(Leitner.status(card))
                Text(
                    "Leitner хайрцаг: ${card.box} / ${Leitner.MAX_BOX} · Сүүлд давтсан: ${formatDate(card.lastReviewed)}",
                    style = MaterialTheme.typography.bodySmall,
                    color = MaterialTheme.colorScheme.onSurfaceVariant,
                )
            }
            if (uiState.savedCount > 0) {
                Text(
                    "${uiState.savedCount} карт нэмэгдлээ ✓",
                    color = MaterialTheme.colorScheme.primary,
                    style = MaterialTheme.typography.bodyMedium,
                )
            }

            Button(onClick = { viewModel.save() }, modifier = Modifier.fillMaxWidth()) {
                Text("Хадгалах")
            }
            if (uiState.isNew) {
                OutlinedButton(onClick = { viewModel.save(addAnother = true) }, modifier = Modifier.fillMaxWidth()) {
                    Text("Хадгалаад дараагийн карт нэмэх")
                }
            }
        }
    }

    if (uiState.showDeleteDialog) {
        AlertDialog(
            onDismissRequest = viewModel::dismissDelete,
            title = { Text("Карт устгах уу?") },
            text = { Text("\"${uiState.term}\" карт болон түүний ахиц устна.") },
            confirmButton = {
                TextButton(onClick = viewModel::confirmDelete) {
                    Text("Устгах", color = MaterialTheme.colorScheme.error)
                }
            },
            dismissButton = {
                TextButton(onClick = viewModel::dismissDelete) { Text("Болих") }
            },
        )
    }
}
