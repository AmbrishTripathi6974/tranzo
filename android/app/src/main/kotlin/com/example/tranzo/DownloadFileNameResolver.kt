package com.example.tranzo

internal object DownloadFileNameResolver {
    fun resolveUniqueFileName(
        originalFileName: String,
        exists: (String) -> Boolean,
    ): String {
        val extensionStart = originalFileName.lastIndexOf('.')
        val hasExtension = extensionStart > 0
        val baseName = if (hasExtension) originalFileName.substring(0, extensionStart) else originalFileName
        val extension = if (hasExtension) originalFileName.substring(extensionStart) else ""
        var copyIndex = 0

        while (true) {
            val candidate = if (copyIndex == 0) {
                "$baseName$extension"
            } else {
                "$baseName ($copyIndex)$extension"
            }
            if (!exists(candidate)) {
                return candidate
            }
            copyIndex += 1
        }
    }
}
