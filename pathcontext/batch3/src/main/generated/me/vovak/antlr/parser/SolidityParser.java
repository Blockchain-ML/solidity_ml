// Generated from /home/supriya/pathcontext/batch3/antlr/Solidity.g4 by ANTLR 4.2.2
package me.vovak.antlr.parser;
import org.antlr.v4.runtime.atn.*;
import org.antlr.v4.runtime.dfa.DFA;
import org.antlr.v4.runtime.*;
import org.antlr.v4.runtime.misc.*;
import org.antlr.v4.runtime.tree.*;
import java.util.List;
import java.util.Iterator;
import java.util.ArrayList;

@SuppressWarnings({"all", "warnings", "unchecked", "unused", "cast"})
public class SolidityParser extends Parser {
	protected static final DFA[] _decisionToDFA;
	protected static final PredictionContextCache _sharedContextCache =
		new PredictionContextCache();
	public static final int
		T__89=1, T__88=2, T__87=3, T__86=4, T__85=5, T__84=6, T__83=7, T__82=8, 
		T__81=9, T__80=10, T__79=11, T__78=12, T__77=13, T__76=14, T__75=15, T__74=16, 
		T__73=17, T__72=18, T__71=19, T__70=20, T__69=21, T__68=22, T__67=23, 
		T__66=24, T__65=25, T__64=26, T__63=27, T__62=28, T__61=29, T__60=30, 
		T__59=31, T__58=32, T__57=33, T__56=34, T__55=35, T__54=36, T__53=37, 
		T__52=38, T__51=39, T__50=40, T__49=41, T__48=42, T__47=43, T__46=44, 
		T__45=45, T__44=46, T__43=47, T__42=48, T__41=49, T__40=50, T__39=51, 
		T__38=52, T__37=53, T__36=54, T__35=55, T__34=56, T__33=57, T__32=58, 
		T__31=59, T__30=60, T__29=61, T__28=62, T__27=63, T__26=64, T__25=65, 
		T__24=66, T__23=67, T__22=68, T__21=69, T__20=70, T__19=71, T__18=72, 
		T__17=73, T__16=74, T__15=75, T__14=76, T__13=77, T__12=78, T__11=79, 
		T__10=80, T__9=81, T__8=82, T__7=83, T__6=84, T__5=85, T__4=86, T__3=87, 
		T__2=88, T__1=89, T__0=90, NatSpecSingleLine=91, NatSpecMultiLine=92, 
		Int=93, Uint=94, Byte=95, Fixed=96, Ufixed=97, VersionLiteral=98, BooleanLiteral=99, 
		DecimalNumber=100, HexNumber=101, NumberUnit=102, HexLiteral=103, ReservedKeyword=104, 
		AnonymousKeyword=105, BreakKeyword=106, ConstantKeyword=107, ContinueKeyword=108, 
		ExternalKeyword=109, IndexedKeyword=110, InternalKeyword=111, PayableKeyword=112, 
		PrivateKeyword=113, PublicKeyword=114, PureKeyword=115, TypeKeyword=116, 
		ViewKeyword=117, Identifier=118, StringLiteral=119, WS=120, COMMENT=121, 
		LINE_COMMENT=122;
	public static final String[] tokenNames = {
		"<INVALID>", "'default'", "'+='", "'%='", "'library'", "'interface'", 
		"'new'", "'storage'", "'!='", "'while'", "'{'", "'pragma'", "'^='", "'&&'", 
		"'>>'", "'**'", "'byte'", "'='", "'<<='", "'for'", "'^'", "'delete'", 
		"'|='", "'constructor'", "'do'", "'('", "'-='", "','", "'/='", "'after'", 
		"'memory'", "'var'", "'>='", "'++'", "'<'", "']'", "'~'", "'calldata'", 
		"'let'", "'returns'", "'function'", "'+'", "'mapping'", "'struct'", "'*='", 
		"'/'", "'as'", "'&='", "'return'", "'using'", "'>>='", "'||'", "';'", 
		"'<<'", "'=:'", "'}'", "'if'", "':='", "'?'", "'enum'", "'event'", "'<='", 
		"'from'", "'&'", "'switch'", "'is'", "'*'", "'emit'", "'.'", "'->'", "'case'", 
		"'throw'", "':'", "'['", "'contract'", "'=='", "'|'", "'--'", "'address'", 
		"'bool'", "'>'", "'!'", "'=>'", "'string'", "'%'", "'modifier'", "'else'", 
		"')'", "'assembly'", "'-'", "'import'", "NatSpecSingleLine", "NatSpecMultiLine", 
		"Int", "Uint", "Byte", "Fixed", "Ufixed", "VersionLiteral", "BooleanLiteral", 
		"DecimalNumber", "HexNumber", "NumberUnit", "HexLiteral", "ReservedKeyword", 
		"'anonymous'", "'break'", "'constant'", "'continue'", "'external'", "'indexed'", 
		"'internal'", "'payable'", "'private'", "'public'", "'pure'", "'type'", 
		"'view'", "Identifier", "StringLiteral", "WS", "COMMENT", "LINE_COMMENT"
	};
	public static final int
		RULE_sourceUnit = 0, RULE_pragmaDirective = 1, RULE_pragmaName = 2, RULE_pragmaValue = 3, 
		RULE_version = 4, RULE_versionOperator = 5, RULE_versionConstraint = 6, 
		RULE_importDeclaration = 7, RULE_importDirective = 8, RULE_natSpec = 9, 
		RULE_contractDefinition = 10, RULE_inheritanceSpecifier = 11, RULE_contractPart = 12, 
		RULE_stateVariableDeclaration = 13, RULE_usingForDeclaration = 14, RULE_structDefinition = 15, 
		RULE_constructorDefinition = 16, RULE_modifierDefinition = 17, RULE_modifierInvocation = 18, 
		RULE_functionDefinition = 19, RULE_returnParameters = 20, RULE_modifierList = 21, 
		RULE_eventDefinition = 22, RULE_enumValue = 23, RULE_enumDefinition = 24, 
		RULE_parameterList = 25, RULE_parameter = 26, RULE_eventParameterList = 27, 
		RULE_eventParameter = 28, RULE_functionTypeParameterList = 29, RULE_functionTypeParameter = 30, 
		RULE_variableDeclaration = 31, RULE_typeName = 32, RULE_userDefinedTypeName = 33, 
		RULE_mapping = 34, RULE_functionTypeName = 35, RULE_storageLocation = 36, 
		RULE_stateMutability = 37, RULE_block = 38, RULE_statement = 39, RULE_expressionStatement = 40, 
		RULE_ifStatement = 41, RULE_whileStatement = 42, RULE_simpleStatement = 43, 
		RULE_forStatement = 44, RULE_inlineAssemblyStatement = 45, RULE_doWhileStatement = 46, 
		RULE_continueStatement = 47, RULE_breakStatement = 48, RULE_returnStatement = 49, 
		RULE_throwStatement = 50, RULE_emitStatement = 51, RULE_variableDeclarationStatement = 52, 
		RULE_variableDeclarationList = 53, RULE_identifierList = 54, RULE_elementaryTypeName = 55, 
		RULE_expression = 56, RULE_primaryExpression = 57, RULE_expressionList = 58, 
		RULE_nameValueList = 59, RULE_nameValue = 60, RULE_functionCallArguments = 61, 
		RULE_functionCall = 62, RULE_assemblyBlock = 63, RULE_assemblyItem = 64, 
		RULE_assemblyExpression = 65, RULE_assemblyCall = 66, RULE_assemblyLocalDefinition = 67, 
		RULE_assemblyAssignment = 68, RULE_assemblyIdentifierOrList = 69, RULE_assemblyIdentifierList = 70, 
		RULE_assemblyStackAssignment = 71, RULE_labelDefinition = 72, RULE_assemblySwitch = 73, 
		RULE_assemblyCase = 74, RULE_assemblyFunctionDefinition = 75, RULE_assemblyFunctionReturns = 76, 
		RULE_assemblyFor = 77, RULE_assemblyIf = 78, RULE_assemblyLiteral = 79, 
		RULE_subAssembly = 80, RULE_tupleExpression = 81, RULE_typeNameExpression = 82, 
		RULE_numberLiteral = 83, RULE_identifier = 84;
	public static final String[] ruleNames = {
		"sourceUnit", "pragmaDirective", "pragmaName", "pragmaValue", "version", 
		"versionOperator", "versionConstraint", "importDeclaration", "importDirective", 
		"natSpec", "contractDefinition", "inheritanceSpecifier", "contractPart", 
		"stateVariableDeclaration", "usingForDeclaration", "structDefinition", 
		"constructorDefinition", "modifierDefinition", "modifierInvocation", "functionDefinition", 
		"returnParameters", "modifierList", "eventDefinition", "enumValue", "enumDefinition", 
		"parameterList", "parameter", "eventParameterList", "eventParameter", 
		"functionTypeParameterList", "functionTypeParameter", "variableDeclaration", 
		"typeName", "userDefinedTypeName", "mapping", "functionTypeName", "storageLocation", 
		"stateMutability", "block", "statement", "expressionStatement", "ifStatement", 
		"whileStatement", "simpleStatement", "forStatement", "inlineAssemblyStatement", 
		"doWhileStatement", "continueStatement", "breakStatement", "returnStatement", 
		"throwStatement", "emitStatement", "variableDeclarationStatement", "variableDeclarationList", 
		"identifierList", "elementaryTypeName", "expression", "primaryExpression", 
		"expressionList", "nameValueList", "nameValue", "functionCallArguments", 
		"functionCall", "assemblyBlock", "assemblyItem", "assemblyExpression", 
		"assemblyCall", "assemblyLocalDefinition", "assemblyAssignment", "assemblyIdentifierOrList", 
		"assemblyIdentifierList", "assemblyStackAssignment", "labelDefinition", 
		"assemblySwitch", "assemblyCase", "assemblyFunctionDefinition", "assemblyFunctionReturns", 
		"assemblyFor", "assemblyIf", "assemblyLiteral", "subAssembly", "tupleExpression", 
		"typeNameExpression", "numberLiteral", "identifier"
	};

	@Override
	public String getGrammarFileName() { return "Solidity.g4"; }

	@Override
	public String[] getTokenNames() { return tokenNames; }

	@Override
	public String[] getRuleNames() { return ruleNames; }

	@Override
	public String getSerializedATN() { return _serializedATN; }

	@Override
	public ATN getATN() { return _ATN; }

	public SolidityParser(TokenStream input) {
		super(input);
		_interp = new ParserATNSimulator(this,_ATN,_decisionToDFA,_sharedContextCache);
	}
	public static class SourceUnitContext extends ParserRuleContext {
		public ContractDefinitionContext contractDefinition(int i) {
			return getRuleContext(ContractDefinitionContext.class,i);
		}
		public TerminalNode EOF() { return getToken(SolidityParser.EOF, 0); }
		public PragmaDirectiveContext pragmaDirective(int i) {
			return getRuleContext(PragmaDirectiveContext.class,i);
		}
		public ImportDirectiveContext importDirective(int i) {
			return getRuleContext(ImportDirectiveContext.class,i);
		}
		public List<ContractDefinitionContext> contractDefinition() {
			return getRuleContexts(ContractDefinitionContext.class);
		}
		public List<ImportDirectiveContext> importDirective() {
			return getRuleContexts(ImportDirectiveContext.class);
		}
		public List<PragmaDirectiveContext> pragmaDirective() {
			return getRuleContexts(PragmaDirectiveContext.class);
		}
		public SourceUnitContext(ParserRuleContext parent, int invokingState) {
			super(parent, invokingState);
		}
		@Override public int getRuleIndex() { return RULE_sourceUnit; }
		@Override
		public void enterRule(ParseTreeListener listener) {
			if ( listener instanceof SolidityListener ) ((SolidityListener)listener).enterSourceUnit(this);
		}
		@Override
		public void exitRule(ParseTreeListener listener) {
			if ( listener instanceof SolidityListener ) ((SolidityListener)listener).exitSourceUnit(this);
		}
		@Override
		public <T> T accept(ParseTreeVisitor<? extends T> visitor) {
			if ( visitor instanceof SolidityVisitor ) return ((SolidityVisitor<? extends T>)visitor).visitSourceUnit(this);
			else return visitor.visitChildren(this);
		}
	}

	public final SourceUnitContext sourceUnit() throws RecognitionException {
		SourceUnitContext _localctx = new SourceUnitContext(_ctx, getState());
		enterRule(_localctx, 0, RULE_sourceUnit);
		int _la;
		try {
			enterOuterAlt(_localctx, 1);
			{
			setState(175);
			_errHandler.sync(this);
			_la = _input.LA(1);
			while ((((_la) & ~0x3f) == 0 && ((1L << _la) & ((1L << 4) | (1L << 5) | (1L << 11))) != 0) || ((((_la - 74)) & ~0x3f) == 0 && ((1L << (_la - 74)) & ((1L << (74 - 74)) | (1L << (90 - 74)) | (1L << (NatSpecSingleLine - 74)) | (1L << (NatSpecMultiLine - 74)))) != 0)) {
				{
				setState(173);
				switch (_input.LA(1)) {
				case 11:
					{
					setState(170); pragmaDirective();
					}
					break;
				case 90:
					{
					setState(171); importDirective();
					}
					break;
				case 4:
				case 5:
				case 74:
				case NatSpecSingleLine:
				case NatSpecMultiLine:
					{
					setState(172); contractDefinition();
					}
					break;
				default:
					throw new NoViableAltException(this);
				}
				}
				setState(177);
				_errHandler.sync(this);
				_la = _input.LA(1);
			}
			setState(178); match(EOF);
			}
		}
		catch (RecognitionException re) {
			_localctx.exception = re;
			_errHandler.reportError(this, re);
			_errHandler.recover(this, re);
		}
		finally {
			exitRule();
		}
		return _localctx;
	}

	public static class PragmaDirectiveContext extends ParserRuleContext {
		public PragmaNameContext pragmaName() {
			return getRuleContext(PragmaNameContext.class,0);
		}
		public PragmaValueContext pragmaValue() {
			return getRuleContext(PragmaValueContext.class,0);
		}
		public PragmaDirectiveContext(ParserRuleContext parent, int invokingState) {
			super(parent, invokingState);
		}
		@Override public int getRuleIndex() { return RULE_pragmaDirective; }
		@Override
		public void enterRule(ParseTreeListener listener) {
			if ( listener instanceof SolidityListener ) ((SolidityListener)listener).enterPragmaDirective(this);
		}
		@Override
		public void exitRule(ParseTreeListener listener) {
			if ( listener instanceof SolidityListener ) ((SolidityListener)listener).exitPragmaDirective(this);
		}
		@Override
		public <T> T accept(ParseTreeVisitor<? extends T> visitor) {
			if ( visitor instanceof SolidityVisitor ) return ((SolidityVisitor<? extends T>)visitor).visitPragmaDirective(this);
			else return visitor.visitChildren(this);
		}
	}

	public final PragmaDirectiveContext pragmaDirective() throws RecognitionException {
		PragmaDirectiveContext _localctx = new PragmaDirectiveContext(_ctx, getState());
		enterRule(_localctx, 2, RULE_pragmaDirective);
		try {
			enterOuterAlt(_localctx, 1);
			{
			setState(180); match(11);
			setState(181); pragmaName();
			setState(182); pragmaValue();
			setState(183); match(52);
			}
		}
		catch (RecognitionException re) {
			_localctx.exception = re;
			_errHandler.reportError(this, re);
			_errHandler.recover(this, re);
		}
		finally {
			exitRule();
		}
		return _localctx;
	}

	public static class PragmaNameContext extends ParserRuleContext {
		public IdentifierContext identifier() {
			return getRuleContext(IdentifierContext.class,0);
		}
		public PragmaNameContext(ParserRuleContext parent, int invokingState) {
			super(parent, invokingState);
		}
		@Override public int getRuleIndex() { return RULE_pragmaName; }
		@Override
		public void enterRule(ParseTreeListener listener) {
			if ( listener instanceof SolidityListener ) ((SolidityListener)listener).enterPragmaName(this);
		}
		@Override
		public void exitRule(ParseTreeListener listener) {
			if ( listener instanceof SolidityListener ) ((SolidityListener)listener).exitPragmaName(this);
		}
		@Override
		public <T> T accept(ParseTreeVisitor<? extends T> visitor) {
			if ( visitor instanceof SolidityVisitor ) return ((SolidityVisitor<? extends T>)visitor).visitPragmaName(this);
			else return visitor.visitChildren(this);
		}
	}

	public final PragmaNameContext pragmaName() throws RecognitionException {
		PragmaNameContext _localctx = new PragmaNameContext(_ctx, getState());
		enterRule(_localctx, 4, RULE_pragmaName);
		try {
			enterOuterAlt(_localctx, 1);
			{
			setState(185); identifier();
			}
		}
		catch (RecognitionException re) {
			_localctx.exception = re;
			_errHandler.reportError(this, re);
			_errHandler.recover(this, re);
		}
		finally {
			exitRule();
		}
		return _localctx;
	}

	public static class PragmaValueContext extends ParserRuleContext {
		public VersionContext version() {
			return getRuleContext(VersionContext.class,0);
		}
		public ExpressionContext expression() {
			return getRuleContext(ExpressionContext.class,0);
		}
		public PragmaValueContext(ParserRuleContext parent, int invokingState) {
			super(parent, invokingState);
		}
		@Override public int getRuleIndex() { return RULE_pragmaValue; }
		@Override
		public void enterRule(ParseTreeListener listener) {
			if ( listener instanceof SolidityListener ) ((SolidityListener)listener).enterPragmaValue(this);
		}
		@Override
		public void exitRule(ParseTreeListener listener) {
			if ( listener instanceof SolidityListener ) ((SolidityListener)listener).exitPragmaValue(this);
		}
		@Override
		public <T> T accept(ParseTreeVisitor<? extends T> visitor) {
			if ( visitor instanceof SolidityVisitor ) return ((SolidityVisitor<? extends T>)visitor).visitPragmaValue(this);
			else return visitor.visitChildren(this);
		}
	}

	public final PragmaValueContext pragmaValue() throws RecognitionException {
		PragmaValueContext _localctx = new PragmaValueContext(_ctx, getState());
		enterRule(_localctx, 6, RULE_pragmaValue);
		try {
			setState(189);
			switch ( getInterpreter().adaptivePredict(_input,2,_ctx) ) {
			case 1:
				enterOuterAlt(_localctx, 1);
				{
				setState(187); version();
				}
				break;

			case 2:
				enterOuterAlt(_localctx, 2);
				{
				setState(188); expression(0);
				}
				break;
			}
		}
		catch (RecognitionException re) {
			_localctx.exception = re;
			_errHandler.reportError(this, re);
			_errHandler.recover(this, re);
		}
		finally {
			exitRule();
		}
		return _localctx;
	}

	public static class VersionContext extends ParserRuleContext {
		public List<VersionConstraintContext> versionConstraint() {
			return getRuleContexts(VersionConstraintContext.class);
		}
		public VersionConstraintContext versionConstraint(int i) {
			return getRuleContext(VersionConstraintContext.class,i);
		}
		public VersionContext(ParserRuleContext parent, int invokingState) {
			super(parent, invokingState);
		}
		@Override public int getRuleIndex() { return RULE_version; }
		@Override
		public void enterRule(ParseTreeListener listener) {
			if ( listener instanceof SolidityListener ) ((SolidityListener)listener).enterVersion(this);
		}
		@Override
		public void exitRule(ParseTreeListener listener) {
			if ( listener instanceof SolidityListener ) ((SolidityListener)listener).exitVersion(this);
		}
		@Override
		public <T> T accept(ParseTreeVisitor<? extends T> visitor) {
			if ( visitor instanceof SolidityVisitor ) return ((SolidityVisitor<? extends T>)visitor).visitVersion(this);
			else return visitor.visitChildren(this);
		}
	}

	public final VersionContext version() throws RecognitionException {
		VersionContext _localctx = new VersionContext(_ctx, getState());
		enterRule(_localctx, 8, RULE_version);
		int _la;
		try {
			enterOuterAlt(_localctx, 1);
			{
			setState(191); versionConstraint();
			setState(193);
			_la = _input.LA(1);
			if ((((_la) & ~0x3f) == 0 && ((1L << _la) & ((1L << 17) | (1L << 20) | (1L << 32) | (1L << 34) | (1L << 36) | (1L << 61))) != 0) || _la==80 || _la==VersionLiteral) {
				{
				setState(192); versionConstraint();
				}
			}

			}
		}
		catch (RecognitionException re) {
			_localctx.exception = re;
			_errHandler.reportError(this, re);
			_errHandler.recover(this, re);
		}
		finally {
			exitRule();
		}
		return _localctx;
	}

	public static class VersionOperatorContext extends ParserRuleContext {
		public VersionOperatorContext(ParserRuleContext parent, int invokingState) {
			super(parent, invokingState);
		}
		@Override public int getRuleIndex() { return RULE_versionOperator; }
		@Override
		public void enterRule(ParseTreeListener listener) {
			if ( listener instanceof SolidityListener ) ((SolidityListener)listener).enterVersionOperator(this);
		}
		@Override
		public void exitRule(ParseTreeListener listener) {
			if ( listener instanceof SolidityListener ) ((SolidityListener)listener).exitVersionOperator(this);
		}
		@Override
		public <T> T accept(ParseTreeVisitor<? extends T> visitor) {
			if ( visitor instanceof SolidityVisitor ) return ((SolidityVisitor<? extends T>)visitor).visitVersionOperator(this);
			else return visitor.visitChildren(this);
		}
	}

	public final VersionOperatorContext versionOperator() throws RecognitionException {
		VersionOperatorContext _localctx = new VersionOperatorContext(_ctx, getState());
		enterRule(_localctx, 10, RULE_versionOperator);
		int _la;
		try {
			enterOuterAlt(_localctx, 1);
			{
			setState(195);
			_la = _input.LA(1);
			if ( !(((((_la - 17)) & ~0x3f) == 0 && ((1L << (_la - 17)) & ((1L << (17 - 17)) | (1L << (20 - 17)) | (1L << (32 - 17)) | (1L << (34 - 17)) | (1L << (36 - 17)) | (1L << (61 - 17)) | (1L << (80 - 17)))) != 0)) ) {
			_errHandler.recoverInline(this);
			}
			consume();
			}
		}
		catch (RecognitionException re) {
			_localctx.exception = re;
			_errHandler.reportError(this, re);
			_errHandler.recover(this, re);
		}
		finally {
			exitRule();
		}
		return _localctx;
	}

	public static class VersionConstraintContext extends ParserRuleContext {
		public TerminalNode VersionLiteral() { return getToken(SolidityParser.VersionLiteral, 0); }
		public VersionOperatorContext versionOperator() {
			return getRuleContext(VersionOperatorContext.class,0);
		}
		public VersionConstraintContext(ParserRuleContext parent, int invokingState) {
			super(parent, invokingState);
		}
		@Override public int getRuleIndex() { return RULE_versionConstraint; }
		@Override
		public void enterRule(ParseTreeListener listener) {
			if ( listener instanceof SolidityListener ) ((SolidityListener)listener).enterVersionConstraint(this);
		}
		@Override
		public void exitRule(ParseTreeListener listener) {
			if ( listener instanceof SolidityListener ) ((SolidityListener)listener).exitVersionConstraint(this);
		}
		@Override
		public <T> T accept(ParseTreeVisitor<? extends T> visitor) {
			if ( visitor instanceof SolidityVisitor ) return ((SolidityVisitor<? extends T>)visitor).visitVersionConstraint(this);
			else return visitor.visitChildren(this);
		}
	}

	public final VersionConstraintContext versionConstraint() throws RecognitionException {
		VersionConstraintContext _localctx = new VersionConstraintContext(_ctx, getState());
		enterRule(_localctx, 12, RULE_versionConstraint);
		int _la;
		try {
			enterOuterAlt(_localctx, 1);
			{
			setState(198);
			_la = _input.LA(1);
			if (((((_la - 17)) & ~0x3f) == 0 && ((1L << (_la - 17)) & ((1L << (17 - 17)) | (1L << (20 - 17)) | (1L << (32 - 17)) | (1L << (34 - 17)) | (1L << (36 - 17)) | (1L << (61 - 17)) | (1L << (80 - 17)))) != 0)) {
				{
				setState(197); versionOperator();
				}
			}

			setState(200); match(VersionLiteral);
			}
		}
		catch (RecognitionException re) {
			_localctx.exception = re;
			_errHandler.reportError(this, re);
			_errHandler.recover(this, re);
		}
		finally {
			exitRule();
		}
		return _localctx;
	}

	public static class ImportDeclarationContext extends ParserRuleContext {
		public IdentifierContext identifier(int i) {
			return getRuleContext(IdentifierContext.class,i);
		}
		public List<IdentifierContext> identifier() {
			return getRuleContexts(IdentifierContext.class);
		}
		public ImportDeclarationContext(ParserRuleContext parent, int invokingState) {
			super(parent, invokingState);
		}
		@Override public int getRuleIndex() { return RULE_importDeclaration; }
		@Override
		public void enterRule(ParseTreeListener listener) {
			if ( listener instanceof SolidityListener ) ((SolidityListener)listener).enterImportDeclaration(this);
		}
		@Override
		public void exitRule(ParseTreeListener listener) {
			if ( listener instanceof SolidityListener ) ((SolidityListener)listener).exitImportDeclaration(this);
		}
		@Override
		public <T> T accept(ParseTreeVisitor<? extends T> visitor) {
			if ( visitor instanceof SolidityVisitor ) return ((SolidityVisitor<? extends T>)visitor).visitImportDeclaration(this);
			else return visitor.visitChildren(this);
		}
	}

	public final ImportDeclarationContext importDeclaration() throws RecognitionException {
		ImportDeclarationContext _localctx = new ImportDeclarationContext(_ctx, getState());
		enterRule(_localctx, 14, RULE_importDeclaration);
		int _la;
		try {
			enterOuterAlt(_localctx, 1);
			{
			setState(202); identifier();
			setState(205);
			_la = _input.LA(1);
			if (_la==46) {
				{
				setState(203); match(46);
				setState(204); identifier();
				}
			}

			}
		}
		catch (RecognitionException re) {
			_localctx.exception = re;
			_errHandler.reportError(this, re);
			_errHandler.recover(this, re);
		}
		finally {
			exitRule();
		}
		return _localctx;
	}

	public static class ImportDirectiveContext extends ParserRuleContext {
		public IdentifierContext identifier(int i) {
			return getRuleContext(IdentifierContext.class,i);
		}
		public ImportDeclarationContext importDeclaration(int i) {
			return getRuleContext(ImportDeclarationContext.class,i);
		}
		public List<ImportDeclarationContext> importDeclaration() {
			return getRuleContexts(ImportDeclarationContext.class);
		}
		public TerminalNode StringLiteral() { return getToken(SolidityParser.StringLiteral, 0); }
		public List<IdentifierContext> identifier() {
			return getRuleContexts(IdentifierContext.class);
		}
		public ImportDirectiveContext(ParserRuleContext parent, int invokingState) {
			super(parent, invokingState);
		}
		@Override public int getRuleIndex() { return RULE_importDirective; }
		@Override
		public void enterRule(ParseTreeListener listener) {
			if ( listener instanceof SolidityListener ) ((SolidityListener)listener).enterImportDirective(this);
		}
		@Override
		public void exitRule(ParseTreeListener listener) {
			if ( listener instanceof SolidityListener ) ((SolidityListener)listener).exitImportDirective(this);
		}
		@Override
		public <T> T accept(ParseTreeVisitor<? extends T> visitor) {
			if ( visitor instanceof SolidityVisitor ) return ((SolidityVisitor<? extends T>)visitor).visitImportDirective(this);
			else return visitor.visitChildren(this);
		}
	}

	public final ImportDirectiveContext importDirective() throws RecognitionException {
		ImportDirectiveContext _localctx = new ImportDirectiveContext(_ctx, getState());
		enterRule(_localctx, 16, RULE_importDirective);
		int _la;
		try {
			setState(241);
			switch ( getInterpreter().adaptivePredict(_input,10,_ctx) ) {
			case 1:
				enterOuterAlt(_localctx, 1);
				{
				setState(207); match(90);
				setState(208); match(StringLiteral);
				setState(211);
				_la = _input.LA(1);
				if (_la==46) {
					{
					setState(209); match(46);
					setState(210); identifier();
					}
				}

				setState(213); match(52);
				}
				break;

			case 2:
				enterOuterAlt(_localctx, 2);
				{
				setState(214); match(90);
				setState(217);
				switch (_input.LA(1)) {
				case 66:
					{
					setState(215); match(66);
					}
					break;
				case 37:
				case 62:
				case Identifier:
					{
					setState(216); identifier();
					}
					break;
				default:
					throw new NoViableAltException(this);
				}
				setState(221);
				_la = _input.LA(1);
				if (_la==46) {
					{
					setState(219); match(46);
					setState(220); identifier();
					}
				}

				setState(223); match(62);
				setState(224); match(StringLiteral);
				setState(225); match(52);
				}
				break;

			case 3:
				enterOuterAlt(_localctx, 3);
				{
				setState(226); match(90);
				setState(227); match(10);
				setState(228); importDeclaration();
				setState(233);
				_errHandler.sync(this);
				_la = _input.LA(1);
				while (_la==27) {
					{
					{
					setState(229); match(27);
					setState(230); importDeclaration();
					}
					}
					setState(235);
					_errHandler.sync(this);
					_la = _input.LA(1);
				}
				setState(236); match(55);
				setState(237); match(62);
				setState(238); match(StringLiteral);
				setState(239); match(52);
				}
				break;
			}
		}
		catch (RecognitionException re) {
			_localctx.exception = re;
			_errHandler.reportError(this, re);
			_errHandler.recover(this, re);
		}
		finally {
			exitRule();
		}
		return _localctx;
	}

	public static class NatSpecContext extends ParserRuleContext {
		public TerminalNode NatSpecMultiLine() { return getToken(SolidityParser.NatSpecMultiLine, 0); }
		public TerminalNode NatSpecSingleLine() { return getToken(SolidityParser.NatSpecSingleLine, 0); }
		public NatSpecContext(ParserRuleContext parent, int invokingState) {
			super(parent, invokingState);
		}
		@Override public int getRuleIndex() { return RULE_natSpec; }
		@Override
		public void enterRule(ParseTreeListener listener) {
			if ( listener instanceof SolidityListener ) ((SolidityListener)listener).enterNatSpec(this);
		}
		@Override
		public void exitRule(ParseTreeListener listener) {
			if ( listener instanceof SolidityListener ) ((SolidityListener)listener).exitNatSpec(this);
		}
		@Override
		public <T> T accept(ParseTreeVisitor<? extends T> visitor) {
			if ( visitor instanceof SolidityVisitor ) return ((SolidityVisitor<? extends T>)visitor).visitNatSpec(this);
			else return visitor.visitChildren(this);
		}
	}

	public final NatSpecContext natSpec() throws RecognitionException {
		NatSpecContext _localctx = new NatSpecContext(_ctx, getState());
		enterRule(_localctx, 18, RULE_natSpec);
		int _la;
		try {
			enterOuterAlt(_localctx, 1);
			{
			setState(243);
			_la = _input.LA(1);
			if ( !(_la==NatSpecSingleLine || _la==NatSpecMultiLine) ) {
			_errHandler.recoverInline(this);
			}
			consume();
			}
		}
		catch (RecognitionException re) {
			_localctx.exception = re;
			_errHandler.reportError(this, re);
			_errHandler.recover(this, re);
		}
		finally {
			exitRule();
		}
		return _localctx;
	}

	public static class ContractDefinitionContext extends ParserRuleContext {
		public List<ContractPartContext> contractPart() {
			return getRuleContexts(ContractPartContext.class);
		}
		public ContractPartContext contractPart(int i) {
			return getRuleContext(ContractPartContext.class,i);
		}
		public NatSpecContext natSpec() {
			return getRuleContext(NatSpecContext.class,0);
		}
		public IdentifierContext identifier() {
			return getRuleContext(IdentifierContext.class,0);
		}
		public InheritanceSpecifierContext inheritanceSpecifier(int i) {
			return getRuleContext(InheritanceSpecifierContext.class,i);
		}
		public List<InheritanceSpecifierContext> inheritanceSpecifier() {
			return getRuleContexts(InheritanceSpecifierContext.class);
		}
		public ContractDefinitionContext(ParserRuleContext parent, int invokingState) {
			super(parent, invokingState);
		}
		@Override public int getRuleIndex() { return RULE_contractDefinition; }
		@Override
		public void enterRule(ParseTreeListener listener) {
			if ( listener instanceof SolidityListener ) ((SolidityListener)listener).enterContractDefinition(this);
		}
		@Override
		public void exitRule(ParseTreeListener listener) {
			if ( listener instanceof SolidityListener ) ((SolidityListener)listener).exitContractDefinition(this);
		}
		@Override
		public <T> T accept(ParseTreeVisitor<? extends T> visitor) {
			if ( visitor instanceof SolidityVisitor ) return ((SolidityVisitor<? extends T>)visitor).visitContractDefinition(this);
			else return visitor.visitChildren(this);
		}
	}

	public final ContractDefinitionContext contractDefinition() throws RecognitionException {
		ContractDefinitionContext _localctx = new ContractDefinitionContext(_ctx, getState());
		enterRule(_localctx, 20, RULE_contractDefinition);
		int _la;
		try {
			enterOuterAlt(_localctx, 1);
			{
			setState(246);
			_la = _input.LA(1);
			if (_la==NatSpecSingleLine || _la==NatSpecMultiLine) {
				{
				setState(245); natSpec();
				}
			}

			setState(248);
			_la = _input.LA(1);
			if ( !(_la==4 || _la==5 || _la==74) ) {
			_errHandler.recoverInline(this);
			}
			consume();
			setState(249); identifier();
			setState(259);
			_la = _input.LA(1);
			if (_la==65) {
				{
				setState(250); match(65);
				setState(251); inheritanceSpecifier();
				setState(256);
				_errHandler.sync(this);
				_la = _input.LA(1);
				while (_la==27) {
					{
					{
					setState(252); match(27);
					setState(253); inheritanceSpecifier();
					}
					}
					setState(258);
					_errHandler.sync(this);
					_la = _input.LA(1);
				}
				}
			}

			setState(261); match(10);
			setState(265);
			_errHandler.sync(this);
			_la = _input.LA(1);
			while ((((_la) & ~0x3f) == 0 && ((1L << _la) & ((1L << 16) | (1L << 23) | (1L << 31) | (1L << 37) | (1L << 40) | (1L << 42) | (1L << 43) | (1L << 49) | (1L << 59) | (1L << 60) | (1L << 62))) != 0) || ((((_la - 78)) & ~0x3f) == 0 && ((1L << (_la - 78)) & ((1L << (78 - 78)) | (1L << (79 - 78)) | (1L << (83 - 78)) | (1L << (85 - 78)) | (1L << (NatSpecSingleLine - 78)) | (1L << (NatSpecMultiLine - 78)) | (1L << (Int - 78)) | (1L << (Uint - 78)) | (1L << (Byte - 78)) | (1L << (Fixed - 78)) | (1L << (Ufixed - 78)) | (1L << (Identifier - 78)))) != 0)) {
				{
				{
				setState(262); contractPart();
				}
				}
				setState(267);
				_errHandler.sync(this);
				_la = _input.LA(1);
			}
			setState(268); match(55);
			}
		}
		catch (RecognitionException re) {
			_localctx.exception = re;
			_errHandler.reportError(this, re);
			_errHandler.recover(this, re);
		}
		finally {
			exitRule();
		}
		return _localctx;
	}

