package miningtool.examples

import miningtool.common.toPathContext
import miningtool.parse.antlr.solidity.Solidity1Parser
import miningtool.paths.PathMiner
import miningtool.paths.PathRetrievalSettings
import miningtool.paths.storage.VocabularyPathStorage
import java.io.File


fun allSolidityFiles() {
    val folder = "./testData/examples/solidity"

    val miner = PathMiner(PathRetrievalSettings(100, 50))
    val storage = VocabularyPathStorage()

    File(folder).walkTopDown().filter { it.path.endsWith(".sol") }.forEach { file ->
        val node = Solidity1Parser().parse(file.inputStream()) ?: return@forEach
        val paths = miner.retrievePaths(node)

        storage.store(paths.map { toPathContext(it) }, entityId = file.path)
    }

    storage.save("out_examples/allSolidityFilesAntlr")
}