package miningtool.parse.antlr.solidity

import me.vovak.antlr.parser.SolidityLexer
import me.vovak.antlr.parser.SolidityParser
import miningtool.common.Parser
import miningtool.parse.antlr.SimpleNode
import miningtool.parse.antlr.convertAntlrTree
import org.antlr.v4.runtime.ANTLRInputStream
import org.antlr.v4.runtime.CommonTokenStream
import java.io.InputStream

class Solidity1Parser : Parser<SimpleNode> {
    override fun parse(content: InputStream): SimpleNode? {
        val lexer = SolidityLexer(ANTLRInputStream(content))
        lexer.removeErrorListeners()
        val tokens = CommonTokenStream(lexer)
        val parser = SolidityParser(tokens)
        parser.removeErrorListeners()
        val context = parser.sourceUnit()
        return convertAntlrTree(context, SolidityParser.ruleNames)
    }

}