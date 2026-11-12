package com.example.flashcard.ui.decks

import androidx.activity.compose.rememberLauncherForActivityResult
import androidx.activity.result.PickVisualMediaRequest
import androidx.activity.result.contract.ActivityResultContracts.PickVisualMedia
import androidx.compose.foundation.BorderStroke
import androidx.compose.foundation.layout.Arrangement
import androidx.compose.foundation.layout.Box
import androidx.compose.foundation.layout.Column
import androidx.compose.foundation.layout.PaddingValues
import androidx.compose.foundation.layout.Row
import androidx.compose.foundation.layout.Spacer
import androidx.compose.foundation.layout.fillMaxWidth
import androidx.compose.foundation.layout.height
import androidx.compose.foundation.layout.heightIn
import androidx.compose.foundation.layout.imePadding
import androidx.compose.foundation.layout.padding
import androidx.compose.foundation.layout.width
import androidx.compose.foundation.lazy.LazyColumn
import androidx.compose.foundation.lazy.itemsIndexed
import androidx.compose.foundation.shape.RoundedCornerShape
import androidx.compose.material.icons.Icons
import androidx.compose.material.icons.filled.Add
import androidx.compose.material.icons.filled.Check
import androidx.compose.material.icons.filled.Close
import androidx.compose.material.icons.filled.Delete
import androidx.compose.material3.AlertDialog
import androidx.compose.material3.Button
import androidx.compose.material3.Card
import androidx.compose.material3.CardDefaults
import androidx.compose.material3.Icon
import androidx.compose.material3.IconButton
import androidx.compose.material3.MaterialTheme
import androidx.compose.material3.OutlinedButton
import androidx.compose.material3.OutlinedTextField
import androidx.compose.material3.Scaffold
import androidx.compose.material3.Text
import androidx.compose.material3.TextButton
import androidx.compose.runtime.Composable
import androidx.compose.runtime.LaunchedEffect
import androidx.compose.runtime.getValue
import androidx.compose.runtime.mutableStateOf
import androidx.compose.runtime.saveable.rememberSaveable
import androidx.compose.runtime.setValue
import androidx.compose.ui.Alignment
import androidx.compose.ui.Modifier
import androidx.compose.ui.text.font.FontWeight
import androidx.compose.ui.unit.dp
import androidx.lifecycle.viewmodel.compose.viewModel
import com.example.flashcard.ui.AppViewModelProvider
import com.example.flashcard.ui.components.BrandHeader
import com.example.flashcard.ui.components.CardImage
import com.example.flashcard.ui.components.LoadingBox
import com.example.flashcard.ui.components.SectionTitle
import com.example.flashcard.ui.components.errorText

