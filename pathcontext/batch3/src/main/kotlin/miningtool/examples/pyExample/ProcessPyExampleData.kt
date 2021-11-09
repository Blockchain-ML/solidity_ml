@file:JvmName("PyExample")

package miningtool.examples.pyExample

import miningtool.common.toPathContext
import miningtool.parse.antlr.java.Java8Parser
import miningtool.paths.PathMiner
import miningtool.paths.PathRetrievalSettings
import miningtool.paths.storage.VocabularyPathStorage
import java.io.File

// Retrieve paths from two Java projects for further usage in python example.
fun processPyExampleData() {
    val folder = "./py_example/data/"

    val miner = PathMiner(PathRetrievalSettings(5, 5))
    val storage = VocabularyPathStorage()

    File(folder).walkTopDown().filter { it.path.endsWith(".java") }.forEach { file ->
        val node = Java8Parser().parse(file.inputStream()) ?: return@forEach
        val paths = miner.retrievePaths(node)

        storage.store(paths.map { toPathContext(it) }, entityId = file.path)
    }

    storage.save("py_example/processed_data/")
}

fun main(args: Array<String>) {
    processPyExampleData()
}