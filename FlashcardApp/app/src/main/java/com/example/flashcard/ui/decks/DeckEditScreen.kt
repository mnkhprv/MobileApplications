package com.example.flashcard.ui.decks

import androidx.compose.foundation.layout.Arrangement
import androidx.compose.foundation.layout.Column
import androidx.compose.foundation.layout.PaddingValues
import androidx.compose.foundation.layout.Row
import androidx.compose.foundation.layout.Spacer
import androidx.compose.foundation.layout.fillMaxWidth
import androidx.compose.foundation.layout.imePadding
import androidx.compose.foundation.layout.padding
import androidx.compose.foundation.layout.width
import androidx.compose.foundation.lazy.LazyColumn
import androidx.compose.foundation.lazy.itemsIndexed
import androidx.compose.material.icons.Icons
import androidx.compose.material.icons.automirrored.filled.ArrowBack
import androidx.compose.material.icons.filled.Add
import androidx.compose.material.icons.filled.Check
import androidx.compose.material.icons.filled.Close
import androidx.compose.material.icons.filled.Delete
import androidx.compose.material3.AlertDialog
import androidx.compose.material3.ElevatedCard
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
import androidx.compose.ui.Alignment
import androidx.compose.ui.Modifier
import androidx.compose.ui.text.font.FontWeight
import androidx.compose.ui.unit.dp
import androidx.lifecycle.viewmodel.compose.viewModel
import com.example.flashcard.ui.AppViewModelProvider
import com.example.flashcard.ui.components.LoadingBox
import com.example.flashcard.ui.components.errorText

@OptIn(ExperimentalMaterial3Api::class)
@Composable
fun DeckEditScreen(
    onBack: () -> Unit,
    onSaved: (deckId: Long, isNew: Boolean) -> Unit,
    onDeleted: () -> Unit,
    viewModel: DeckEditViewModel = viewModel(factory = AppViewModelProvider.Factory),
) {
    val uiState = viewModel.uiState

    // Нэг удаагийн үйл явдал: хадгалсан/устгасан бол дэлгэцээс гарна.
    LaunchedEffect(uiState.savedDeckId) {
        uiState.savedDeckId?.let { onSaved(it, uiState.isNew) }
    }
    LaunchedEffect(uiState.deleted) {
        if (uiState.deleted) onDeleted()
    }

    Scaffold(
        topBar = {
            TopAppBar(
                title = { Text(if (uiState.isNew) "Шинэ багц" else "Багц засах") },
                navigationIcon = {
                    IconButton(onClick = onBack) {
                        Icon(Icons.AutoMirrored.Filled.ArrowBack, contentDescription = "Буцах")
                    }
                },
                actions = {
                    if (!uiState.isNew) {
                        IconButton(onClick = viewModel::requestDelete) {
                            Icon(Icons.Filled.Delete, contentDescription = "Багц устгах")
                        }
                    }
                    IconButton(onClick = viewModel::save) {
                        Icon(Icons.Filled.Check, contentDescription = "Хадгалах")
                    }
                },
            )
        },
    ) { padding ->
        if (uiState.isLoading) {
            LoadingBox(Modifier.padding(padding))
            return@Scaffold
        }
        LazyColumn(
            modifier = Modifier.imePadding(),
            contentPadding = PaddingValues(
                start = 16.dp,
                end = 16.dp,
                top = padding.calculateTopPadding() + 8.dp,
                bottom = padding.calculateBottomPadding() + 24.dp,
            ),
            verticalArrangement = Arrangement.spacedBy(12.dp),
        ) {
            item {
                OutlinedTextField(
                    value = uiState.name,
                    onValueChange = viewModel::onNameChange,
                    modifier = Modifier.fillMaxWidth(),
                    label = { Text("Багцын нэр *") },
                    isError = uiState.nameError != null,
                    supportingText = errorText(uiState.nameError),
                    singleLine = true,
                )
            }
            item {
                OutlinedTextField(
                    value = uiState.description,
                    onValueChange = viewModel::onDescriptionChange,
                    modifier = Modifier.fillMaxWidth(),
                    label = { Text("Тайлбар") },
                    minLines = 2,
                )
            }
            item {
                Text(
                    "Картууд (${uiState.cards.size})",
                    style = MaterialTheme.typography.titleMedium,
                    fontWeight = FontWeight.SemiBold,
                )
            }
            itemsIndexed(uiState.cards, key = { _, card -> card.key }) { index, card ->
                DraftCardEditor(
                    index = index,
                    card = card,
                    onTermChange = { viewModel.onTermChange(card.key, it) },
                    onDefinitionChange = { viewModel.onDefinitionChange(card.key, it) },
                    onRemove = { viewModel.removeCard(card.key) },
                    modifier = Modifier.animateItem(),
                )
            }
            item {
                OutlinedButton(onClick = viewModel::addCard, modifier = Modifier.fillMaxWidth()) {
                    Icon(Icons.Filled.Add, contentDescription = null)
                    Spacer(Modifier.width(8.dp))
                    Text("Карт нэмэх")
                }
            }
        }
    }

    if (uiState.showDeleteDialog) {
        AlertDialog(
            onDismissRequest = viewModel::dismissDelete,
            title = { Text("Багц устгах уу?") },
            text = { Text("\"${uiState.name}\" багц болон доторх бүх карт, ахицын мэдээлэл устна. Энэ үйлдлийг буцаах боломжгүй.") },
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

@Composable
private fun DraftCardEditor(
    index: Int,
    card: DraftCardUi,
    onTermChange: (String) -> Unit,
    onDefinitionChange: (String) -> Unit,
    onRemove: () -> Unit,
    modifier: Modifier = Modifier,
) {
    ElevatedCard(modifier.fillMaxWidth()) {
        Column(Modifier.padding(start = 16.dp, end = 4.dp, bottom = 12.dp)) {
            Row(verticalAlignment = Alignment.CenterVertically) {
                Text(
                    "${index + 1}",
                    style = MaterialTheme.typography.titleSmall,
                    color = MaterialTheme.colorScheme.primary,
                    modifier = Modifier.weight(1f),
                )
                IconButton(onClick = onRemove) {
                    Icon(Icons.Filled.Close, contentDescription = "Карт хасах")
                }
            }
            Column(Modifier.padding(end = 12.dp)) {
                OutlinedTextField(
                    value = card.term,
                    onValueChange = onTermChange,
                    modifier = Modifier.fillMaxWidth(),
                    label = { Text("Герман үг (term)") },
                    isError = card.error != null && card.term.isBlank(),
                )
                OutlinedTextField(
                    value = card.definition,
                    onValueChange = onDefinitionChange,
                    modifier = Modifier.fillMaxWidth(),
                    label = { Text("Монгол орчуулга (definition)") },
                    isError = card.error != null && card.definition.isBlank(),
                )
                card.error?.let {
                    Text(it, color = MaterialTheme.colorScheme.error, style = MaterialTheme.typography.bodySmall)
                }
            }
        }
    }
}