	public static class InheritanceSpecifierContext extends ParserRuleContext {
		public ExpressionListContext expressionList() {
			return getRuleContext(ExpressionListContext.class,0);
		}
		public UserDefinedTypeNameContext userDefinedTypeName() {
			return getRuleContext(UserDefinedTypeNameContext.class,0);
		}
		public InheritanceSpecifierContext(ParserRuleContext parent, int invokingState) {
			super(parent, invokingState);
		}
		@Override public int getRuleIndex() { return RULE_inheritanceSpecifier; }
		@Override
		public void enterRule(ParseTreeListener listener) {
			if ( listener instanceof SolidityListener ) ((SolidityListener)listener).enterInheritanceSpecifier(this);
		}
		@Override
		public void exitRule(ParseTreeListener listener) {
			if ( listener instanceof SolidityListener ) ((SolidityListener)listener).exitInheritanceSpecifier(this);
		}
		@Override
		public <T> T accept(ParseTreeVisitor<? extends T> visitor) {
			if ( visitor instanceof SolidityVisitor ) return ((SolidityVisitor<? extends T>)visitor).visitInheritanceSpecifier(this);
			else return visitor.visitChildren(this);
		}
	}

	public final InheritanceSpecifierContext inheritanceSpecifier() throws RecognitionException {
		InheritanceSpecifierContext _localctx = new InheritanceSpecifierContext(_ctx, getState());
		enterRule(_localctx, 22, RULE_inheritanceSpecifier);
		int _la;
		try {
			enterOuterAlt(_localctx, 1);
			{
			setState(270); userDefinedTypeName();
			setState(276);
			_la = _input.LA(1);
			if (_la==25) {
				{
				setState(271); match(25);
				setState(273);
				_la = _input.LA(1);
				if ((((_la) & ~0x3f) == 0 && ((1L << _la) & ((1L << 6) | (1L << 16) | (1L << 21) | (1L << 25) | (1L << 29) | (1L << 31) | (1L << 33) | (1L << 36) | (1L << 37) | (1L << 41) | (1L << 62))) != 0) || ((((_la - 73)) & ~0x3f) == 0 && ((1L << (_la - 73)) & ((1L << (73 - 73)) | (1L << (77 - 73)) | (1L << (78 - 73)) | (1L << (79 - 73)) | (1L << (81 - 73)) | (1L << (83 - 73)) | (1L << (89 - 73)) | (1L << (Int - 73)) | (1L << (Uint - 73)) | (1L << (Byte - 73)) | (1L << (Fixed - 73)) | (1L << (Ufixed - 73)) | (1L << (BooleanLiteral - 73)) | (1L << (DecimalNumber - 73)) | (1L << (HexNumber - 73)) | (1L << (HexLiteral - 73)) | (1L << (TypeKeyword - 73)) | (1L << (Identifier - 73)) | (1L << (StringLiteral - 73)))) != 0)) {
					{
					setState(272); expressionList();
					}
				}

				setState(275); match(87);
				}
			}

			}
		}
		catch (RecognitionException re) {
			_localctx.exception = re;
			_errHandler.reportError(this, re);
			_errHandler.recover(this, re);
		}
		finally {
			exitRule();
		}
		return _localctx;
	}

	public static class ContractPartContext extends ParserRuleContext {
		public ConstructorDefinitionContext constructorDefinition() {
			return getRuleContext(ConstructorDefinitionContext.class,0);
		}
		public UsingForDeclarationContext usingForDeclaration() {
			return getRuleContext(UsingForDeclarationContext.class,0);
		}
		public EventDefinitionContext eventDefinition() {
			return getRuleContext(EventDefinitionContext.class,0);
		}
		public StructDefinitionContext structDefinition() {
			return getRuleContext(StructDefinitionContext.class,0);
		}
		public FunctionDefinitionContext functionDefinition() {
			return getRuleContext(FunctionDefinitionContext.class,0);
		}
		public EnumDefinitionContext enumDefinition() {
			return getRuleContext(EnumDefinitionContext.class,0);
		}
		public ModifierDefinitionContext modifierDefinition() {
			return getRuleContext(ModifierDefinitionContext.class,0);
		}
		public StateVariableDeclarationContext stateVariableDeclaration() {
			return getRuleContext(StateVariableDeclarationContext.class,0);
		}
		public ContractPartContext(ParserRuleContext parent, int invokingState) {
			super(parent, invokingState);
		}
		@Override public int getRuleIndex() { return RULE_contractPart; }
		@Override
		public void enterRule(ParseTreeListener listener) {
			if ( listener instanceof SolidityListener ) ((SolidityListener)listener).enterContractPart(this);
		}
		@Override
		public void exitRule(ParseTreeListener listener) {
			if ( listener instanceof SolidityListener ) ((SolidityListener)listener).exitContractPart(this);
		}
		@Override
		public <T> T accept(ParseTreeVisitor<? extends T> visitor) {
			if ( visitor instanceof SolidityVisitor ) return ((SolidityVisitor<? extends T>)visitor).visitContractPart(this);
			else return visitor.visitChildren(this);
		}
	}

	public final ContractPartContext contractPart() throws RecognitionException {
		ContractPartContext _localctx = new ContractPartContext(_ctx, getState());
		enterRule(_localctx, 24, RULE_contractPart);
		try {
			setState(286);
			switch ( getInterpreter().adaptivePredict(_input,17,_ctx) ) {
			case 1:
				enterOuterAlt(_localctx, 1);
				{
				setState(278); stateVariableDeclaration();
				}
				break;

			case 2:
				enterOuterAlt(_localctx, 2);
				{
				setState(279); usingForDeclaration();
				}
				break;

			case 3:
				enterOuterAlt(_localctx, 3);
				{
				setState(280); structDefinition();
				}
				break;

			case 4:
				enterOuterAlt(_localctx, 4);
				{
				setState(281); constructorDefinition();
				}
				break;

			case 5:
				enterOuterAlt(_localctx, 5);
				{
				setState(282); modifierDefinition();
				}
				break;

			case 6:
				enterOuterAlt(_localctx, 6);
				{
				setState(283); functionDefinition();
				}
				break;

			case 7:
				enterOuterAlt(_localctx, 7);
				{
				setState(284); eventDefinition();
				}
				break;

			case 8:
				enterOuterAlt(_localctx, 8);
				{
				setState(285); enumDefinition();
				}
				break;
			}
		}
		catch (RecognitionException re) {
			_localctx.exception = re;
			_errHandler.reportError(this, re);
			_errHandler.recover(this, re);
		}
		finally {
			exitRule();
		}
		return _localctx;
	}

	public static class StateVariableDeclarationContext extends ParserRuleContext {
		public List<TerminalNode> PrivateKeyword() { return getTokens(SolidityParser.PrivateKeyword); }
		public TerminalNode PrivateKeyword(int i) {
			return getToken(SolidityParser.PrivateKeyword, i);
		}
		public TypeNameContext typeName() {
			return getRuleContext(TypeNameContext.class,0);
		}
		public TerminalNode PublicKeyword(int i) {
			return getToken(SolidityParser.PublicKeyword, i);
		}
		public TerminalNode InternalKeyword(int i) {
			return getToken(SolidityParser.InternalKeyword, i);
		}
		public IdentifierContext identifier() {
			return getRuleContext(IdentifierContext.class,0);
		}
		public List<TerminalNode> ConstantKeyword() { return getTokens(SolidityParser.ConstantKeyword); }
		public ExpressionContext expression() {
			return getRuleContext(ExpressionContext.class,0);
		}
		public List<TerminalNode> InternalKeyword() { return getTokens(SolidityParser.InternalKeyword); }
		public TerminalNode ConstantKeyword(int i) {
			return getToken(SolidityParser.ConstantKeyword, i);
		}
		public List<TerminalNode> PublicKeyword() { return getTokens(SolidityParser.PublicKeyword); }
		public StateVariableDeclarationContext(ParserRuleContext parent, int invokingState) {
			super(parent, invokingState);
		}
		@Override public int getRuleIndex() { return RULE_stateVariableDeclaration; }
		@Override
		public void enterRule(ParseTreeListener listener) {
			if ( listener instanceof SolidityListener ) ((SolidityListener)listener).enterStateVariableDeclaration(this);
		}
		@Override
		public void exitRule(ParseTreeListener listener) {
			if ( listener instanceof SolidityListener ) ((SolidityListener)listener).exitStateVariableDeclaration(this);
		}
		@Override
		public <T> T accept(ParseTreeVisitor<? extends T> visitor) {
			if ( visitor instanceof SolidityVisitor ) return ((SolidityVisitor<? extends T>)visitor).visitStateVariableDeclaration(this);
			else return visitor.visitChildren(this);
		}
	}

	public final StateVariableDeclarationContext stateVariableDeclaration() throws RecognitionException {
		StateVariableDeclarationContext _localctx = new StateVariableDeclarationContext(_ctx, getState());
		enterRule(_localctx, 26, RULE_stateVariableDeclaration);
		int _la;
		try {
			enterOuterAlt(_localctx, 1);
			{
			setState(288); typeName(0);
			setState(292);
			_errHandler.sync(this);
			_la = _input.LA(1);
			while (((((_la - 107)) & ~0x3f) == 0 && ((1L << (_la - 107)) & ((1L << (ConstantKeyword - 107)) | (1L << (InternalKeyword - 107)) | (1L << (PrivateKeyword - 107)) | (1L << (PublicKeyword - 107)))) != 0)) {
				{
				{
				setState(289);
				_la = _input.LA(1);
				if ( !(((((_la - 107)) & ~0x3f) == 0 && ((1L << (_la - 107)) & ((1L << (ConstantKeyword - 107)) | (1L << (InternalKeyword - 107)) | (1L << (PrivateKeyword - 107)) | (1L << (PublicKeyword - 107)))) != 0)) ) {
				_errHandler.recoverInline(this);
				}
				consume();
				}
				}
				setState(294);
				_errHandler.sync(this);
				_la = _input.LA(1);
			}
			setState(295); identifier();
			setState(298);
			_la = _input.LA(1);
			if (_la==17) {
				{
				setState(296); match(17);
				setState(297); expression(0);
				}
			}

			setState(300); match(52);
			}
		}
		catch (RecognitionException re) {
			_localctx.exception = re;
			_errHandler.reportError(this, re);
			_errHandler.recover(this, re);
		}
		finally {
			exitRule();
		}
		return _localctx;
	}

	public static class UsingForDeclarationContext extends ParserRuleContext {
		public TypeNameContext typeName() {
			return getRuleContext(TypeNameContext.class,0);
		}
		public IdentifierContext identifier() {
			return getRuleContext(IdentifierContext.class,0);
		}
		public UsingForDeclarationContext(ParserRuleContext parent, int invokingState) {
			super(parent, invokingState);
		}
		@Override public int getRuleIndex() { return RULE_usingForDeclaration; }
		@Override
		public void enterRule(ParseTreeListener listener) {
			if ( listener instanceof SolidityListener ) ((SolidityListener)listener).enterUsingForDeclaration(this);
		}
		@Override
		public void exitRule(ParseTreeListener listener) {
			if ( listener instanceof SolidityListener ) ((SolidityListener)listener).exitUsingForDeclaration(this);
		}
		@Override
		public <T> T accept(ParseTreeVisitor<? extends T> visitor) {
			if ( visitor instanceof SolidityVisitor ) return ((SolidityVisitor<? extends T>)visitor).visitUsingForDeclaration(this);
			else return visitor.visitChildren(this);
		}
	}

	public final UsingForDeclarationContext usingForDeclaration() throws RecognitionException {
		UsingForDeclarationContext _localctx = new UsingForDeclarationContext(_ctx, getState());
		enterRule(_localctx, 28, RULE_usingForDeclaration);
		try {
			enterOuterAlt(_localctx, 1);
			{
			setState(302); match(49);
			setState(303); identifier();
			setState(304); match(19);
			setState(307);
			switch (_input.LA(1)) {
			case 66:
				{
				setState(305); match(66);
				}
				break;
			case 16:
			case 31:
			case 37:
			case 40:
			case 42:
			case 62:
			case 78:
			case 79:
			case 83:
			case Int:
			case Uint:
			case Byte:
			case Fixed:
			case Ufixed:
			case Identifier:
				{
				setState(306); typeName(0);
				}
				break;
			default:
				throw new NoViableAltException(this);
			}
			setState(309); match(52);
			}
		}
		catch (RecognitionException re) {
			_localctx.exception = re;
			_errHandler.reportError(this, re);
			_errHandler.recover(this, re);
		}
		finally {
			exitRule();
		}
		return _localctx;
	}

	public static class StructDefinitionContext extends ParserRuleContext {
		public List<VariableDeclarationContext> variableDeclaration() {
			return getRuleContexts(VariableDeclarationContext.class);
		}
		public VariableDeclarationContext variableDeclaration(int i) {
			return getRuleContext(VariableDeclarationContext.class,i);
		}
		public IdentifierContext identifier() {
			return getRuleContext(IdentifierContext.class,0);
		}
		public StructDefinitionContext(ParserRuleContext parent, int invokingState) {
			super(parent, invokingState);
		}
		@Override public int getRuleIndex() { return RULE_structDefinition; }
		@Override
		public void enterRule(ParseTreeListener listener) {
			if ( listener instanceof SolidityListener ) ((SolidityListener)listener).enterStructDefinition(this);
		}
		@Override
		public void exitRule(ParseTreeListener listener) {
			if ( listener instanceof SolidityListener ) ((SolidityListener)listener).exitStructDefinition(this);
		}
		@Override
		public <T> T accept(ParseTreeVisitor<? extends T> visitor) {
			if ( visitor instanceof SolidityVisitor ) return ((SolidityVisitor<? extends T>)visitor).visitStructDefinition(this);
			else return visitor.visitChildren(this);
		}
	}

	public final StructDefinitionContext structDefinition() throws RecognitionException {
		StructDefinitionContext _localctx = new StructDefinitionContext(_ctx, getState());
		enterRule(_localctx, 30, RULE_structDefinition);
		int _la;
		try {
			enterOuterAlt(_localctx, 1);
			{
			setState(311); match(43);
			setState(312); identifier();
			setState(313); match(10);
			setState(324);
			_la = _input.LA(1);
			if ((((_la) & ~0x3f) == 0 && ((1L << _la) & ((1L << 16) | (1L << 31) | (1L << 37) | (1L << 40) | (1L << 42) | (1L << 62))) != 0) || ((((_la - 78)) & ~0x3f) == 0 && ((1L << (_la - 78)) & ((1L << (78 - 78)) | (1L << (79 - 78)) | (1L << (83 - 78)) | (1L << (Int - 78)) | (1L << (Uint - 78)) | (1L << (Byte - 78)) | (1L << (Fixed - 78)) | (1L << (Ufixed - 78)) | (1L << (Identifier - 78)))) != 0)) {
				{
				setState(314); variableDeclaration();
				setState(315); match(52);
				setState(321);
				_errHandler.sync(this);
				_la = _input.LA(1);
				while ((((_la) & ~0x3f) == 0 && ((1L << _la) & ((1L << 16) | (1L << 31) | (1L << 37) | (1L << 40) | (1L << 42) | (1L << 62))) != 0) || ((((_la - 78)) & ~0x3f) == 0 && ((1L << (_la - 78)) & ((1L << (78 - 78)) | (1L << (79 - 78)) | (1L << (83 - 78)) | (1L << (Int - 78)) | (1L << (Uint - 78)) | (1L << (Byte - 78)) | (1L << (Fixed - 78)) | (1L << (Ufixed - 78)) | (1L << (Identifier - 78)))) != 0)) {
					{
					{
					setState(316); variableDeclaration();
					setState(317); match(52);
					}
					}
					setState(323);
					_errHandler.sync(this);
					_la = _input.LA(1);
				}
				}
			}

			setState(326); match(55);
			}
		}
		catch (RecognitionException re) {
			_localctx.exception = re;
			_errHandler.reportError(this, re);
			_errHandler.recover(this, re);
		}
		finally {
			exitRule();
		}
		return _localctx;
	}

	public static class ConstructorDefinitionContext extends ParserRuleContext {
		public ModifierListContext modifierList() {
			return getRuleContext(ModifierListContext.class,0);
		}
		public ParameterListContext parameterList() {
			return getRuleContext(ParameterListContext.class,0);
		}
		public BlockContext block() {
			return getRuleContext(BlockContext.class,0);
		}
		public ConstructorDefinitionContext(ParserRuleContext parent, int invokingState) {
			super(parent, invokingState);
		}
		@Override public int getRuleIndex() { return RULE_constructorDefinition; }
		@Override
		public void enterRule(ParseTreeListener listener) {
			if ( listener instanceof SolidityListener ) ((SolidityListener)listener).enterConstructorDefinition(this);
		}
		@Override
		public void exitRule(ParseTreeListener listener) {
			if ( listener instanceof SolidityListener ) ((SolidityListener)listener).exitConstructorDefinition(this);
		}
		@Override
		public <T> T accept(ParseTreeVisitor<? extends T> visitor) {
			if ( visitor instanceof SolidityVisitor ) return ((SolidityVisitor<? extends T>)visitor).visitConstructorDefinition(this);
			else return visitor.visitChildren(this);
		}
	}

	public final ConstructorDefinitionContext constructorDefinition() throws RecognitionException {
		ConstructorDefinitionContext _localctx = new ConstructorDefinitionContext(_ctx, getState());
		enterRule(_localctx, 32, RULE_constructorDefinition);
		try {
			enterOuterAlt(_localctx, 1);
			{
			setState(328); match(23);
			setState(329); parameterList();
			setState(330); modifierList();
			setState(331); block();
			}
		}
		catch (RecognitionException re) {
			_localctx.exception = re;
			_errHandler.reportError(this, re);
			_errHandler.recover(this, re);
		}
		finally {
			exitRule();
		}
		return _localctx;
	}

	public static class ModifierDefinitionContext extends ParserRuleContext {
		public IdentifierContext identifier() {
			return getRuleContext(IdentifierContext.class,0);
		}
		public ParameterListContext parameterList() {
			return getRuleContext(ParameterListContext.class,0);
		}
		public BlockContext block() {
			return getRuleContext(BlockContext.class,0);
		}
		public ModifierDefinitionContext(ParserRuleContext parent, int invokingState) {
			super(parent, invokingState);
		}
		@Override public int getRuleIndex() { return RULE_modifierDefinition; }
		@Override
		public void enterRule(ParseTreeListener listener) {
			if ( listener instanceof SolidityListener ) ((SolidityListener)listener).enterModifierDefinition(this);
		}
		@Override
		public void exitRule(ParseTreeListener listener) {
			if ( listener instanceof SolidityListener ) ((SolidityListener)listener).exitModifierDefinition(this);
		}
		@Override
		public <T> T accept(ParseTreeVisitor<? extends T> visitor) {
			if ( visitor instanceof SolidityVisitor ) return ((SolidityVisitor<? extends T>)visitor).visitModifierDefinition(this);
			else return visitor.visitChildren(this);
		}
	}

	public final ModifierDefinitionContext modifierDefinition() throws RecognitionException {
		ModifierDefinitionContext _localctx = new ModifierDefinitionContext(_ctx, getState());
		enterRule(_localctx, 34, RULE_modifierDefinition);
		int _la;
		try {
			enterOuterAlt(_localctx, 1);
			{
			setState(333); match(85);
			setState(334); identifier();
			setState(336);
			_la = _input.LA(1);
			if (_la==25) {
				{
				setState(335); parameterList();
				}
			}

			setState(338); block();
			}
		}
		catch (RecognitionException re) {
			_localctx.exception = re;
			_errHandler.reportError(this, re);
			_errHandler.recover(this, re);
		}
		finally {
			exitRule();
		}
		return _localctx;
	}

	public static class ModifierInvocationContext extends ParserRuleContext {
		public ExpressionListContext expressionList() {
			return getRuleContext(ExpressionListContext.class,0);
		}
		public IdentifierContext identifier() {
			return getRuleContext(IdentifierContext.class,0);
		}
		public ModifierInvocationContext(ParserRuleContext parent, int invokingState) {
			super(parent, invokingState);
		}
		@Override public int getRuleIndex() { return RULE_modifierInvocation; }
		@Override
		public void enterRule(ParseTreeListener listener) {
			if ( listener instanceof SolidityListener ) ((SolidityListener)listener).enterModifierInvocation(this);
		}
		@Override
		public void exitRule(ParseTreeListener listener) {
			if ( listener instanceof SolidityListener ) ((SolidityListener)listener).exitModifierInvocation(this);
		}
		@Override
		public <T> T accept(ParseTreeVisitor<? extends T> visitor) {
			if ( visitor instanceof SolidityVisitor ) return ((SolidityVisitor<? extends T>)visitor).visitModifierInvocation(this);
			else return visitor.visitChildren(this);
		}
	}

	public final ModifierInvocationContext modifierInvocation() throws RecognitionException {
		ModifierInvocationContext _localctx = new ModifierInvocationContext(_ctx, getState());
		enterRule(_localctx, 36, RULE_modifierInvocation);
		int _la;
		try {
			enterOuterAlt(_localctx, 1);
			{
			setState(340); identifier();
			setState(346);
			_la = _input.LA(1);
			if (_la==25) {
				{
				setState(341); match(25);
				setState(343);
				_la = _input.LA(1);
				if ((((_la) & ~0x3f) == 0 && ((1L << _la) & ((1L << 6) | (1L << 16) | (1L << 21) | (1L << 25) | (1L << 29) | (1L << 31) | (1L << 33) | (1L << 36) | (1L << 37) | (1L << 41) | (1L << 62))) != 0) || ((((_la - 73)) & ~0x3f) == 0 && ((1L << (_la - 73)) & ((1L << (73 - 73)) | (1L << (77 - 73)) | (1L << (78 - 73)) | (1L << (79 - 73)) | (1L << (81 - 73)) | (1L << (83 - 73)) | (1L << (89 - 73)) | (1L << (Int - 73)) | (1L << (Uint - 73)) | (1L << (Byte - 73)) | (1L << (Fixed - 73)) | (1L << (Ufixed - 73)) | (1L << (BooleanLiteral - 73)) | (1L << (DecimalNumber - 73)) | (1L << (HexNumber - 73)) | (1L << (HexLiteral - 73)) | (1L << (TypeKeyword - 73)) | (1L << (Identifier - 73)) | (1L << (StringLiteral - 73)))) != 0)) {
					{
					setState(342); expressionList();
					}
				}

				setState(345); match(87);
				}
			}

			}
		}
		catch (RecognitionException re) {
			_localctx.exception = re;
			_errHandler.reportError(this, re);
			_errHandler.recover(this, re);
		}
		finally {
			exitRule();
		}
		return _localctx;
	}

	public static class FunctionDefinitionContext extends ParserRuleContext {
		public ReturnParametersContext returnParameters() {
			return getRuleContext(ReturnParametersContext.class,0);
		}
		public ModifierListContext modifierList() {
			return getRuleContext(ModifierListContext.class,0);
		}
		public NatSpecContext natSpec() {
			return getRuleContext(NatSpecContext.class,0);
		}
		public ParameterListContext parameterList() {
			return getRuleContext(ParameterListContext.class,0);
		}
		public IdentifierContext identifier() {
			return getRuleContext(IdentifierContext.class,0);
		}
		public BlockContext block() {
			return getRuleContext(BlockContext.class,0);
		}
		public FunctionDefinitionContext(ParserRuleContext parent, int invokingState) {
			super(parent, invokingState);
		}
		@Override public int getRuleIndex() { return RULE_functionDefinition; }
		@Override
		public void enterRule(ParseTreeListener listener) {
			if ( listener instanceof SolidityListener ) ((SolidityListener)listener).enterFunctionDefinition(this);
		}
		@Override
		public void exitRule(ParseTreeListener listener) {
			if ( listener instanceof SolidityListener ) ((SolidityListener)listener).exitFunctionDefinition(this);
		}
		@Override
		public <T> T accept(ParseTreeVisitor<? extends T> visitor) {
			if ( visitor instanceof SolidityVisitor ) return ((SolidityVisitor<? extends T>)visitor).visitFunctionDefinition(this);
			else return visitor.visitChildren(this);
		}
	}

	public final FunctionDefinitionContext functionDefinition() throws RecognitionException {
		FunctionDefinitionContext _localctx = new FunctionDefinitionContext(_ctx, getState());
		enterRule(_localctx, 38, RULE_functionDefinition);
		int _la;
		try {
			enterOuterAlt(_localctx, 1);
			{
			setState(349);
			_la = _input.LA(1);
			if (_la==NatSpecSingleLine || _la==NatSpecMultiLine) {
				{
				setState(348); natSpec();
				}
			}

			setState(351); match(40);
			setState(353);
			_la = _input.LA(1);
			if (_la==37 || _la==62 || _la==Identifier) {
				{
				setState(352); identifier();
				}
			}

			setState(355); parameterList();
			setState(356); modifierList();
			setState(358);
			_la = _input.LA(1);
			if (_la==39) {
				{
				setState(357); returnParameters();
				}
			}

			setState(362);
			switch (_input.LA(1)) {
			case 52:
				{
				setState(360); match(52);
				}
				break;
			case 10:
				{
				setState(361); block();
				}
				break;
			default:
				throw new NoViableAltException(this);
			}
			}
		}
		catch (RecognitionException re) {
			_localctx.exception = re;
			_errHandler.reportError(this, re);
			_errHandler.recover(this, re);
		}
		finally {
			exitRule();
		}
		return _localctx;
	}

	public static class ReturnParametersContext extends ParserRuleContext {
		public ParameterListContext parameterList() {
			return getRuleContext(ParameterListContext.class,0);
		}
		public ReturnParametersContext(ParserRuleContext parent, int invokingState) {
			super(parent, invokingState);
		}
		@Override public int getRuleIndex() { return RULE_returnParameters; }
		@Override
		public void enterRule(ParseTreeListener listener) {
			if ( listener instanceof SolidityListener ) ((SolidityListener)listener).enterReturnParameters(this);
		}
		@Override
		public void exitRule(ParseTreeListener listener) {
			if ( listener instanceof SolidityListener ) ((SolidityListener)listener).exitReturnParameters(this);
		}
		@Override
		public <T> T accept(ParseTreeVisitor<? extends T> visitor) {
			if ( visitor instanceof SolidityVisitor ) return ((SolidityVisitor<? extends T>)visitor).visitReturnParameters(this);
			else return visitor.visitChildren(this);
		}
	}

	public final ReturnParametersContext returnParameters() throws RecognitionException {
		ReturnParametersContext _localctx = new ReturnParametersContext(_ctx, getState());
		enterRule(_localctx, 40, RULE_returnParameters);
		try {
			enterOuterAlt(_localctx, 1);
			{
			setState(364); match(39);
			setState(365); parameterList();
			}
		}
		catch (RecognitionException re) {
			_localctx.exception = re;
			_errHandler.reportError(this, re);
			_errHandler.recover(this, re);
		}
		finally {
			exitRule();
		}
		return _localctx;
	}

	public static class ModifierListContext extends ParserRuleContext {
		public List<ModifierInvocationContext> modifierInvocation() {
			return getRuleContexts(ModifierInvocationContext.class);
		}
		public List<StateMutabilityContext> stateMutability() {
			return getRuleContexts(StateMutabilityContext.class);
		}
		public TerminalNode ExternalKeyword(int i) {
			return getToken(SolidityParser.ExternalKeyword, i);
		}
		public List<TerminalNode> PrivateKeyword() { return getTokens(SolidityParser.PrivateKeyword); }
		public TerminalNode PrivateKeyword(int i) {
			return getToken(SolidityParser.PrivateKeyword, i);
		}
		public ModifierInvocationContext modifierInvocation(int i) {
			return getRuleContext(ModifierInvocationContext.class,i);
		}
		public TerminalNode PublicKeyword(int i) {
			return getToken(SolidityParser.PublicKeyword, i);
		}
		public StateMutabilityContext stateMutability(int i) {
			return getRuleContext(StateMutabilityContext.class,i);
		}
		public TerminalNode InternalKeyword(int i) {
			return getToken(SolidityParser.InternalKeyword, i);
		}
		public List<TerminalNode> InternalKeyword() { return getTokens(SolidityParser.InternalKeyword); }
		public List<TerminalNode> PublicKeyword() { return getTokens(SolidityParser.PublicKeyword); }
		public List<TerminalNode> ExternalKeyword() { return getTokens(SolidityParser.ExternalKeyword); }
		public ModifierListContext(ParserRuleContext parent, int invokingState) {
			super(parent, invokingState);
		}
		@Override public int getRuleIndex() { return RULE_modifierList; }
		@Override
		public void enterRule(ParseTreeListener listener) {
			if ( listener instanceof SolidityListener ) ((SolidityListener)listener).enterModifierList(this);
		}
		@Override
		public void exitRule(ParseTreeListener listener) {
			if ( listener instanceof SolidityListener ) ((SolidityListener)listener).exitModifierList(this);
		}
		@Override
		public <T> T accept(ParseTreeVisitor<? extends T> visitor) {
			if ( visitor instanceof SolidityVisitor ) return ((SolidityVisitor<? extends T>)visitor).visitModifierList(this);
			else return visitor.visitChildren(this);
		}
	}

	public final ModifierListContext modifierList() throws RecognitionException {
		ModifierListContext _localctx = new ModifierListContext(_ctx, getState());
		enterRule(_localctx, 42, RULE_modifierList);
		int _la;
		try {
			enterOuterAlt(_localctx, 1);
			{
			setState(375);
			_errHandler.sync(this);
			_la = _input.LA(1);
			while (_la==37 || _la==62 || ((((_la - 107)) & ~0x3f) == 0 && ((1L << (_la - 107)) & ((1L << (ConstantKeyword - 107)) | (1L << (ExternalKeyword - 107)) | (1L << (InternalKeyword - 107)) | (1L << (PayableKeyword - 107)) | (1L << (PrivateKeyword - 107)) | (1L << (PublicKeyword - 107)) | (1L << (PureKeyword - 107)) | (1L << (ViewKeyword - 107)) | (1L << (Identifier - 107)))) != 0)) {
				{
				setState(373);
				switch (_input.LA(1)) {
				case 37:
				case 62:
				case Identifier:
					{
					setState(367); modifierInvocation();
					}
					break;
				case ConstantKeyword:
				case PayableKeyword:
				case PureKeyword:
				case ViewKeyword:
					{
					setState(368); stateMutability();
					}
					break;
				case ExternalKeyword:
					{
					setState(369); match(ExternalKeyword);
					}
					break;
				case PublicKeyword:
					{
					setState(370); match(PublicKeyword);
					}
					break;
				case InternalKeyword:
					{
					setState(371); match(InternalKeyword);
					}
					break;
				case PrivateKeyword:
					{
					setState(372); match(PrivateKeyword);
					}
					break;
				default:
					throw new NoViableAltException(this);
				}
				}
				setState(377);
				_errHandler.sync(this);
				_la = _input.LA(1);
			}
			}
		}
		catch (RecognitionException re) {
			_localctx.exception = re;
			_errHandler.reportError(this, re);
			_errHandler.recover(this, re);
		}
		finally {
			exitRule();
		}
		return _localctx;
	}

	public static class EventDefinitionContext extends ParserRuleContext {
		public TerminalNode AnonymousKeyword() { return getToken(SolidityParser.AnonymousKeyword, 0); }
		public NatSpecContext natSpec() {
			return getRuleContext(NatSpecContext.class,0);
		}
		public IdentifierContext identifier() {
			return getRuleContext(IdentifierContext.class,0);
		}
		public EventParameterListContext eventParameterList() {
			return getRuleContext(EventParameterListContext.class,0);
		}
		public EventDefinitionContext(ParserRuleContext parent, int invokingState) {
			super(parent, invokingState);
		}
		@Override public int getRuleIndex() { return RULE_eventDefinition; }
		@Override
		public void enterRule(ParseTreeListener listener) {
			if ( listener instanceof SolidityListener ) ((SolidityListener)listener).enterEventDefinition(this);
		}
		@Override
		public void exitRule(ParseTreeListener listener) {
			if ( listener instanceof SolidityListener ) ((SolidityListener)listener).exitEventDefinition(this);
		}
		@Override
		public <T> T accept(ParseTreeVisitor<? extends T> visitor) {
			if ( visitor instanceof SolidityVisitor ) return ((SolidityVisitor<? extends T>)visitor).visitEventDefinition(this);
			else return visitor.visitChildren(this);
		}
	}

	public final EventDefinitionContext eventDefinition() throws RecognitionException {
		EventDefinitionContext _localctx = new EventDefinitionContext(_ctx, getState());
		enterRule(_localctx, 44, RULE_eventDefinition);
		int _la;
		try {
			enterOuterAlt(_localctx, 1);
			{
			setState(379);
			_la = _input.LA(1);
			if (_la==NatSpecSingleLine || _la==NatSpecMultiLine) {
				{
				setState(378); natSpec();
				}
			}

			setState(381); match(60);
			setState(382); identifier();
			setState(383); eventParameterList();
			setState(385);
			_la = _input.LA(1);
			if (_la==AnonymousKeyword) {
				{
				setState(384); match(AnonymousKeyword);
				}
			}

			setState(387); match(52);
			}
		}
		catch (RecognitionException re) {
			_localctx.exception = re;
			_errHandler.reportError(this, re);
			_errHandler.recover(this, re);
		}
		finally {
			exitRule();
		}
		return _localctx;
	}

	public static class EnumValueContext extends ParserRuleContext {
		public IdentifierContext identifier() {
			return getRuleContext(IdentifierContext.class,0);
		}
		public EnumValueContext(ParserRuleContext parent, int invokingState) {
			super(parent, invokingState);
		}
		@Override public int getRuleIndex() { return RULE_enumValue; }
		@Override
		public void enterRule(ParseTreeListener listener) {
			if ( listener instanceof SolidityListener ) ((SolidityListener)listener).enterEnumValue(this);
		}
		@Override
		public void exitRule(ParseTreeListener listener) {
			if ( listener instanceof SolidityListener ) ((SolidityListener)listener).exitEnumValue(this);
		}
		@Override
		public <T> T accept(ParseTreeVisitor<? extends T> visitor) {
			if ( visitor instanceof SolidityVisitor ) return ((SolidityVisitor<? extends T>)visitor).visitEnumValue(this);
			else return visitor.visitChildren(this);
		}
	}

	public final EnumValueContext enumValue() throws RecognitionException {
		EnumValueContext _localctx = new EnumValueContext(_ctx, getState());
		enterRule(_localctx, 46, RULE_enumValue);
		try {
			enterOuterAlt(_localctx, 1);
			{
			setState(389); identifier();
			}
		}
		catch (RecognitionException re) {
			_localctx.exception = re;
			_errHandler.reportError(this, re);
			_errHandler.recover(this, re);
		}
		finally {
			exitRule();
		}
		return _localctx;
	}

	public static class EnumDefinitionContext extends ParserRuleContext {
		public IdentifierContext identifier() {
			return getRuleContext(IdentifierContext.class,0);
		}
		public List<EnumValueContext> enumValue() {
			return getRuleContexts(EnumValueContext.class);
		}
		public EnumValueContext enumValue(int i) {
			return getRuleContext(EnumValueContext.class,i);
		}
		public EnumDefinitionContext(ParserRuleContext parent, int invokingState) {
			super(parent, invokingState);
		}
		@Override public int getRuleIndex() { return RULE_enumDefinition; }
		@Override
		public void enterRule(ParseTreeListener listener) {
			if ( listener instanceof SolidityListener ) ((SolidityListener)listener).enterEnumDefinition(this);
		}
		@Override
		public void exitRule(ParseTreeListener listener) {
			if ( listener instanceof SolidityListener ) ((SolidityListener)listener).exitEnumDefinition(this);
		}
		@Override
		public <T> T accept(ParseTreeVisitor<? extends T> visitor) {
			if ( visitor instanceof SolidityVisitor ) return ((SolidityVisitor<? extends T>)visitor).visitEnumDefinition(this);
			else return visitor.visitChildren(this);
		}
	}