@Composable
fun DeckEditScreen(
    onBack: () -> Unit,
    onSaved: (deckId: Long, isNew: Boolean) -> Unit,
    onDeleted: () -> Unit,
    viewModel: DeckEditViewModel = viewModel(factory = AppViewModelProvider.Factory),
) {
    val uiState = viewModel.uiState

    // Аль картад зураг сонгож буйг санана (Photo Picker-ээс буцаж ирэхэд хэрэгтэй).
    var pickingFor by rememberSaveable { mutableStateOf<Long?>(null) }
    // Android Photo Picker: зөвшөөрөл (permission) шаардахгүй.
    val pickImage = rememberLauncherForActivityResult(PickVisualMedia()) { uri ->
        val key = pickingFor
        if (uri != null && key != null) viewModel.onImagePicked(key, uri)
        pickingFor = null
    }
    val launchPicker: (Long) -> Unit = { key ->
        pickingFor = key
        pickImage.launch(PickVisualMediaRequest(PickVisualMedia.ImageOnly))
    }

    // Нэг удаагийн үйл явдал: хадгалсан/устгасан бол дэлгэцээс гарна.
    LaunchedEffect(uiState.savedDeckId) {
        uiState.savedDeckId?.let { onSaved(it, uiState.isNew) }
    }
    LaunchedEffect(uiState.deleted) {
        if (uiState.deleted) onDeleted()
    }

    Scaffold(
        topBar = {
            BrandHeader(
                title = if (uiState.isNew) "Шинэ багц" else "Багц засах",
                onBack = onBack,
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
                top = padding.calculateTopPadding() + 16.dp,
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
                    shape = RoundedCornerShape(14.dp),
                )
            }
            item {
                OutlinedTextField(
                    value = uiState.description,
                    onValueChange = viewModel::onDescriptionChange,
                    modifier = Modifier.fillMaxWidth(),
                    label = { Text("Тайлбар") },
                    minLines = 2,
                    shape = RoundedCornerShape(14.dp),
                )
            }
            item {
                Column {
                    SectionTitle("Картууд (${uiState.cards.size})")
                    uiState.imageError?.let {
                        Text(it, color = MaterialTheme.colorScheme.error, style = MaterialTheme.typography.bodySmall)
                    }
                }
            }
            itemsIndexed(uiState.cards, key = { _, card -> card.key }) { index, card ->
                DraftCardEditor(
                    index = index,
                    card = card,
                    onTermChange = { viewModel.onTermChange(card.key, it) },
                    onDefinitionChange = { viewModel.onDefinitionChange(card.key, it) },
                    onPickImage = { launchPicker(card.key) },
                    onRemoveImage = { viewModel.removeImage(card.key) },
                    onRemove = { viewModel.removeCard(card.key) },
                    modifier = Modifier.animateItem(),
                )
            }
            item {
                OutlinedButton(
                    onClick = viewModel::addCard,
                    modifier = Modifier
                        .fillMaxWidth()
                        .height(52.dp),
                ) {
                    Icon(Icons.Filled.Add, contentDescription = null)
                    Spacer(Modifier.width(8.dp))
                    Text("Карт нэмэх")
                }
            }
            item {
                Button(
                    onClick = viewModel::save,
                    modifier = Modifier
                        .fillMaxWidth()
                        .height(52.dp),
                ) { Text("Хадгалах", fontWeight = FontWeight.SemiBold) }
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
    onPickImage: () -> Unit,
    onRemoveImage: () -> Unit,
    onRemove: () -> Unit,
    modifier: Modifier = Modifier,
) {
    Card(
        modifier = modifier.fillMaxWidth(),
        shape = MaterialTheme.shapes.large,
        colors = CardDefaults.cardColors(containerColor = MaterialTheme.colorScheme.surfaceContainerLowest),
        elevation = CardDefaults.cardElevation(defaultElevation = 2.dp),
    ) {
        Column(Modifier.padding(start = 16.dp, end = 4.dp, bottom = 16.dp)) {
            Row(verticalAlignment = Alignment.CenterVertically) {
                Text(
                    "Карт ${index + 1}",
                    style = MaterialTheme.typography.titleSmall,
                    fontWeight = FontWeight.Bold,
                    color = MaterialTheme.colorScheme.primary,
                    modifier = Modifier.weight(1f),
                )
                IconButton(onClick = onRemove) {
                    Icon(Icons.Filled.Close, contentDescription = "Карт хасах")
                }
            }
            Column(Modifier.padding(end = 12.dp), verticalArrangement = Arrangement.spacedBy(8.dp)) {
                OutlinedTextField(
                    value = card.term,
                    onValueChange = onTermChange,
                    modifier = Modifier.fillMaxWidth(),
                    label = { Text("Герман үг (term)") },
                    isError = card.error != null && card.term.isBlank(),
                    singleLine = true,
                    shape = RoundedCornerShape(14.dp),
                )
                OutlinedTextField(
                    value = card.definition,
                    onValueChange = onDefinitionChange,
                    modifier = Modifier.fillMaxWidth(),
                    label = { Text("Монгол орчуулга (definition)") },
                    isError = card.error != null && card.definition.isBlank(),
                    shape = RoundedCornerShape(14.dp),
                )
                DraftImage(card.imagePath, onPickImage, onRemoveImage)
                card.error?.let {
                    Text(it, color = MaterialTheme.colorScheme.error, style = MaterialTheme.typography.bodySmall)
                }
            }
        }
    }
}

/** Картын зураг: байхгүй бол "Зураг нэмэх" товч, байвал урьдчилан харах + солих/хасах. */
@Composable
private fun DraftImage(imagePath: String?, onPick: () -> Unit, onRemove: () -> Unit) {
    if (imagePath == null) {
        OutlinedButton(
            onClick = onPick,
            modifier = Modifier.fillMaxWidth(),
            shape = RoundedCornerShape(14.dp),
            border = BorderStroke(1.dp, MaterialTheme.colorScheme.outlineVariant),
        ) {
            Text("🖼  Зураг нэмэх (заавал биш)")
        }
    } else {
        Box(Modifier.fillMaxWidth(), contentAlignment = Alignment.Center) {
            CardImage(imagePath, Modifier.heightIn(max = 160.dp))
        }
        Row(horizontalArrangement = Arrangement.spacedBy(8.dp)) {
            TextButton(onClick = onPick) { Text("Зураг солих") }
            TextButton(onClick = onRemove) {
                Text("Зураг хасах", color = MaterialTheme.colorScheme.error)
            }
        }
    }
}
