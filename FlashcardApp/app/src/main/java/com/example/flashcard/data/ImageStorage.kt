package com.example.flashcard.data

import android.content.Context
import android.graphics.Bitmap
import android.graphics.BitmapFactory
import android.graphics.Matrix
import android.media.ExifInterface
import android.net.Uri
import kotlinx.coroutines.Dispatchers
import kotlinx.coroutines.withContext
import java.io.File
import java.util.UUID

/**
 * Картын зургийг аппын дотоод хавтсанд (filesDir/card_images) хадгална.
 * Галерейн Uri хэсэг хугацааны дараа хүчингүй болдог тул зургийг өөр рүүгээ хуулж, замыг нь Room-д хадгална.
 */
class ImageStorage(context: Context) {
    private val resolver = context.contentResolver
    private val dir = File(context.filesDir, "card_images").apply { mkdirs() }

    /** Зургийг 1024px хүртэл жижигрүүлж JPEG болгон хадгална. Алдаа гарвал null. */
    suspend fun save(uri: Uri): String? = withContext(Dispatchers.IO) {
        try {
            val bounds = BitmapFactory.Options().apply { inJustDecodeBounds = true }
            resolver.openInputStream(uri)?.use { BitmapFactory.decodeStream(it, null, bounds) }
            var sample = 1
            while (maxOf(bounds.outWidth, bounds.outHeight) / (sample * 2) >= MAX_SIZE) sample *= 2

            val options = BitmapFactory.Options().apply { inSampleSize = sample }
            var bitmap = resolver.openInputStream(uri)?.use { BitmapFactory.decodeStream(it, null, options) }
                ?: return@withContext null

            // Утасны камерын зураг хажуу тийш харагдахгүйн тулд EXIF-ийн дагуу эргүүлнэ.
            val degrees = resolver.openInputStream(uri)?.use { exifRotation(ExifInterface(it)) } ?: 0
            if (degrees != 0) {
                val matrix = Matrix().apply { postRotate(degrees.toFloat()) }
                bitmap = Bitmap.createBitmap(bitmap, 0, 0, bitmap.width, bitmap.height, matrix, true)
            }

            val file = File(dir, "${UUID.randomUUID()}.jpg")
            file.outputStream().use { bitmap.compress(Bitmap.CompressFormat.JPEG, 85, it) }
            file.absolutePath
        } catch (e: Exception) {
            null
        }
    }

    fun delete(path: String?) {
        if (path != null) File(path).delete()
    }

    private fun exifRotation(exif: ExifInterface): Int =
        when (exif.getAttributeInt(ExifInterface.TAG_ORIENTATION, ExifInterface.ORIENTATION_NORMAL)) {
            ExifInterface.ORIENTATION_ROTATE_90 -> 90
            ExifInterface.ORIENTATION_ROTATE_180 -> 180
            ExifInterface.ORIENTATION_ROTATE_270 -> 270
            else -> 0
        }

    private companion object {
        const val MAX_SIZE = 1024
    }
}