	public final EnumDefinitionContext enumDefinition() throws RecognitionException {
		EnumDefinitionContext _localctx = new EnumDefinitionContext(_ctx, getState());
		enterRule(_localctx, 48, RULE_enumDefinition);
		int _la;
		try {
			enterOuterAlt(_localctx, 1);
			{
			setState(391); match(59);
			setState(392); identifier();
			setState(393); match(10);
			setState(395);
			_la = _input.LA(1);
			if (_la==37 || _la==62 || _la==Identifier) {
				{
				setState(394); enumValue();
				}
			}

			setState(401);
			_errHandler.sync(this);
			_la = _input.LA(1);
			while (_la==27) {
				{
				{
				setState(397); match(27);
				setState(398); enumValue();
				}
				}
				setState(403);
				_errHandler.sync(this);
				_la = _input.LA(1);
			}
			setState(404); match(55);
			}
		}
		catch (RecognitionException re) {
			_localctx.exception = re;
			_errHandler.reportError(this, re);
			_errHandler.recover(this, re);
		}
		finally {
			exitRule();
		}
		return _localctx;
	}

	public static class ParameterListContext extends ParserRuleContext {
		public List<ParameterContext> parameter() {
			return getRuleContexts(ParameterContext.class);
		}
		public ParameterContext parameter(int i) {
			return getRuleContext(ParameterContext.class,i);
		}
		public ParameterListContext(ParserRuleContext parent, int invokingState) {
			super(parent, invokingState);
		}
		@Override public int getRuleIndex() { return RULE_parameterList; }
		@Override
		public void enterRule(ParseTreeListener listener) {
			if ( listener instanceof SolidityListener ) ((SolidityListener)listener).enterParameterList(this);
		}
		@Override
		public void exitRule(ParseTreeListener listener) {
			if ( listener instanceof SolidityListener ) ((SolidityListener)listener).exitParameterList(this);
		}
		@Override
		public <T> T accept(ParseTreeVisitor<? extends T> visitor) {
			if ( visitor instanceof SolidityVisitor ) return ((SolidityVisitor<? extends T>)visitor).visitParameterList(this);
			else return visitor.visitChildren(this);
		}
	}

	public final ParameterListContext parameterList() throws RecognitionException {
		ParameterListContext _localctx = new ParameterListContext(_ctx, getState());
		enterRule(_localctx, 50, RULE_parameterList);
		int _la;
		try {
			enterOuterAlt(_localctx, 1);
			{
			setState(406); match(25);
			setState(415);
			_la = _input.LA(1);
			if ((((_la) & ~0x3f) == 0 && ((1L << _la) & ((1L << 16) | (1L << 31) | (1L << 37) | (1L << 40) | (1L << 42) | (1L << 62))) != 0) || ((((_la - 78)) & ~0x3f) == 0 && ((1L << (_la - 78)) & ((1L << (78 - 78)) | (1L << (79 - 78)) | (1L << (83 - 78)) | (1L << (Int - 78)) | (1L << (Uint - 78)) | (1L << (Byte - 78)) | (1L << (Fixed - 78)) | (1L << (Ufixed - 78)) | (1L << (Identifier - 78)))) != 0)) {
				{
				setState(407); parameter();
				setState(412);
				_errHandler.sync(this);
				_la = _input.LA(1);
				while (_la==27) {
					{
					{
					setState(408); match(27);
					setState(409); parameter();
					}
					}
					setState(414);
					_errHandler.sync(this);
					_la = _input.LA(1);
				}
				}
			}

			setState(417); match(87);
			}
		}
		catch (RecognitionException re) {
			_localctx.exception = re;
			_errHandler.reportError(this, re);
			_errHandler.recover(this, re);
		}
		finally {
			exitRule();
		}
		return _localctx;
	}

	public static class ParameterContext extends ParserRuleContext {
		public TypeNameContext typeName() {
			return getRuleContext(TypeNameContext.class,0);
		}
		public IdentifierContext identifier() {
			return getRuleContext(IdentifierContext.class,0);
		}
		public StorageLocationContext storageLocation() {
			return getRuleContext(StorageLocationContext.class,0);
		}
		public ParameterContext(ParserRuleContext parent, int invokingState) {
			super(parent, invokingState);
		}
		@Override public int getRuleIndex() { return RULE_parameter; }
		@Override
		public void enterRule(ParseTreeListener listener) {
			if ( listener instanceof SolidityListener ) ((SolidityListener)listener).enterParameter(this);
		}
		@Override
		public void exitRule(ParseTreeListener listener) {
			if ( listener instanceof SolidityListener ) ((SolidityListener)listener).exitParameter(this);
		}
		@Override
		public <T> T accept(ParseTreeVisitor<? extends T> visitor) {
			if ( visitor instanceof SolidityVisitor ) return ((SolidityVisitor<? extends T>)visitor).visitParameter(this);
			else return visitor.visitChildren(this);
		}
	}

	public final ParameterContext parameter() throws RecognitionException {
		ParameterContext _localctx = new ParameterContext(_ctx, getState());
		enterRule(_localctx, 52, RULE_parameter);
		int _la;
		try {
			enterOuterAlt(_localctx, 1);
			{
			setState(419); typeName(0);
			setState(421);
			switch ( getInterpreter().adaptivePredict(_input,38,_ctx) ) {
			case 1:
				{
				setState(420); storageLocation();
				}
				break;
			}
			setState(424);
			_la = _input.LA(1);
			if (_la==37 || _la==62 || _la==Identifier) {
				{
				setState(423); identifier();
				}
			}

			}
		}
		catch (RecognitionException re) {
			_localctx.exception = re;
			_errHandler.reportError(this, re);
			_errHandler.recover(this, re);
		}
		finally {
			exitRule();
		}
		return _localctx;
	}

	public static class EventParameterListContext extends ParserRuleContext {
		public EventParameterContext eventParameter(int i) {
			return getRuleContext(EventParameterContext.class,i);
		}
		public List<EventParameterContext> eventParameter() {
			return getRuleContexts(EventParameterContext.class);
		}
		public EventParameterListContext(ParserRuleContext parent, int invokingState) {
			super(parent, invokingState);
		}
		@Override public int getRuleIndex() { return RULE_eventParameterList; }
		@Override
		public void enterRule(ParseTreeListener listener) {
			if ( listener instanceof SolidityListener ) ((SolidityListener)listener).enterEventParameterList(this);
		}
		@Override
		public void exitRule(ParseTreeListener listener) {
			if ( listener instanceof SolidityListener ) ((SolidityListener)listener).exitEventParameterList(this);
		}
		@Override
		public <T> T accept(ParseTreeVisitor<? extends T> visitor) {
			if ( visitor instanceof SolidityVisitor ) return ((SolidityVisitor<? extends T>)visitor).visitEventParameterList(this);
			else return visitor.visitChildren(this);
		}
	}

	public final EventParameterListContext eventParameterList() throws RecognitionException {
		EventParameterListContext _localctx = new EventParameterListContext(_ctx, getState());
		enterRule(_localctx, 54, RULE_eventParameterList);
		int _la;
		try {
			enterOuterAlt(_localctx, 1);
			{
			setState(426); match(25);
			setState(435);
			_la = _input.LA(1);
			if ((((_la) & ~0x3f) == 0 && ((1L << _la) & ((1L << 16) | (1L << 31) | (1L << 37) | (1L << 40) | (1L << 42) | (1L << 62))) != 0) || ((((_la - 78)) & ~0x3f) == 0 && ((1L << (_la - 78)) & ((1L << (78 - 78)) | (1L << (79 - 78)) | (1L << (83 - 78)) | (1L << (Int - 78)) | (1L << (Uint - 78)) | (1L << (Byte - 78)) | (1L << (Fixed - 78)) | (1L << (Ufixed - 78)) | (1L << (Identifier - 78)))) != 0)) {
				{
				setState(427); eventParameter();
				setState(432);
				_errHandler.sync(this);
				_la = _input.LA(1);
				while (_la==27) {
					{
					{
					setState(428); match(27);
					setState(429); eventParameter();
					}
					}
					setState(434);
					_errHandler.sync(this);
					_la = _input.LA(1);
				}
				}
			}

			setState(437); match(87);
			}
		}
		catch (RecognitionException re) {
			_localctx.exception = re;
			_errHandler.reportError(this, re);
			_errHandler.recover(this, re);
		}
		finally {
			exitRule();
		}
		return _localctx;
	}

	public static class EventParameterContext extends ParserRuleContext {
		public TypeNameContext typeName() {
			return getRuleContext(TypeNameContext.class,0);
		}
		public TerminalNode IndexedKeyword() { return getToken(SolidityParser.IndexedKeyword, 0); }
		public IdentifierContext identifier() {
			return getRuleContext(IdentifierContext.class,0);
		}
		public EventParameterContext(ParserRuleContext parent, int invokingState) {
			super(parent, invokingState);
		}
		@Override public int getRuleIndex() { return RULE_eventParameter; }
		@Override
		public void enterRule(ParseTreeListener listener) {
			if ( listener instanceof SolidityListener ) ((SolidityListener)listener).enterEventParameter(this);
		}
		@Override
		public void exitRule(ParseTreeListener listener) {
			if ( listener instanceof SolidityListener ) ((SolidityListener)listener).exitEventParameter(this);
		}
		@Override
		public <T> T accept(ParseTreeVisitor<? extends T> visitor) {
			if ( visitor instanceof SolidityVisitor ) return ((SolidityVisitor<? extends T>)visitor).visitEventParameter(this);
			else return visitor.visitChildren(this);
		}
	}

	public final EventParameterContext eventParameter() throws RecognitionException {
		EventParameterContext _localctx = new EventParameterContext(_ctx, getState());
		enterRule(_localctx, 56, RULE_eventParameter);
		int _la;
		try {
			enterOuterAlt(_localctx, 1);
			{
			setState(439); typeName(0);
			setState(441);
			_la = _input.LA(1);
			if (_la==IndexedKeyword) {
				{
				setState(440); match(IndexedKeyword);
				}
			}

			setState(444);
			_la = _input.LA(1);
			if (_la==37 || _la==62 || _la==Identifier) {
				{
				setState(443); identifier();
				}
			}

			}
		}
		catch (RecognitionException re) {
			_localctx.exception = re;
			_errHandler.reportError(this, re);
			_errHandler.recover(this, re);
		}
		finally {
			exitRule();
		}
		return _localctx;
	}

	public static class FunctionTypeParameterListContext extends ParserRuleContext {
		public FunctionTypeParameterContext functionTypeParameter(int i) {
			return getRuleContext(FunctionTypeParameterContext.class,i);
		}
		public List<FunctionTypeParameterContext> functionTypeParameter() {
			return getRuleContexts(FunctionTypeParameterContext.class);
		}
		public FunctionTypeParameterListContext(ParserRuleContext parent, int invokingState) {
			super(parent, invokingState);
		}
		@Override public int getRuleIndex() { return RULE_functionTypeParameterList; }
		@Override
		public void enterRule(ParseTreeListener listener) {
			if ( listener instanceof SolidityListener ) ((SolidityListener)listener).enterFunctionTypeParameterList(this);
		}
		@Override
		public void exitRule(ParseTreeListener listener) {
			if ( listener instanceof SolidityListener ) ((SolidityListener)listener).exitFunctionTypeParameterList(this);
		}
		@Override
		public <T> T accept(ParseTreeVisitor<? extends T> visitor) {
			if ( visitor instanceof SolidityVisitor ) return ((SolidityVisitor<? extends T>)visitor).visitFunctionTypeParameterList(this);
			else return visitor.visitChildren(this);
		}
	}

	public final FunctionTypeParameterListContext functionTypeParameterList() throws RecognitionException {
		FunctionTypeParameterListContext _localctx = new FunctionTypeParameterListContext(_ctx, getState());
		enterRule(_localctx, 58, RULE_functionTypeParameterList);
		int _la;
		try {
			enterOuterAlt(_localctx, 1);
			{
			setState(446); match(25);
			setState(455);
			_la = _input.LA(1);
			if ((((_la) & ~0x3f) == 0 && ((1L << _la) & ((1L << 16) | (1L << 31) | (1L << 37) | (1L << 40) | (1L << 42) | (1L << 62))) != 0) || ((((_la - 78)) & ~0x3f) == 0 && ((1L << (_la - 78)) & ((1L << (78 - 78)) | (1L << (79 - 78)) | (1L << (83 - 78)) | (1L << (Int - 78)) | (1L << (Uint - 78)) | (1L << (Byte - 78)) | (1L << (Fixed - 78)) | (1L << (Ufixed - 78)) | (1L << (Identifier - 78)))) != 0)) {
				{
				setState(447); functionTypeParameter();
				setState(452);
				_errHandler.sync(this);
				_la = _input.LA(1);
				while (_la==27) {
					{
					{
					setState(448); match(27);
					setState(449); functionTypeParameter();
					}
					}
					setState(454);
					_errHandler.sync(this);
					_la = _input.LA(1);
				}
				}
			}

			setState(457); match(87);
			}
		}
		catch (RecognitionException re) {
			_localctx.exception = re;
			_errHandler.reportError(this, re);
			_errHandler.recover(this, re);
		}
		finally {
			exitRule();
		}
		return _localctx;
	}

	public static class FunctionTypeParameterContext extends ParserRuleContext {
		public TypeNameContext typeName() {
			return getRuleContext(TypeNameContext.class,0);
		}
		public StorageLocationContext storageLocation() {
			return getRuleContext(StorageLocationContext.class,0);
		}
		public FunctionTypeParameterContext(ParserRuleContext parent, int invokingState) {
			super(parent, invokingState);
		}
		@Override public int getRuleIndex() { return RULE_functionTypeParameter; }
		@Override
		public void enterRule(ParseTreeListener listener) {
			if ( listener instanceof SolidityListener ) ((SolidityListener)listener).enterFunctionTypeParameter(this);
		}
		@Override
		public void exitRule(ParseTreeListener listener) {
			if ( listener instanceof SolidityListener ) ((SolidityListener)listener).exitFunctionTypeParameter(this);
		}
		@Override
		public <T> T accept(ParseTreeVisitor<? extends T> visitor) {
			if ( visitor instanceof SolidityVisitor ) return ((SolidityVisitor<? extends T>)visitor).visitFunctionTypeParameter(this);
			else return visitor.visitChildren(this);
		}
	}

	public final FunctionTypeParameterContext functionTypeParameter() throws RecognitionException {
		FunctionTypeParameterContext _localctx = new FunctionTypeParameterContext(_ctx, getState());
		enterRule(_localctx, 60, RULE_functionTypeParameter);
		int _la;
		try {
			enterOuterAlt(_localctx, 1);
			{
			setState(459); typeName(0);
			setState(461);
			_la = _input.LA(1);
			if ((((_la) & ~0x3f) == 0 && ((1L << _la) & ((1L << 7) | (1L << 30) | (1L << 37))) != 0)) {
				{
				setState(460); storageLocation();
				}
			}

			}
		}
		catch (RecognitionException re) {
			_localctx.exception = re;
			_errHandler.reportError(this, re);
			_errHandler.recover(this, re);
		}
		finally {
			exitRule();
		}
		return _localctx;
	}

	public static class VariableDeclarationContext extends ParserRuleContext {
		public TypeNameContext typeName() {
			return getRuleContext(TypeNameContext.class,0);
		}
		public IdentifierContext identifier() {
			return getRuleContext(IdentifierContext.class,0);
		}
		public StorageLocationContext storageLocation() {
			return getRuleContext(StorageLocationContext.class,0);
		}
		public VariableDeclarationContext(ParserRuleContext parent, int invokingState) {
			super(parent, invokingState);
		}
		@Override public int getRuleIndex() { return RULE_variableDeclaration; }
		@Override
		public void enterRule(ParseTreeListener listener) {
			if ( listener instanceof SolidityListener ) ((SolidityListener)listener).enterVariableDeclaration(this);
		}
		@Override
		public void exitRule(ParseTreeListener listener) {
			if ( listener instanceof SolidityListener ) ((SolidityListener)listener).exitVariableDeclaration(this);
		}
		@Override
		public <T> T accept(ParseTreeVisitor<? extends T> visitor) {
			if ( visitor instanceof SolidityVisitor ) return ((SolidityVisitor<? extends T>)visitor).visitVariableDeclaration(this);
			else return visitor.visitChildren(this);
		}
	}

	public final VariableDeclarationContext variableDeclaration() throws RecognitionException {
		VariableDeclarationContext _localctx = new VariableDeclarationContext(_ctx, getState());
		enterRule(_localctx, 62, RULE_variableDeclaration);
		try {
			enterOuterAlt(_localctx, 1);
			{
			setState(463); typeName(0);
			setState(465);
			switch ( getInterpreter().adaptivePredict(_input,47,_ctx) ) {
			case 1:
				{
				setState(464); storageLocation();
				}
				break;
			}
			setState(467); identifier();
			}
		}
		catch (RecognitionException re) {
			_localctx.exception = re;
			_errHandler.reportError(this, re);
			_errHandler.recover(this, re);
		}
		finally {
			exitRule();
		}
		return _localctx;
	}

	public static class TypeNameContext extends ParserRuleContext {
		public TypeNameContext typeName() {
			return getRuleContext(TypeNameContext.class,0);
		}
		public UserDefinedTypeNameContext userDefinedTypeName() {
			return getRuleContext(UserDefinedTypeNameContext.class,0);
		}
		public FunctionTypeNameContext functionTypeName() {
			return getRuleContext(FunctionTypeNameContext.class,0);
		}
		public MappingContext mapping() {
			return getRuleContext(MappingContext.class,0);
		}
		public ExpressionContext expression() {
			return getRuleContext(ExpressionContext.class,0);
		}
		public ElementaryTypeNameContext elementaryTypeName() {
			return getRuleContext(ElementaryTypeNameContext.class,0);
		}
		public TypeNameContext(ParserRuleContext parent, int invokingState) {
			super(parent, invokingState);
		}
		@Override public int getRuleIndex() { return RULE_typeName; }
		@Override
		public void enterRule(ParseTreeListener listener) {
			if ( listener instanceof SolidityListener ) ((SolidityListener)listener).enterTypeName(this);
		}
		@Override
		public void exitRule(ParseTreeListener listener) {
			if ( listener instanceof SolidityListener ) ((SolidityListener)listener).exitTypeName(this);
		}
		@Override
		public <T> T accept(ParseTreeVisitor<? extends T> visitor) {
			if ( visitor instanceof SolidityVisitor ) return ((SolidityVisitor<? extends T>)visitor).visitTypeName(this);
			else return visitor.visitChildren(this);
		}
	}

	public final TypeNameContext typeName() throws RecognitionException {
		return typeName(0);
	}

	private TypeNameContext typeName(int _p) throws RecognitionException {
		ParserRuleContext _parentctx = _ctx;
		int _parentState = getState();
		TypeNameContext _localctx = new TypeNameContext(_ctx, _parentState);
		TypeNameContext _prevctx = _localctx;
		int _startState = 64;
		enterRecursionRule(_localctx, 64, RULE_typeName, _p);
		int _la;
		try {
			int _alt;
			enterOuterAlt(_localctx, 1);
			{
			setState(476);
			switch ( getInterpreter().adaptivePredict(_input,48,_ctx) ) {
			case 1:
				{
				setState(470); elementaryTypeName();
				}
				break;

			case 2:
				{
				setState(471); userDefinedTypeName();
				}
				break;

			case 3:
				{
				setState(472); mapping();
				}
				break;

			case 4:
				{
				setState(473); functionTypeName();
				}
				break;

			case 5:
				{
				setState(474); match(78);
				setState(475); match(PayableKeyword);
				}
				break;
			}
			_ctx.stop = _input.LT(-1);
			setState(486);
			_errHandler.sync(this);
			_alt = getInterpreter().adaptivePredict(_input,50,_ctx);
			while ( _alt!=2 && _alt!=ATN.INVALID_ALT_NUMBER ) {
				if ( _alt==1 ) {
					if ( _parseListeners!=null ) triggerExitRuleEvent();
					_prevctx = _localctx;
					{
					{
					_localctx = new TypeNameContext(_parentctx, _parentState);
					pushNewRecursionContext(_localctx, _startState, RULE_typeName);
					setState(478);
					if (!(precpred(_ctx, 3))) throw new FailedPredicateException(this, "precpred(_ctx, 3)");
					setState(479); match(73);
					setState(481);
					_la = _input.LA(1);
					if ((((_la) & ~0x3f) == 0 && ((1L << _la) & ((1L << 6) | (1L << 16) | (1L << 21) | (1L << 25) | (1L << 29) | (1L << 31) | (1L << 33) | (1L << 36) | (1L << 37) | (1L << 41) | (1L << 62))) != 0) || ((((_la - 73)) & ~0x3f) == 0 && ((1L << (_la - 73)) & ((1L << (73 - 73)) | (1L << (77 - 73)) | (1L << (78 - 73)) | (1L << (79 - 73)) | (1L << (81 - 73)) | (1L << (83 - 73)) | (1L << (89 - 73)) | (1L << (Int - 73)) | (1L << (Uint - 73)) | (1L << (Byte - 73)) | (1L << (Fixed - 73)) | (1L << (Ufixed - 73)) | (1L << (BooleanLiteral - 73)) | (1L << (DecimalNumber - 73)) | (1L << (HexNumber - 73)) | (1L << (HexLiteral - 73)) | (1L << (TypeKeyword - 73)) | (1L << (Identifier - 73)) | (1L << (StringLiteral - 73)))) != 0)) {
						{
						setState(480); expression(0);
						}
					}

					setState(483); match(35);
					}
					} 
				}
				setState(488);
				_errHandler.sync(this);
				_alt = getInterpreter().adaptivePredict(_input,50,_ctx);
			}
			}
		}
		catch (RecognitionException re) {
			_localctx.exception = re;
			_errHandler.reportError(this, re);
			_errHandler.recover(this, re);
		}
		finally {
			unrollRecursionContexts(_parentctx);
		}
		return _localctx;
	}

	public static class UserDefinedTypeNameContext extends ParserRuleContext {
		public IdentifierContext identifier(int i) {
			return getRuleContext(IdentifierContext.class,i);
		}
		public List<IdentifierContext> identifier() {
			return getRuleContexts(IdentifierContext.class);
		}
		public UserDefinedTypeNameContext(ParserRuleContext parent, int invokingState) {
			super(parent, invokingState);
		}
		@Override public int getRuleIndex() { return RULE_userDefinedTypeName; }
		@Override
		public void enterRule(ParseTreeListener listener) {
			if ( listener instanceof SolidityListener ) ((SolidityListener)listener).enterUserDefinedTypeName(this);
		}
		@Override
		public void exitRule(ParseTreeListener listener) {
			if ( listener instanceof SolidityListener ) ((SolidityListener)listener).exitUserDefinedTypeName(this);
		}
		@Override
		public <T> T accept(ParseTreeVisitor<? extends T> visitor) {
			if ( visitor instanceof SolidityVisitor ) return ((SolidityVisitor<? extends T>)visitor).visitUserDefinedTypeName(this);
			else return visitor.visitChildren(this);
		}
	}

	public final UserDefinedTypeNameContext userDefinedTypeName() throws RecognitionException {
		UserDefinedTypeNameContext _localctx = new UserDefinedTypeNameContext(_ctx, getState());
		enterRule(_localctx, 66, RULE_userDefinedTypeName);
		try {
			int _alt;
			enterOuterAlt(_localctx, 1);
			{
			setState(489); identifier();
			setState(494);
			_errHandler.sync(this);
			_alt = getInterpreter().adaptivePredict(_input,51,_ctx);
			while ( _alt!=2 && _alt!=ATN.INVALID_ALT_NUMBER ) {
				if ( _alt==1 ) {
					{
					{
					setState(490); match(68);
					setState(491); identifier();
					}
					} 
				}
				setState(496);
				_errHandler.sync(this);
				_alt = getInterpreter().adaptivePredict(_input,51,_ctx);
			}
			}
		}
		catch (RecognitionException re) {
			_localctx.exception = re;
			_errHandler.reportError(this, re);
			_errHandler.recover(this, re);
		}
		finally {
			exitRule();
		}
		return _localctx;
	}

	public static class MappingContext extends ParserRuleContext {
		public TypeNameContext typeName() {
			return getRuleContext(TypeNameContext.class,0);
		}
		public ElementaryTypeNameContext elementaryTypeName() {
			return getRuleContext(ElementaryTypeNameContext.class,0);
		}
		public MappingContext(ParserRuleContext parent, int invokingState) {
			super(parent, invokingState);
		}
		@Override public int getRuleIndex() { return RULE_mapping; }
		@Override
		public void enterRule(ParseTreeListener listener) {
			if ( listener instanceof SolidityListener ) ((SolidityListener)listener).enterMapping(this);
		}
		@Override
		public void exitRule(ParseTreeListener listener) {
			if ( listener instanceof SolidityListener ) ((SolidityListener)listener).exitMapping(this);
		}
		@Override
		public <T> T accept(ParseTreeVisitor<? extends T> visitor) {
			if ( visitor instanceof SolidityVisitor ) return ((SolidityVisitor<? extends T>)visitor).visitMapping(this);
			else return visitor.visitChildren(this);
		}
	}

	public final MappingContext mapping() throws RecognitionException {
		MappingContext _localctx = new MappingContext(_ctx, getState());
		enterRule(_localctx, 68, RULE_mapping);
		try {
			enterOuterAlt(_localctx, 1);
			{
			setState(497); match(42);
			setState(498); match(25);
			setState(499); elementaryTypeName();
			setState(500); match(82);
			setState(501); typeName(0);
			setState(502); match(87);
			}
		}
		catch (RecognitionException re) {
			_localctx.exception = re;
			_errHandler.reportError(this, re);
			_errHandler.recover(this, re);
		}
		finally {
			exitRule();
		}
		return _localctx;
	}

	public static class FunctionTypeNameContext extends ParserRuleContext {
		public TerminalNode ExternalKeyword(int i) {
			return getToken(SolidityParser.ExternalKeyword, i);
		}
		public List<StateMutabilityContext> stateMutability() {
			return getRuleContexts(StateMutabilityContext.class);
		}
		public FunctionTypeParameterListContext functionTypeParameterList(int i) {
			return getRuleContext(FunctionTypeParameterListContext.class,i);
		}
		public StateMutabilityContext stateMutability(int i) {
			return getRuleContext(StateMutabilityContext.class,i);
		}
		public List<FunctionTypeParameterListContext> functionTypeParameterList() {
			return getRuleContexts(FunctionTypeParameterListContext.class);
		}
		public TerminalNode InternalKeyword(int i) {
			return getToken(SolidityParser.InternalKeyword, i);
		}
		public List<TerminalNode> InternalKeyword() { return getTokens(SolidityParser.InternalKeyword); }
		public List<TerminalNode> ExternalKeyword() { return getTokens(SolidityParser.ExternalKeyword); }
		public FunctionTypeNameContext(ParserRuleContext parent, int invokingState) {
			super(parent, invokingState);
		}
		@Override public int getRuleIndex() { return RULE_functionTypeName; }
		@Override
		public void enterRule(ParseTreeListener listener) {
			if ( listener instanceof SolidityListener ) ((SolidityListener)listener).enterFunctionTypeName(this);
		}
		@Override
		public void exitRule(ParseTreeListener listener) {
			if ( listener instanceof SolidityListener ) ((SolidityListener)listener).exitFunctionTypeName(this);
		}
		@Override
		public <T> T accept(ParseTreeVisitor<? extends T> visitor) {
			if ( visitor instanceof SolidityVisitor ) return ((SolidityVisitor<? extends T>)visitor).visitFunctionTypeName(this);
			else return visitor.visitChildren(this);
		}
	}

	public final FunctionTypeNameContext functionTypeName() throws RecognitionException {
		FunctionTypeNameContext _localctx = new FunctionTypeNameContext(_ctx, getState());
		enterRule(_localctx, 70, RULE_functionTypeName);
		try {
			int _alt;
			enterOuterAlt(_localctx, 1);
			{
			setState(504); match(40);
			setState(505); functionTypeParameterList();
			setState(511);
			_errHandler.sync(this);
			_alt = getInterpreter().adaptivePredict(_input,53,_ctx);
			while ( _alt!=2 && _alt!=ATN.INVALID_ALT_NUMBER ) {
				if ( _alt==1 ) {
					{
					setState(509);
					switch (_input.LA(1)) {
					case InternalKeyword:
						{
						setState(506); match(InternalKeyword);
						}
						break;
					case ExternalKeyword:
						{
						setState(507); match(ExternalKeyword);
						}
						break;
					case ConstantKeyword:
					case PayableKeyword:
					case PureKeyword:
					case ViewKeyword:
						{
						setState(508); stateMutability();
						}
						break;
					default:
						throw new NoViableAltException(this);
					}
					} 
				}
				setState(513);
				_errHandler.sync(this);
				_alt = getInterpreter().adaptivePredict(_input,53,_ctx);
			}
			setState(516);
			switch ( getInterpreter().adaptivePredict(_input,54,_ctx) ) {
			case 1:
				{
				setState(514); match(39);
				setState(515); functionTypeParameterList();
				}
				break;
			}
			}
		}
		catch (RecognitionException re) {
			_localctx.exception = re;
			_errHandler.reportError(this, re);
			_errHandler.recover(this, re);
		}
		finally {
			exitRule();
		}
		return _localctx;
	}

	public static class StorageLocationContext extends ParserRuleContext {
		public StorageLocationContext(ParserRuleContext parent, int invokingState) {
			super(parent, invokingState);
		}
		@Override public int getRuleIndex() { return RULE_storageLocation; }
		@Override
		public void enterRule(ParseTreeListener listener) {
			if ( listener instanceof SolidityListener ) ((SolidityListener)listener).enterStorageLocation(this);
		}
		@Override
		public void exitRule(ParseTreeListener listener) {
			if ( listener instanceof SolidityListener ) ((SolidityListener)listener).exitStorageLocation(this);
		}
		@Override
		public <T> T accept(ParseTreeVisitor<? extends T> visitor) {
			if ( visitor instanceof SolidityVisitor ) return ((SolidityVisitor<? extends T>)visitor).visitStorageLocation(this);
			else return visitor.visitChildren(this);
		}
	}

	public final StorageLocationContext storageLocation() throws RecognitionException {
		StorageLocationContext _localctx = new StorageLocationContext(_ctx, getState());
		enterRule(_localctx, 72, RULE_storageLocation);
		int _la;
		try {
			enterOuterAlt(_localctx, 1);
			{
			setState(518);
			_la = _input.LA(1);
			if ( !((((_la) & ~0x3f) == 0 && ((1L << _la) & ((1L << 7) | (1L << 30) | (1L << 37))) != 0)) ) {
			_errHandler.recoverInline(this);
			}
			consume();
			}
		}
		catch (RecognitionException re) {
			_localctx.exception = re;
			_errHandler.reportError(this, re);
			_errHandler.recover(this, re);
		}
		finally {
			exitRule();
		}
		return _localctx;
	}

	public static class StateMutabilityContext extends ParserRuleContext {
		public TerminalNode PayableKeyword() { return getToken(SolidityParser.PayableKeyword, 0); }
		public TerminalNode PureKeyword() { return getToken(SolidityParser.PureKeyword, 0); }
		public TerminalNode ViewKeyword() { return getToken(SolidityParser.ViewKeyword, 0); }
		public TerminalNode ConstantKeyword() { return getToken(SolidityParser.ConstantKeyword, 0); }
		public StateMutabilityContext(ParserRuleContext parent, int invokingState) {
			super(parent, invokingState);
		}
		@Override public int getRuleIndex() { return RULE_stateMutability; }
		@Override
		public void enterRule(ParseTreeListener listener) {
			if ( listener instanceof SolidityListener ) ((SolidityListener)listener).enterStateMutability(this);
		}
		@Override
		public void exitRule(ParseTreeListener listener) {
			if ( listener instanceof SolidityListener ) ((SolidityListener)listener).exitStateMutability(this);
		}
		@Override
		public <T> T accept(ParseTreeVisitor<? extends T> visitor) {
			if ( visitor instanceof SolidityVisitor ) return ((SolidityVisitor<? extends T>)visitor).visitStateMutability(this);
			else return visitor.visitChildren(this);
		}
	}

	public final StateMutabilityContext stateMutability() throws RecognitionException {
		StateMutabilityContext _localctx = new StateMutabilityContext(_ctx, getState());
		enterRule(_localctx, 74, RULE_stateMutability);
		int _la;
		try {
			enterOuterAlt(_localctx, 1);
			{
			setState(520);
			_la = _input.LA(1);
			if ( !(((((_la - 107)) & ~0x3f) == 0 && ((1L << (_la - 107)) & ((1L << (ConstantKeyword - 107)) | (1L << (PayableKeyword - 107)) | (1L << (PureKeyword - 107)) | (1L << (ViewKeyword - 107)))) != 0)) ) {
			_errHandler.recoverInline(this);
			}
			consume();
			}
		}
		catch (RecognitionException re) {
			_localctx.exception = re;
			_errHandler.reportError(this, re);
			_errHandler.recover(this, re);
		}
		finally {
			exitRule();
		}
		return _localctx;
	}

	public static class BlockContext extends ParserRuleContext {
		public StatementContext statement(int i) {
			return getRuleContext(StatementContext.class,i);
		}
		public List<StatementContext> statement() {
			return getRuleContexts(StatementContext.class);
		}
		public BlockContext(ParserRuleContext parent, int invokingState) {
			super(parent, invokingState);
		}
		@Override public int getRuleIndex() { return RULE_block; }
		@Override
		public void enterRule(ParseTreeListener listener) {
			if ( listener instanceof SolidityListener ) ((SolidityListener)listener).enterBlock(this);
		}
		@Override
		public void exitRule(ParseTreeListener listener) {
			if ( listener instanceof SolidityListener ) ((SolidityListener)listener).exitBlock(this);
		}
		@Override
		public <T> T accept(ParseTreeVisitor<? extends T> visitor) {
			if ( visitor instanceof SolidityVisitor ) return ((SolidityVisitor<? extends T>)visitor).visitBlock(this);
			else return visitor.visitChildren(this);
		}
	}

	public final BlockContext block() throws RecognitionException {
		BlockContext _localctx = new BlockContext(_ctx, getState());
		enterRule(_localctx, 76, RULE_block);
		int _la;
		try {
			enterOuterAlt(_localctx, 1);
			{
			setState(522); match(10);
			setState(526);
			_errHandler.sync(this);
			_la = _input.LA(1);
			while ((((_la) & ~0x3f) == 0 && ((1L << _la) & ((1L << 6) | (1L << 9) | (1L << 10) | (1L << 16) | (1L << 19) | (1L << 21) | (1L << 24) | (1L << 25) | (1L << 29) | (1L << 31) | (1L << 33) | (1L << 36) | (1L << 37) | (1L << 40) | (1L << 41) | (1L << 42) | (1L << 48) | (1L << 56) | (1L << 62))) != 0) || ((((_la - 67)) & ~0x3f) == 0 && ((1L << (_la - 67)) & ((1L << (67 - 67)) | (1L << (71 - 67)) | (1L << (73 - 67)) | (1L << (77 - 67)) | (1L << (78 - 67)) | (1L << (79 - 67)) | (1L << (81 - 67)) | (1L << (83 - 67)) | (1L << (88 - 67)) | (1L << (89 - 67)) | (1L << (Int - 67)) | (1L << (Uint - 67)) | (1L << (Byte - 67)) | (1L << (Fixed - 67)) | (1L << (Ufixed - 67)) | (1L << (BooleanLiteral - 67)) | (1L << (DecimalNumber - 67)) | (1L << (HexNumber - 67)) | (1L << (HexLiteral - 67)) | (1L << (BreakKeyword - 67)) | (1L << (ContinueKeyword - 67)) | (1L << (TypeKeyword - 67)) | (1L << (Identifier - 67)) | (1L << (StringLiteral - 67)))) != 0)) {
				{
				{
				setState(523); statement();
				}
				}
				setState(528);
				_errHandler.sync(this);
				_la = _input.LA(1);
			}
			setState(529); match(55);
			}
		}
		catch (RecognitionException re) {
			_localctx.exception = re;
			_errHandler.reportError(this, re);
			_errHandler.recover(this, re);
		}
		finally {
			exitRule();
		}
		return _localctx;
	}

