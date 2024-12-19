package expo.modules.bundleupdater

import java.io.File
import java.io.FileInputStream
import java.io.FileOutputStream
import java.nio.channels.FileChannel

object FSUtil {
    fun moveWithOverride(sourcePath: String, destinationPath: String) {
        val source = File(sourcePath)
        val destination = File(destinationPath)

        if (destination.exists()) {
            destination.delete()
        }

        var sourceChannel: FileChannel? = null
        var destChannel: FileChannel? = null

        try {
            sourceChannel = FileInputStream(source).channel
            destChannel = FileOutputStream(destination).channel
            destChannel.transferFrom(sourceChannel, 0, sourceChannel.size())
        } finally {
            sourceChannel?.close()
            destChannel?.close()
        }
    }

    fun removeFile(file: File) {
        if (file.exists()) {
            file.delete()
        }
    }
} 