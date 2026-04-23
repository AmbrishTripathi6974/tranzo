package com.example.tranzo

import org.junit.Assert.assertEquals
import org.junit.Test

class DownloadFileNameResolverTest {
    @Test
    fun returnsOriginalNameWhenNoCollisionExists() {
        val resolved = DownloadFileNameResolver.resolveUniqueFileName("photo.png") { false }
        assertEquals("photo.png", resolved)
    }

    @Test
    fun appendsNumericSuffixWhenCollisionExists() {
        val existing = setOf("photo.png")
        val resolved = DownloadFileNameResolver.resolveUniqueFileName("photo.png") {
            candidate -> existing.contains(candidate)
        }
        assertEquals("photo (1).png", resolved)
    }

    @Test
    fun findsNextAvailableSuffixAcrossMultipleCollisions() {
        val existing = setOf("photo.png", "photo (1).png", "photo (2).png")
        val resolved = DownloadFileNameResolver.resolveUniqueFileName("photo.png") {
            candidate -> existing.contains(candidate)
        }
        assertEquals("photo (3).png", resolved)
    }

    @Test
    fun handlesFilesWithoutExtension() {
        val existing = setOf("archive", "archive (1)")
        val resolved = DownloadFileNameResolver.resolveUniqueFileName("archive") {
            candidate -> existing.contains(candidate)
        }
        assertEquals("archive (2)", resolved)
    }

    @Test
    fun preservesInnerDotsInBaseName() {
        val existing = setOf("backup.2026.04.tar.gz")
        val resolved = DownloadFileNameResolver.resolveUniqueFileName("backup.2026.04.tar.gz") {
            candidate -> existing.contains(candidate)
        }
        assertEquals("backup.2026.04.tar (1).gz", resolved)
    }
}