	public static class StatementContext extends ParserRuleContext {
		public DoWhileStatementContext doWhileStatement() {
			return getRuleContext(DoWhileStatementContext.class,0);
		}
		public IfStatementContext ifStatement() {
			return getRuleContext(IfStatementContext.class,0);
		}
		public InlineAssemblyStatementContext inlineAssemblyStatement() {
			return getRuleContext(InlineAssemblyStatementContext.class,0);
		}
		public ThrowStatementContext throwStatement() {
			return getRuleContext(ThrowStatementContext.class,0);
		}
		public WhileStatementContext whileStatement() {
			return getRuleContext(WhileStatementContext.class,0);
		}
		public ForStatementContext forStatement() {
			return getRuleContext(ForStatementContext.class,0);
		}
		public EmitStatementContext emitStatement() {
			return getRuleContext(EmitStatementContext.class,0);
		}
		public ContinueStatementContext continueStatement() {
			return getRuleContext(ContinueStatementContext.class,0);
		}
		public BlockContext block() {
			return getRuleContext(BlockContext.class,0);
		}
		public ReturnStatementContext returnStatement() {
			return getRuleContext(ReturnStatementContext.class,0);
		}
		public BreakStatementContext breakStatement() {
			return getRuleContext(BreakStatementContext.class,0);
		}
		public SimpleStatementContext simpleStatement() {
			return getRuleContext(SimpleStatementContext.class,0);
		}
		public StatementContext(ParserRuleContext parent, int invokingState) {
			super(parent, invokingState);
		}
		@Override public int getRuleIndex() { return RULE_statement; }
		@Override
		public void enterRule(ParseTreeListener listener) {
			if ( listener instanceof SolidityListener ) ((SolidityListener)listener).enterStatement(this);
		}
		@Override
		public void exitRule(ParseTreeListener listener) {
			if ( listener instanceof SolidityListener ) ((SolidityListener)listener).exitStatement(this);
		}
		@Override
		public <T> T accept(ParseTreeVisitor<? extends T> visitor) {
			if ( visitor instanceof SolidityVisitor ) return ((SolidityVisitor<? extends T>)visitor).visitStatement(this);
			else return visitor.visitChildren(this);
		}
	}

	public final StatementContext statement() throws RecognitionException {
		StatementContext _localctx = new StatementContext(_ctx, getState());
		enterRule(_localctx, 78, RULE_statement);
		try {
			setState(543);
			switch (_input.LA(1)) {
			case 56:
				enterOuterAlt(_localctx, 1);
				{
				setState(531); ifStatement();
				}
				break;
			case 9:
				enterOuterAlt(_localctx, 2);
				{
				setState(532); whileStatement();
				}
				break;
			case 19:
				enterOuterAlt(_localctx, 3);
				{
				setState(533); forStatement();
				}
				break;
			case 10:
				enterOuterAlt(_localctx, 4);
				{
				setState(534); block();
				}
				break;
			case 88:
				enterOuterAlt(_localctx, 5);
				{
				setState(535); inlineAssemblyStatement();
				}
				break;
			case 24:
				enterOuterAlt(_localctx, 6);
				{
				setState(536); doWhileStatement();
				}
				break;
			case ContinueKeyword:
				enterOuterAlt(_localctx, 7);
				{
				setState(537); continueStatement();
				}
				break;
			case BreakKeyword:
				enterOuterAlt(_localctx, 8);
				{
				setState(538); breakStatement();
				}
				break;
			case 48:
				enterOuterAlt(_localctx, 9);
				{
				setState(539); returnStatement();
				}
				break;
			case 71:
				enterOuterAlt(_localctx, 10);
				{
				setState(540); throwStatement();
				}
				break;
			case 67:
				enterOuterAlt(_localctx, 11);
				{
				setState(541); emitStatement();
				}
				break;
			case 6:
			case 16:
			case 21:
			case 25:
			case 29:
			case 31:
			case 33:
			case 36:
			case 37:
			case 40:
			case 41:
			case 42:
			case 62:
			case 73:
			case 77:
			case 78:
			case 79:
			case 81:
			case 83:
			case 89:
			case Int:
			case Uint:
			case Byte:
			case Fixed:
			case Ufixed:
			case BooleanLiteral:
			case DecimalNumber:
			case HexNumber:
			case HexLiteral:
			case TypeKeyword:
			case Identifier:
			case StringLiteral:
				enterOuterAlt(_localctx, 12);
				{
				setState(542); simpleStatement();
				}
				break;
			default:
				throw new NoViableAltException(this);
			}
		}
		catch (RecognitionException re) {
			_localctx.exception = re;
			_errHandler.reportError(this, re);
			_errHandler.recover(this, re);
		}
		finally {
			exitRule();
		}
		return _localctx;
	}

	public static class ExpressionStatementContext extends ParserRuleContext {
		public ExpressionContext expression() {
			return getRuleContext(ExpressionContext.class,0);
		}
		public ExpressionStatementContext(ParserRuleContext parent, int invokingState) {
			super(parent, invokingState);
		}
		@Override public int getRuleIndex() { return RULE_expressionStatement; }
		@Override
		public void enterRule(ParseTreeListener listener) {
			if ( listener instanceof SolidityListener ) ((SolidityListener)listener).enterExpressionStatement(this);
		}
		@Override
		public void exitRule(ParseTreeListener listener) {
			if ( listener instanceof SolidityListener ) ((SolidityListener)listener).exitExpressionStatement(this);
		}
		@Override
		public <T> T accept(ParseTreeVisitor<? extends T> visitor) {
			if ( visitor instanceof SolidityVisitor ) return ((SolidityVisitor<? extends T>)visitor).visitExpressionStatement(this);
			else return visitor.visitChildren(this);
		}
	}

	public final ExpressionStatementContext expressionStatement() throws RecognitionException {
		ExpressionStatementContext _localctx = new ExpressionStatementContext(_ctx, getState());
		enterRule(_localctx, 80, RULE_expressionStatement);
		try {
			enterOuterAlt(_localctx, 1);
			{
			setState(545); expression(0);
			setState(546); match(52);
			}
		}
		catch (RecognitionException re) {
			_localctx.exception = re;
			_errHandler.reportError(this, re);
			_errHandler.recover(this, re);
		}
		finally {
			exitRule();
		}
		return _localctx;
	}

	public static class IfStatementContext extends ParserRuleContext {
		public StatementContext statement(int i) {
			return getRuleContext(StatementContext.class,i);
		}
		public List<StatementContext> statement() {
			return getRuleContexts(StatementContext.class);
		}
		public ExpressionContext expression() {
			return getRuleContext(ExpressionContext.class,0);
		}
		public IfStatementContext(ParserRuleContext parent, int invokingState) {
			super(parent, invokingState);
		}
		@Override public int getRuleIndex() { return RULE_ifStatement; }
		@Override
		public void enterRule(ParseTreeListener listener) {
			if ( listener instanceof SolidityListener ) ((SolidityListener)listener).enterIfStatement(this);
		}
		@Override
		public void exitRule(ParseTreeListener listener) {
			if ( listener instanceof SolidityListener ) ((SolidityListener)listener).exitIfStatement(this);
		}
		@Override
		public <T> T accept(ParseTreeVisitor<? extends T> visitor) {
			if ( visitor instanceof SolidityVisitor ) return ((SolidityVisitor<? extends T>)visitor).visitIfStatement(this);
			else return visitor.visitChildren(this);
		}
	}

	public final IfStatementContext ifStatement() throws RecognitionException {
		IfStatementContext _localctx = new IfStatementContext(_ctx, getState());
		enterRule(_localctx, 82, RULE_ifStatement);
		try {
			enterOuterAlt(_localctx, 1);
			{
			setState(548); match(56);
			setState(549); match(25);
			setState(550); expression(0);
			setState(551); match(87);
			setState(552); statement();
			setState(555);
			switch ( getInterpreter().adaptivePredict(_input,57,_ctx) ) {
			case 1:
				{
				setState(553); match(86);
				setState(554); statement();
				}
				break;
			}
			}
		}
		catch (RecognitionException re) {
			_localctx.exception = re;
			_errHandler.reportError(this, re);
			_errHandler.recover(this, re);
		}
		finally {
			exitRule();
		}
		return _localctx;
	}

	public static class WhileStatementContext extends ParserRuleContext {
		public StatementContext statement() {
			return getRuleContext(StatementContext.class,0);
		}
		public ExpressionContext expression() {
			return getRuleContext(ExpressionContext.class,0);
		}
		public WhileStatementContext(ParserRuleContext parent, int invokingState) {
			super(parent, invokingState);
		}
		@Override public int getRuleIndex() { return RULE_whileStatement; }
		@Override
		public void enterRule(ParseTreeListener listener) {
			if ( listener instanceof SolidityListener ) ((SolidityListener)listener).enterWhileStatement(this);
		}
		@Override
		public void exitRule(ParseTreeListener listener) {
			if ( listener instanceof SolidityListener ) ((SolidityListener)listener).exitWhileStatement(this);
		}
		@Override
		public <T> T accept(ParseTreeVisitor<? extends T> visitor) {
			if ( visitor instanceof SolidityVisitor ) return ((SolidityVisitor<? extends T>)visitor).visitWhileStatement(this);
			else return visitor.visitChildren(this);
		}
	}

	public final WhileStatementContext whileStatement() throws RecognitionException {
		WhileStatementContext _localctx = new WhileStatementContext(_ctx, getState());
		enterRule(_localctx, 84, RULE_whileStatement);
		try {
			enterOuterAlt(_localctx, 1);
			{
			setState(557); match(9);
			setState(558); match(25);
			setState(559); expression(0);
			setState(560); match(87);
			setState(561); statement();
			}
		}
		catch (RecognitionException re) {
			_localctx.exception = re;
			_errHandler.reportError(this, re);
			_errHandler.recover(this, re);
		}
		finally {
			exitRule();
		}
		return _localctx;
	}

	public static class SimpleStatementContext extends ParserRuleContext {
		public ExpressionStatementContext expressionStatement() {
			return getRuleContext(ExpressionStatementContext.class,0);
		}
		public VariableDeclarationStatementContext variableDeclarationStatement() {
			return getRuleContext(VariableDeclarationStatementContext.class,0);
		}
		public SimpleStatementContext(ParserRuleContext parent, int invokingState) {
			super(parent, invokingState);
		}
		@Override public int getRuleIndex() { return RULE_simpleStatement; }
		@Override
		public void enterRule(ParseTreeListener listener) {
			if ( listener instanceof SolidityListener ) ((SolidityListener)listener).enterSimpleStatement(this);
		}
		@Override
		public void exitRule(ParseTreeListener listener) {
			if ( listener instanceof SolidityListener ) ((SolidityListener)listener).exitSimpleStatement(this);
		}
		@Override
		public <T> T accept(ParseTreeVisitor<? extends T> visitor) {
			if ( visitor instanceof SolidityVisitor ) return ((SolidityVisitor<? extends T>)visitor).visitSimpleStatement(this);
			else return visitor.visitChildren(this);
		}
	}

	public final SimpleStatementContext simpleStatement() throws RecognitionException {
		SimpleStatementContext _localctx = new SimpleStatementContext(_ctx, getState());
		enterRule(_localctx, 86, RULE_simpleStatement);
		try {
			enterOuterAlt(_localctx, 1);
			{
			setState(565);
			switch ( getInterpreter().adaptivePredict(_input,58,_ctx) ) {
			case 1:
				{
				setState(563); variableDeclarationStatement();
				}
				break;

			case 2:
				{
				setState(564); expressionStatement();
				}
				break;
			}
			}
		}
		catch (RecognitionException re) {
			_localctx.exception = re;
			_errHandler.reportError(this, re);
			_errHandler.recover(this, re);
		}
		finally {
			exitRule();
		}
		return _localctx;
	}

	public static class ForStatementContext extends ParserRuleContext {
		public ExpressionStatementContext expressionStatement() {
			return getRuleContext(ExpressionStatementContext.class,0);
		}
		public StatementContext statement() {
			return getRuleContext(StatementContext.class,0);
		}
		public ExpressionContext expression() {
			return getRuleContext(ExpressionContext.class,0);
		}
		public SimpleStatementContext simpleStatement() {
			return getRuleContext(SimpleStatementContext.class,0);
		}
		public ForStatementContext(ParserRuleContext parent, int invokingState) {
			super(parent, invokingState);
		}
		@Override public int getRuleIndex() { return RULE_forStatement; }
		@Override
		public void enterRule(ParseTreeListener listener) {
			if ( listener instanceof SolidityListener ) ((SolidityListener)listener).enterForStatement(this);
		}
		@Override
		public void exitRule(ParseTreeListener listener) {
			if ( listener instanceof SolidityListener ) ((SolidityListener)listener).exitForStatement(this);
		}
		@Override
		public <T> T accept(ParseTreeVisitor<? extends T> visitor) {
			if ( visitor instanceof SolidityVisitor ) return ((SolidityVisitor<? extends T>)visitor).visitForStatement(this);
			else return visitor.visitChildren(this);
		}
	}

	public final ForStatementContext forStatement() throws RecognitionException {
		ForStatementContext _localctx = new ForStatementContext(_ctx, getState());
		enterRule(_localctx, 88, RULE_forStatement);
		int _la;
		try {
			enterOuterAlt(_localctx, 1);
			{
			setState(567); match(19);
			setState(568); match(25);
			setState(571);
			switch (_input.LA(1)) {
			case 6:
			case 16:
			case 21:
			case 25:
			case 29:
			case 31:
			case 33:
			case 36:
			case 37:
			case 40:
			case 41:
			case 42:
			case 62:
			case 73:
			case 77:
			case 78:
			case 79:
			case 81:
			case 83:
			case 89:
			case Int:
			case Uint:
			case Byte:
			case Fixed:
			case Ufixed:
			case BooleanLiteral:
			case DecimalNumber:
			case HexNumber:
			case HexLiteral:
			case TypeKeyword:
			case Identifier:
			case StringLiteral:
				{
				setState(569); simpleStatement();
				}
				break;
			case 52:
				{
				setState(570); match(52);
				}
				break;
			default:
				throw new NoViableAltException(this);
			}
			setState(575);
			switch (_input.LA(1)) {
			case 6:
			case 16:
			case 21:
			case 25:
			case 29:
			case 31:
			case 33:
			case 36:
			case 37:
			case 41:
			case 62:
			case 73:
			case 77:
			case 78:
			case 79:
			case 81:
			case 83:
			case 89:
			case Int:
			case Uint:
			case Byte:
			case Fixed:
			case Ufixed:
			case BooleanLiteral:
			case DecimalNumber:
			case HexNumber:
			case HexLiteral:
			case TypeKeyword:
			case Identifier:
			case StringLiteral:
				{
				setState(573); expressionStatement();
				}
				break;
			case 52:
				{
				setState(574); match(52);
				}
				break;
			default:
				throw new NoViableAltException(this);
			}
			setState(578);
			_la = _input.LA(1);
			if ((((_la) & ~0x3f) == 0 && ((1L << _la) & ((1L << 6) | (1L << 16) | (1L << 21) | (1L << 25) | (1L << 29) | (1L << 31) | (1L << 33) | (1L << 36) | (1L << 37) | (1L << 41) | (1L << 62))) != 0) || ((((_la - 73)) & ~0x3f) == 0 && ((1L << (_la - 73)) & ((1L << (73 - 73)) | (1L << (77 - 73)) | (1L << (78 - 73)) | (1L << (79 - 73)) | (1L << (81 - 73)) | (1L << (83 - 73)) | (1L << (89 - 73)) | (1L << (Int - 73)) | (1L << (Uint - 73)) | (1L << (Byte - 73)) | (1L << (Fixed - 73)) | (1L << (Ufixed - 73)) | (1L << (BooleanLiteral - 73)) | (1L << (DecimalNumber - 73)) | (1L << (HexNumber - 73)) | (1L << (HexLiteral - 73)) | (1L << (TypeKeyword - 73)) | (1L << (Identifier - 73)) | (1L << (StringLiteral - 73)))) != 0)) {
				{
				setState(577); expression(0);
				}
			}

			setState(580); match(87);
			setState(581); statement();
			}
		}
		catch (RecognitionException re) {
			_localctx.exception = re;
			_errHandler.reportError(this, re);
			_errHandler.recover(this, re);
		}
		finally {
			exitRule();
		}
		return _localctx;
	}

	public static class InlineAssemblyStatementContext extends ParserRuleContext {
		public TerminalNode StringLiteral() { return getToken(SolidityParser.StringLiteral, 0); }
		public AssemblyBlockContext assemblyBlock() {
			return getRuleContext(AssemblyBlockContext.class,0);
		}
		public InlineAssemblyStatementContext(ParserRuleContext parent, int invokingState) {
			super(parent, invokingState);
		}
		@Override public int getRuleIndex() { return RULE_inlineAssemblyStatement; }
		@Override
		public void enterRule(ParseTreeListener listener) {
			if ( listener instanceof SolidityListener ) ((SolidityListener)listener).enterInlineAssemblyStatement(this);
		}
		@Override
		public void exitRule(ParseTreeListener listener) {
			if ( listener instanceof SolidityListener ) ((SolidityListener)listener).exitInlineAssemblyStatement(this);
		}
		@Override
		public <T> T accept(ParseTreeVisitor<? extends T> visitor) {
			if ( visitor instanceof SolidityVisitor ) return ((SolidityVisitor<? extends T>)visitor).visitInlineAssemblyStatement(this);
			else return visitor.visitChildren(this);
		}
	}

	public final InlineAssemblyStatementContext inlineAssemblyStatement() throws RecognitionException {
		InlineAssemblyStatementContext _localctx = new InlineAssemblyStatementContext(_ctx, getState());
		enterRule(_localctx, 90, RULE_inlineAssemblyStatement);
		int _la;
		try {
			enterOuterAlt(_localctx, 1);
			{
			setState(583); match(88);
			setState(585);
			_la = _input.LA(1);
			if (_la==StringLiteral) {
				{
				setState(584); match(StringLiteral);
				}
			}

			setState(587); assemblyBlock();
			}
		}
		catch (RecognitionException re) {
			_localctx.exception = re;
			_errHandler.reportError(this, re);
			_errHandler.recover(this, re);
		}
		finally {
			exitRule();
		}
		return _localctx;
	}

	public static class DoWhileStatementContext extends ParserRuleContext {
		public StatementContext statement() {
			return getRuleContext(StatementContext.class,0);
		}
		public ExpressionContext expression() {
			return getRuleContext(ExpressionContext.class,0);
		}
		public DoWhileStatementContext(ParserRuleContext parent, int invokingState) {
			super(parent, invokingState);
		}
		@Override public int getRuleIndex() { return RULE_doWhileStatement; }
		@Override
		public void enterRule(ParseTreeListener listener) {
			if ( listener instanceof SolidityListener ) ((SolidityListener)listener).enterDoWhileStatement(this);
		}
		@Override
		public void exitRule(ParseTreeListener listener) {
			if ( listener instanceof SolidityListener ) ((SolidityListener)listener).exitDoWhileStatement(this);
		}
		@Override
		public <T> T accept(ParseTreeVisitor<? extends T> visitor) {
			if ( visitor instanceof SolidityVisitor ) return ((SolidityVisitor<? extends T>)visitor).visitDoWhileStatement(this);
			else return visitor.visitChildren(this);
		}
	}

	public final DoWhileStatementContext doWhileStatement() throws RecognitionException {
		DoWhileStatementContext _localctx = new DoWhileStatementContext(_ctx, getState());
		enterRule(_localctx, 92, RULE_doWhileStatement);
		try {
			enterOuterAlt(_localctx, 1);
			{
			setState(589); match(24);
			setState(590); statement();
			setState(591); match(9);
			setState(592); match(25);
			setState(593); expression(0);
			setState(594); match(87);
			setState(595); match(52);
			}
		}
		catch (RecognitionException re) {
			_localctx.exception = re;
			_errHandler.reportError(this, re);
			_errHandler.recover(this, re);
		}
		finally {
			exitRule();
		}
		return _localctx;
	}

	public static class ContinueStatementContext extends ParserRuleContext {
		public ContinueStatementContext(ParserRuleContext parent, int invokingState) {
			super(parent, invokingState);
		}
		@Override public int getRuleIndex() { return RULE_continueStatement; }
		@Override
		public void enterRule(ParseTreeListener listener) {
			if ( listener instanceof SolidityListener ) ((SolidityListener)listener).enterContinueStatement(this);
		}
		@Override
		public void exitRule(ParseTreeListener listener) {
			if ( listener instanceof SolidityListener ) ((SolidityListener)listener).exitContinueStatement(this);
		}
		@Override
		public <T> T accept(ParseTreeVisitor<? extends T> visitor) {
			if ( visitor instanceof SolidityVisitor ) return ((SolidityVisitor<? extends T>)visitor).visitContinueStatement(this);
			else return visitor.visitChildren(this);
		}
	}

	public final ContinueStatementContext continueStatement() throws RecognitionException {
		ContinueStatementContext _localctx = new ContinueStatementContext(_ctx, getState());
		enterRule(_localctx, 94, RULE_continueStatement);
		try {
			enterOuterAlt(_localctx, 1);
			{
			setState(597); match(ContinueKeyword);
			setState(598); match(52);
			}
		}
		catch (RecognitionException re) {
			_localctx.exception = re;
			_errHandler.reportError(this, re);
			_errHandler.recover(this, re);
		}
		finally {
			exitRule();
		}
		return _localctx;
	}

	public static class BreakStatementContext extends ParserRuleContext {
		public BreakStatementContext(ParserRuleContext parent, int invokingState) {
			super(parent, invokingState);
		}
		@Override public int getRuleIndex() { return RULE_breakStatement; }
		@Override
		public void enterRule(ParseTreeListener listener) {
			if ( listener instanceof SolidityListener ) ((SolidityListener)listener).enterBreakStatement(this);
		}
		@Override
		public void exitRule(ParseTreeListener listener) {
			if ( listener instanceof SolidityListener ) ((SolidityListener)listener).exitBreakStatement(this);
		}
		@Override
		public <T> T accept(ParseTreeVisitor<? extends T> visitor) {
			if ( visitor instanceof SolidityVisitor ) return ((SolidityVisitor<? extends T>)visitor).visitBreakStatement(this);
			else return visitor.visitChildren(this);
		}
	}

	public final BreakStatementContext breakStatement() throws RecognitionException {
		BreakStatementContext _localctx = new BreakStatementContext(_ctx, getState());
		enterRule(_localctx, 96, RULE_breakStatement);
		try {
			enterOuterAlt(_localctx, 1);
			{
			setState(600); match(BreakKeyword);
			setState(601); match(52);
			}
		}
		catch (RecognitionException re) {
			_localctx.exception = re;
			_errHandler.reportError(this, re);
			_errHandler.recover(this, re);
		}
		finally {
			exitRule();
		}
		return _localctx;
	}

	public static class ReturnStatementContext extends ParserRuleContext {
		public ExpressionContext expression() {
			return getRuleContext(ExpressionContext.class,0);
		}
		public ReturnStatementContext(ParserRuleContext parent, int invokingState) {
			super(parent, invokingState);
		}
		@Override public int getRuleIndex() { return RULE_returnStatement; }
		@Override
		public void enterRule(ParseTreeListener listener) {
			if ( listener instanceof SolidityListener ) ((SolidityListener)listener).enterReturnStatement(this);
		}
		@Override
		public void exitRule(ParseTreeListener listener) {
			if ( listener instanceof SolidityListener ) ((SolidityListener)listener).exitReturnStatement(this);
		}
		@Override
		public <T> T accept(ParseTreeVisitor<? extends T> visitor) {
			if ( visitor instanceof SolidityVisitor ) return ((SolidityVisitor<? extends T>)visitor).visitReturnStatement(this);
			else return visitor.visitChildren(this);
		}
	}

	public final ReturnStatementContext returnStatement() throws RecognitionException {
		ReturnStatementContext _localctx = new ReturnStatementContext(_ctx, getState());
		enterRule(_localctx, 98, RULE_returnStatement);
		int _la;
		try {
			enterOuterAlt(_localctx, 1);
			{
			setState(603); match(48);
			setState(605);
			_la = _input.LA(1);
			if ((((_la) & ~0x3f) == 0 && ((1L << _la) & ((1L << 6) | (1L << 16) | (1L << 21) | (1L << 25) | (1L << 29) | (1L << 31) | (1L << 33) | (1L << 36) | (1L << 37) | (1L << 41) | (1L << 62))) != 0) || ((((_la - 73)) & ~0x3f) == 0 && ((1L << (_la - 73)) & ((1L << (73 - 73)) | (1L << (77 - 73)) | (1L << (78 - 73)) | (1L << (79 - 73)) | (1L << (81 - 73)) | (1L << (83 - 73)) | (1L << (89 - 73)) | (1L << (Int - 73)) | (1L << (Uint - 73)) | (1L << (Byte - 73)) | (1L << (Fixed - 73)) | (1L << (Ufixed - 73)) | (1L << (BooleanLiteral - 73)) | (1L << (DecimalNumber - 73)) | (1L << (HexNumber - 73)) | (1L << (HexLiteral - 73)) | (1L << (TypeKeyword - 73)) | (1L << (Identifier - 73)) | (1L << (StringLiteral - 73)))) != 0)) {
				{
				setState(604); expression(0);
				}
			}

			setState(607); match(52);
			}
		}
		catch (RecognitionException re) {
			_localctx.exception = re;
			_errHandler.reportError(this, re);
			_errHandler.recover(this, re);
		}
		finally {
			exitRule();
		}
		return _localctx;
	}

	public static class ThrowStatementContext extends ParserRuleContext {
		public ThrowStatementContext(ParserRuleContext parent, int invokingState) {
			super(parent, invokingState);
		}
		@Override public int getRuleIndex() { return RULE_throwStatement; }
		@Override
		public void enterRule(ParseTreeListener listener) {
			if ( listener instanceof SolidityListener ) ((SolidityListener)listener).enterThrowStatement(this);
		}
		@Override
		public void exitRule(ParseTreeListener listener) {
			if ( listener instanceof SolidityListener ) ((SolidityListener)listener).exitThrowStatement(this);
		}
		@Override
		public <T> T accept(ParseTreeVisitor<? extends T> visitor) {
			if ( visitor instanceof SolidityVisitor ) return ((SolidityVisitor<? extends T>)visitor).visitThrowStatement(this);
			else return visitor.visitChildren(this);
		}
	}

	public final ThrowStatementContext throwStatement() throws RecognitionException {
		ThrowStatementContext _localctx = new ThrowStatementContext(_ctx, getState());
		enterRule(_localctx, 100, RULE_throwStatement);
		try {
			enterOuterAlt(_localctx, 1);
			{
			setState(609); match(71);
			setState(610); match(52);
			}
		}
		catch (RecognitionException re) {
			_localctx.exception = re;
			_errHandler.reportError(this, re);
			_errHandler.recover(this, re);
		}
		finally {
			exitRule();
		}
		return _localctx;
	}

	public static class EmitStatementContext extends ParserRuleContext {
		public FunctionCallContext functionCall() {
			return getRuleContext(FunctionCallContext.class,0);
		}
		public EmitStatementContext(ParserRuleContext parent, int invokingState) {
			super(parent, invokingState);
		}
		@Override public int getRuleIndex() { return RULE_emitStatement; }
		@Override
		public void enterRule(ParseTreeListener listener) {
			if ( listener instanceof SolidityListener ) ((SolidityListener)listener).enterEmitStatement(this);
		}
		@Override
		public void exitRule(ParseTreeListener listener) {
			if ( listener instanceof SolidityListener ) ((SolidityListener)listener).exitEmitStatement(this);
		}
		@Override
		public <T> T accept(ParseTreeVisitor<? extends T> visitor) {
			if ( visitor instanceof SolidityVisitor ) return ((SolidityVisitor<? extends T>)visitor).visitEmitStatement(this);
			else return visitor.visitChildren(this);
		}
	}

	public final EmitStatementContext emitStatement() throws RecognitionException {
		EmitStatementContext _localctx = new EmitStatementContext(_ctx, getState());
		enterRule(_localctx, 102, RULE_emitStatement);
		try {
			enterOuterAlt(_localctx, 1);
			{
			setState(612); match(67);
			setState(613); functionCall();
			setState(614); match(52);
			}
		}
		catch (RecognitionException re) {
			_localctx.exception = re;
			_errHandler.reportError(this, re);
			_errHandler.recover(this, re);
		}
		finally {
			exitRule();
		}
		return _localctx;
	}

	public static class VariableDeclarationStatementContext extends ParserRuleContext {
		public VariableDeclarationContext variableDeclaration() {
			return getRuleContext(VariableDeclarationContext.class,0);
		}
		public IdentifierListContext identifierList() {
			return getRuleContext(IdentifierListContext.class,0);
		}
		public VariableDeclarationListContext variableDeclarationList() {
			return getRuleContext(VariableDeclarationListContext.class,0);
		}
		public ExpressionContext expression() {
			return getRuleContext(ExpressionContext.class,0);
		}
		public VariableDeclarationStatementContext(ParserRuleContext parent, int invokingState) {
			super(parent, invokingState);
		}
		@Override public int getRuleIndex() { return RULE_variableDeclarationStatement; }
		@Override
		public void enterRule(ParseTreeListener listener) {
			if ( listener instanceof SolidityListener ) ((SolidityListener)listener).enterVariableDeclarationStatement(this);
		}
		@Override
		public void exitRule(ParseTreeListener listener) {
			if ( listener instanceof SolidityListener ) ((SolidityListener)listener).exitVariableDeclarationStatement(this);
		}
		@Override
		public <T> T accept(ParseTreeVisitor<? extends T> visitor) {
			if ( visitor instanceof SolidityVisitor ) return ((SolidityVisitor<? extends T>)visitor).visitVariableDeclarationStatement(this);
			else return visitor.visitChildren(this);
		}
	}

	public final VariableDeclarationStatementContext variableDeclarationStatement() throws RecognitionException {
		VariableDeclarationStatementContext _localctx = new VariableDeclarationStatementContext(_ctx, getState());
		enterRule(_localctx, 104, RULE_variableDeclarationStatement);
		int _la;
		try {
			enterOuterAlt(_localctx, 1);
			{
			setState(623);
			switch ( getInterpreter().adaptivePredict(_input,64,_ctx) ) {
			case 1:
				{
				setState(616); match(31);
				setState(617); identifierList();
				}
				break;

			case 2:
				{
				setState(618); variableDeclaration();
				}
				break;

			case 3:
				{
				setState(619); match(25);
				setState(620); variableDeclarationList();
				setState(621); match(87);
				}
				break;
			}
			setState(627);
			_la = _input.LA(1);
			if (_la==17) {
				{
				setState(625); match(17);
				setState(626); expression(0);
				}
			}

			setState(629); match(52);
			}
		}
		catch (RecognitionException re) {
			_localctx.exception = re;
			_errHandler.reportError(this, re);
			_errHandler.recover(this, re);
		}
		finally {
			exitRule();
		}
		return _localctx;
	}

	public static class VariableDeclarationListContext extends ParserRuleContext {
		public List<VariableDeclarationContext> variableDeclaration() {
			return getRuleContexts(VariableDeclarationContext.class);
		}
		public VariableDeclarationContext variableDeclaration(int i) {
			return getRuleContext(VariableDeclarationContext.class,i);
		}
		public VariableDeclarationListContext(ParserRuleContext parent, int invokingState) {
			super(parent, invokingState);
		}
		@Override public int getRuleIndex() { return RULE_variableDeclarationList; }
		@Override
		public void enterRule(ParseTreeListener listener) {
			if ( listener instanceof SolidityListener ) ((SolidityListener)listener).enterVariableDeclarationList(this);
		}
		@Override
		public void exitRule(ParseTreeListener listener) {
			if ( listener instanceof SolidityListener ) ((SolidityListener)listener).exitVariableDeclarationList(this);
		}
		@Override
		public <T> T accept(ParseTreeVisitor<? extends T> visitor) {
			if ( visitor instanceof SolidityVisitor ) return ((SolidityVisitor<? extends T>)visitor).visitVariableDeclarationList(this);
			else return visitor.visitChildren(this);
		}
	}

	public final VariableDeclarationListContext variableDeclarationList() throws RecognitionException {
		VariableDeclarationListContext _localctx = new VariableDeclarationListContext(_ctx, getState());
		enterRule(_localctx, 106, RULE_variableDeclarationList);
		int _la;
		try {
			enterOuterAlt(_localctx, 1);
			{
			setState(632);
			_la = _input.LA(1);
			if ((((_la) & ~0x3f) == 0 && ((1L << _la) & ((1L << 16) | (1L << 31) | (1L << 37) | (1L << 40) | (1L << 42) | (1L << 62))) != 0) || ((((_la - 78)) & ~0x3f) == 0 && ((1L << (_la - 78)) & ((1L << (78 - 78)) | (1L << (79 - 78)) | (1L << (83 - 78)) | (1L << (Int - 78)) | (1L << (Uint - 78)) | (1L << (Byte - 78)) | (1L << (Fixed - 78)) | (1L << (Ufixed - 78)) | (1L << (Identifier - 78)))) != 0)) {
				{
				setState(631); variableDeclaration();
				}
			}

			setState(640);
			_errHandler.sync(this);
			_la = _input.LA(1);
			while (_la==27) {
				{
				{
				setState(634); match(27);
				setState(636);
				_la = _input.LA(1);
				if ((((_la) & ~0x3f) == 0 && ((1L << _la) & ((1L << 16) | (1L << 31) | (1L << 37) | (1L << 40) | (1L << 42) | (1L << 62))) != 0) || ((((_la - 78)) & ~0x3f) == 0 && ((1L << (_la - 78)) & ((1L << (78 - 78)) | (1L << (79 - 78)) | (1L << (83 - 78)) | (1L << (Int - 78)) | (1L << (Uint - 78)) | (1L << (Byte - 78)) | (1L << (Fixed - 78)) | (1L << (Ufixed - 78)) | (1L << (Identifier - 78)))) != 0)) {
					{
					setState(635); variableDeclaration();
					}
				}

				}
				}
				setState(642);
				_errHandler.sync(this);
				_la = _input.LA(1);
			}
			}
		}
		catch (RecognitionException re) {
			_localctx.exception = re;
			_errHandler.reportError(this, re);
			_errHandler.recover(this, re);
		}
		finally {
			exitRule();
		}
		return _localctx;
	}

	public static class IdentifierListContext extends ParserRuleContext {
		public IdentifierContext identifier(int i) {
			return getRuleContext(IdentifierContext.class,i);
		}
		public List<IdentifierContext> identifier() {
			return getRuleContexts(IdentifierContext.class);
		}
		public IdentifierListContext(ParserRuleContext parent, int invokingState) {
			super(parent, invokingState);
		}
		@Override public int getRuleIndex() { return RULE_identifierList; }
		@Override
		public void enterRule(ParseTreeListener listener) {
			if ( listener instanceof SolidityListener ) ((SolidityListener)listener).enterIdentifierList(this);
		}
		@Override
		public void exitRule(ParseTreeListener listener) {
			if ( listener instanceof SolidityListener ) ((SolidityListener)listener).exitIdentifierList(this);
		}
		@Override
		public <T> T accept(ParseTreeVisitor<? extends T> visitor) {
			if ( visitor instanceof SolidityVisitor ) return ((SolidityVisitor<? extends T>)visitor).visitIdentifierList(this);
			else return visitor.visitChildren(this);
		}
	}

