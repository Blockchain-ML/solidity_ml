package miningtool.parse.antlr.solidity


import org.junit.Assert
import org.junit.Test
import java.io.File
import java.io.FileInputStream

class ANTLRSolidity1ParserTest {
    @Test
    fun testNode1sol() {
        val parser = Solidity1Parser()
        val file = File("testData/examples/solidity/")

        val node = parser.parse(FileInputStream(file))
        Assert.assertNotNull("Parse tree for a valid file should not be null", node)
    }
}