	public final IdentifierListContext identifierList() throws RecognitionException {
		IdentifierListContext _localctx = new IdentifierListContext(_ctx, getState());
		enterRule(_localctx, 108, RULE_identifierList);
		int _la;
		try {
			int _alt;
			enterOuterAlt(_localctx, 1);
			{
			setState(643); match(25);
			setState(650);
			_errHandler.sync(this);
			_alt = getInterpreter().adaptivePredict(_input,70,_ctx);
			while ( _alt!=2 && _alt!=ATN.INVALID_ALT_NUMBER ) {
				if ( _alt==1 ) {
					{
					{
					setState(645);
					_la = _input.LA(1);
					if (_la==37 || _la==62 || _la==Identifier) {
						{
						setState(644); identifier();
						}
					}

					setState(647); match(27);
					}
					} 
				}
				setState(652);
				_errHandler.sync(this);
				_alt = getInterpreter().adaptivePredict(_input,70,_ctx);
			}
			setState(654);
			_la = _input.LA(1);
			if (_la==37 || _la==62 || _la==Identifier) {
				{
				setState(653); identifier();
				}
			}

			setState(656); match(87);
			}
		}
		catch (RecognitionException re) {
			_localctx.exception = re;
			_errHandler.reportError(this, re);
			_errHandler.recover(this, re);
		}
		finally {
			exitRule();
		}
		return _localctx;
	}

	public static class ElementaryTypeNameContext extends ParserRuleContext {
		public TerminalNode Uint() { return getToken(SolidityParser.Uint, 0); }
		public TerminalNode Byte() { return getToken(SolidityParser.Byte, 0); }
		public TerminalNode Ufixed() { return getToken(SolidityParser.Ufixed, 0); }
		public TerminalNode Int() { return getToken(SolidityParser.Int, 0); }
		public TerminalNode Fixed() { return getToken(SolidityParser.Fixed, 0); }
		public ElementaryTypeNameContext(ParserRuleContext parent, int invokingState) {
			super(parent, invokingState);
		}
		@Override public int getRuleIndex() { return RULE_elementaryTypeName; }
		@Override
		public void enterRule(ParseTreeListener listener) {
			if ( listener instanceof SolidityListener ) ((SolidityListener)listener).enterElementaryTypeName(this);
		}
		@Override
		public void exitRule(ParseTreeListener listener) {
			if ( listener instanceof SolidityListener ) ((SolidityListener)listener).exitElementaryTypeName(this);
		}
		@Override
		public <T> T accept(ParseTreeVisitor<? extends T> visitor) {
			if ( visitor instanceof SolidityVisitor ) return ((SolidityVisitor<? extends T>)visitor).visitElementaryTypeName(this);
			else return visitor.visitChildren(this);
		}
	}

	public final ElementaryTypeNameContext elementaryTypeName() throws RecognitionException {
		ElementaryTypeNameContext _localctx = new ElementaryTypeNameContext(_ctx, getState());
		enterRule(_localctx, 110, RULE_elementaryTypeName);
		int _la;
		try {
			enterOuterAlt(_localctx, 1);
			{
			setState(658);
			_la = _input.LA(1);
			if ( !(_la==16 || _la==31 || ((((_la - 78)) & ~0x3f) == 0 && ((1L << (_la - 78)) & ((1L << (78 - 78)) | (1L << (79 - 78)) | (1L << (83 - 78)) | (1L << (Int - 78)) | (1L << (Uint - 78)) | (1L << (Byte - 78)) | (1L << (Fixed - 78)) | (1L << (Ufixed - 78)))) != 0)) ) {
			_errHandler.recoverInline(this);
			}
			consume();
			}
		}
		catch (RecognitionException re) {
			_localctx.exception = re;
			_errHandler.reportError(this, re);
			_errHandler.recover(this, re);
		}
		finally {
			exitRule();
		}
		return _localctx;
	}

	public static class ExpressionContext extends ParserRuleContext {
		public TypeNameContext typeName() {
			return getRuleContext(TypeNameContext.class,0);
		}
		public FunctionCallArgumentsContext functionCallArguments() {
			return getRuleContext(FunctionCallArgumentsContext.class,0);
		}
		public ExpressionContext expression(int i) {
			return getRuleContext(ExpressionContext.class,i);
		}
		public PrimaryExpressionContext primaryExpression() {
			return getRuleContext(PrimaryExpressionContext.class,0);
		}
		public IdentifierContext identifier() {
			return getRuleContext(IdentifierContext.class,0);
		}
		public List<ExpressionContext> expression() {
			return getRuleContexts(ExpressionContext.class);
		}
		public ExpressionContext(ParserRuleContext parent, int invokingState) {
			super(parent, invokingState);
		}
		@Override public int getRuleIndex() { return RULE_expression; }
		@Override
		public void enterRule(ParseTreeListener listener) {
			if ( listener instanceof SolidityListener ) ((SolidityListener)listener).enterExpression(this);
		}
		@Override
		public void exitRule(ParseTreeListener listener) {
			if ( listener instanceof SolidityListener ) ((SolidityListener)listener).exitExpression(this);
		}
		@Override
		public <T> T accept(ParseTreeVisitor<? extends T> visitor) {
			if ( visitor instanceof SolidityVisitor ) return ((SolidityVisitor<? extends T>)visitor).visitExpression(this);
			else return visitor.visitChildren(this);
		}
	}

	public final ExpressionContext expression() throws RecognitionException {
		return expression(0);
	}

	private ExpressionContext expression(int _p) throws RecognitionException {
		ParserRuleContext _parentctx = _ctx;
		int _parentState = getState();
		ExpressionContext _localctx = new ExpressionContext(_ctx, _parentState);
		ExpressionContext _prevctx = _localctx;
		int _startState = 112;
		enterRecursionRule(_localctx, 112, RULE_expression, _p);
		int _la;
		try {
			int _alt;
			enterOuterAlt(_localctx, 1);
			{
			setState(678);
			switch ( getInterpreter().adaptivePredict(_input,72,_ctx) ) {
			case 1:
				{
				setState(661);
				_la = _input.LA(1);
				if ( !(_la==33 || _la==77) ) {
				_errHandler.recoverInline(this);
				}
				consume();
				setState(662); expression(19);
				}
				break;

			case 2:
				{
				setState(663);
				_la = _input.LA(1);
				if ( !(_la==41 || _la==89) ) {
				_errHandler.recoverInline(this);
				}
				consume();
				setState(664); expression(18);
				}
				break;

			case 3:
				{
				setState(665);
				_la = _input.LA(1);
				if ( !(_la==21 || _la==29) ) {
				_errHandler.recoverInline(this);
				}
				consume();
				setState(666); expression(17);
				}
				break;

			case 4:
				{
				setState(667); match(81);
				setState(668); expression(16);
				}
				break;

			case 5:
				{
				setState(669); match(36);
				setState(670); expression(15);
				}
				break;

			case 6:
				{
				setState(671); match(6);
				setState(672); typeName(0);
				}
				break;

			case 7:
				{
				setState(673); match(25);
				setState(674); expression(0);
				setState(675); match(87);
				}
				break;

			case 8:
				{
				setState(677); primaryExpression();
				}
				break;
			}
			_ctx.stop = _input.LT(-1);
			setState(739);
			_errHandler.sync(this);
			_alt = getInterpreter().adaptivePredict(_input,74,_ctx);
			while ( _alt!=2 && _alt!=ATN.INVALID_ALT_NUMBER ) {
				if ( _alt==1 ) {
					if ( _parseListeners!=null ) triggerExitRuleEvent();
					_prevctx = _localctx;
					{
					setState(737);
					switch ( getInterpreter().adaptivePredict(_input,73,_ctx) ) {
					case 1:
						{
						_localctx = new ExpressionContext(_parentctx, _parentState);
						pushNewRecursionContext(_localctx, _startState, RULE_expression);
						setState(680);
						if (!(precpred(_ctx, 14))) throw new FailedPredicateException(this, "precpred(_ctx, 14)");
						setState(681); match(15);
						setState(682); expression(15);
						}
						break;

					case 2:
						{
						_localctx = new ExpressionContext(_parentctx, _parentState);
						pushNewRecursionContext(_localctx, _startState, RULE_expression);
						setState(683);
						if (!(precpred(_ctx, 13))) throw new FailedPredicateException(this, "precpred(_ctx, 13)");
						setState(684);
						_la = _input.LA(1);
						if ( !(((((_la - 45)) & ~0x3f) == 0 && ((1L << (_la - 45)) & ((1L << (45 - 45)) | (1L << (66 - 45)) | (1L << (84 - 45)))) != 0)) ) {
						_errHandler.recoverInline(this);
						}
						consume();
						setState(685); expression(14);
						}
						break;

					case 3:
						{
						_localctx = new ExpressionContext(_parentctx, _parentState);
						pushNewRecursionContext(_localctx, _startState, RULE_expression);
						setState(686);
						if (!(precpred(_ctx, 12))) throw new FailedPredicateException(this, "precpred(_ctx, 12)");
						setState(687);
						_la = _input.LA(1);
						if ( !(_la==41 || _la==89) ) {
						_errHandler.recoverInline(this);
						}
						consume();
						setState(688); expression(13);
						}
						break;

					case 4:
						{
						_localctx = new ExpressionContext(_parentctx, _parentState);
						pushNewRecursionContext(_localctx, _startState, RULE_expression);
						setState(689);
						if (!(precpred(_ctx, 11))) throw new FailedPredicateException(this, "precpred(_ctx, 11)");
						setState(690);
						_la = _input.LA(1);
						if ( !(_la==14 || _la==53) ) {
						_errHandler.recoverInline(this);
						}
						consume();
						setState(691); expression(12);
						}
						break;

					case 5:
						{
						_localctx = new ExpressionContext(_parentctx, _parentState);
						pushNewRecursionContext(_localctx, _startState, RULE_expression);
						setState(692);
						if (!(precpred(_ctx, 10))) throw new FailedPredicateException(this, "precpred(_ctx, 10)");
						setState(693); match(63);
						setState(694); expression(11);
						}
						break;

					case 6:
						{
						_localctx = new ExpressionContext(_parentctx, _parentState);
						pushNewRecursionContext(_localctx, _startState, RULE_expression);
						setState(695);
						if (!(precpred(_ctx, 9))) throw new FailedPredicateException(this, "precpred(_ctx, 9)");
						setState(696); match(20);
						setState(697); expression(10);
						}
						break;

					case 7:
						{
						_localctx = new ExpressionContext(_parentctx, _parentState);
						pushNewRecursionContext(_localctx, _startState, RULE_expression);
						setState(698);
						if (!(precpred(_ctx, 8))) throw new FailedPredicateException(this, "precpred(_ctx, 8)");
						setState(699); match(76);
						setState(700); expression(9);
						}
						break;

					case 8:
						{
						_localctx = new ExpressionContext(_parentctx, _parentState);
						pushNewRecursionContext(_localctx, _startState, RULE_expression);
						setState(701);
						if (!(precpred(_ctx, 7))) throw new FailedPredicateException(this, "precpred(_ctx, 7)");
						setState(702);
						_la = _input.LA(1);
						if ( !(((((_la - 32)) & ~0x3f) == 0 && ((1L << (_la - 32)) & ((1L << (32 - 32)) | (1L << (34 - 32)) | (1L << (61 - 32)) | (1L << (80 - 32)))) != 0)) ) {
						_errHandler.recoverInline(this);
						}
						consume();
						setState(703); expression(8);
						}
						break;

					case 9:
						{
						_localctx = new ExpressionContext(_parentctx, _parentState);
						pushNewRecursionContext(_localctx, _startState, RULE_expression);
						setState(704);
						if (!(precpred(_ctx, 6))) throw new FailedPredicateException(this, "precpred(_ctx, 6)");
						setState(705);
						_la = _input.LA(1);
						if ( !(_la==8 || _la==75) ) {
						_errHandler.recoverInline(this);
						}
						consume();
						setState(706); expression(7);
						}
						break;

					case 10:
						{
						_localctx = new ExpressionContext(_parentctx, _parentState);
						pushNewRecursionContext(_localctx, _startState, RULE_expression);
						setState(707);
						if (!(precpred(_ctx, 5))) throw new FailedPredicateException(this, "precpred(_ctx, 5)");
						setState(708); match(13);
						setState(709); expression(6);
						}
						break;

					case 11:
						{
						_localctx = new ExpressionContext(_parentctx, _parentState);
						pushNewRecursionContext(_localctx, _startState, RULE_expression);
						setState(710);
						if (!(precpred(_ctx, 4))) throw new FailedPredicateException(this, "precpred(_ctx, 4)");
						setState(711); match(51);
						setState(712); expression(5);
						}
						break;

					case 12:
						{
						_localctx = new ExpressionContext(_parentctx, _parentState);
						pushNewRecursionContext(_localctx, _startState, RULE_expression);
						setState(713);
						if (!(precpred(_ctx, 3))) throw new FailedPredicateException(this, "precpred(_ctx, 3)");
						setState(714); match(58);
						setState(715); expression(0);
						setState(716); match(72);
						setState(717); expression(4);
						}
						break;

					case 13:
						{
						_localctx = new ExpressionContext(_parentctx, _parentState);
						pushNewRecursionContext(_localctx, _startState, RULE_expression);
						setState(719);
						if (!(precpred(_ctx, 2))) throw new FailedPredicateException(this, "precpred(_ctx, 2)");
						setState(720);
						_la = _input.LA(1);
						if ( !((((_la) & ~0x3f) == 0 && ((1L << _la) & ((1L << 2) | (1L << 3) | (1L << 12) | (1L << 17) | (1L << 18) | (1L << 22) | (1L << 26) | (1L << 28) | (1L << 44) | (1L << 47) | (1L << 50))) != 0)) ) {
						_errHandler.recoverInline(this);
						}
						consume();
						setState(721); expression(3);
						}
						break;

					case 14:
						{
						_localctx = new ExpressionContext(_parentctx, _parentState);
						pushNewRecursionContext(_localctx, _startState, RULE_expression);
						setState(722);
						if (!(precpred(_ctx, 25))) throw new FailedPredicateException(this, "precpred(_ctx, 25)");
						setState(723);
						_la = _input.LA(1);
						if ( !(_la==33 || _la==77) ) {
						_errHandler.recoverInline(this);
						}
						consume();
						}
						break;

					case 15:
						{
						_localctx = new ExpressionContext(_parentctx, _parentState);
						pushNewRecursionContext(_localctx, _startState, RULE_expression);
						setState(724);
						if (!(precpred(_ctx, 23))) throw new FailedPredicateException(this, "precpred(_ctx, 23)");
						setState(725); match(73);
						setState(726); expression(0);
						setState(727); match(35);
						}
						break;

					case 16:
						{
						_localctx = new ExpressionContext(_parentctx, _parentState);
						pushNewRecursionContext(_localctx, _startState, RULE_expression);
						setState(729);
						if (!(precpred(_ctx, 22))) throw new FailedPredicateException(this, "precpred(_ctx, 22)");
						setState(730); match(25);
						setState(731); functionCallArguments();
						setState(732); match(87);
						}
						break;

					case 17:
						{
						_localctx = new ExpressionContext(_parentctx, _parentState);
						pushNewRecursionContext(_localctx, _startState, RULE_expression);
						setState(734);
						if (!(precpred(_ctx, 21))) throw new FailedPredicateException(this, "precpred(_ctx, 21)");
						setState(735); match(68);
						setState(736); identifier();
						}
						break;
					}
					} 
				}
				setState(741);
				_errHandler.sync(this);
				_alt = getInterpreter().adaptivePredict(_input,74,_ctx);
			}
			}
		}
		catch (RecognitionException re) {
			_localctx.exception = re;
			_errHandler.reportError(this, re);
			_errHandler.recover(this, re);
		}
		finally {
			unrollRecursionContexts(_parentctx);
		}
		return _localctx;
	}

	public static class PrimaryExpressionContext extends ParserRuleContext {
		public TerminalNode TypeKeyword() { return getToken(SolidityParser.TypeKeyword, 0); }
		public TupleExpressionContext tupleExpression() {
			return getRuleContext(TupleExpressionContext.class,0);
		}
		public TerminalNode HexLiteral() { return getToken(SolidityParser.HexLiteral, 0); }
		public TerminalNode StringLiteral() { return getToken(SolidityParser.StringLiteral, 0); }
		public TypeNameExpressionContext typeNameExpression() {
			return getRuleContext(TypeNameExpressionContext.class,0);
		}
		public NumberLiteralContext numberLiteral() {
			return getRuleContext(NumberLiteralContext.class,0);
		}
		public TerminalNode BooleanLiteral() { return getToken(SolidityParser.BooleanLiteral, 0); }
		public IdentifierContext identifier() {
			return getRuleContext(IdentifierContext.class,0);
		}
		public PrimaryExpressionContext(ParserRuleContext parent, int invokingState) {
			super(parent, invokingState);
		}
		@Override public int getRuleIndex() { return RULE_primaryExpression; }
		@Override
		public void enterRule(ParseTreeListener listener) {
			if ( listener instanceof SolidityListener ) ((SolidityListener)listener).enterPrimaryExpression(this);
		}
		@Override
		public void exitRule(ParseTreeListener listener) {
			if ( listener instanceof SolidityListener ) ((SolidityListener)listener).exitPrimaryExpression(this);
		}
		@Override
		public <T> T accept(ParseTreeVisitor<? extends T> visitor) {
			if ( visitor instanceof SolidityVisitor ) return ((SolidityVisitor<? extends T>)visitor).visitPrimaryExpression(this);
			else return visitor.visitChildren(this);
		}
	}

	public final PrimaryExpressionContext primaryExpression() throws RecognitionException {
		PrimaryExpressionContext _localctx = new PrimaryExpressionContext(_ctx, getState());
		enterRule(_localctx, 114, RULE_primaryExpression);
		try {
			setState(758);
			switch ( getInterpreter().adaptivePredict(_input,77,_ctx) ) {
			case 1:
				enterOuterAlt(_localctx, 1);
				{
				setState(742); match(BooleanLiteral);
				}
				break;

			case 2:
				enterOuterAlt(_localctx, 2);
				{
				setState(743); numberLiteral();
				}
				break;

			case 3:
				enterOuterAlt(_localctx, 3);
				{
				setState(744); match(HexLiteral);
				}
				break;

			case 4:
				enterOuterAlt(_localctx, 4);
				{
				setState(745); match(StringLiteral);
				}
				break;

			case 5:
				enterOuterAlt(_localctx, 5);
				{
				setState(746); identifier();
				setState(749);
				switch ( getInterpreter().adaptivePredict(_input,75,_ctx) ) {
				case 1:
					{
					setState(747); match(73);
					setState(748); match(35);
					}
					break;
				}
				}
				break;

			case 6:
				enterOuterAlt(_localctx, 6);
				{
				setState(751); match(TypeKeyword);
				}
				break;

			case 7:
				enterOuterAlt(_localctx, 7);
				{
				setState(752); tupleExpression();
				}
				break;

			case 8:
				enterOuterAlt(_localctx, 8);
				{
				setState(753); typeNameExpression();
				setState(756);
				switch ( getInterpreter().adaptivePredict(_input,76,_ctx) ) {
				case 1:
					{
					setState(754); match(73);
					setState(755); match(35);
					}
					break;
				}
				}
				break;
			}
		}
		catch (RecognitionException re) {
			_localctx.exception = re;
			_errHandler.reportError(this, re);
			_errHandler.recover(this, re);
		}
		finally {
			exitRule();
		}
		return _localctx;
	}

	public static class ExpressionListContext extends ParserRuleContext {
		public ExpressionContext expression(int i) {
			return getRuleContext(ExpressionContext.class,i);
		}
		public List<ExpressionContext> expression() {
			return getRuleContexts(ExpressionContext.class);
		}
		public ExpressionListContext(ParserRuleContext parent, int invokingState) {
			super(parent, invokingState);
		}
		@Override public int getRuleIndex() { return RULE_expressionList; }
		@Override
		public void enterRule(ParseTreeListener listener) {
			if ( listener instanceof SolidityListener ) ((SolidityListener)listener).enterExpressionList(this);
		}
		@Override
		public void exitRule(ParseTreeListener listener) {
			if ( listener instanceof SolidityListener ) ((SolidityListener)listener).exitExpressionList(this);
		}
		@Override
		public <T> T accept(ParseTreeVisitor<? extends T> visitor) {
			if ( visitor instanceof SolidityVisitor ) return ((SolidityVisitor<? extends T>)visitor).visitExpressionList(this);
			else return visitor.visitChildren(this);
		}
	}

	public final ExpressionListContext expressionList() throws RecognitionException {
		ExpressionListContext _localctx = new ExpressionListContext(_ctx, getState());
		enterRule(_localctx, 116, RULE_expressionList);
		int _la;
		try {
			enterOuterAlt(_localctx, 1);
			{
			setState(760); expression(0);
			setState(765);
			_errHandler.sync(this);
			_la = _input.LA(1);
			while (_la==27) {
				{
				{
				setState(761); match(27);
				setState(762); expression(0);
				}
				}
				setState(767);
				_errHandler.sync(this);
				_la = _input.LA(1);
			}
			}
		}
		catch (RecognitionException re) {
			_localctx.exception = re;
			_errHandler.reportError(this, re);
			_errHandler.recover(this, re);
		}
		finally {
			exitRule();
		}
		return _localctx;
	}

	public static class NameValueListContext extends ParserRuleContext {
		public NameValueContext nameValue(int i) {
			return getRuleContext(NameValueContext.class,i);
		}
		public List<NameValueContext> nameValue() {
			return getRuleContexts(NameValueContext.class);
		}
		public NameValueListContext(ParserRuleContext parent, int invokingState) {
			super(parent, invokingState);
		}
		@Override public int getRuleIndex() { return RULE_nameValueList; }
		@Override
		public void enterRule(ParseTreeListener listener) {
			if ( listener instanceof SolidityListener ) ((SolidityListener)listener).enterNameValueList(this);
		}
		@Override
		public void exitRule(ParseTreeListener listener) {
			if ( listener instanceof SolidityListener ) ((SolidityListener)listener).exitNameValueList(this);
		}
		@Override
		public <T> T accept(ParseTreeVisitor<? extends T> visitor) {
			if ( visitor instanceof SolidityVisitor ) return ((SolidityVisitor<? extends T>)visitor).visitNameValueList(this);
			else return visitor.visitChildren(this);
		}
	}

	public final NameValueListContext nameValueList() throws RecognitionException {
		NameValueListContext _localctx = new NameValueListContext(_ctx, getState());
		enterRule(_localctx, 118, RULE_nameValueList);
		int _la;
		try {
			int _alt;
			enterOuterAlt(_localctx, 1);
			{
			setState(768); nameValue();
			setState(773);
			_errHandler.sync(this);
			_alt = getInterpreter().adaptivePredict(_input,79,_ctx);
			while ( _alt!=2 && _alt!=ATN.INVALID_ALT_NUMBER ) {
				if ( _alt==1 ) {
					{
					{
					setState(769); match(27);
					setState(770); nameValue();
					}
					} 
				}
				setState(775);
				_errHandler.sync(this);
				_alt = getInterpreter().adaptivePredict(_input,79,_ctx);
			}
			setState(777);
			_la = _input.LA(1);
			if (_la==27) {
				{
				setState(776); match(27);
				}
			}

			}
		}
		catch (RecognitionException re) {
			_localctx.exception = re;
			_errHandler.reportError(this, re);
			_errHandler.recover(this, re);
		}
		finally {
			exitRule();
		}
		return _localctx;
	}

	public static class NameValueContext extends ParserRuleContext {
		public IdentifierContext identifier() {
			return getRuleContext(IdentifierContext.class,0);
		}
		public ExpressionContext expression() {
			return getRuleContext(ExpressionContext.class,0);
		}
		public NameValueContext(ParserRuleContext parent, int invokingState) {
			super(parent, invokingState);
		}
		@Override public int getRuleIndex() { return RULE_nameValue; }
		@Override
		public void enterRule(ParseTreeListener listener) {
			if ( listener instanceof SolidityListener ) ((SolidityListener)listener).enterNameValue(this);
		}
		@Override
		public void exitRule(ParseTreeListener listener) {
			if ( listener instanceof SolidityListener ) ((SolidityListener)listener).exitNameValue(this);
		}
		@Override
		public <T> T accept(ParseTreeVisitor<? extends T> visitor) {
			if ( visitor instanceof SolidityVisitor ) return ((SolidityVisitor<? extends T>)visitor).visitNameValue(this);
			else return visitor.visitChildren(this);
		}
	}

	public final NameValueContext nameValue() throws RecognitionException {
		NameValueContext _localctx = new NameValueContext(_ctx, getState());
		enterRule(_localctx, 120, RULE_nameValue);
		try {
			enterOuterAlt(_localctx, 1);
			{
			setState(779); identifier();
			setState(780); match(72);
			setState(781); expression(0);
			}
		}
		catch (RecognitionException re) {
			_localctx.exception = re;
			_errHandler.reportError(this, re);
			_errHandler.recover(this, re);
		}
		finally {
			exitRule();
		}
		return _localctx;
	}

	public static class FunctionCallArgumentsContext extends ParserRuleContext {
		public ExpressionListContext expressionList() {
			return getRuleContext(ExpressionListContext.class,0);
		}
		public NameValueListContext nameValueList() {
			return getRuleContext(NameValueListContext.class,0);
		}
		public FunctionCallArgumentsContext(ParserRuleContext parent, int invokingState) {
			super(parent, invokingState);
		}
		@Override public int getRuleIndex() { return RULE_functionCallArguments; }
		@Override
		public void enterRule(ParseTreeListener listener) {
			if ( listener instanceof SolidityListener ) ((SolidityListener)listener).enterFunctionCallArguments(this);
		}
		@Override
		public void exitRule(ParseTreeListener listener) {
			if ( listener instanceof SolidityListener ) ((SolidityListener)listener).exitFunctionCallArguments(this);
		}
		@Override
		public <T> T accept(ParseTreeVisitor<? extends T> visitor) {
			if ( visitor instanceof SolidityVisitor ) return ((SolidityVisitor<? extends T>)visitor).visitFunctionCallArguments(this);
			else return visitor.visitChildren(this);
		}
	}

	public final FunctionCallArgumentsContext functionCallArguments() throws RecognitionException {
		FunctionCallArgumentsContext _localctx = new FunctionCallArgumentsContext(_ctx, getState());
		enterRule(_localctx, 122, RULE_functionCallArguments);
		int _la;
		try {
			setState(791);
			switch (_input.LA(1)) {
			case 10:
				enterOuterAlt(_localctx, 1);
				{
				setState(783); match(10);
				setState(785);
				_la = _input.LA(1);
				if (_la==37 || _la==62 || _la==Identifier) {
					{
					setState(784); nameValueList();
					}
				}

				setState(787); match(55);
				}
				break;
			case 6:
			case 16:
			case 21:
			case 25:
			case 29:
			case 31:
			case 33:
			case 36:
			case 37:
			case 41:
			case 62:
			case 73:
			case 77:
			case 78:
			case 79:
			case 81:
			case 83:
			case 87:
			case 89:
			case Int:
			case Uint:
			case Byte:
			case Fixed:
			case Ufixed:
			case BooleanLiteral:
			case DecimalNumber:
			case HexNumber:
			case HexLiteral:
			case TypeKeyword:
			case Identifier:
			case StringLiteral:
				enterOuterAlt(_localctx, 2);
				{
				setState(789);
				_la = _input.LA(1);
				if ((((_la) & ~0x3f) == 0 && ((1L << _la) & ((1L << 6) | (1L << 16) | (1L << 21) | (1L << 25) | (1L << 29) | (1L << 31) | (1L << 33) | (1L << 36) | (1L << 37) | (1L << 41) | (1L << 62))) != 0) || ((((_la - 73)) & ~0x3f) == 0 && ((1L << (_la - 73)) & ((1L << (73 - 73)) | (1L << (77 - 73)) | (1L << (78 - 73)) | (1L << (79 - 73)) | (1L << (81 - 73)) | (1L << (83 - 73)) | (1L << (89 - 73)) | (1L << (Int - 73)) | (1L << (Uint - 73)) | (1L << (Byte - 73)) | (1L << (Fixed - 73)) | (1L << (Ufixed - 73)) | (1L << (BooleanLiteral - 73)) | (1L << (DecimalNumber - 73)) | (1L << (HexNumber - 73)) | (1L << (HexLiteral - 73)) | (1L << (TypeKeyword - 73)) | (1L << (Identifier - 73)) | (1L << (StringLiteral - 73)))) != 0)) {
					{
					setState(788); expressionList();
					}
				}

				}
				break;
			default:
				throw new NoViableAltException(this);
			}
		}
		catch (RecognitionException re) {
			_localctx.exception = re;
			_errHandler.reportError(this, re);
			_errHandler.recover(this, re);
		}
		finally {
			exitRule();
		}
		return _localctx;
	}

	public static class FunctionCallContext extends ParserRuleContext {
		public FunctionCallArgumentsContext functionCallArguments() {
			return getRuleContext(FunctionCallArgumentsContext.class,0);
		}
		public ExpressionContext expression() {
			return getRuleContext(ExpressionContext.class,0);
		}
		public FunctionCallContext(ParserRuleContext parent, int invokingState) {
			super(parent, invokingState);
		}
		@Override public int getRuleIndex() { return RULE_functionCall; }
		@Override
		public void enterRule(ParseTreeListener listener) {
			if ( listener instanceof SolidityListener ) ((SolidityListener)listener).enterFunctionCall(this);
		}
		@Override
		public void exitRule(ParseTreeListener listener) {
			if ( listener instanceof SolidityListener ) ((SolidityListener)listener).exitFunctionCall(this);
		}
		@Override
		public <T> T accept(ParseTreeVisitor<? extends T> visitor) {
			if ( visitor instanceof SolidityVisitor ) return ((SolidityVisitor<? extends T>)visitor).visitFunctionCall(this);
			else return visitor.visitChildren(this);
		}
	}

	public final FunctionCallContext functionCall() throws RecognitionException {
		FunctionCallContext _localctx = new FunctionCallContext(_ctx, getState());
		enterRule(_localctx, 124, RULE_functionCall);
		try {
			enterOuterAlt(_localctx, 1);
			{
			setState(793); expression(0);
			setState(794); match(25);
			setState(795); functionCallArguments();
			setState(796); match(87);
			}
		}
		catch (RecognitionException re) {
			_localctx.exception = re;
			_errHandler.reportError(this, re);
			_errHandler.recover(this, re);
		}
		finally {
			exitRule();
		}
		return _localctx;
	}

	public static class AssemblyBlockContext extends ParserRuleContext {
		public List<AssemblyItemContext> assemblyItem() {
			return getRuleContexts(AssemblyItemContext.class);
		}
		public AssemblyItemContext assemblyItem(int i) {
			return getRuleContext(AssemblyItemContext.class,i);
		}
		public AssemblyBlockContext(ParserRuleContext parent, int invokingState) {
			super(parent, invokingState);
		}
		@Override public int getRuleIndex() { return RULE_assemblyBlock; }
		@Override
		public void enterRule(ParseTreeListener listener) {
			if ( listener instanceof SolidityListener ) ((SolidityListener)listener).enterAssemblyBlock(this);
		}
		@Override
		public void exitRule(ParseTreeListener listener) {
			if ( listener instanceof SolidityListener ) ((SolidityListener)listener).exitAssemblyBlock(this);
		}
		@Override
		public <T> T accept(ParseTreeVisitor<? extends T> visitor) {
			if ( visitor instanceof SolidityVisitor ) return ((SolidityVisitor<? extends T>)visitor).visitAssemblyBlock(this);
			else return visitor.visitChildren(this);
		}
	}

	public final AssemblyBlockContext assemblyBlock() throws RecognitionException {
		AssemblyBlockContext _localctx = new AssemblyBlockContext(_ctx, getState());
		enterRule(_localctx, 126, RULE_assemblyBlock);
		int _la;
		try {
			enterOuterAlt(_localctx, 1);
			{
			setState(798); match(10);
			setState(802);
			_errHandler.sync(this);
			_la = _input.LA(1);
			while ((((_la) & ~0x3f) == 0 && ((1L << _la) & ((1L << 10) | (1L << 16) | (1L << 19) | (1L << 25) | (1L << 37) | (1L << 38) | (1L << 40) | (1L << 48) | (1L << 54) | (1L << 56) | (1L << 62))) != 0) || ((((_la - 64)) & ~0x3f) == 0 && ((1L << (_la - 64)) & ((1L << (64 - 64)) | (1L << (78 - 64)) | (1L << (88 - 64)) | (1L << (DecimalNumber - 64)) | (1L << (HexNumber - 64)) | (1L << (HexLiteral - 64)) | (1L << (BreakKeyword - 64)) | (1L << (ContinueKeyword - 64)) | (1L << (Identifier - 64)) | (1L << (StringLiteral - 64)))) != 0)) {
				{
				{
				setState(799); assemblyItem();
				}
				}
				setState(804);
				_errHandler.sync(this);
				_la = _input.LA(1);
			}
			setState(805); match(55);
			}
		}
		catch (RecognitionException re) {
			_localctx.exception = re;
			_errHandler.reportError(this, re);
			_errHandler.recover(this, re);
		}
		finally {
			exitRule();
		}
		return _localctx;
	}

	public static class AssemblyItemContext extends ParserRuleContext {
		public AssemblyLocalDefinitionContext assemblyLocalDefinition() {
			return getRuleContext(AssemblyLocalDefinitionContext.class,0);
		}
		public AssemblyFunctionDefinitionContext assemblyFunctionDefinition() {
			return getRuleContext(AssemblyFunctionDefinitionContext.class,0);
		}
		public SubAssemblyContext subAssembly() {
			return getRuleContext(SubAssemblyContext.class,0);
		}
		public TerminalNode BreakKeyword() { return getToken(SolidityParser.BreakKeyword, 0); }
		public NumberLiteralContext numberLiteral() {
			return getRuleContext(NumberLiteralContext.class,0);
		}
		public AssemblyExpressionContext assemblyExpression() {
			return getRuleContext(AssemblyExpressionContext.class,0);
		}
		public IdentifierContext identifier() {
			return getRuleContext(IdentifierContext.class,0);
		}
		public AssemblyBlockContext assemblyBlock() {
			return getRuleContext(AssemblyBlockContext.class,0);
		}
		public AssemblyIfContext assemblyIf() {
			return getRuleContext(AssemblyIfContext.class,0);
		}
		public AssemblySwitchContext assemblySwitch() {
			return getRuleContext(AssemblySwitchContext.class,0);
		}
		public TerminalNode HexLiteral() { return getToken(SolidityParser.HexLiteral, 0); }
		public TerminalNode StringLiteral() { return getToken(SolidityParser.StringLiteral, 0); }
		public LabelDefinitionContext labelDefinition() {
			return getRuleContext(LabelDefinitionContext.class,0);
		}
		public AssemblyAssignmentContext assemblyAssignment() {
			return getRuleContext(AssemblyAssignmentContext.class,0);
		}
		public TerminalNode ContinueKeyword() { return getToken(SolidityParser.ContinueKeyword, 0); }
		public AssemblyStackAssignmentContext assemblyStackAssignment() {
			return getRuleContext(AssemblyStackAssignmentContext.class,0);
		}
		public AssemblyForContext assemblyFor() {
			return getRuleContext(AssemblyForContext.class,0);
		}
		public AssemblyItemContext(ParserRuleContext parent, int invokingState) {
			super(parent, invokingState);
		}
		@Override public int getRuleIndex() { return RULE_assemblyItem; }
		@Override
		public void enterRule(ParseTreeListener listener) {
			if ( listener instanceof SolidityListener ) ((SolidityListener)listener).enterAssemblyItem(this);
		}
		@Override
		public void exitRule(ParseTreeListener listener) {
			if ( listener instanceof SolidityListener ) ((SolidityListener)listener).exitAssemblyItem(this);
		}
		@Override
		public <T> T accept(ParseTreeVisitor<? extends T> visitor) {
			if ( visitor instanceof SolidityVisitor ) return ((SolidityVisitor<? extends T>)visitor).visitAssemblyItem(this);
			else return visitor.visitChildren(this);
		}
	}

	public final AssemblyItemContext assemblyItem() throws RecognitionException {
		AssemblyItemContext _localctx = new AssemblyItemContext(_ctx, getState());
		enterRule(_localctx, 128, RULE_assemblyItem);
		try {
			setState(824);
			switch ( getInterpreter().adaptivePredict(_input,85,_ctx) ) {
			case 1:
				enterOuterAlt(_localctx, 1);
				{
				setState(807); identifier();
				}
				break;

			case 2:
				enterOuterAlt(_localctx, 2);
				{
				setState(808); assemblyBlock();
				}
				break;

			case 3:
				enterOuterAlt(_localctx, 3);
				{
				setState(809); assemblyExpression();
				}
				break;

			case 4:
				enterOuterAlt(_localctx, 4);
				{
				setState(810); assemblyLocalDefinition();
				}
				break;

			case 5:
				enterOuterAlt(_localctx, 5);
				{
				setState(811); assemblyAssignment();
				}
				break;

			case 6:
				enterOuterAlt(_localctx, 6);
				{
				setState(812); assemblyStackAssignment();
				}
				break;

			case 7:
				enterOuterAlt(_localctx, 7);
				{
				setState(813); labelDefinition();
				}
				break;

			case 8:
				enterOuterAlt(_localctx, 8);
				{
				setState(814); assemblySwitch();
				}
				break;

			case 9:
				enterOuterAlt(_localctx, 9);
				{
				setState(815); assemblyFunctionDefinition();
				}
				break;

			case 10:
				enterOuterAlt(_localctx, 10);
				{
				setState(816); assemblyFor();
				}
				break;

			case 11:
				enterOuterAlt(_localctx, 11);
				{
				setState(817); assemblyIf();
				}
				break;

			case 12:
				enterOuterAlt(_localctx, 12);
				{
				setState(818); match(BreakKeyword);
				}
				break;

			case 13:
				enterOuterAlt(_localctx, 13);
				{
				setState(819); match(ContinueKeyword);
				}
				break;

			case 14:
				enterOuterAlt(_localctx, 14);
				{
				setState(820); subAssembly();
				}
				break;

			case 15:
				enterOuterAlt(_localctx, 15);
				{
				setState(821); numberLiteral();
				}
				break;

			case 16:
				enterOuterAlt(_localctx, 16);
				{
				setState(822); match(StringLiteral);
				}
				break;

			case 17:
				enterOuterAlt(_localctx, 17);
				{
				setState(823); match(HexLiteral);
				}
				break;
			}
		}
		catch (RecognitionException re) {
			_localctx.exception = re;
			_errHandler.reportError(this, re);
			_errHandler.recover(this, re);
		}
		finally {
			exitRule();
		}
		return _localctx;
	}

	public static class AssemblyExpressionContext extends ParserRuleContext {
		public AssemblyCallContext assemblyCall() {
			return getRuleContext(AssemblyCallContext.class,0);
		}
		public AssemblyLiteralContext assemblyLiteral() {
			return getRuleContext(AssemblyLiteralContext.class,0);
		}
		public AssemblyExpressionContext(ParserRuleContext parent, int invokingState) {
			super(parent, invokingState);
		}
		@Override public int getRuleIndex() { return RULE_assemblyExpression; }
		@Override
		public void enterRule(ParseTreeListener listener) {
			if ( listener instanceof SolidityListener ) ((SolidityListener)listener).enterAssemblyExpression(this);
		}
		@Override
		public void exitRule(ParseTreeListener listener) {
			if ( listener instanceof SolidityListener ) ((SolidityListener)listener).exitAssemblyExpression(this);
		}
		@Override
		public <T> T accept(ParseTreeVisitor<? extends T> visitor) {
			if ( visitor instanceof SolidityVisitor ) return ((SolidityVisitor<? extends T>)visitor).visitAssemblyExpression(this);
			else return visitor.visitChildren(this);
		}
	}

	public final AssemblyExpressionContext assemblyExpression() throws RecognitionException {
		AssemblyExpressionContext _localctx = new AssemblyExpressionContext(_ctx, getState());
		enterRule(_localctx, 130, RULE_assemblyExpression);
		try {
			setState(828);
			switch (_input.LA(1)) {
			case 16:
			case 37:
			case 48:
			case 62:
			case 78:
			case Identifier:
				enterOuterAlt(_localctx, 1);
				{
				setState(826); assemblyCall();
				}
				break;
			case DecimalNumber:
			case HexNumber:
			case HexLiteral:
			case StringLiteral:
				enterOuterAlt(_localctx, 2);
				{
				setState(827); assemblyLiteral();
				}
				break;
			default:
				throw new NoViableAltException(this);
			}
		}
		catch (RecognitionException re) {
			_localctx.exception = re;
			_errHandler.reportError(this, re);
			_errHandler.recover(this, re);
		}
		finally {
			exitRule();
		}
		return _localctx;
	}

	public static class AssemblyCallContext extends ParserRuleContext {
		public AssemblyExpressionContext assemblyExpression(int i) {
			return getRuleContext(AssemblyExpressionContext.class,i);
		}
		public List<AssemblyExpressionContext> assemblyExpression() {
			return getRuleContexts(AssemblyExpressionContext.class);
		}
		public IdentifierContext identifier() {
			return getRuleContext(IdentifierContext.class,0);
		}
		public AssemblyCallContext(ParserRuleContext parent, int invokingState) {
			super(parent, invokingState);
		}
		@Override public int getRuleIndex() { return RULE_assemblyCall; }
		@Override
		public void enterRule(ParseTreeListener listener) {
			if ( listener instanceof SolidityListener ) ((SolidityListener)listener).enterAssemblyCall(this);
		}
		@Override
		public void exitRule(ParseTreeListener listener) {
			if ( listener instanceof SolidityListener ) ((SolidityListener)listener).exitAssemblyCall(this);
		}
		@Override
		public <T> T accept(ParseTreeVisitor<? extends T> visitor) {
			if ( visitor instanceof SolidityVisitor ) return ((SolidityVisitor<? extends T>)visitor).visitAssemblyCall(this);
			else return visitor.visitChildren(this);
		}
	}

	public final AssemblyCallContext assemblyCall() throws RecognitionException {
		AssemblyCallContext _localctx = new AssemblyCallContext(_ctx, getState());
		enterRule(_localctx, 132, RULE_assemblyCall);
		int _la;
		try {
			enterOuterAlt(_localctx, 1);
			{
			setState(834);
			switch (_input.LA(1)) {
			case 48:
				{
				setState(830); match(48);
				}
				break;
			case 78:
				{
				setState(831); match(78);
				}
				break;
			case 16:
				{
				setState(832); match(16);
				}
				break;
			case 37:
			case 62:
			case Identifier:
				{
				setState(833); identifier();
				}
				break;
			default:
				throw new NoViableAltException(this);
			}
			setState(848);
			switch ( getInterpreter().adaptivePredict(_input,90,_ctx) ) {
			case 1:
				{
				setState(836); match(25);
				setState(838);
				_la = _input.LA(1);
				if ((((_la) & ~0x3f) == 0 && ((1L << _la) & ((1L << 16) | (1L << 37) | (1L << 48) | (1L << 62))) != 0) || ((((_la - 78)) & ~0x3f) == 0 && ((1L << (_la - 78)) & ((1L << (78 - 78)) | (1L << (DecimalNumber - 78)) | (1L << (HexNumber - 78)) | (1L << (HexLiteral - 78)) | (1L << (Identifier - 78)) | (1L << (StringLiteral - 78)))) != 0)) {
					{
					setState(837); assemblyExpression();
					}
				}

				setState(844);
				_errHandler.sync(this);
				_la = _input.LA(1);
				while (_la==27) {
					{
					{
					setState(840); match(27);
					setState(841); assemblyExpression();
					}
					}
					setState(846);
					_errHandler.sync(this);
					_la = _input.LA(1);
				}
				setState(847); match(87);
				}
				break;
			}
			}
		}
		catch (RecognitionException re) {
			_localctx.exception = re;
			_errHandler.reportError(this, re);
			_errHandler.recover(this, re);
		}
		finally {
			exitRule();
		}
		return _localctx;
	}

	public static class AssemblyLocalDefinitionContext extends ParserRuleContext {
		public AssemblyExpressionContext assemblyExpression() {
			return getRuleContext(AssemblyExpressionContext.class,0);
		}
		public AssemblyIdentifierOrListContext assemblyIdentifierOrList() {
			return getRuleContext(AssemblyIdentifierOrListContext.class,0);
		}
		public AssemblyLocalDefinitionContext(ParserRuleContext parent, int invokingState) {
			super(parent, invokingState);
		}
		@Override public int getRuleIndex() { return RULE_assemblyLocalDefinition; }
		@Override
		public void enterRule(ParseTreeListener listener) {
			if ( listener instanceof SolidityListener ) ((SolidityListener)listener).enterAssemblyLocalDefinition(this);
		}
		@Override
		public void exitRule(ParseTreeListener listener) {
			if ( listener instanceof SolidityListener ) ((SolidityListener)listener).exitAssemblyLocalDefinition(this);
		}
		@Override
		public <T> T accept(ParseTreeVisitor<? extends T> visitor) {
			if ( visitor instanceof SolidityVisitor ) return ((SolidityVisitor<? extends T>)visitor).visitAssemblyLocalDefinition(this);
			else return visitor.visitChildren(this);
		}
	}

	public final AssemblyLocalDefinitionContext assemblyLocalDefinition() throws RecognitionException {
		AssemblyLocalDefinitionContext _localctx = new AssemblyLocalDefinitionContext(_ctx, getState());
		enterRule(_localctx, 134, RULE_assemblyLocalDefinition);
		int _la;
		try {
			enterOuterAlt(_localctx, 1);
			{
			setState(850); match(38);
			setState(851); assemblyIdentifierOrList();
			setState(854);
			_la = _input.LA(1);
			if (_la==57) {
				{
				setState(852); match(57);
				setState(853); assemblyExpression();
				}
			}

			}
		}
		catch (RecognitionException re) {
			_localctx.exception = re;
			_errHandler.reportError(this, re);
			_errHandler.recover(this, re);
		}
		finally {
			exitRule();
		}
		return _localctx;
	}

	public static class AssemblyAssignmentContext extends ParserRuleContext {
		public AssemblyExpressionContext assemblyExpression() {
			return getRuleContext(AssemblyExpressionContext.class,0);
		}
		public AssemblyIdentifierOrListContext assemblyIdentifierOrList() {
			return getRuleContext(AssemblyIdentifierOrListContext.class,0);
		}
		public AssemblyAssignmentContext(ParserRuleContext parent, int invokingState) {
			super(parent, invokingState);
		}
		@Override public int getRuleIndex() { return RULE_assemblyAssignment; }
		@Override
		public void enterRule(ParseTreeListener listener) {
			if ( listener instanceof SolidityListener ) ((SolidityListener)listener).enterAssemblyAssignment(this);
		}
		@Override
		public void exitRule(ParseTreeListener listener) {
			if ( listener instanceof SolidityListener ) ((SolidityListener)listener).exitAssemblyAssignment(this);
		}
		@Override
		public <T> T accept(ParseTreeVisitor<? extends T> visitor) {
			if ( visitor instanceof SolidityVisitor ) return ((SolidityVisitor<? extends T>)visitor).visitAssemblyAssignment(this);
			else return visitor.visitChildren(this);
		}
	}

	public final AssemblyAssignmentContext assemblyAssignment() throws RecognitionException {
		AssemblyAssignmentContext _localctx = new AssemblyAssignmentContext(_ctx, getState());
		enterRule(_localctx, 136, RULE_assemblyAssignment);
		try {
			enterOuterAlt(_localctx, 1);
			{
			setState(856); assemblyIdentifierOrList();
			setState(857); match(57);
			setState(858); assemblyExpression();
			}
		}
		catch (RecognitionException re) {
			_localctx.exception = re;
			_errHandler.reportError(this, re);
			_errHandler.recover(this, re);
		}
		finally {
			exitRule();
		}
		return _localctx;
	}

	public static class AssemblyIdentifierOrListContext extends ParserRuleContext {
		public AssemblyIdentifierListContext assemblyIdentifierList() {
			return getRuleContext(AssemblyIdentifierListContext.class,0);
		}
		public IdentifierContext identifier() {
			return getRuleContext(IdentifierContext.class,0);
		}
		public AssemblyIdentifierOrListContext(ParserRuleContext parent, int invokingState) {
			super(parent, invokingState);
		}
		@Override public int getRuleIndex() { return RULE_assemblyIdentifierOrList; }
		@Override
		public void enterRule(ParseTreeListener listener) {
			if ( listener instanceof SolidityListener ) ((SolidityListener)listener).enterAssemblyIdentifierOrList(this);
		}
		@Override
		public void exitRule(ParseTreeListener listener) {
			if ( listener instanceof SolidityListener ) ((SolidityListener)listener).exitAssemblyIdentifierOrList(this);
		}
		@Override
		public <T> T accept(ParseTreeVisitor<? extends T> visitor) {
			if ( visitor instanceof SolidityVisitor ) return ((SolidityVisitor<? extends T>)visitor).visitAssemblyIdentifierOrList(this);
			else return visitor.visitChildren(this);
		}
	}

	public final AssemblyIdentifierOrListContext assemblyIdentifierOrList() throws RecognitionException {
		AssemblyIdentifierOrListContext _localctx = new AssemblyIdentifierOrListContext(_ctx, getState());
		enterRule(_localctx, 138, RULE_assemblyIdentifierOrList);
		try {
			setState(865);
			switch (_input.LA(1)) {
			case 37:
			case 62:
			case Identifier:
				enterOuterAlt(_localctx, 1);
				{
				setState(860); identifier();
				}
				break;
			case 25:
				enterOuterAlt(_localctx, 2);
				{
				setState(861); match(25);
				setState(862); assemblyIdentifierList();
				setState(863); match(87);
				}
				break;
			default:
				throw new NoViableAltException(this);
			}
		}
		catch (RecognitionException re) {
			_localctx.exception = re;
			_errHandler.reportError(this, re);
			_errHandler.recover(this, re);
		}
		finally {
			exitRule();
		}
		return _localctx;
	}

	public static class AssemblyIdentifierListContext extends ParserRuleContext {
		public IdentifierContext identifier(int i) {
			return getRuleContext(IdentifierContext.class,i);
		}
		public List<IdentifierContext> identifier() {
			return getRuleContexts(IdentifierContext.class);
		}
		public AssemblyIdentifierListContext(ParserRuleContext parent, int invokingState) {
			super(parent, invokingState);
		}
		@Override public int getRuleIndex() { return RULE_assemblyIdentifierList; }
		@Override
		public void enterRule(ParseTreeListener listener) {
			if ( listener instanceof SolidityListener ) ((SolidityListener)listener).enterAssemblyIdentifierList(this);
		}
		@Override
		public void exitRule(ParseTreeListener listener) {
			if ( listener instanceof SolidityListener ) ((SolidityListener)listener).exitAssemblyIdentifierList(this);
		}
		@Override
		public <T> T accept(ParseTreeVisitor<? extends T> visitor) {
			if ( visitor instanceof SolidityVisitor ) return ((SolidityVisitor<? extends T>)visitor).visitAssemblyIdentifierList(this);
			else return visitor.visitChildren(this);
		}
	}

	public final AssemblyIdentifierListContext assemblyIdentifierList() throws RecognitionException {
		AssemblyIdentifierListContext _localctx = new AssemblyIdentifierListContext(_ctx, getState());
		enterRule(_localctx, 140, RULE_assemblyIdentifierList);
		int _la;
		try {
			enterOuterAlt(_localctx, 1);
			{
			setState(867); identifier();
			setState(872);
			_errHandler.sync(this);
			_la = _input.LA(1);
			while (_la==27) {
				{
				{
				setState(868); match(27);
				setState(869); identifier();
				}
				}
				setState(874);
				_errHandler.sync(this);
				_la = _input.LA(1);
			}
			}
		}
		catch (RecognitionException re) {
			_localctx.exception = re;
			_errHandler.reportError(this, re);
			_errHandler.recover(this, re);
		}
		finally {
			exitRule();
		}
		return _localctx;
	}

	public static class AssemblyStackAssignmentContext extends ParserRuleContext {
		public IdentifierContext identifier() {
			return getRuleContext(IdentifierContext.class,0);
		}
		public AssemblyStackAssignmentContext(ParserRuleContext parent, int invokingState) {
			super(parent, invokingState);
		}
		@Override public int getRuleIndex() { return RULE_assemblyStackAssignment; }
		@Override
		public void enterRule(ParseTreeListener listener) {
			if ( listener instanceof SolidityListener ) ((SolidityListener)listener).enterAssemblyStackAssignment(this);
		}
		@Override
		public void exitRule(ParseTreeListener listener) {
			if ( listener instanceof SolidityListener ) ((SolidityListener)listener).exitAssemblyStackAssignment(this);
		}
		@Override
		public <T> T accept(ParseTreeVisitor<? extends T> visitor) {
			if ( visitor instanceof SolidityVisitor ) return ((SolidityVisitor<? extends T>)visitor).visitAssemblyStackAssignment(this);
			else return visitor.visitChildren(this);
		}
	}

	public final AssemblyStackAssignmentContext assemblyStackAssignment() throws RecognitionException {
		AssemblyStackAssignmentContext _localctx = new AssemblyStackAssignmentContext(_ctx, getState());
		enterRule(_localctx, 142, RULE_assemblyStackAssignment);
		try {
			enterOuterAlt(_localctx, 1);
			{
			setState(875); match(54);
			setState(876); identifier();
			}
		}
		catch (RecognitionException re) {
			_localctx.exception = re;
			_errHandler.reportError(this, re);
			_errHandler.recover(this, re);
		}
		finally {
			exitRule();
		}
		return _localctx;
	}

	public static class LabelDefinitionContext extends ParserRuleContext {
		public IdentifierContext identifier() {
			return getRuleContext(IdentifierContext.class,0);
		}
		public LabelDefinitionContext(ParserRuleContext parent, int invokingState) {
			super(parent, invokingState);
		}
		@Override public int getRuleIndex() { return RULE_labelDefinition; }
		@Override
		public void enterRule(ParseTreeListener listener) {
			if ( listener instanceof SolidityListener ) ((SolidityListener)listener).enterLabelDefinition(this);
		}
		@Override
		public void exitRule(ParseTreeListener listener) {
			if ( listener instanceof SolidityListener ) ((SolidityListener)listener).exitLabelDefinition(this);
		}
		@Override
		public <T> T accept(ParseTreeVisitor<? extends T> visitor) {
			if ( visitor instanceof SolidityVisitor ) return ((SolidityVisitor<? extends T>)visitor).visitLabelDefinition(this);
			else return visitor.visitChildren(this);
		}
	}

	public final LabelDefinitionContext labelDefinition() throws RecognitionException {
		LabelDefinitionContext _localctx = new LabelDefinitionContext(_ctx, getState());
		enterRule(_localctx, 144, RULE_labelDefinition);
		try {
			enterOuterAlt(_localctx, 1);
			{
			setState(878); identifier();
			setState(879); match(72);
			}
		}
		catch (RecognitionException re) {
			_localctx.exception = re;
			_errHandler.reportError(this, re);
			_errHandler.recover(this, re);
		}
		finally {
			exitRule();
		}
		return _localctx;
	}

	public static class AssemblySwitchContext extends ParserRuleContext {
		public AssemblyCaseContext assemblyCase(int i) {
			return getRuleContext(AssemblyCaseContext.class,i);
		}
		public AssemblyExpressionContext assemblyExpression() {
			return getRuleContext(AssemblyExpressionContext.class,0);
		}
		public List<AssemblyCaseContext> assemblyCase() {
			return getRuleContexts(AssemblyCaseContext.class);
		}
		public AssemblySwitchContext(ParserRuleContext parent, int invokingState) {
			super(parent, invokingState);
		}
		@Override public int getRuleIndex() { return RULE_assemblySwitch; }
		@Override
		public void enterRule(ParseTreeListener listener) {
			if ( listener instanceof SolidityListener ) ((SolidityListener)listener).enterAssemblySwitch(this);
		}
		@Override
		public void exitRule(ParseTreeListener listener) {
			if ( listener instanceof SolidityListener ) ((SolidityListener)listener).exitAssemblySwitch(this);
		}
		@Override
		public <T> T accept(ParseTreeVisitor<? extends T> visitor) {
			if ( visitor instanceof SolidityVisitor ) return ((SolidityVisitor<? extends T>)visitor).visitAssemblySwitch(this);
			else return visitor.visitChildren(this);
		}
	}

	public final AssemblySwitchContext assemblySwitch() throws RecognitionException {
		AssemblySwitchContext _localctx = new AssemblySwitchContext(_ctx, getState());
		enterRule(_localctx, 146, RULE_assemblySwitch);
		int _la;
		try {
			enterOuterAlt(_localctx, 1);
			{
			setState(881); match(64);
			setState(882); assemblyExpression();
			setState(886);
			_errHandler.sync(this);
			_la = _input.LA(1);
			while (_la==1 || _la==70) {
				{
				{
				setState(883); assemblyCase();
				}
				}
				setState(888);
				_errHandler.sync(this);
				_la = _input.LA(1);
			}
			}
		}
		catch (RecognitionException re) {
			_localctx.exception = re;
			_errHandler.reportError(this, re);
			_errHandler.recover(this, re);
		}
		finally {
			exitRule();
		}
		return _localctx;
	}

	public static class AssemblyCaseContext extends ParserRuleContext {
		public AssemblyLiteralContext assemblyLiteral() {
			return getRuleContext(AssemblyLiteralContext.class,0);
		}
		public AssemblyBlockContext assemblyBlock() {
			return getRuleContext(AssemblyBlockContext.class,0);
		}
		public AssemblyCaseContext(ParserRuleContext parent, int invokingState) {
			super(parent, invokingState);
		}
		@Override public int getRuleIndex() { return RULE_assemblyCase; }
		@Override
		public void enterRule(ParseTreeListener listener) {
			if ( listener instanceof SolidityListener ) ((SolidityListener)listener).enterAssemblyCase(this);
		}
		@Override
		public void exitRule(ParseTreeListener listener) {
			if ( listener instanceof SolidityListener ) ((SolidityListener)listener).exitAssemblyCase(this);
		}
		@Override
		public <T> T accept(ParseTreeVisitor<? extends T> visitor) {
			if ( visitor instanceof SolidityVisitor ) return ((SolidityVisitor<? extends T>)visitor).visitAssemblyCase(this);
			else return visitor.visitChildren(this);
		}
	}

	public final AssemblyCaseContext assemblyCase() throws RecognitionException {
		AssemblyCaseContext _localctx = new AssemblyCaseContext(_ctx, getState());
		enterRule(_localctx, 148, RULE_assemblyCase);
		try {
			setState(895);
			switch (_input.LA(1)) {
			case 70:
				enterOuterAlt(_localctx, 1);
				{
				setState(889); match(70);
				setState(890); assemblyLiteral();
				setState(891); assemblyBlock();
				}
				break;
			case 1:
				enterOuterAlt(_localctx, 2);
				{
				setState(893); match(1);
				setState(894); assemblyBlock();
				}
				break;
			default:
				throw new NoViableAltException(this);
			}
		}
		catch (RecognitionException re) {
			_localctx.exception = re;
			_errHandler.reportError(this, re);
			_errHandler.recover(this, re);
		}
		finally {
			exitRule();
		}
		return _localctx;
	}

	public static class AssemblyFunctionDefinitionContext extends ParserRuleContext {
		public AssemblyFunctionReturnsContext assemblyFunctionReturns() {
			return getRuleContext(AssemblyFunctionReturnsContext.class,0);
		}
		public AssemblyIdentifierListContext assemblyIdentifierList() {
			return getRuleContext(AssemblyIdentifierListContext.class,0);
		}
		public IdentifierContext identifier() {
			return getRuleContext(IdentifierContext.class,0);
		}
		public AssemblyBlockContext assemblyBlock() {
			return getRuleContext(AssemblyBlockContext.class,0);
		}
		public AssemblyFunctionDefinitionContext(ParserRuleContext parent, int invokingState) {
			super(parent, invokingState);
		}
		@Override public int getRuleIndex() { return RULE_assemblyFunctionDefinition; }
		@Override
		public void enterRule(ParseTreeListener listener) {
			if ( listener instanceof SolidityListener ) ((SolidityListener)listener).enterAssemblyFunctionDefinition(this);
		}
		@Override
		public void exitRule(ParseTreeListener listener) {
			if ( listener instanceof SolidityListener ) ((SolidityListener)listener).exitAssemblyFunctionDefinition(this);
		}
		@Override
		public <T> T accept(ParseTreeVisitor<? extends T> visitor) {
			if ( visitor instanceof SolidityVisitor ) return ((SolidityVisitor<? extends T>)visitor).visitAssemblyFunctionDefinition(this);
			else return visitor.visitChildren(this);
		}
	}

	public final AssemblyFunctionDefinitionContext assemblyFunctionDefinition() throws RecognitionException {
		AssemblyFunctionDefinitionContext _localctx = new AssemblyFunctionDefinitionContext(_ctx, getState());
		enterRule(_localctx, 150, RULE_assemblyFunctionDefinition);
		int _la;
		try {
			enterOuterAlt(_localctx, 1);
			{
			setState(897); match(40);
			setState(898); identifier();
			setState(899); match(25);
			setState(901);
			_la = _input.LA(1);
			if (_la==37 || _la==62 || _la==Identifier) {
				{
				setState(900); assemblyIdentifierList();
				}
			}

			setState(903); match(87);
			setState(905);
			_la = _input.LA(1);
			if (_la==69) {
				{
				setState(904); assemblyFunctionReturns();
				}
			}

			setState(907); assemblyBlock();
			}
		}
		catch (RecognitionException re) {
			_localctx.exception = re;
			_errHandler.reportError(this, re);
			_errHandler.recover(this, re);
		}
		finally {
			exitRule();
		}
		return _localctx;
	}

	public static class AssemblyFunctionReturnsContext extends ParserRuleContext {
		public AssemblyIdentifierListContext assemblyIdentifierList() {
			return getRuleContext(AssemblyIdentifierListContext.class,0);
		}
		public AssemblyFunctionReturnsContext(ParserRuleContext parent, int invokingState) {
			super(parent, invokingState);
		}
		@Override public int getRuleIndex() { return RULE_assemblyFunctionReturns; }
		@Override
		public void enterRule(ParseTreeListener listener) {
			if ( listener instanceof SolidityListener ) ((SolidityListener)listener).enterAssemblyFunctionReturns(this);
		}
		@Override
		public void exitRule(ParseTreeListener listener) {
			if ( listener instanceof SolidityListener ) ((SolidityListener)listener).exitAssemblyFunctionReturns(this);
		}
		@Override
		public <T> T accept(ParseTreeVisitor<? extends T> visitor) {
			if ( visitor instanceof SolidityVisitor ) return ((SolidityVisitor<? extends T>)visitor).visitAssemblyFunctionReturns(this);
			else return visitor.visitChildren(this);
		}
	}

	public final AssemblyFunctionReturnsContext assemblyFunctionReturns() throws RecognitionException {
		AssemblyFunctionReturnsContext _localctx = new AssemblyFunctionReturnsContext(_ctx, getState());
		enterRule(_localctx, 152, RULE_assemblyFunctionReturns);
		try {
			enterOuterAlt(_localctx, 1);
			{
			{
			setState(909); match(69);
			setState(910); assemblyIdentifierList();
			}
			}
		}
		catch (RecognitionException re) {
			_localctx.exception = re;
			_errHandler.reportError(this, re);
			_errHandler.recover(this, re);
		}
		finally {
			exitRule();
		}
		return _localctx;
	}

	public static class AssemblyForContext extends ParserRuleContext {
		public AssemblyExpressionContext assemblyExpression(int i) {
			return getRuleContext(AssemblyExpressionContext.class,i);
		}
		public AssemblyBlockContext assemblyBlock(int i) {
			return getRuleContext(AssemblyBlockContext.class,i);
		}
		public List<AssemblyExpressionContext> assemblyExpression() {
			return getRuleContexts(AssemblyExpressionContext.class);
		}
		public List<AssemblyBlockContext> assemblyBlock() {
			return getRuleContexts(AssemblyBlockContext.class);
		}
		public AssemblyForContext(ParserRuleContext parent, int invokingState) {
			super(parent, invokingState);
		}
		@Override public int getRuleIndex() { return RULE_assemblyFor; }
		@Override
		public void enterRule(ParseTreeListener listener) {
			if ( listener instanceof SolidityListener ) ((SolidityListener)listener).enterAssemblyFor(this);
		}
		@Override
		public void exitRule(ParseTreeListener listener) {
			if ( listener instanceof SolidityListener ) ((SolidityListener)listener).exitAssemblyFor(this);
		}
		@Override
		public <T> T accept(ParseTreeVisitor<? extends T> visitor) {
			if ( visitor instanceof SolidityVisitor ) return ((SolidityVisitor<? extends T>)visitor).visitAssemblyFor(this);
			else return visitor.visitChildren(this);
		}
	}

	public final AssemblyForContext assemblyFor() throws RecognitionException {
		AssemblyForContext _localctx = new AssemblyForContext(_ctx, getState());
		enterRule(_localctx, 154, RULE_assemblyFor);
		try {
			enterOuterAlt(_localctx, 1);
			{
			setState(912); match(19);
			setState(915);
			switch (_input.LA(1)) {
			case 10:
				{
				setState(913); assemblyBlock();
				}
				break;
			case 16:
			case 37:
			case 48:
			case 62:
			case 78:
			case DecimalNumber:
			case HexNumber:
			case HexLiteral:
			case Identifier:
			case StringLiteral:
				{
				setState(914); assemblyExpression();
				}
				break;
			default:
				throw new NoViableAltException(this);
			}
			setState(917); assemblyExpression();
			setState(920);
			switch (_input.LA(1)) {
			case 10:
				{
				setState(918); assemblyBlock();
				}
				break;
			case 16:
			case 37:
			case 48:
			case 62:
			case 78:
			case DecimalNumber:
			case HexNumber:
			case HexLiteral:
			case Identifier:
			case StringLiteral:
				{
				setState(919); assemblyExpression();
				}
				break;
			default:
				throw new NoViableAltException(this);
			}
			setState(922); assemblyBlock();
			}
		}
		catch (RecognitionException re) {
			_localctx.exception = re;
			_errHandler.reportError(this, re);
			_errHandler.recover(this, re);
		}
		finally {
			exitRule();
		}
		return _localctx;
	}

	public static class AssemblyIfContext extends ParserRuleContext {
		public AssemblyExpressionContext assemblyExpression() {
			return getRuleContext(AssemblyExpressionContext.class,0);
		}
		public AssemblyBlockContext assemblyBlock() {
			return getRuleContext(AssemblyBlockContext.class,0);
		}
		public AssemblyIfContext(ParserRuleContext parent, int invokingState) {
			super(parent, invokingState);
		}
		@Override public int getRuleIndex() { return RULE_assemblyIf; }
		@Override
		public void enterRule(ParseTreeListener listener) {
			if ( listener instanceof SolidityListener ) ((SolidityListener)listener).enterAssemblyIf(this);
		}
		@Override
		public void exitRule(ParseTreeListener listener) {
			if ( listener instanceof SolidityListener ) ((SolidityListener)listener).exitAssemblyIf(this);
		}
		@Override
		public <T> T accept(ParseTreeVisitor<? extends T> visitor) {
			if ( visitor instanceof SolidityVisitor ) return ((SolidityVisitor<? extends T>)visitor).visitAssemblyIf(this);
			else return visitor.visitChildren(this);
		}
	}

	public final AssemblyIfContext assemblyIf() throws RecognitionException {
		AssemblyIfContext _localctx = new AssemblyIfContext(_ctx, getState());
		enterRule(_localctx, 156, RULE_assemblyIf);
		try {
			enterOuterAlt(_localctx, 1);
			{
			setState(924); match(56);
			setState(925); assemblyExpression();
			setState(926); assemblyBlock();
			}
		}
		catch (RecognitionException re) {
			_localctx.exception = re;
			_errHandler.reportError(this, re);
			_errHandler.recover(this, re);
		}
		finally {
			exitRule();
		}
		return _localctx;
	}

	public static class AssemblyLiteralContext extends ParserRuleContext {
		public TerminalNode HexNumber() { return getToken(SolidityParser.HexNumber, 0); }
		public TerminalNode HexLiteral() { return getToken(SolidityParser.HexLiteral, 0); }
		public TerminalNode StringLiteral() { return getToken(SolidityParser.StringLiteral, 0); }
		public TerminalNode DecimalNumber() { return getToken(SolidityParser.DecimalNumber, 0); }
		public AssemblyLiteralContext(ParserRuleContext parent, int invokingState) {
			super(parent, invokingState);
		}
		@Override public int getRuleIndex() { return RULE_assemblyLiteral; }
		@Override
		public void enterRule(ParseTreeListener listener) {
			if ( listener instanceof SolidityListener ) ((SolidityListener)listener).enterAssemblyLiteral(this);
		}
		@Override
		public void exitRule(ParseTreeListener listener) {
			if ( listener instanceof SolidityListener ) ((SolidityListener)listener).exitAssemblyLiteral(this);
		}
		@Override
		public <T> T accept(ParseTreeVisitor<? extends T> visitor) {
			if ( visitor instanceof SolidityVisitor ) return ((SolidityVisitor<? extends T>)visitor).visitAssemblyLiteral(this);
			else return visitor.visitChildren(this);
		}
	}

	public final AssemblyLiteralContext assemblyLiteral() throws RecognitionException {
		AssemblyLiteralContext _localctx = new AssemblyLiteralContext(_ctx, getState());
		enterRule(_localctx, 158, RULE_assemblyLiteral);
		int _la;
		try {
			enterOuterAlt(_localctx, 1);
			{
			setState(928);
			_la = _input.LA(1);
			if ( !(((((_la - 100)) & ~0x3f) == 0 && ((1L << (_la - 100)) & ((1L << (DecimalNumber - 100)) | (1L << (HexNumber - 100)) | (1L << (HexLiteral - 100)) | (1L << (StringLiteral - 100)))) != 0)) ) {
			_errHandler.recoverInline(this);
			}
			consume();
			}
		}
		catch (RecognitionException re) {
			_localctx.exception = re;
			_errHandler.reportError(this, re);
			_errHandler.recover(this, re);
		}
		finally {
			exitRule();
		}
		return _localctx;
	}

	public static class SubAssemblyContext extends ParserRuleContext {
		public IdentifierContext identifier() {
			return getRuleContext(IdentifierContext.class,0);
		}
		public AssemblyBlockContext assemblyBlock() {
			return getRuleContext(AssemblyBlockContext.class,0);
		}
		public SubAssemblyContext(ParserRuleContext parent, int invokingState) {
			super(parent, invokingState);
		}
		@Override public int getRuleIndex() { return RULE_subAssembly; }
		@Override
		public void enterRule(ParseTreeListener listener) {
			if ( listener instanceof SolidityListener ) ((SolidityListener)listener).enterSubAssembly(this);
		}
		@Override
		public void exitRule(ParseTreeListener listener) {
			if ( listener instanceof SolidityListener ) ((SolidityListener)listener).exitSubAssembly(this);
		}
		@Override
		public <T> T accept(ParseTreeVisitor<? extends T> visitor) {
			if ( visitor instanceof SolidityVisitor ) return ((SolidityVisitor<? extends T>)visitor).visitSubAssembly(this);
			else return visitor.visitChildren(this);
		}
	}

	public final SubAssemblyContext subAssembly() throws RecognitionException {
		SubAssemblyContext _localctx = new SubAssemblyContext(_ctx, getState());
		enterRule(_localctx, 160, RULE_subAssembly);
		try {
			enterOuterAlt(_localctx, 1);
			{
			setState(930); match(88);
			setState(931); identifier();
			setState(932); assemblyBlock();
			}
		}
		catch (RecognitionException re) {
			_localctx.exception = re;
			_errHandler.reportError(this, re);
			_errHandler.recover(this, re);
		}
		finally {
			exitRule();
		}
		return _localctx;
	}

	public static class TupleExpressionContext extends ParserRuleContext {
		public ExpressionContext expression(int i) {
			return getRuleContext(ExpressionContext.class,i);
		}
		public List<ExpressionContext> expression() {
			return getRuleContexts(ExpressionContext.class);
		}
		public TupleExpressionContext(ParserRuleContext parent, int invokingState) {
			super(parent, invokingState);
		}
		@Override public int getRuleIndex() { return RULE_tupleExpression; }
		@Override
		public void enterRule(ParseTreeListener listener) {
			if ( listener instanceof SolidityListener ) ((SolidityListener)listener).enterTupleExpression(this);
		}
		@Override
		public void exitRule(ParseTreeListener listener) {
			if ( listener instanceof SolidityListener ) ((SolidityListener)listener).exitTupleExpression(this);
		}
		@Override
		public <T> T accept(ParseTreeVisitor<? extends T> visitor) {
			if ( visitor instanceof SolidityVisitor ) return ((SolidityVisitor<? extends T>)visitor).visitTupleExpression(this);
			else return visitor.visitChildren(this);
		}
	}

	public final TupleExpressionContext tupleExpression() throws RecognitionException {
		TupleExpressionContext _localctx = new TupleExpressionContext(_ctx, getState());
		enterRule(_localctx, 162, RULE_tupleExpression);
		int _la;
		try {
			setState(960);
			switch (_input.LA(1)) {
			case 25:
				enterOuterAlt(_localctx, 1);
				{
				setState(934); match(25);
				{
				setState(936);
				_la = _input.LA(1);
				if ((((_la) & ~0x3f) == 0 && ((1L << _la) & ((1L << 6) | (1L << 16) | (1L << 21) | (1L << 25) | (1L << 29) | (1L << 31) | (1L << 33) | (1L << 36) | (1L << 37) | (1L << 41) | (1L << 62))) != 0) || ((((_la - 73)) & ~0x3f) == 0 && ((1L << (_la - 73)) & ((1L << (73 - 73)) | (1L << (77 - 73)) | (1L << (78 - 73)) | (1L << (79 - 73)) | (1L << (81 - 73)) | (1L << (83 - 73)) | (1L << (89 - 73)) | (1L << (Int - 73)) | (1L << (Uint - 73)) | (1L << (Byte - 73)) | (1L << (Fixed - 73)) | (1L << (Ufixed - 73)) | (1L << (BooleanLiteral - 73)) | (1L << (DecimalNumber - 73)) | (1L << (HexNumber - 73)) | (1L << (HexLiteral - 73)) | (1L << (TypeKeyword - 73)) | (1L << (Identifier - 73)) | (1L << (StringLiteral - 73)))) != 0)) {
					{
					setState(935); expression(0);
					}
				}

				setState(944);
				_errHandler.sync(this);
				_la = _input.LA(1);
				while (_la==27) {
					{
					{
					setState(938); match(27);
					setState(940);
					_la = _input.LA(1);
					if ((((_la) & ~0x3f) == 0 && ((1L << _la) & ((1L << 6) | (1L << 16) | (1L << 21) | (1L << 25) | (1L << 29) | (1L << 31) | (1L << 33) | (1L << 36) | (1L << 37) | (1L << 41) | (1L << 62))) != 0) || ((((_la - 73)) & ~0x3f) == 0 && ((1L << (_la - 73)) & ((1L << (73 - 73)) | (1L << (77 - 73)) | (1L << (78 - 73)) | (1L << (79 - 73)) | (1L << (81 - 73)) | (1L << (83 - 73)) | (1L << (89 - 73)) | (1L << (Int - 73)) | (1L << (Uint - 73)) | (1L << (Byte - 73)) | (1L << (Fixed - 73)) | (1L << (Ufixed - 73)) | (1L << (BooleanLiteral - 73)) | (1L << (DecimalNumber - 73)) | (1L << (HexNumber - 73)) | (1L << (HexLiteral - 73)) | (1L << (TypeKeyword - 73)) | (1L << (Identifier - 73)) | (1L << (StringLiteral - 73)))) != 0)) {
						{
						setState(939); expression(0);
						}
					}

					}
					}
					setState(946);
					_errHandler.sync(this);
					_la = _input.LA(1);
				}
				}
				setState(947); match(87);
				}
				break;
			case 73:
				enterOuterAlt(_localctx, 2);
				{
				setState(948); match(73);
				setState(957);
				_la = _input.LA(1);
				if ((((_la) & ~0x3f) == 0 && ((1L << _la) & ((1L << 6) | (1L << 16) | (1L << 21) | (1L << 25) | (1L << 29) | (1L << 31) | (1L << 33) | (1L << 36) | (1L << 37) | (1L << 41) | (1L << 62))) != 0) || ((((_la - 73)) & ~0x3f) == 0 && ((1L << (_la - 73)) & ((1L << (73 - 73)) | (1L << (77 - 73)) | (1L << (78 - 73)) | (1L << (79 - 73)) | (1L << (81 - 73)) | (1L << (83 - 73)) | (1L << (89 - 73)) | (1L << (Int - 73)) | (1L << (Uint - 73)) | (1L << (Byte - 73)) | (1L << (Fixed - 73)) | (1L << (Ufixed - 73)) | (1L << (BooleanLiteral - 73)) | (1L << (DecimalNumber - 73)) | (1L << (HexNumber - 73)) | (1L << (HexLiteral - 73)) | (1L << (TypeKeyword - 73)) | (1L << (Identifier - 73)) | (1L << (StringLiteral - 73)))) != 0)) {
					{
					setState(949); expression(0);
					setState(954);
					_errHandler.sync(this);
					_la = _input.LA(1);
					while (_la==27) {
						{
						{
						setState(950); match(27);
						setState(951); expression(0);
						}
						}
						setState(956);
						_errHandler.sync(this);
						_la = _input.LA(1);
					}
					}
				}

				setState(959); match(35);
				}
				break;
			default:
				throw new NoViableAltException(this);
			}
		}
		catch (RecognitionException re) {
			_localctx.exception = re;
			_errHandler.reportError(this, re);
			_errHandler.recover(this, re);
		}
		finally {
			exitRule();
		}
		return _localctx;
	}

	public static class TypeNameExpressionContext extends ParserRuleContext {
		public UserDefinedTypeNameContext userDefinedTypeName() {
			return getRuleContext(UserDefinedTypeNameContext.class,0);
		}
		public ElementaryTypeNameContext elementaryTypeName() {
			return getRuleContext(ElementaryTypeNameContext.class,0);
		}
		public TypeNameExpressionContext(ParserRuleContext parent, int invokingState) {
			super(parent, invokingState);
		}
		@Override public int getRuleIndex() { return RULE_typeNameExpression; }
		@Override
		public void enterRule(ParseTreeListener listener) {
			if ( listener instanceof SolidityListener ) ((SolidityListener)listener).enterTypeNameExpression(this);
		}
		@Override
		public void exitRule(ParseTreeListener listener) {
			if ( listener instanceof SolidityListener ) ((SolidityListener)listener).exitTypeNameExpression(this);
		}
		@Override
		public <T> T accept(ParseTreeVisitor<? extends T> visitor) {
			if ( visitor instanceof SolidityVisitor ) return ((SolidityVisitor<? extends T>)visitor).visitTypeNameExpression(this);
			else return visitor.visitChildren(this);
		}
	}

	public final TypeNameExpressionContext typeNameExpression() throws RecognitionException {
		TypeNameExpressionContext _localctx = new TypeNameExpressionContext(_ctx, getState());
		enterRule(_localctx, 164, RULE_typeNameExpression);
		try {
			setState(964);
			switch (_input.LA(1)) {
			case 16:
			case 31:
			case 78:
			case 79:
			case 83:
			case Int:
			case Uint:
			case Byte:
			case Fixed:
			case Ufixed:
				enterOuterAlt(_localctx, 1);
				{
				setState(962); elementaryTypeName();
				}
				break;
			case 37:
			case 62:
			case Identifier:
				enterOuterAlt(_localctx, 2);
				{
				setState(963); userDefinedTypeName();
				}
				break;
			default:
				throw new NoViableAltException(this);
			}
		}
		catch (RecognitionException re) {
			_localctx.exception = re;
			_errHandler.reportError(this, re);
			_errHandler.recover(this, re);
		}
		finally {
			exitRule();
		}
		return _localctx;
	}

	public static class NumberLiteralContext extends ParserRuleContext {
		public TerminalNode HexNumber() { return getToken(SolidityParser.HexNumber, 0); }
		public TerminalNode DecimalNumber() { return getToken(SolidityParser.DecimalNumber, 0); }
		public TerminalNode NumberUnit() { return getToken(SolidityParser.NumberUnit, 0); }
		public NumberLiteralContext(ParserRuleContext parent, int invokingState) {
			super(parent, invokingState);
		}
		@Override public int getRuleIndex() { return RULE_numberLiteral; }
		@Override
		public void enterRule(ParseTreeListener listener) {
			if ( listener instanceof SolidityListener ) ((SolidityListener)listener).enterNumberLiteral(this);
		}
		@Override
		public void exitRule(ParseTreeListener listener) {
			if ( listener instanceof SolidityListener ) ((SolidityListener)listener).exitNumberLiteral(this);
		}
		@Override
		public <T> T accept(ParseTreeVisitor<? extends T> visitor) {
			if ( visitor instanceof SolidityVisitor ) return ((SolidityVisitor<? extends T>)visitor).visitNumberLiteral(this);
			else return visitor.visitChildren(this);
		}
	}

	public final NumberLiteralContext numberLiteral() throws RecognitionException {
		NumberLiteralContext _localctx = new NumberLiteralContext(_ctx, getState());
		enterRule(_localctx, 166, RULE_numberLiteral);
		int _la;
		try {
			enterOuterAlt(_localctx, 1);
			{
			setState(966);
			_la = _input.LA(1);
			if ( !(_la==DecimalNumber || _la==HexNumber) ) {
			_errHandler.recoverInline(this);
			}
			consume();
			setState(968);
			switch ( getInterpreter().adaptivePredict(_input,107,_ctx) ) {
			case 1:
				{
				setState(967); match(NumberUnit);
				}
				break;
			}
			}
		}
		catch (RecognitionException re) {
			_localctx.exception = re;
			_errHandler.reportError(this, re);
			_errHandler.recover(this, re);
		}
		finally {
			exitRule();
		}
		return _localctx;
	}

	public static class IdentifierContext extends ParserRuleContext {
		public TerminalNode Identifier() { return getToken(SolidityParser.Identifier, 0); }
		public IdentifierContext(ParserRuleContext parent, int invokingState) {
			super(parent, invokingState);
		}
		@Override public int getRuleIndex() { return RULE_identifier; }
		@Override
		public void enterRule(ParseTreeListener listener) {
			if ( listener instanceof SolidityListener ) ((SolidityListener)listener).enterIdentifier(this);
		}
		@Override
		public void exitRule(ParseTreeListener listener) {
			if ( listener instanceof SolidityListener ) ((SolidityListener)listener).exitIdentifier(this);
		}
		@Override
		public <T> T accept(ParseTreeVisitor<? extends T> visitor) {
			if ( visitor instanceof SolidityVisitor ) return ((SolidityVisitor<? extends T>)visitor).visitIdentifier(this);
			else return visitor.visitChildren(this);
		}
	}

	public final IdentifierContext identifier() throws RecognitionException {
		IdentifierContext _localctx = new IdentifierContext(_ctx, getState());
		enterRule(_localctx, 168, RULE_identifier);
		int _la;
		try {
			enterOuterAlt(_localctx, 1);
			{
			setState(970);
			_la = _input.LA(1);
			if ( !(_la==37 || _la==62 || _la==Identifier) ) {
			_errHandler.recoverInline(this);
			}
			consume();
			}
		}
		catch (RecognitionException re) {
			_localctx.exception = re;
			_errHandler.reportError(this, re);
			_errHandler.recover(this, re);
		}
		finally {
			exitRule();
		}
		return _localctx;
	}

	public boolean sempred(RuleContext _localctx, int ruleIndex, int predIndex) {
		switch (ruleIndex) {
		case 32: return typeName_sempred((TypeNameContext)_localctx, predIndex);

		case 56: return expression_sempred((ExpressionContext)_localctx, predIndex);
		}
		return true;
	}
	private boolean expression_sempred(ExpressionContext _localctx, int predIndex) {
		switch (predIndex) {
		case 1: return precpred(_ctx, 14);

		case 2: return precpred(_ctx, 13);

		case 3: return precpred(_ctx, 12);

		case 4: return precpred(_ctx, 11);

		case 5: return precpred(_ctx, 10);

		case 6: return precpred(_ctx, 9);

		case 7: return precpred(_ctx, 8);

		case 8: return precpred(_ctx, 7);

		case 9: return precpred(_ctx, 6);

		case 10: return precpred(_ctx, 5);

		case 11: return precpred(_ctx, 4);

		case 12: return precpred(_ctx, 3);

		case 13: return precpred(_ctx, 2);

		case 14: return precpred(_ctx, 25);

		case 15: return precpred(_ctx, 23);

		case 16: return precpred(_ctx, 22);

		case 17: return precpred(_ctx, 21);
		}
		return true;
	}
	private boolean typeName_sempred(TypeNameContext _localctx, int predIndex) {
		switch (predIndex) {
		case 0: return precpred(_ctx, 3);
		}
		return true;
	}

	public static final String _serializedATN =
		"\3\u0430\ud6d1\u8206\uad2d\u4417\uaef1\u8d80\uaadd\3|\u03cf\4\2\t\2\4"+
		"\3\t\3\4\4\t\4\4\5\t\5\4\6\t\6\4\7\t\7\4\b\t\b\4\t\t\t\4\n\t\n\4\13\t"+
		"\13\4\f\t\f\4\r\t\r\4\16\t\16\4\17\t\17\4\20\t\20\4\21\t\21\4\22\t\22"+
		"\4\23\t\23\4\24\t\24\4\25\t\25\4\26\t\26\4\27\t\27\4\30\t\30\4\31\t\31"+
		"\4\32\t\32\4\33\t\33\4\34\t\34\4\35\t\35\4\36\t\36\4\37\t\37\4 \t \4!"+
		"\t!\4\"\t\"\4#\t#\4$\t$\4%\t%\4&\t&\4\'\t\'\4(\t(\4)\t)\4*\t*\4+\t+\4"+
		",\t,\4-\t-\4.\t.\4/\t/\4\60\t\60\4\61\t\61\4\62\t\62\4\63\t\63\4\64\t"+
		"\64\4\65\t\65\4\66\t\66\4\67\t\67\48\t8\49\t9\4:\t:\4;\t;\4<\t<\4=\t="+
		"\4>\t>\4?\t?\4@\t@\4A\tA\4B\tB\4C\tC\4D\tD\4E\tE\4F\tF\4G\tG\4H\tH\4I"+
		"\tI\4J\tJ\4K\tK\4L\tL\4M\tM\4N\tN\4O\tO\4P\tP\4Q\tQ\4R\tR\4S\tS\4T\tT"+
		"\4U\tU\4V\tV\3\2\3\2\3\2\7\2\u00b0\n\2\f\2\16\2\u00b3\13\2\3\2\3\2\3\3"+
		"\3\3\3\3\3\3\3\3\3\4\3\4\3\5\3\5\5\5\u00c0\n\5\3\6\3\6\5\6\u00c4\n\6\3"+
		"\7\3\7\3\b\5\b\u00c9\n\b\3\b\3\b\3\t\3\t\3\t\5\t\u00d0\n\t\3\n\3\n\3\n"+
		"\3\n\5\n\u00d6\n\n\3\n\3\n\3\n\3\n\5\n\u00dc\n\n\3\n\3\n\5\n\u00e0\n\n"+
		"\3\n\3\n\3\n\3\n\3\n\3\n\3\n\3\n\7\n\u00ea\n\n\f\n\16\n\u00ed\13\n\3\n"+
		"\3\n\3\n\3\n\3\n\5\n\u00f4\n\n\3\13\3\13\3\f\5\f\u00f9\n\f\3\f\3\f\3\f"+
		"\3\f\3\f\3\f\7\f\u0101\n\f\f\f\16\f\u0104\13\f\5\f\u0106\n\f\3\f\3\f\7"+
		"\f\u010a\n\f\f\f\16\f\u010d\13\f\3\f\3\f\3\r\3\r\3\r\5\r\u0114\n\r\3\r"+
		"\5\r\u0117\n\r\3\16\3\16\3\16\3\16\3\16\3\16\3\16\3\16\5\16\u0121\n\16"+
		"\3\17\3\17\7\17\u0125\n\17\f\17\16\17\u0128\13\17\3\17\3\17\3\17\5\17"+
		"\u012d\n\17\3\17\3\17\3\20\3\20\3\20\3\20\3\20\5\20\u0136\n\20\3\20\3"+
		"\20\3\21\3\21\3\21\3\21\3\21\3\21\3\21\3\21\7\21\u0142\n\21\f\21\16\21"+
		"\u0145\13\21\5\21\u0147\n\21\3\21\3\21\3\22\3\22\3\22\3\22\3\22\3\23\3"+
		"\23\3\23\5\23\u0153\n\23\3\23\3\23\3\24\3\24\3\24\5\24\u015a\n\24\3\24"+
		"\5\24\u015d\n\24\3\25\5\25\u0160\n\25\3\25\3\25\5\25\u0164\n\25\3\25\3"+
		"\25\3\25\5\25\u0169\n\25\3\25\3\25\5\25\u016d\n\25\3\26\3\26\3\26\3\27"+
		"\3\27\3\27\3\27\3\27\3\27\7\27\u0178\n\27\f\27\16\27\u017b\13\27\3\30"+
		"\5\30\u017e\n\30\3\30\3\30\3\30\3\30\5\30\u0184\n\30\3\30\3\30\3\31\3"+
		"\31\3\32\3\32\3\32\3\32\5\32\u018e\n\32\3\32\3\32\7\32\u0192\n\32\f\32"+
		"\16\32\u0195\13\32\3\32\3\32\3\33\3\33\3\33\3\33\7\33\u019d\n\33\f\33"+
		"\16\33\u01a0\13\33\5\33\u01a2\n\33\3\33\3\33\3\34\3\34\5\34\u01a8\n\34"+
		"\3\34\5\34\u01ab\n\34\3\35\3\35\3\35\3\35\7\35\u01b1\n\35\f\35\16\35\u01b4"+
		"\13\35\5\35\u01b6\n\35\3\35\3\35\3\36\3\36\5\36\u01bc\n\36\3\36\5\36\u01bf"+
		"\n\36\3\37\3\37\3\37\3\37\7\37\u01c5\n\37\f\37\16\37\u01c8\13\37\5\37"+
		"\u01ca\n\37\3\37\3\37\3 \3 \5 \u01d0\n \3!\3!\5!\u01d4\n!\3!\3!\3\"\3"+
		"\"\3\"\3\"\3\"\3\"\3\"\5\"\u01df\n\"\3\"\3\"\3\"\5\"\u01e4\n\"\3\"\7\""+
		"\u01e7\n\"\f\"\16\"\u01ea\13\"\3#\3#\3#\7#\u01ef\n#\f#\16#\u01f2\13#\3"+
		"$\3$\3$\3$\3$\3$\3$\3%\3%\3%\3%\3%\7%\u0200\n%\f%\16%\u0203\13%\3%\3%"+
		"\5%\u0207\n%\3&\3&\3\'\3\'\3(\3(\7(\u020f\n(\f(\16(\u0212\13(\3(\3(\3"+
		")\3)\3)\3)\3)\3)\3)\3)\3)\3)\3)\3)\5)\u0222\n)\3*\3*\3*\3+\3+\3+\3+\3"+
		"+\3+\3+\5+\u022e\n+\3,\3,\3,\3,\3,\3,\3-\3-\5-\u0238\n-\3.\3.\3.\3.\5"+
		".\u023e\n.\3.\3.\5.\u0242\n.\3.\5.\u0245\n.\3.\3.\3.\3/\3/\5/\u024c\n"+
		"/\3/\3/\3\60\3\60\3\60\3\60\3\60\3\60\3\60\3\60\3\61\3\61\3\61\3\62\3"+
		"\62\3\62\3\63\3\63\5\63\u0260\n\63\3\63\3\63\3\64\3\64\3\64\3\65\3\65"+
		"\3\65\3\65\3\66\3\66\3\66\3\66\3\66\3\66\3\66\5\66\u0272\n\66\3\66\3\66"+
		"\5\66\u0276\n\66\3\66\3\66\3\67\5\67\u027b\n\67\3\67\3\67\5\67\u027f\n"+
		"\67\7\67\u0281\n\67\f\67\16\67\u0284\13\67\38\38\58\u0288\n8\38\78\u028b"+
		"\n8\f8\168\u028e\138\38\58\u0291\n8\38\38\39\39\3:\3:\3:\3:\3:\3:\3:\3"+
		":\3:\3:\3:\3:\3:\3:\3:\3:\3:\3:\5:\u02a9\n:\3:\3:\3:\3:\3:\3:\3:\3:\3"+
		":\3:\3:\3:\3:\3:\3:\3:\3:\3:\3:\3:\3:\3:\3:\3:\3:\3:\3:\3:\3:\3:\3:\3"+
		":\3:\3:\3:\3:\3:\3:\3:\3:\3:\3:\3:\3:\3:\3:\3:\3:\3:\3:\3:\3:\3:\3:\3"+
		":\3:\3:\7:\u02e4\n:\f:\16:\u02e7\13:\3;\3;\3;\3;\3;\3;\3;\5;\u02f0\n;"+
		"\3;\3;\3;\3;\3;\5;\u02f7\n;\5;\u02f9\n;\3<\3<\3<\7<\u02fe\n<\f<\16<\u0301"+
		"\13<\3=\3=\3=\7=\u0306\n=\f=\16=\u0309\13=\3=\5=\u030c\n=\3>\3>\3>\3>"+
		"\3?\3?\5?\u0314\n?\3?\3?\5?\u0318\n?\5?\u031a\n?\3@\3@\3@\3@\3@\3A\3A"+
		"\7A\u0323\nA\fA\16A\u0326\13A\3A\3A\3B\3B\3B\3B\3B\3B\3B\3B\3B\3B\3B\3"+
		"B\3B\3B\3B\3B\3B\5B\u033b\nB\3C\3C\5C\u033f\nC\3D\3D\3D\3D\5D\u0345\n"+
		"D\3D\3D\5D\u0349\nD\3D\3D\7D\u034d\nD\fD\16D\u0350\13D\3D\5D\u0353\nD"+
		"\3E\3E\3E\3E\5E\u0359\nE\3F\3F\3F\3F\3G\3G\3G\3G\3G\5G\u0364\nG\3H\3H"+
		"\3H\7H\u0369\nH\fH\16H\u036c\13H\3I\3I\3I\3J\3J\3J\3K\3K\3K\7K\u0377\n"+
		"K\fK\16K\u037a\13K\3L\3L\3L\3L\3L\3L\5L\u0382\nL\3M\3M\3M\3M\5M\u0388"+
		"\nM\3M\3M\5M\u038c\nM\3M\3M\3N\3N\3N\3O\3O\3O\5O\u0396\nO\3O\3O\3O\5O"+
		"\u039b\nO\3O\3O\3P\3P\3P\3P\3Q\3Q\3R\3R\3R\3R\3S\3S\5S\u03ab\nS\3S\3S"+
		"\5S\u03af\nS\7S\u03b1\nS\fS\16S\u03b4\13S\3S\3S\3S\3S\3S\7S\u03bb\nS\f"+
		"S\16S\u03be\13S\5S\u03c0\nS\3S\5S\u03c3\nS\3T\3T\5T\u03c7\nT\3U\3U\5U"+
		"\u03cb\nU\3V\3V\3V\2\4BrW\2\4\6\b\n\f\16\20\22\24\26\30\32\34\36 \"$&"+
		"(*,.\60\62\64\668:<>@BDFHJLNPRTVXZ\\^`bdfhjlnprtvxz|~\u0080\u0082\u0084"+
		"\u0086\u0088\u008a\u008c\u008e\u0090\u0092\u0094\u0096\u0098\u009a\u009c"+
		"\u009e\u00a0\u00a2\u00a4\u00a6\u00a8\u00aa\2\24\t\2\23\23\26\26\"\"$$"+
		"&&??RR\3\2]^\4\2\6\7LL\5\2mmqqst\5\2\t\t  \'\'\6\2mmrruuww\7\2\22\22!"+
		"!PQUU_c\4\2##OO\4\2++[[\4\2\27\27\37\37\5\2//DDVV\4\2\20\20\67\67\6\2"+
		"\"\"$$??RR\4\2\n\nMM\13\2\4\5\16\16\23\24\30\30\34\34\36\36..\61\61\64"+
		"\64\5\2fgiiyy\3\2fg\5\2\'\'@@xx\u042c\2\u00b1\3\2\2\2\4\u00b6\3\2\2\2"+
		"\6\u00bb\3\2\2\2\b\u00bf\3\2\2\2\n\u00c1\3\2\2\2\f\u00c5\3\2\2\2\16\u00c8"+
		"\3\2\2\2\20\u00cc\3\2\2\2\22\u00f3\3\2\2\2\24\u00f5\3\2\2\2\26\u00f8\3"+
		"\2\2\2\30\u0110\3\2\2\2\32\u0120\3\2\2\2\34\u0122\3\2\2\2\36\u0130\3\2"+
		"\2\2 \u0139\3\2\2\2\"\u014a\3\2\2\2$\u014f\3\2\2\2&\u0156\3\2\2\2(\u015f"+
		"\3\2\2\2*\u016e\3\2\2\2,\u0179\3\2\2\2.\u017d\3\2\2\2\60\u0187\3\2\2\2"+
		"\62\u0189\3\2\2\2\64\u0198\3\2\2\2\66\u01a5\3\2\2\28\u01ac\3\2\2\2:\u01b9"+
		"\3\2\2\2<\u01c0\3\2\2\2>\u01cd\3\2\2\2@\u01d1\3\2\2\2B\u01de\3\2\2\2D"+
		"\u01eb\3\2\2\2F\u01f3\3\2\2\2H\u01fa\3\2\2\2J\u0208\3\2\2\2L\u020a\3\2"+
		"\2\2N\u020c\3\2\2\2P\u0221\3\2\2\2R\u0223\3\2\2\2T\u0226\3\2\2\2V\u022f"+
		"\3\2\2\2X\u0237\3\2\2\2Z\u0239\3\2\2\2\\\u0249\3\2\2\2^\u024f\3\2\2\2"+
		"`\u0257\3\2\2\2b\u025a\3\2\2\2d\u025d\3\2\2\2f\u0263\3\2\2\2h\u0266\3"+
		"\2\2\2j\u0271\3\2\2\2l\u027a\3\2\2\2n\u0285\3\2\2\2p\u0294\3\2\2\2r\u02a8"+
		"\3\2\2\2t\u02f8\3\2\2\2v\u02fa\3\2\2\2x\u0302\3\2\2\2z\u030d\3\2\2\2|"+
		"\u0319\3\2\2\2~\u031b\3\2\2\2\u0080\u0320\3\2\2\2\u0082\u033a\3\2\2\2"+
		"\u0084\u033e\3\2\2\2\u0086\u0344\3\2\2\2\u0088\u0354\3\2\2\2\u008a\u035a"+
		"\3\2\2\2\u008c\u0363\3\2\2\2\u008e\u0365\3\2\2\2\u0090\u036d\3\2\2\2\u0092"+
		"\u0370\3\2\2\2\u0094\u0373\3\2\2\2\u0096\u0381\3\2\2\2\u0098\u0383\3\2"+
		"\2\2\u009a\u038f\3\2\2\2\u009c\u0392\3\2\2\2\u009e\u039e\3\2\2\2\u00a0"+
		"\u03a2\3\2\2\2\u00a2\u03a4\3\2\2\2\u00a4\u03c2\3\2\2\2\u00a6\u03c6\3\2"+
		"\2\2\u00a8\u03c8\3\2\2\2\u00aa\u03cc\3\2\2\2\u00ac\u00b0\5\4\3\2\u00ad"+
		"\u00b0\5\22\n\2\u00ae\u00b0\5\26\f\2\u00af\u00ac\3\2\2\2\u00af\u00ad\3"+
		"\2\2\2\u00af\u00ae\3\2\2\2\u00b0\u00b3\3\2\2\2\u00b1\u00af\3\2\2\2\u00b1"+
		"\u00b2\3\2\2\2\u00b2\u00b4\3\2\2\2\u00b3\u00b1\3\2\2\2\u00b4\u00b5\7\2"+
		"\2\3\u00b5\3\3\2\2\2\u00b6\u00b7\7\r\2\2\u00b7\u00b8\5\6\4\2\u00b8\u00b9"+
		"\5\b\5\2\u00b9\u00ba\7\66\2\2\u00ba\5\3\2\2\2\u00bb\u00bc\5\u00aaV\2\u00bc"+
		"\7\3\2\2\2\u00bd\u00c0\5\n\6\2\u00be\u00c0\5r:\2\u00bf\u00bd\3\2\2\2\u00bf"+
		"\u00be\3\2\2\2\u00c0\t\3\2\2\2\u00c1\u00c3\5\16\b\2\u00c2\u00c4\5\16\b"+
		"\2\u00c3\u00c2\3\2\2\2\u00c3\u00c4\3\2\2\2\u00c4\13\3\2\2\2\u00c5\u00c6"+
		"\t\2\2\2\u00c6\r\3\2\2\2\u00c7\u00c9\5\f\7\2\u00c8\u00c7\3\2\2\2\u00c8"+
		"\u00c9\3\2\2\2\u00c9\u00ca\3\2\2\2\u00ca\u00cb\7d\2\2\u00cb\17\3\2\2\2"+
		"\u00cc\u00cf\5\u00aaV\2\u00cd\u00ce\7\60\2\2\u00ce\u00d0\5\u00aaV\2\u00cf"+
		"\u00cd\3\2\2\2\u00cf\u00d0\3\2\2\2\u00d0\21\3\2\2\2\u00d1\u00d2\7\\\2"+
		"\2\u00d2\u00d5\7y\2\2\u00d3\u00d4\7\60\2\2\u00d4\u00d6\5\u00aaV\2\u00d5"+
		"\u00d3\3\2\2\2\u00d5\u00d6\3\2\2\2\u00d6\u00d7\3\2\2\2\u00d7\u00f4\7\66"+
		"\2\2\u00d8\u00db\7\\\2\2\u00d9\u00dc\7D\2\2\u00da\u00dc\5\u00aaV\2\u00db"+
		"\u00d9\3\2\2\2\u00db\u00da\3\2\2\2\u00dc\u00df\3\2\2\2\u00dd\u00de\7\60"+
		"\2\2\u00de\u00e0\5\u00aaV\2\u00df\u00dd\3\2\2\2\u00df\u00e0\3\2\2\2\u00e0"+
		"\u00e1\3\2\2\2\u00e1\u00e2\7@\2\2\u00e2\u00e3\7y\2\2\u00e3\u00f4\7\66"+
		"\2\2\u00e4\u00e5\7\\\2\2\u00e5\u00e6\7\f\2\2\u00e6\u00eb\5\20\t\2\u00e7"+
		"\u00e8\7\35\2\2\u00e8\u00ea\5\20\t\2\u00e9\u00e7\3\2\2\2\u00ea\u00ed\3"+
		"\2\2\2\u00eb\u00e9\3\2\2\2\u00eb\u00ec\3\2\2\2\u00ec\u00ee\3\2\2\2\u00ed"+
		"\u00eb\3\2\2\2\u00ee\u00ef\79\2\2\u00ef\u00f0\7@\2\2\u00f0\u00f1\7y\2"+
		"\2\u00f1\u00f2\7\66\2\2\u00f2\u00f4\3\2\2\2\u00f3\u00d1\3\2\2\2\u00f3"+
		"\u00d8\3\2\2\2\u00f3\u00e4\3\2\2\2\u00f4\23\3\2\2\2\u00f5\u00f6\t\3\2"+
		"\2\u00f6\25\3\2\2\2\u00f7\u00f9\5\24\13\2\u00f8\u00f7\3\2\2\2\u00f8\u00f9"+
		"\3\2\2\2\u00f9\u00fa\3\2\2\2\u00fa\u00fb\t\4\2\2\u00fb\u0105\5\u00aaV"+
		"\2\u00fc\u00fd\7C\2\2\u00fd\u0102\5\30\r\2\u00fe\u00ff\7\35\2\2\u00ff"+
		"\u0101\5\30\r\2\u0100\u00fe\3\2\2\2\u0101\u0104\3\2\2\2\u0102\u0100\3"+
		"\2\2\2\u0102\u0103\3\2\2\2\u0103\u0106\3\2\2\2\u0104\u0102\3\2\2\2\u0105"+
		"\u00fc\3\2\2\2\u0105\u0106\3\2\2\2\u0106\u0107\3\2\2\2\u0107\u010b\7\f"+
		"\2\2\u0108\u010a\5\32\16\2\u0109\u0108\3\2\2\2\u010a\u010d\3\2\2\2\u010b"+
		"\u0109\3\2\2\2\u010b\u010c\3\2\2\2\u010c\u010e\3\2\2\2\u010d\u010b\3\2"+
		"\2\2\u010e\u010f\79\2\2\u010f\27\3\2\2\2\u0110\u0116\5D#\2\u0111\u0113"+
		"\7\33\2\2\u0112\u0114\5v<\2\u0113\u0112\3\2\2\2\u0113\u0114\3\2\2\2\u0114"+
		"\u0115\3\2\2\2\u0115\u0117\7Y\2\2\u0116\u0111\3\2\2\2\u0116\u0117\3\2"+
		"\2\2\u0117\31\3\2\2\2\u0118\u0121\5\34\17\2\u0119\u0121\5\36\20\2\u011a"+
		"\u0121\5 \21\2\u011b\u0121\5\"\22\2\u011c\u0121\5$\23\2\u011d\u0121\5"+
		"(\25\2\u011e\u0121\5.\30\2\u011f\u0121\5\62\32\2\u0120\u0118\3\2\2\2\u0120"+
		"\u0119\3\2\2\2\u0120\u011a\3\2\2\2\u0120\u011b\3\2\2\2\u0120\u011c\3\2"+
		"\2\2\u0120\u011d\3\2\2\2\u0120\u011e\3\2\2\2\u0120\u011f\3\2\2\2\u0121"+
		"\33\3\2\2\2\u0122\u0126\5B\"\2\u0123\u0125\t\5\2\2\u0124\u0123\3\2\2\2"+
		"\u0125\u0128\3\2\2\2\u0126\u0124\3\2\2\2\u0126\u0127\3\2\2\2\u0127\u0129"+
		"\3\2\2\2\u0128\u0126\3\2\2\2\u0129\u012c\5\u00aaV\2\u012a\u012b\7\23\2"+
		"\2\u012b\u012d\5r:\2\u012c\u012a\3\2\2\2\u012c\u012d\3\2\2\2\u012d\u012e"+
		"\3\2\2\2\u012e\u012f\7\66\2\2\u012f\35\3\2\2\2\u0130\u0131\7\63\2\2\u0131"+
		"\u0132\5\u00aaV\2\u0132\u0135\7\25\2\2\u0133\u0136\7D\2\2\u0134\u0136"+
		"\5B\"\2\u0135\u0133\3\2\2\2\u0135\u0134\3\2\2\2\u0136\u0137\3\2\2\2\u0137"+
		"\u0138\7\66\2\2\u0138\37\3\2\2\2\u0139\u013a\7-\2\2\u013a\u013b\5\u00aa"+
		"V\2\u013b\u0146\7\f\2\2\u013c\u013d\5@!\2\u013d\u0143\7\66\2\2\u013e\u013f"+
		"\5@!\2\u013f\u0140\7\66\2\2\u0140\u0142\3\2\2\2\u0141\u013e\3\2\2\2\u0142"+
		"\u0145\3\2\2\2\u0143\u0141\3\2\2\2\u0143\u0144\3\2\2\2\u0144\u0147\3\2"+
		"\2\2\u0145\u0143\3\2\2\2\u0146\u013c\3\2\2\2\u0146\u0147\3\2\2\2\u0147"+
		"\u0148\3\2\2\2\u0148\u0149\79\2\2\u0149!\3\2\2\2\u014a\u014b\7\31\2\2"+
		"\u014b\u014c\5\64\33\2\u014c\u014d\5,\27\2\u014d\u014e\5N(\2\u014e#\3"+
		"\2\2\2\u014f\u0150\7W\2\2\u0150\u0152\5\u00aaV\2\u0151\u0153\5\64\33\2"+
		"\u0152\u0151\3\2\2\2\u0152\u0153\3\2\2\2\u0153\u0154\3\2\2\2\u0154\u0155"+
		"\5N(\2\u0155%\3\2\2\2\u0156\u015c\5\u00aaV\2\u0157\u0159\7\33\2\2\u0158"+
		"\u015a\5v<\2\u0159\u0158\3\2\2\2\u0159\u015a\3\2\2\2\u015a\u015b\3\2\2"+
		"\2\u015b\u015d\7Y\2\2\u015c\u0157\3\2\2\2\u015c\u015d\3\2\2\2\u015d\'"+
		"\3\2\2\2\u015e\u0160\5\24\13\2\u015f\u015e\3\2\2\2\u015f\u0160\3\2\2\2"+
		"\u0160\u0161\3\2\2\2\u0161\u0163\7*\2\2\u0162\u0164\5\u00aaV\2\u0163\u0162"+
		"\3\2\2\2\u0163\u0164\3\2\2\2\u0164\u0165\3\2\2\2\u0165\u0166\5\64\33\2"+
		"\u0166\u0168\5,\27\2\u0167\u0169\5*\26\2\u0168\u0167\3\2\2\2\u0168\u0169"+
		"\3\2\2\2\u0169\u016c\3\2\2\2\u016a\u016d\7\66\2\2\u016b\u016d\5N(\2\u016c"+
		"\u016a\3\2\2\2\u016c\u016b\3\2\2\2\u016d)\3\2\2\2\u016e\u016f\7)\2\2\u016f"+
		"\u0170\5\64\33\2\u0170+\3\2\2\2\u0171\u0178\5&\24\2\u0172\u0178\5L\'\2"+
		"\u0173\u0178\7o\2\2\u0174\u0178\7t\2\2\u0175\u0178\7q\2\2\u0176\u0178"+
		"\7s\2\2\u0177\u0171\3\2\2\2\u0177\u0172\3\2\2\2\u0177\u0173\3\2\2\2\u0177"+
		"\u0174\3\2\2\2\u0177\u0175\3\2\2\2\u0177\u0176\3\2\2\2\u0178\u017b\3\2"+
		"\2\2\u0179\u0177\3\2\2\2\u0179\u017a\3\2\2\2\u017a-\3\2\2\2\u017b\u0179"+
		"\3\2\2\2\u017c\u017e\5\24\13\2\u017d\u017c\3\2\2\2\u017d\u017e\3\2\2\2"+
		"\u017e\u017f\3\2\2\2\u017f\u0180\7>\2\2\u0180\u0181\5\u00aaV\2\u0181\u0183"+
		"\58\35\2\u0182\u0184\7k\2\2\u0183\u0182\3\2\2\2\u0183\u0184\3\2\2\2\u0184"+
		"\u0185\3\2\2\2\u0185\u0186\7\66\2\2\u0186/\3\2\2\2\u0187\u0188\5\u00aa"+
		"V\2\u0188\61\3\2\2\2\u0189\u018a\7=\2\2\u018a\u018b\5\u00aaV\2\u018b\u018d"+
		"\7\f\2\2\u018c\u018e\5\60\31\2\u018d\u018c\3\2\2\2\u018d\u018e\3\2\2\2"+
		"\u018e\u0193\3\2\2\2\u018f\u0190\7\35\2\2\u0190\u0192\5\60\31\2\u0191"+
		"\u018f\3\2\2\2\u0192\u0195\3\2\2\2\u0193\u0191\3\2\2\2\u0193\u0194\3\2"+
		"\2\2\u0194\u0196\3\2\2\2\u0195\u0193\3\2\2\2\u0196\u0197\79\2\2\u0197"+
		"\63\3\2\2\2\u0198\u01a1\7\33\2\2\u0199\u019e\5\66\34\2\u019a\u019b\7\35"+
		"\2\2\u019b\u019d\5\66\34\2\u019c\u019a\3\2\2\2\u019d\u01a0\3\2\2\2\u019e"+
		"\u019c\3\2\2\2\u019e\u019f\3\2\2\2\u019f\u01a2\3\2\2\2\u01a0\u019e\3\2"+
		"\2\2\u01a1\u0199\3\2\2\2\u01a1\u01a2\3\2\2\2\u01a2\u01a3\3\2\2\2\u01a3"+
		"\u01a4\7Y\2\2\u01a4\65\3\2\2\2\u01a5\u01a7\5B\"\2\u01a6\u01a8\5J&\2\u01a7"+
		"\u01a6\3\2\2\2\u01a7\u01a8\3\2\2\2\u01a8\u01aa\3\2\2\2\u01a9\u01ab\5\u00aa"+
		"V\2\u01aa\u01a9\3\2\2\2\u01aa\u01ab\3\2\2\2\u01ab\67\3\2\2\2\u01ac\u01b5"+
		"\7\33\2\2\u01ad\u01b2\5:\36\2\u01ae\u01af\7\35\2\2\u01af\u01b1\5:\36\2"+
		"\u01b0\u01ae\3\2\2\2\u01b1\u01b4\3\2\2\2\u01b2\u01b0\3\2\2\2\u01b2\u01b3"+
		"\3\2\2\2\u01b3\u01b6\3\2\2\2\u01b4\u01b2\3\2\2\2\u01b5\u01ad\3\2\2\2\u01b5"+
		"\u01b6\3\2\2\2\u01b6\u01b7\3\2\2\2\u01b7\u01b8\7Y\2\2\u01b89\3\2\2\2\u01b9"+
		"\u01bb\5B\"\2\u01ba\u01bc\7p\2\2\u01bb\u01ba\3\2\2\2\u01bb\u01bc\3\2\2"+
		"\2\u01bc\u01be\3\2\2\2\u01bd\u01bf\5\u00aaV\2\u01be\u01bd\3\2\2\2\u01be"+
		"\u01bf\3\2\2\2\u01bf;\3\2\2\2\u01c0\u01c9\7\33\2\2\u01c1\u01c6\5> \2\u01c2"+
		"\u01c3\7\35\2\2\u01c3\u01c5\5> \2\u01c4\u01c2\3\2\2\2\u01c5\u01c8\3\2"+
		"\2\2\u01c6\u01c4\3\2\2\2\u01c6\u01c7\3\2\2\2\u01c7\u01ca\3\2\2\2\u01c8"+
		"\u01c6\3\2\2\2\u01c9\u01c1\3\2\2\2\u01c9\u01ca\3\2\2\2\u01ca\u01cb\3\2"+
		"\2\2\u01cb\u01cc\7Y\2\2\u01cc=\3\2\2\2\u01cd\u01cf\5B\"\2\u01ce\u01d0"+
		"\5J&\2\u01cf\u01ce\3\2\2\2\u01cf\u01d0\3\2\2\2\u01d0?\3\2\2\2\u01d1\u01d3"+
		"\5B\"\2\u01d2\u01d4\5J&\2\u01d3\u01d2\3\2\2\2\u01d3\u01d4\3\2\2\2\u01d4"+
		"\u01d5\3\2\2\2\u01d5\u01d6\5\u00aaV\2\u01d6A\3\2\2\2\u01d7\u01d8\b\"\1"+
		"\2\u01d8\u01df\5p9\2\u01d9\u01df\5D#\2\u01da\u01df\5F$\2\u01db\u01df\5"+
		"H%\2\u01dc\u01dd\7P\2\2\u01dd\u01df\7r\2\2\u01de\u01d7\3\2\2\2\u01de\u01d9"+
		"\3\2\2\2\u01de\u01da\3\2\2\2\u01de\u01db\3\2\2\2\u01de\u01dc\3\2\2\2\u01df"+
		"\u01e8\3\2\2\2\u01e0\u01e1\f\5\2\2\u01e1\u01e3\7K\2\2\u01e2\u01e4\5r:"+
		"\2\u01e3\u01e2\3\2\2\2\u01e3\u01e4\3\2\2\2\u01e4\u01e5\3\2\2\2\u01e5\u01e7"+
		"\7%\2\2\u01e6\u01e0\3\2\2\2\u01e7\u01ea\3\2\2\2\u01e8\u01e6\3\2\2\2\u01e8"+
		"\u01e9\3\2\2\2\u01e9C\3\2\2\2\u01ea\u01e8\3\2\2\2\u01eb\u01f0\5\u00aa"+
		"V\2\u01ec\u01ed\7F\2\2\u01ed\u01ef\5\u00aaV\2\u01ee\u01ec\3\2\2\2\u01ef"+
		"\u01f2\3\2\2\2\u01f0\u01ee\3\2\2\2\u01f0\u01f1\3\2\2\2\u01f1E\3\2\2\2"+
		"\u01f2\u01f0\3\2\2\2\u01f3\u01f4\7,\2\2\u01f4\u01f5\7\33\2\2\u01f5\u01f6"+
		"\5p9\2\u01f6\u01f7\7T\2\2\u01f7\u01f8\5B\"\2\u01f8\u01f9\7Y\2\2\u01f9"+
		"G\3\2\2\2\u01fa\u01fb\7*\2\2\u01fb\u0201\5<\37\2\u01fc\u0200\7q\2\2\u01fd"+
		"\u0200\7o\2\2\u01fe\u0200\5L\'\2\u01ff\u01fc\3\2\2\2\u01ff\u01fd\3\2\2"+
		"\2\u01ff\u01fe\3\2\2\2\u0200\u0203\3\2\2\2\u0201\u01ff\3\2\2\2\u0201\u0202"+
		"\3\2\2\2\u0202\u0206\3\2\2\2\u0203\u0201\3\2\2\2\u0204\u0205\7)\2\2\u0205"+
		"\u0207\5<\37\2\u0206\u0204\3\2\2\2\u0206\u0207\3\2\2\2\u0207I\3\2\2\2"+
		"\u0208\u0209\t\6\2\2\u0209K\3\2\2\2\u020a\u020b\t\7\2\2\u020bM\3\2\2\2"+
		"\u020c\u0210\7\f\2\2\u020d\u020f\5P)\2\u020e\u020d\3\2\2\2\u020f\u0212"+
		"\3\2\2\2\u0210\u020e\3\2\2\2\u0210\u0211\3\2\2\2\u0211\u0213\3\2\2\2\u0212"+
		"\u0210\3\2\2\2\u0213\u0214\79\2\2\u0214O\3\2\2\2\u0215\u0222\5T+\2\u0216"+
		"\u0222\5V,\2\u0217\u0222\5Z.\2\u0218\u0222\5N(\2\u0219\u0222\5\\/\2\u021a"+
		"\u0222\5^\60\2\u021b\u0222\5`\61\2\u021c\u0222\5b\62\2\u021d\u0222\5d"+
		"\63\2\u021e\u0222\5f\64\2\u021f\u0222\5h\65\2\u0220\u0222\5X-\2\u0221"+
		"\u0215\3\2\2\2\u0221\u0216\3\2\2\2\u0221\u0217\3\2\2\2\u0221\u0218\3\2"+
		"\2\2\u0221\u0219\3\2\2\2\u0221\u021a\3\2\2\2\u0221\u021b\3\2\2\2\u0221"+
		"\u021c\3\2\2\2\u0221\u021d\3\2\2\2\u0221\u021e\3\2\2\2\u0221\u021f\3\2"+
		"\2\2\u0221\u0220\3\2\2\2\u0222Q\3\2\2\2\u0223\u0224\5r:\2\u0224\u0225"+
		"\7\66\2\2\u0225S\3\2\2\2\u0226\u0227\7:\2\2\u0227\u0228\7\33\2\2\u0228"+
		"\u0229\5r:\2\u0229\u022a\7Y\2\2\u022a\u022d\5P)\2\u022b\u022c\7X\2\2\u022c"+
		"\u022e\5P)\2\u022d\u022b\3\2\2\2\u022d\u022e\3\2\2\2\u022eU\3\2\2\2\u022f"+
		"\u0230\7\13\2\2\u0230\u0231\7\33\2\2\u0231\u0232\5r:\2\u0232\u0233\7Y"+
		"\2\2\u0233\u0234\5P)\2\u0234W\3\2\2\2\u0235\u0238\5j\66\2\u0236\u0238"+
		"\5R*\2\u0237\u0235\3\2\2\2\u0237\u0236\3\2\2\2\u0238Y\3\2\2\2\u0239\u023a"+
		"\7\25\2\2\u023a\u023d\7\33\2\2\u023b\u023e\5X-\2\u023c\u023e\7\66\2\2"+
		"\u023d\u023b\3\2\2\2\u023d\u023c\3\2\2\2\u023e\u0241\3\2\2\2\u023f\u0242"+
		"\5R*\2\u0240\u0242\7\66\2\2\u0241\u023f\3\2\2\2\u0241\u0240\3\2\2\2\u0242"+
		"\u0244\3\2\2\2\u0243\u0245\5r:\2\u0244\u0243\3\2\2\2\u0244\u0245\3\2\2"+
		"\2\u0245\u0246\3\2\2\2\u0246\u0247\7Y\2\2\u0247\u0248\5P)\2\u0248[\3\2"+
		"\2\2\u0249\u024b\7Z\2\2\u024a\u024c\7y\2\2\u024b\u024a\3\2\2\2\u024b\u024c"+
		"\3\2\2\2\u024c\u024d\3\2\2\2\u024d\u024e\5\u0080A\2\u024e]\3\2\2\2\u024f"+
		"\u0250\7\32\2\2\u0250\u0251\5P)\2\u0251\u0252\7\13\2\2\u0252\u0253\7\33"+
		"\2\2\u0253\u0254\5r:\2\u0254\u0255\7Y\2\2\u0255\u0256\7\66\2\2\u0256_"+
		"\3\2\2\2\u0257\u0258\7n\2\2\u0258\u0259\7\66\2\2\u0259a\3\2\2\2\u025a"+
		"\u025b\7l\2\2\u025b\u025c\7\66\2\2\u025cc\3\2\2\2\u025d\u025f\7\62\2\2"+
		"\u025e\u0260\5r:\2\u025f\u025e\3\2\2\2\u025f\u0260\3\2\2\2\u0260\u0261"+
		"\3\2\2\2\u0261\u0262\7\66\2\2\u0262e\3\2\2\2\u0263\u0264\7I\2\2\u0264"+
		"\u0265\7\66\2\2\u0265g\3\2\2\2\u0266\u0267\7E\2\2\u0267\u0268\5~@\2\u0268"+
		"\u0269\7\66\2\2\u0269i\3\2\2\2\u026a\u026b\7!\2\2\u026b\u0272\5n8\2\u026c"+
		"\u0272\5@!\2\u026d\u026e\7\33\2\2\u026e\u026f\5l\67\2\u026f\u0270\7Y\2"+
		"\2\u0270\u0272\3\2\2\2\u0271\u026a\3\2\2\2\u0271\u026c\3\2\2\2\u0271\u026d"+
		"\3\2\2\2\u0272\u0275\3\2\2\2\u0273\u0274\7\23\2\2\u0274\u0276\5r:\2\u0275"+
		"\u0273\3\2\2\2\u0275\u0276\3\2\2\2\u0276\u0277\3\2\2\2\u0277\u0278\7\66"+
		"\2\2\u0278k\3\2\2\2\u0279\u027b\5@!\2\u027a\u0279\3\2\2\2\u027a\u027b"+
		"\3\2\2\2\u027b\u0282\3\2\2\2\u027c\u027e\7\35\2\2\u027d\u027f\5@!\2\u027e"+
		"\u027d\3\2\2\2\u027e\u027f\3\2\2\2\u027f\u0281\3\2\2\2\u0280\u027c\3\2"+
		"\2\2\u0281\u0284\3\2\2\2\u0282\u0280\3\2\2\2\u0282\u0283\3\2\2\2\u0283"+
		"m\3\2\2\2\u0284\u0282\3\2\2\2\u0285\u028c\7\33\2\2\u0286\u0288\5\u00aa"+
		"V\2\u0287\u0286\3\2\2\2\u0287\u0288\3\2\2\2\u0288\u0289\3\2\2\2\u0289"+
		"\u028b\7\35\2\2\u028a\u0287\3\2\2\2\u028b\u028e\3\2\2\2\u028c\u028a\3"+
		"\2\2\2\u028c\u028d\3\2\2\2\u028d\u0290\3\2\2\2\u028e\u028c\3\2\2\2\u028f"+
		"\u0291\5\u00aaV\2\u0290\u028f\3\2\2\2\u0290\u0291\3\2\2\2\u0291\u0292"+
		"\3\2\2\2\u0292\u0293\7Y\2\2\u0293o\3\2\2\2\u0294\u0295\t\b\2\2\u0295q"+
		"\3\2\2\2\u0296\u0297\b:\1\2\u0297\u0298\t\t\2\2\u0298\u02a9\5r:\25\u0299"+
		"\u029a\t\n\2\2\u029a\u02a9\5r:\24\u029b\u029c\t\13\2\2\u029c\u02a9\5r"+
		":\23\u029d\u029e\7S\2\2\u029e\u02a9\5r:\22\u029f\u02a0\7&\2\2\u02a0\u02a9"+
		"\5r:\21\u02a1\u02a2\7\b\2\2\u02a2\u02a9\5B\"\2\u02a3\u02a4\7\33\2\2\u02a4"+
		"\u02a5\5r:\2\u02a5\u02a6\7Y\2\2\u02a6\u02a9\3\2\2\2\u02a7\u02a9\5t;\2"+
		"\u02a8\u0296\3\2\2\2\u02a8\u0299\3\2\2\2\u02a8\u029b\3\2\2\2\u02a8\u029d"+
		"\3\2\2\2\u02a8\u029f\3\2\2\2\u02a8\u02a1\3\2\2\2\u02a8\u02a3\3\2\2\2\u02a8"+
		"\u02a7\3\2\2\2\u02a9\u02e5\3\2\2\2\u02aa\u02ab\f\20\2\2\u02ab\u02ac\7"+
		"\21\2\2\u02ac\u02e4\5r:\21\u02ad\u02ae\f\17\2\2\u02ae\u02af\t\f\2\2\u02af"+
		"\u02e4\5r:\20\u02b0\u02b1\f\16\2\2\u02b1\u02b2\t\n\2\2\u02b2\u02e4\5r"+
		":\17\u02b3\u02b4\f\r\2\2\u02b4\u02b5\t\r\2\2\u02b5\u02e4\5r:\16\u02b6"+
		"\u02b7\f\f\2\2\u02b7\u02b8\7A\2\2\u02b8\u02e4\5r:\r\u02b9\u02ba\f\13\2"+
		"\2\u02ba\u02bb\7\26\2\2\u02bb\u02e4\5r:\f\u02bc\u02bd\f\n\2\2\u02bd\u02be"+
		"\7N\2\2\u02be\u02e4\5r:\13\u02bf\u02c0\f\t\2\2\u02c0\u02c1\t\16\2\2\u02c1"+
		"\u02e4\5r:\n\u02c2\u02c3\f\b\2\2\u02c3\u02c4\t\17\2\2\u02c4\u02e4\5r:"+
		"\t\u02c5\u02c6\f\7\2\2\u02c6\u02c7\7\17\2\2\u02c7\u02e4\5r:\b\u02c8\u02c9"+
		"\f\6\2\2\u02c9\u02ca\7\65\2\2\u02ca\u02e4\5r:\7\u02cb\u02cc\f\5\2\2\u02cc"+
		"\u02cd\7<\2\2\u02cd\u02ce\5r:\2\u02ce\u02cf\7J\2\2\u02cf\u02d0\5r:\6\u02d0"+
		"\u02e4\3\2\2\2\u02d1\u02d2\f\4\2\2\u02d2\u02d3\t\20\2\2\u02d3\u02e4\5"+
		"r:\5\u02d4\u02d5\f\33\2\2\u02d5\u02e4\t\t\2\2\u02d6\u02d7\f\31\2\2\u02d7"+
		"\u02d8\7K\2\2\u02d8\u02d9\5r:\2\u02d9\u02da\7%\2\2\u02da\u02e4\3\2\2\2"+
		"\u02db\u02dc\f\30\2\2\u02dc\u02dd\7\33\2\2\u02dd\u02de\5|?\2\u02de\u02df"+
		"\7Y\2\2\u02df\u02e4\3\2\2\2\u02e0\u02e1\f\27\2\2\u02e1\u02e2\7F\2\2\u02e2"+
		"\u02e4\5\u00aaV\2\u02e3\u02aa\3\2\2\2\u02e3\u02ad\3\2\2\2\u02e3\u02b0"+
		"\3\2\2\2\u02e3\u02b3\3\2\2\2\u02e3\u02b6\3\2\2\2\u02e3\u02b9\3\2\2\2\u02e3"+
		"\u02bc\3\2\2\2\u02e3\u02bf\3\2\2\2\u02e3\u02c2\3\2\2\2\u02e3\u02c5\3\2"+
		"\2\2\u02e3\u02c8\3\2\2\2\u02e3\u02cb\3\2\2\2\u02e3\u02d1\3\2\2\2\u02e3"+
		"\u02d4\3\2\2\2\u02e3\u02d6\3\2\2\2\u02e3\u02db\3\2\2\2\u02e3\u02e0\3\2"+
		"\2\2\u02e4\u02e7\3\2\2\2\u02e5\u02e3\3\2\2\2\u02e5\u02e6\3\2\2\2\u02e6"+
		"s\3\2\2\2\u02e7\u02e5\3\2\2\2\u02e8\u02f9\7e\2\2\u02e9\u02f9\5\u00a8U"+
		"\2\u02ea\u02f9\7i\2\2\u02eb\u02f9\7y\2\2\u02ec\u02ef\5\u00aaV\2\u02ed"+
		"\u02ee\7K\2\2\u02ee\u02f0\7%\2\2\u02ef\u02ed\3\2\2\2\u02ef\u02f0\3\2\2"+
		"\2\u02f0\u02f9\3\2\2\2\u02f1\u02f9\7v\2\2\u02f2\u02f9\5\u00a4S\2\u02f3"+
		"\u02f6\5\u00a6T\2\u02f4\u02f5\7K\2\2\u02f5\u02f7\7%\2\2\u02f6\u02f4\3"+
		"\2\2\2\u02f6\u02f7\3\2\2\2\u02f7\u02f9\3\2\2\2\u02f8\u02e8\3\2\2\2\u02f8"+
		"\u02e9\3\2\2\2\u02f8\u02ea\3\2\2\2\u02f8\u02eb\3\2\2\2\u02f8\u02ec\3\2"+
		"\2\2\u02f8\u02f1\3\2\2\2\u02f8\u02f2\3\2\2\2\u02f8\u02f3\3\2\2\2\u02f9"+
		"u\3\2\2\2\u02fa\u02ff\5r:\2\u02fb\u02fc\7\35\2\2\u02fc\u02fe\5r:\2\u02fd"+
		"\u02fb\3\2\2\2\u02fe\u0301\3\2\2\2\u02ff\u02fd\3\2\2\2\u02ff\u0300\3\2"+
		"\2\2\u0300w\3\2\2\2\u0301\u02ff\3\2\2\2\u0302\u0307\5z>\2\u0303\u0304"+
		"\7\35\2\2\u0304\u0306\5z>\2\u0305\u0303\3\2\2\2\u0306\u0309\3\2\2\2\u0307"+
		"\u0305\3\2\2\2\u0307\u0308\3\2\2\2\u0308\u030b\3\2\2\2\u0309\u0307\3\2"+
		"\2\2\u030a\u030c\7\35\2\2\u030b\u030a\3\2\2\2\u030b\u030c\3\2\2\2\u030c"+
		"y\3\2\2\2\u030d\u030e\5\u00aaV\2\u030e\u030f\7J\2\2\u030f\u0310\5r:\2"+
		"\u0310{\3\2\2\2\u0311\u0313\7\f\2\2\u0312\u0314\5x=\2\u0313\u0312\3\2"+
		"\2\2\u0313\u0314\3\2\2\2\u0314\u0315\3\2\2\2\u0315\u031a\79\2\2\u0316"+
		"\u0318\5v<\2\u0317\u0316\3\2\2\2\u0317\u0318\3\2\2\2\u0318\u031a\3\2\2"+
		"\2\u0319\u0311\3\2\2\2\u0319\u0317\3\2\2\2\u031a}\3\2\2\2\u031b\u031c"+
		"\5r:\2\u031c\u031d\7\33\2\2\u031d\u031e\5|?\2\u031e\u031f\7Y\2\2\u031f"+
		"\177\3\2\2\2\u0320\u0324\7\f\2\2\u0321\u0323\5\u0082B\2\u0322\u0321\3"+
		"\2\2\2\u0323\u0326\3\2\2\2\u0324\u0322\3\2\2\2\u0324\u0325\3\2\2\2\u0325"+
		"\u0327\3\2\2\2\u0326\u0324\3\2\2\2\u0327\u0328\79\2\2\u0328\u0081\3\2"+
		"\2\2\u0329\u033b\5\u00aaV\2\u032a\u033b\5\u0080A\2\u032b\u033b\5\u0084"+
		"C\2\u032c\u033b\5\u0088E\2\u032d\u033b\5\u008aF\2\u032e\u033b\5\u0090"+
		"I\2\u032f\u033b\5\u0092J\2\u0330\u033b\5\u0094K\2\u0331\u033b\5\u0098"+
		"M\2\u0332\u033b\5\u009cO\2\u0333\u033b\5\u009eP\2\u0334\u033b\7l\2\2\u0335"+
		"\u033b\7n\2\2\u0336\u033b\5\u00a2R\2\u0337\u033b\5\u00a8U\2\u0338\u033b"+
		"\7y\2\2\u0339\u033b\7i\2\2\u033a\u0329\3\2\2\2\u033a\u032a\3\2\2\2\u033a"+
		"\u032b\3\2\2\2\u033a\u032c\3\2\2\2\u033a\u032d\3\2\2\2\u033a\u032e\3\2"+
		"\2\2\u033a\u032f\3\2\2\2\u033a\u0330\3\2\2\2\u033a\u0331\3\2\2\2\u033a"+
		"\u0332\3\2\2\2\u033a\u0333\3\2\2\2\u033a\u0334\3\2\2\2\u033a\u0335\3\2"+
		"\2\2\u033a\u0336\3\2\2\2\u033a\u0337\3\2\2\2\u033a\u0338\3\2\2\2\u033a"+
		"\u0339\3\2\2\2\u033b\u0083\3\2\2\2\u033c\u033f\5\u0086D\2\u033d\u033f"+
		"\5\u00a0Q\2\u033e\u033c\3\2\2\2\u033e\u033d\3\2\2\2\u033f\u0085\3\2\2"+
		"\2\u0340\u0345\7\62\2\2\u0341\u0345\7P\2\2\u0342\u0345\7\22\2\2\u0343"+
		"\u0345\5\u00aaV\2\u0344\u0340\3\2\2\2\u0344\u0341\3\2\2\2\u0344\u0342"+
		"\3\2\2\2\u0344\u0343\3\2\2\2\u0345\u0352\3\2\2\2\u0346\u0348\7\33\2\2"+
		"\u0347\u0349\5\u0084C\2\u0348\u0347\3\2\2\2\u0348\u0349\3\2\2\2\u0349"+
		"\u034e\3\2\2\2\u034a\u034b\7\35\2\2\u034b\u034d\5\u0084C\2\u034c\u034a"+
		"\3\2\2\2\u034d\u0350\3\2\2\2\u034e\u034c\3\2\2\2\u034e\u034f\3\2\2\2\u034f"+
		"\u0351\3\2\2\2\u0350\u034e\3\2\2\2\u0351\u0353\7Y\2\2\u0352\u0346\3\2"+
		"\2\2\u0352\u0353\3\2\2\2\u0353\u0087\3\2\2\2\u0354\u0355\7(\2\2\u0355"+
		"\u0358\5\u008cG\2\u0356\u0357\7;\2\2\u0357\u0359\5\u0084C\2\u0358\u0356"+
		"\3\2\2\2\u0358\u0359\3\2\2\2\u0359\u0089\3\2\2\2\u035a\u035b\5\u008cG"+
		"\2\u035b\u035c\7;\2\2\u035c\u035d\5\u0084C\2\u035d\u008b\3\2\2\2\u035e"+
		"\u0364\5\u00aaV\2\u035f\u0360\7\33\2\2\u0360\u0361\5\u008eH\2\u0361\u0362"+
		"\7Y\2\2\u0362\u0364\3\2\2\2\u0363\u035e\3\2\2\2\u0363\u035f\3\2\2\2\u0364"+
		"\u008d\3\2\2\2\u0365\u036a\5\u00aaV\2\u0366\u0367\7\35\2\2\u0367\u0369"+
		"\5\u00aaV\2\u0368\u0366\3\2\2\2\u0369\u036c\3\2\2\2\u036a\u0368\3\2\2"+
		"\2\u036a\u036b\3\2\2\2\u036b\u008f\3\2\2\2\u036c\u036a\3\2\2\2\u036d\u036e"+
		"\78\2\2\u036e\u036f\5\u00aaV\2\u036f\u0091\3\2\2\2\u0370\u0371\5\u00aa"+
		"V\2\u0371\u0372\7J\2\2\u0372\u0093\3\2\2\2\u0373\u0374\7B\2\2\u0374\u0378"+
		"\5\u0084C\2\u0375\u0377\5\u0096L\2\u0376\u0375\3\2\2\2\u0377\u037a\3\2"+
		"\2\2\u0378\u0376\3\2\2\2\u0378\u0379\3\2\2\2\u0379\u0095\3\2\2\2\u037a"+
		"\u0378\3\2\2\2\u037b\u037c\7H\2\2\u037c\u037d\5\u00a0Q\2\u037d\u037e\5"+
		"\u0080A\2\u037e\u0382\3\2\2\2\u037f\u0380\7\3\2\2\u0380\u0382\5\u0080"+
		"A\2\u0381\u037b\3\2\2\2\u0381\u037f\3\2\2\2\u0382\u0097\3\2\2\2\u0383"+
		"\u0384\7*\2\2\u0384\u0385\5\u00aaV\2\u0385\u0387\7\33\2\2\u0386\u0388"+
		"\5\u008eH\2\u0387\u0386\3\2\2\2\u0387\u0388\3\2\2\2\u0388\u0389\3\2\2"+
		"\2\u0389\u038b\7Y\2\2\u038a\u038c\5\u009aN\2\u038b\u038a\3\2\2\2\u038b"+
		"\u038c\3\2\2\2\u038c\u038d\3\2\2\2\u038d\u038e\5\u0080A\2\u038e\u0099"+
		"\3\2\2\2\u038f\u0390\7G\2\2\u0390\u0391\5\u008eH\2\u0391\u009b\3\2\2\2"+
		"\u0392\u0395\7\25\2\2\u0393\u0396\5\u0080A\2\u0394\u0396\5\u0084C\2\u0395"+
		"\u0393\3\2\2\2\u0395\u0394\3\2\2\2\u0396\u0397\3\2\2\2\u0397\u039a\5\u0084"+
		"C\2\u0398\u039b\5\u0080A\2\u0399\u039b\5\u0084C\2\u039a\u0398\3\2\2\2"+
		"\u039a\u0399\3\2\2\2\u039b\u039c\3\2\2\2\u039c\u039d\5\u0080A\2\u039d"+
		"\u009d\3\2\2\2\u039e\u039f\7:\2\2\u039f\u03a0\5\u0084C\2\u03a0\u03a1\5"+
		"\u0080A\2\u03a1\u009f\3\2\2\2\u03a2\u03a3\t\21\2\2\u03a3\u00a1\3\2\2\2"+
		"\u03a4\u03a5\7Z\2\2\u03a5\u03a6\5\u00aaV\2\u03a6\u03a7\5\u0080A\2\u03a7"+
		"\u00a3\3\2\2\2\u03a8\u03aa\7\33\2\2\u03a9\u03ab\5r:\2\u03aa\u03a9\3\2"+
		"\2\2\u03aa\u03ab\3\2\2\2\u03ab\u03b2\3\2\2\2\u03ac\u03ae\7\35\2\2\u03ad"+
		"\u03af\5r:\2\u03ae\u03ad\3\2\2\2\u03ae\u03af\3\2\2\2\u03af\u03b1\3\2\2"+
		"\2\u03b0\u03ac\3\2\2\2\u03b1\u03b4\3\2\2\2\u03b2\u03b0\3\2\2\2\u03b2\u03b3"+
		"\3\2\2\2\u03b3\u03b5\3\2\2\2\u03b4\u03b2\3\2\2\2\u03b5\u03c3\7Y\2\2\u03b6"+
		"\u03bf\7K\2\2\u03b7\u03bc\5r:\2\u03b8\u03b9\7\35\2\2\u03b9\u03bb\5r:\2"+
		"\u03ba\u03b8\3\2\2\2\u03bb\u03be\3\2\2\2\u03bc\u03ba\3\2\2\2\u03bc\u03bd"+
		"\3\2\2\2\u03bd\u03c0\3\2\2\2\u03be\u03bc\3\2\2\2\u03bf\u03b7\3\2\2\2\u03bf"+
		"\u03c0\3\2\2\2\u03c0\u03c1\3\2\2\2\u03c1\u03c3\7%\2\2\u03c2\u03a8\3\2"+
		"\2\2\u03c2\u03b6\3\2\2\2\u03c3\u00a5\3\2\2\2\u03c4\u03c7\5p9\2\u03c5\u03c7"+
		"\5D#\2\u03c6\u03c4\3\2\2\2\u03c6\u03c5\3\2\2\2\u03c7\u00a7\3\2\2\2\u03c8"+
		"\u03ca\t\22\2\2\u03c9\u03cb\7h\2\2\u03ca\u03c9\3\2\2\2\u03ca\u03cb\3\2"+
		"\2\2\u03cb\u00a9\3\2\2\2\u03cc\u03cd\t\23\2\2\u03cd\u00ab\3\2\2\2n\u00af"+
		"\u00b1\u00bf\u00c3\u00c8\u00cf\u00d5\u00db\u00df\u00eb\u00f3\u00f8\u0102"+
		"\u0105\u010b\u0113\u0116\u0120\u0126\u012c\u0135\u0143\u0146\u0152\u0159"+
		"\u015c\u015f\u0163\u0168\u016c\u0177\u0179\u017d\u0183\u018d\u0193\u019e"+
		"\u01a1\u01a7\u01aa\u01b2\u01b5\u01bb\u01be\u01c6\u01c9\u01cf\u01d3\u01de"+
		"\u01e3\u01e8\u01f0\u01ff\u0201\u0206\u0210\u0221\u022d\u0237\u023d\u0241"+
		"\u0244\u024b\u025f\u0271\u0275\u027a\u027e\u0282\u0287\u028c\u0290\u02a8"+
		"\u02e3\u02e5\u02ef\u02f6\u02f8\u02ff\u0307\u030b\u0313\u0317\u0319\u0324"+
		"\u033a\u033e\u0344\u0348\u034e\u0352\u0358\u0363\u036a\u0378\u0381\u0387"+
		"\u038b\u0395\u039a\u03aa\u03ae\u03b2\u03bc\u03bf\u03c2\u03c6\u03ca";
	public static final ATN _ATN =
		new ATNDeserializer().deserialize(_serializedATN.toCharArray());
	static {
		_decisionToDFA = new DFA[_ATN.getNumberOfDecisions()];
		for (int i = 0; i < _ATN.getNumberOfDecisions(); i++) {
			_decisionToDFA[i] = new DFA(_ATN.getDecisionState(i), i);
		}
	}
}