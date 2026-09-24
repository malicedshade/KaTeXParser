//
//  KTXPParser.m
//  KaTeXParser
//
//  Created by Alice Roldán on 5/30/24.
//

#import "KTXPParser.h"
#import "KTXPGroupNode.h"

typedef NS_ENUM(NSUInteger, KTXPContext) {
	KTXPContextStart,
	KTXPContextGroup,
	KTXPContextGroupImplied,
	KTXPContextEnvironment,
	KTXPContextMeasurement,
	KTXPContextSuperscript,
	KTXPContextSubscript
};

@interface KTXPParser()

@property (readwrite) NSString *input;
@property (readwrite) NSDictionary *settings;

@end

@implementation KTXPParser
{
	BOOL _keepParsing;
	NSUInteger     							 _currentTokenIndex;
	KTXPToken *    							 _currentToken;
	NSUInteger     							 _lookaheadIndex;
	KTXPToken *    							 _lookahead;
	KTXPParserMode 							 _mode;
	NSArray<KTXPToken *> *					 _tokens;
	KTXPStack * 		  					 _currentFrame;
	KTXPStack *			  					 _contextStack;
	NSMutableArray<KTXPStack *> * 			 _frames;
	NSMutableArray<__kindof KTXPTreeNode *> *_parsed;
	NSError *								 _parsingError;
}

- (instancetype) init
{
	return [self initWithInput:@"" settings:[KTXPParser DEFAULT_SETTINGS]];
}

- (instancetype) initWithInput:(NSString *)str settings:(NSDictionary *)settings
{
	self = [super init];
	
	if(self)
	{
		[self setInput:str];
		[self setSettings:settings];
	}
	
	return self;
}

+ (instancetype) createWithInput:(NSString *)str settings:(NSDictionary *)settings
{
	return [[KTXPParser alloc] initWithInput:str settings:settings];
}

#pragma mark - Constants
+ (NSDictionary<KTXPSettingsKey, id> *) DEFAULT_SETTINGS
{
	return @{};
}

- (KTXPRootNode * _Nullable) parse:(NSError * _Nullable __autoreleasing *)err
{
	KTXPLexer *lexer = [KTXPLexer createWithString:_input
										  settings:KTXPLexer.DEFAULT_SETTINGS];
	_tokens = [lexer lex:err];
	
	if(_tokens == nil) { return nil; }
	
	_mode 		 	   = KTXPParserModeMath;
	_keepParsing 	   = (_tokens.count == 0) ? NO : YES;
	_currentTokenIndex = 0;
	_currentToken 	   = _keepParsing ? [_tokens objectAtIndex:0] : nil;
	_lookaheadIndex    = ((_currentTokenIndex + 1 < _tokens.count) ? _currentTokenIndex + 1 : NSNotFound);
	_lookahead 	  	   = (_lookaheadIndex != NSNotFound ? [_tokens objectAtIndex:_lookaheadIndex] : nil);
	_frames 	  	   = [NSMutableArray array];
	_currentFrame 	   = [KTXPStack new];
	_contextStack 	   = [KTXPStack new];
	_parsed 	  	   = [NSMutableArray new];
	
	[_contextStack push:@(KTXPContextStart)];
	
	while(_keepParsing)
	{
		__kindof KTXPTreeNode *m = [self macro];
		
		if(m == nil)
		{
			_keepParsing = NO;
			
			break;
		}
		
		[_parsed addObject:m];
		
		_keepParsing = [self incrementToken];
	}
	
	if(_parsingError != nil && err)
	{
		*err = _parsingError;
	}
	
	return [KTXPRootNode createWithChildren:_parsed];
}

- (BOOL)incrementToken
{
	if((_currentTokenIndex + 1) < _tokens.count)
	{
		_currentTokenIndex += 1;
		_currentToken 		= [_tokens objectAtIndex:_currentTokenIndex];
		_lookaheadIndex 	= ((_currentTokenIndex + 1 < _tokens.count) ? _currentTokenIndex + 1 : NSNotFound);
		_lookahead 			= (_lookaheadIndex != NSNotFound ? [_tokens objectAtIndex:_lookaheadIndex] : nil);
		
		return YES;
	}
	
	return NO;
}

- (nullable KTXPToken *)previousToken
{
	if(_currentTokenIndex > 0)
	{
		return [_tokens objectAtIndex:(_currentTokenIndex - 1)];
	}
	
	return nil;
}

#pragma mark - Recursive Descent

- (__kindof KTXPTreeNode *) macro
{
	switch(_currentToken.type)
	{
		case KTXPTokenTypeAtom:
		case KTXPTokenTypeMathOp:
		{
			return [self atom];
		}
			
		case KTXPTokenTypeFunction:
		{
			return [self function];
		}
			
		case KTXPTokenTypeSpecialFunction:
		{
			return [self specialFunction];
		}
			
		case KTXPTokenTypeGroupOpen:
		{
			return [self group:NO];
		}
			
		case KTXPTokenTypeWhitespace:
		{
			return [self whitespace:YES];
		}
			
		case KTXPTokenTypeComment:
		{
			return [self whitespace:NO];
		}
			
		case KTXPTokenTypeEnvironmentOpen:
		{
			return [self environment];
		}
			
		default:
		{
			NSString *desc = [NSString stringWithFormat:@"Unknown error occured at location: %lu.",
							  (unsigned long)(_currentToken.location + _currentToken.lexeme.length)];
			_parsingError = [NSError errorWithDomain:KTXPParserErrorDomain
												code:KTXPParserUnexpectedHalt
											userInfo:@{NSLocalizedDescriptionKey: desc,
													   KTXPErrorLocationKey: @(_currentToken.location)}];
			return nil;
		}
	}
}

- (void) newStackFrame
{
	[_frames addObject:[_currentFrame copy]];
	
	_currentFrame = [KTXPStack new];
}

- (void) restoreStackFrame
{
	_currentFrame = [_frames.lastObject copy];
	
	[_frames removeLastObject];
}

- (KTXPAtomNode *) atom
{
	KTXPAtomNode *an = [KTXPAtomNode createWithToken:_currentToken.copy];
	
	return an;
}

- (KTXPGroupNode *) group:(BOOL)implied
{
	/*
	 There are implicit and explicit groups. An explicit group is the most common, and requires
	 GroupOpen/GroupClose macro types. Implicit groups as far as I can tell, are only 1 macro long.
	 They do not require the GroupOpen/GroupClose macro types, and are expected by certain macros
	 like \frac.
	 
	 For instance \frac12 has implicit groups around 1 and 2. \frac{1}{2} has explicit groups doing
	 the same.
	 
	 Implicit groups require a macro. If you start an implicit group and then the text ends,
	 it is an error.
	 */
	KTXPToken *open = nil;
	
	if(implied == NO)
	{
		// FIXME: need to decide what to do here
		// sometimes we are on {
		// sometimes we are on implicit grouping where we're at the parameter
		// We need a way to have the rule in the loop get one shot when implicit, but auto end if the next token is a closing brace }
		// but if the next thing isn't a closing brace and we're explicit then we want to keep doing the rules
		// im not sure why i dont just use the macro rule for this idk why i explicitly put loop
		// but since i keep making stack frames im thinking it may have to do with that.
		open = _currentToken.copy;
		
		[self incrementToken];
	}
	
	[_contextStack push:@(implied == YES ? KTXPContextGroupImplied : KTXPContextGroup)];
	[self newStackFrame];
	
	__kindof KTXPTreeNode *elem;
	
	/*
	 I wish I could re-execute the not implied case but save it as a variable.
	 So maybe theres a way to do it with blocks or NSInvocation, but that seems more complicated
	 than just doing the below.
	 */
	
	do {
		switch(_currentToken.type)
		{
			case KTXPTokenTypeFunction:
				elem = [self function];
				
				break;
				
			case KTXPTokenTypeSpecialFunction:
				elem = [self specialFunction];
				
				break;
				
			case KTXPTokenTypeGroupOpen:
				elem = [self group:NO];
				
				break;
				
			case KTXPTokenTypeWhitespace:
				elem = [self whitespace:YES];
				
				break;
				
			case KTXPTokenTypeAtom:
				elem = [self atom];
				
				break;
				
			case KTXPTokenTypeComment:
				elem = [self whitespace:NO];
				
				break;
				
			case KTXPTokenTypeEnvironmentOpen:
				elem = [self environment];
				
				break;
				
			default:
				_parsingError = [NSError errorWithDomain:KTXPParserErrorDomain
													code:KTXPParserUnexpectedHalt
												userInfo:@{KTXPErrorLocationKey: @(_currentToken.location),
														   NSLocalizedDescriptionKey: KTXPUnknownErrorReason}];
				
				return nil;
		}
		
		[_currentFrame push:elem.copy];
		
		once = YES;
		finishedGroup = (implied && once) || _lookahead == nil || _currentToken.type == KTXPTokenTypeGroupClose
			? YES : NO;
	} while(finishedGroup == NO);
	
	if(implied == NO && _currentToken.type != KTXPTokenTypeGroupClose)
	{
		NSString *desc = [NSString stringWithFormat:@"Expected a `}` at index %lu, but input ended.", (unsigned long)(_currentToken.location + _currentToken.lexeme.length)];
		
		_parsingError = [NSError errorWithDomain:KTXPParserErrorDomain
											code:KTXPParserExpectedToken
										userInfo:@{NSLocalizedDescriptionKey: desc,
												   KTXPErrorLocationKey: @(_currentToken.location)}];
	}
	
	[_contextStack pop];
	
	NSArray<__kindof KTXPTreeNode *> *elems = _currentFrame.array;
	KTXPToken *close = (implied == NO ? _currentToken.copy : nil);
	
	[self restoreStackFrame];
	
	return [KTXPGroupNode createWithOpen:open elements:elems close:close];
}

- (KTXPFunctionNode *) function
{
	[self newStackFrame];
	
	NSDictionary<KTXPSymbolKey, id> *entry = [[KTXPSymbols summon] lookupLexeme:_currentToken.lexeme
																		 inMode:_mode];
	NSNumber * _Nullable argsVal = [entry objectForKey:Args];
	NSUInteger argsCount = (argsVal != nil ? argsVal.unsignedIntegerValue : 0);
	NSUInteger currentArg = 0;
	KTXPToken *func = _currentToken.copy;
	NSMutableArray<KTXPTreeNode *> *args = [NSMutableArray new];
	
	if([_currentToken.lexeme isEqualToString:@"\\text"])
	{
		// FIXME: This has something to do with functions not being allowed in text mode.
		// ex: \angl \frac12 can't be parsed
		_mode = KTXPParserModeText;
	}
	
	while(currentArg < argsCount)
	{
		if(_lookahead == nil)
		{
			NSString *reason = [NSString stringWithFormat:@"Expected a function argument for function at index %lu, but input ended.", (unsigned long)_currentToken.location];
			_parsingError = [NSError errorWithDomain:KTXPParserErrorDomain
												code:KTXPParserExpectedToken
											userInfo:@{NSLocalizedDescriptionKey: reason, 	                           KTXPErrorLocationKey: @(_currentToken.location)}];
			return nil;
		}
		
		__kindof KTXPTreeNode *arg;
		
		switch(_lookahead.type)
		{
			case KTXPTokenTypeGroupOpen:
			{
				arg = [self group:NO];
				
				break;
			}
				
			case KTXPTokenTypeAtom:
			{
				arg = [self atom];
				
				break;
			}
			
			// Functions are handled as though they are inside an implicit group.
			case KTXPTokenTypeSpecialFunction:
			case KTXPTokenTypeFunction:
			{
				arg = [self group:YES];
				
				break;
			}
				
			default:
				// FIXME: Figure this out, something weird happened
				break;
		}
		
		[args addObject:arg];
		currentArg++;
	}
	
	[self restoreStackFrame];
	
	return [KTXPFunctionNode createWithToken:func arguments:args];
}

/**
 @param legit If \c YES, then is whitespace; else doing a comment.
 */
- (KTXPWhitespaceNode *) whitespace:(BOOL)legit
{
	NSMutableArray<KTXPToken *> *foundToks = [NSMutableArray new];
	
	BOOL testType = _currentToken.type == KTXPTokenTypeWhitespace;
	unichar char0 = [_currentToken.lexeme characterAtIndex:0];
	BOOL testChar = ![NSCharacterSet.newlineCharacterSet characterIsMember:char0];
	BOOL passed = YES;
	
	do {
		[foundToks addObject:_currentToken.copy];
		[self incrementToken];
		
		/*
		 If parsing whitespace, keep going until no longer whitespace.
		 If parsing comment, keep going until EOF or newlines. Any unicode newline counts.
		 */
		passed = legit ? testType : testChar;
	} while(passed && _lookahead != nil);
	
	[self incrementToken];
	
	return [KTXPWhitespaceNode createWithTokens:foundToks];
}

/// Helper function to get a single key value pair.
- (nullable NSDictionary *) parameterKeyValueInstance:(NSString *)sep
{
	/*
	 When you do @{key: value} the compiler replaces it with __NSSingleEntryDictionaryI from a class cluster.
	 So it's already optimized.
	 */
	
	// Key is first, ended by a `=` and then from there we go until the separator.
	NSMutableString *k = [NSMutableString new];
	
	while([_currentToken.lexeme isEqualToString:@"="] == NO)
	{
		[k appendString:_currentToken.lexeme];
		
		if([self incrementToken] == NO)
		{
			NSUInteger loc = (unsigned long)(_currentToken.location + _currentToken.lexeme.length);
			NSString *reason = [NSString stringWithFormat:@"Expected an `=` for macro parameter at index %lu ", loc];
			_parsingError = [NSError errorWithDomain:KTXPParserErrorDomain
												code:KTXPParserExpectedToken
											userInfo:@{NSLocalizedDescriptionKey: reason,
													   KTXPErrorLocationKey: @(loc)}];
			
			return nil;
		}
	}
	
	// go past `=`
	if([self incrementToken] == NO)
	{
		NSUInteger loc = (unsigned long)(_currentToken.location + _currentToken.lexeme.length);
		NSString *reason = [NSString stringWithFormat:@"Expected an `=` for macro parameter at index %lu ", loc];
		_parsingError = [NSError errorWithDomain:KTXPParserErrorDomain
											code:KTXPParserExpectedToken
										userInfo:@{NSLocalizedDescriptionKey: reason,
												   KTXPErrorLocationKey: @(loc)}];
		
		return nil;
	}
	
	NSMutableString *v = [NSMutableString new];
	BOOL findV = YES;
	
	if([_currentToken.lexeme isEqualToString:@"]"] ||
	   [_currentToken.lexeme isEqualToString:sep])
	{
		NSUInteger loc = (unsigned long)(_currentToken.location + _currentToken.lexeme.length);
		NSString *reason = [NSString stringWithFormat:@"Expected a value for macro parameter at index %lu ", loc];
		_parsingError = [NSError errorWithDomain:KTXPParserErrorDomain
											code:KTXPParserExpectedToken
										userInfo:@{NSLocalizedDescriptionKey: reason,
												   KTXPErrorLocationKey: @(_currentTokenIndex)}];
		
		return nil;
	}
	
	while(findV)
	{
		[v appendString:_currentToken.lexeme];
		
		if([_lookahead.lexeme isEqualToString:@"]"] ||
		   [_lookahead.lexeme isEqualToString:sep])
		{
			findV = NO;
		}
	}
	
	return @{k: v};
}

/**
 @param acceptable An array of lexemes that are acceptable to be within the parameter.
 */
- (KTXPParameterNode *) parameter:(nullable NSSet<NSString *> *)acceptable
							style:(KTXPParameterType)s
						separator:(NSString *)sep
{
	KTXPToken *o = _currentToken.copy;
	
	[self incrementToken];
	
	// Maybe I'd have to loop through the built stuff to make sure its part of the acceptable set but idk.
	
	/*
	 So the technique here is that if we're not in the atoms style, we accumulate a string using the tokens we find until the end of the parameter. This should work since we're not really expecting anything beyond very basic macros within these modes.
	 
	 If we are the atom type, just add them to an array.
	 */
	switch(s)
	{
		case KTXPParameterTypeKeyValue:
		{
			NSMutableDictionary *built = [NSMutableDictionary new];
			
			while([_currentToken.lexeme isEqualToString:@"]"] == NO)
			{
				NSDictionary *kv = [self parameterKeyValueInstance:sep];
				
				[built setValue:kv.allValues.firstObject forKey:kv.allKeys.firstObject];
				
				if([self incrementToken] == NO)
				{
					NSUInteger loc = (unsigned long)(_currentToken.location + _currentToken.lexeme.length);
					NSString *reason = [NSString stringWithFormat:@"Expected a ']' macro parameter at index %lu ", loc];
					_parsingError = [NSError errorWithDomain:KTXPParserErrorDomain
														code:KTXPParserExpectedToken
													userInfo:@{NSLocalizedDescriptionKey: reason,
															   KTXPErrorLocationKey: @(_currentTokenIndex)}];
					
					return nil;
				}
			}
			
			KTXPToken *c = _currentToken.copy;
			
			[self incrementToken];
			
			return [KTXPParameterNode createKeyValueParameterNode:o dict:built close:c];
		}
			
		case KTXPParameterTypeFlag:
		{
			// Build a string until we hit the separator.
			NSMutableArray *flags = [NSMutableArray new];
			NSMutableString *built = [NSMutableString new];
			
			while([_currentToken.lexeme isEqualToString:sep] ||
				  [_currentToken.lexeme isEqualToString:@"]"] == NO)
			{
				[built appendString:_currentToken.lexeme];
				
				if(_lookahead == nil)
				{
					NSString *reason = [NSString stringWithFormat:@"Expected a `]` to finish macro parameter at index %lu ", _currentTokenIndex];
					_parsingError = [NSError errorWithDomain:KTXPParserErrorDomain
														code:KTXPParserExpectedToken
													userInfo:@{NSLocalizedDescriptionKey: reason,
															   KTXPErrorLocationKey: @(_currentTokenIndex)}];
					
					return nil;
				}
				
				if([self incrementToken])
				{
					NSUInteger loc = (unsigned long)(_currentToken.location + _currentToken.lexeme.length);
					NSString *reason = [NSString stringWithFormat:@"Expected a value for macro parameter at index %lu ", loc];
					_parsingError = [NSError errorWithDomain:KTXPParserErrorDomain
														code:KTXPParserExpectedToken
													userInfo:@{NSLocalizedDescriptionKey: reason,
															   KTXPErrorLocationKey: @(loc)}];
					
					return nil;
				}
				
				[self incrementToken];
			}
			
			[flags addObject:built.copy];
			
			KTXPToken *c = _currentToken.copy;
			
			[self incrementToken];
			
			return [KTXPParameterNode createFlagParameterNode:o flags:flags close:c];
		}
			
		case KTXPParameterTypeAtoms:
		{
			// Every token is just added to the array.
			NSMutableArray *atoms = [NSMutableArray new];
			KTXPToken *open = _currentToken.copy;
			
			while([_currentToken.lexeme isEqualToString:@"]"] == NO)
			{
				KTXPAtomNode *a = [KTXPAtomNode createWithToken:_currentToken];
				
				[atoms addObject:a];
				
				if(_lookahead == nil)
				{
					NSString *reason = [NSString stringWithFormat:@"Expected a `]` to finish macro parameter at index %lu ", _currentTokenIndex];
					_parsingError = [NSError errorWithDomain:KTXPParserErrorDomain
														code:KTXPParserExpectedToken
													userInfo:@{NSLocalizedDescriptionKey: reason,
															   KTXPErrorLocationKey: @(_currentTokenIndex)}];
					
					return nil;
				}
				
				if([self incrementToken])
				{
					NSUInteger loc = (unsigned long)(_currentToken.location + _currentToken.lexeme.length);
					NSString *reason = [NSString stringWithFormat:@"Expected a value for macro parameter at index %lu ", loc];
					_parsingError = [NSError errorWithDomain:KTXPParserErrorDomain
														code:KTXPParserExpectedToken
													userInfo:@{NSLocalizedDescriptionKey: reason,
															   KTXPErrorLocationKey: @(loc)}];
					
					return nil;
				}
				
				[self incrementToken];
			}
			
			KTXPToken *close = _currentToken.copy;
			
			[self incrementToken]; // move past `]`
			
			return [KTXPParameterNode createAtomsParameterNode:open atoms:atoms close:close];
		}
	}
}

#pragma mark - RD > Environment

- (KTXPEnvironmentNode *) environment
{
	/*
	 Environments in LaTeX cause macros to be rendered a different way.
	 They start with `\begin` and close with `\end`. You need to specify the environment
	 that you are opening by putting the name within braces. If that environment takes
	 parameters then you put those into a second pair of braces.
	 
	 Here's some examples:
	 \begin{matrix} - start matrix environment.
	 \begin{array}{c:c:c} - an array is a square grid like matrix, but you can specify column borders using `c` `:` specifies dashed lines.
	 \begin{subarray}{l} - align an array thats within something else to the left.
	 
	 Due to the complexity required, I have specific nodes for the begin and end macros.
	 Then one entire environment node handles them and the contents together.
	 */
	[self newStackFrame];
	
	KTXPToken *begin = _currentToken.copy;
	
	[_contextStack push:@(KTXPContextEnvironment)];
	[self incrementToken];
	
	if(_currentToken.type != KTXPTokenTypeGroupOpen)
	{
		NSString *desc = [NSString stringWithFormat:@"Expected a `{` at index %lu, but got %@.",
						  (unsigned long)(_currentToken.location + _currentToken.lexeme.length),
						  _currentToken.lexeme];
		_parsingError = [NSError errorWithDomain:KTXPParserErrorDomain
											code:KTXPParserExpectedToken
										userInfo:@{NSLocalizedDescriptionKey: desc,
												   KTXPErrorLocationKey: @(_currentToken.location)}];
	}
	
	[self incrementToken];
	
	KTXPEnvironment env = _currentToken.lexeme.copy;
	
	[self incrementToken];
	
	if(_currentToken.type != KTXPTokenTypeGroupClose)
	{
		NSString *desc = [NSString stringWithFormat:@"Expected a `}` at index %lu, but got %@.",
						  (unsigned long)(_currentToken.location + _currentToken.lexeme.length),
						  _currentToken.lexeme];
		
		_parsingError = [NSError errorWithDomain:KTXPParserErrorDomain
											code:KTXPParserExpectedToken
										userInfo:@{NSLocalizedDescriptionKey: desc,
												   KTXPErrorLocationKey: @(_currentToken.location)}];
	}
	
	KTXPEnvironmentOpen *open = [KTXPEnvironmentOpen createWithBoundary:begin env:env];
	NSDictionary<KTXPEnvironment, NSValue *> *spellTable = @{
		/* Matrix */
			 matrix: [NSValue valueWithPointer:@selector(matrix:)],
		smallmatrix: [NSValue valueWithPointer:@selector(matrix:)],
			pmatrix: [NSValue valueWithPointer:@selector(matrix:)],
			bmatrix: [NSValue valueWithPointer:@selector(matrix:)],
		    Bmatrix: [NSValue valueWithPointer:@selector(matrix:)],
			vmatrix: [NSValue valueWithPointer:@selector(matrix:)],
			Vmatrix: [NSValue valueWithPointer:@selector(matrix:)],
		/* Matrix Star */
		 matrixStar: [NSValue valueWithPointer:@selector(matrixStar:)],
		pmatrixStar: [NSValue valueWithPointer:@selector(matrixStar:)],
		bmatrixStar: [NSValue valueWithPointer:@selector(matrixStar:)],
		BmatrixStar: [NSValue valueWithPointer:@selector(matrixStar:)],
		vmatrixStar: [NSValue valueWithPointer:@selector(matrixStar:)],
		VmatrixStar: [NSValue valueWithPointer:@selector(matrixStar:)],
		/* Array */
		   array: [NSValue valueWithPointer:@selector(array:)],
		subarray: [NSValue valueWithPointer:@selector(array:)],
		  darray: [NSValue valueWithPointer:@selector(array:)],
		/* Cases */
		  cases: [NSValue valueWithPointer:@selector(cases:)],
		 dcases: [NSValue valueWithPointer:@selector(cases:)],
		 rcases: [NSValue valueWithPointer:@selector(cases:)],
		drcases: [NSValue valueWithPointer:@selector(cases:)],
		/* Align */
			  align: [NSValue valueWithPointer:@selector(align:)],
			alignat: [NSValue valueWithPointer:@selector(align:)],
		    aligned: [NSValue valueWithPointer:@selector(align:)],
		  alignedat: [NSValue valueWithPointer:@selector(align:)],
		  alignStar: [NSValue valueWithPointer:@selector(align:)],
		alignatStar: [NSValue valueWithPointer:@selector(align:)],
		/* Equations */
			  gather: [NSValue valueWithPointer:@selector(gather:)],
		  gatherStar: [NSValue valueWithPointer:@selector(gather:)],
			gathered: [NSValue valueWithPointer:@selector(gather:)],
			equation: [NSValue valueWithPointer:@selector(equation:)],
		equationStar: [NSValue valueWithPointer:@selector(equation:)]
	};
	NSValue *sp = [spellTable objectForKey:env];
	
	if(sp == nil)
	{
		NSString *desc = [NSString stringWithFormat:@"An unrecognized or unsupported environment was given: %@ at index: %lu.",
						  _currentToken.lexeme,
						  (unsigned long)(_currentToken.location + _currentToken.lexeme.length)];
		_parsingError = [NSError errorWithDomain:KTXPParserErrorDomain
											code:KTXPParserUnexpectedToken
										userInfo:@{NSLocalizedDescriptionKey: desc,
												   KTXPErrorLocationKey: @(_currentToken.location)}];
		
		return nil;
	}

	
	SEL sel = sp.pointerValue;
	IMP imp = [self methodForSelector:sel];
	KTXPEnvironmentNode *(*incant)(id, SEL, KTXPEnvironmentOpen *) = (void *)imp;
	KTXPEnvironmentNode *envNode = incant(self, sel, open);
	
	[_contextStack pop];
	
	return envNode;
}

- (KTXPEnvironmentNode *) matrix:(KTXPEnvironmentOpen *)begin
{
	[self newStackFrame];
	
	while(_currentToken.type != KTXPTokenTypeEnvironmentClose)
	{
		[self incrementToken];
		[_currentFrame push:[self macro]];
		
		if(_lookahead == nil)
		{
			NSString *desc = [NSString stringWithFormat:@"Expected `\end{}` at index %lu but input ended.",
							  (unsigned long)(_currentToken.location + _currentToken.lexeme.length)];
			_parsingError = [NSError errorWithDomain:KTXPParserErrorDomain
												code:KTXPParserExpectedToken
											userInfo:@{NSLocalizedDescriptionKey: desc,
													   KTXPErrorLocationKey: @(_currentToken.location)}];
		}
	}
	
	NSArray *children = _currentFrame.array;
	
	[self restoreStackFrame];
	
	return [KTXPEnvironmentNode createWithBegin:begin
									   children:children
											end:[self endEnv:begin.env]];
}

- (KTXPEnvironmentNode *) matrixStar:(KTXPEnvironmentOpen *)begin
{
	[self newStackFrame];
	
	NSSet<NSString *> *allowed = [NSSet setWithObjects:@"l", @"c", @"r", nil];
	
	// FIXME: Update parameter code here to use new parameter node.
	if([_lookahead.lexeme isEqualToString:@"["])
	{
		[self incrementToken];
		[self incrementToken];
		
		if([allowed containsObject:_currentToken.lexeme])
		{
			[begin setArgs:@[_currentToken.lexeme.copy]];
		}
		else
		{
			NSString *desc = [NSString stringWithFormat:@"Expected `l`, `c`, or `r` at index %lu, but got %@.",
							  (unsigned long)(_currentToken.location + _currentToken.lexeme.length),
							  _currentToken.lexeme];
			_parsingError = [NSError errorWithDomain:KTXPParserErrorDomain
												code:KTXPParserUnexpectedToken
											userInfo:@{NSLocalizedDescriptionKey: desc,
															KTXPErrorLocationKey: @(_currentToken.location)}];
		}
		
		if(_lookahead == nil || ![_lookahead.lexeme isEqualToString:@"]"])
		{
			NSString *desc = [NSString stringWithFormat:@"Expected a `]` at index %lu.",
							  (unsigned long)(_currentToken.location + _currentToken.lexeme.length)];
			_parsingError = [NSError errorWithDomain:KTXPParserErrorDomain
												code:KTXPParserExpectedToken
											userInfo:@{NSLocalizedDescriptionKey: desc,
															KTXPErrorLocationKey: @(_currentToken.location)}];
		}
	}
	
	while(_currentToken.type != KTXPTokenTypeEnvironmentClose)
	{
		[self incrementToken];
		[_currentFrame push:[self macro]];
		
		if(_lookahead == nil)
		{
			NSString *desc = [NSString stringWithFormat:@"Expected `\end{}` at index %lu but input ended.",
							  (unsigned long)(_currentToken.location + _currentToken.lexeme.length)];
			_parsingError = [NSError errorWithDomain:KTXPParserErrorDomain
												code:KTXPParserExpectedToken
											userInfo:@{NSLocalizedDescriptionKey: desc,
													   KTXPErrorLocationKey: @(_currentToken.location)}];
		}
	}
	
	NSArray *children = _currentFrame.array;
	
	[self restoreStackFrame];
	
	return [KTXPEnvironmentNode createWithBegin:begin
									   children:children
											end:[self endEnv:begin.env]];
}

- (KTXPEnvironmentNode *) array:(KTXPEnvironmentOpen *)begin
{
	if([begin.env isEqualToString:darray])
	{
		_parsingError = [NSError errorWithDomain:KTXPParserErrorDomain
											code:KTXPParserUnexpectedToken
										userInfo:@{NSLocalizedDescriptionKey: @"`darray` is not a supported environment.",
												   KTXPErrorLocationKey: @(_currentToken.location)}];
	}
	
	[self newStackFrame];
	
	__block NSMutableArray *args = [NSMutableArray array];
	
	void (^subArrayBlock)(void) = ^{
		NSSet<NSString *> *allowed = [NSSet setWithObjects:@"l", @"c", @"r", nil];
		
		if(![allowed containsObject:self->_currentToken.lexeme])
		{
			NSString *desc = [NSString stringWithFormat:@"Unknown column alignment at index %lu.",
							  (unsigned long)(self->_currentToken.location + self->_currentToken.lexeme.length)];
			self->_parsingError = [NSError errorWithDomain:KTXPParserErrorDomain
												code:KTXPParserUnexpectedToken
											userInfo:@{NSLocalizedDescriptionKey: desc,
													   KTXPErrorLocationKey: @(self->_currentToken.location)}];
		}
		
		[args addObject:self->_currentToken.lexeme.copy];
		
		[self incrementToken];
		
		if(self->_currentToken.type != KTXPTokenTypeGroupClose)
		{
			NSString *desc = [NSString stringWithFormat:@"Expected `}` at index %lu, but got %@.",
							  (unsigned long)(self->_currentToken.location + self->_currentToken.lexeme.length),
							  self->_currentToken.lexeme];
			self->_parsingError = [NSError errorWithDomain:KTXPParserErrorDomain
												code:KTXPParserUnexpectedToken
											userInfo:@{NSLocalizedDescriptionKey: desc,
													   KTXPErrorLocationKey: @(self->_currentToken.location)}];
		}
		
		[self incrementToken];
	};
	void (^arrayBlock)(void) = ^{
		NSSet<NSString *> *align = [NSSet setWithObjects:@"l", @"c", @"r", nil];
		NSSet<NSString *> *lines = [NSSet setWithObjects:@":", @"|", nil];
		NSSet<NSString *> *allowed = [align setByAddingObjectsFromSet:lines];
		
		while(self->_currentToken.type != KTXPTokenTypeGroupClose)
		{
			if(![allowed containsObject:self->_currentToken.lexeme])
			{
				NSString *desc = [NSString stringWithFormat:@"Unknown column alignment at index %lu.",
								  (unsigned long)(self->_currentToken.location + self->_currentToken.lexeme.length)];
				self->_parsingError = [NSError errorWithDomain:KTXPParserErrorDomain
														  code:KTXPParserUnexpectedToken
													  userInfo:@{NSLocalizedDescriptionKey: desc,
																 KTXPErrorLocationKey: @(self->_currentToken.location)}];
			}
			
			[args addObject:self->_currentToken.lexeme.copy];
			[self incrementToken];
		}
	};
	
	if(![_lookahead.lexeme isEqualToString:@"{"])
	{
		NSString *desc = [NSString stringWithFormat:@"Column alignment parameter was expected at index %lu.",
						  (unsigned long)(self->_currentToken.location + self->_currentToken.lexeme.length)];
		self->_parsingError = [NSError errorWithDomain:KTXPParserErrorDomain
												  code:KTXPParserUnexpectedToken
											  userInfo:@{NSLocalizedDescriptionKey: desc,
														 KTXPErrorLocationKey: @(self->_currentToken.location)}];
	}
	
	[self incrementToken];
	[self incrementToken];
	
	if([begin.env isEqualToString:subarray]) { subArrayBlock(); } else { arrayBlock(); };
	
	[begin setArgs:args];
	
	while(_currentToken.type != KTXPTokenTypeEnvironmentClose)
	{
		[self incrementToken];
		[_currentFrame push:[self macro]];
		
		if(_lookahead == nil)
		{
			NSString *desc = [NSString stringWithFormat:@"Expected `\end{}` at index %lu but input ended.",
							  (unsigned long)(_currentToken.location + _currentToken.lexeme.length)];
			_parsingError = [NSError errorWithDomain:KTXPParserErrorDomain
												code:KTXPParserExpectedToken
											userInfo:@{NSLocalizedDescriptionKey: desc,
													   KTXPErrorLocationKey: @(_currentToken.location)}];
		}
	}
	
	NSArray *children = _currentFrame.array;
	
	[self restoreStackFrame];
	
	return [KTXPEnvironmentNode createWithBegin:begin
									   children:children
											end:[self endEnv:begin.env]];
}

- (KTXPEnvironmentNode *) cases:(KTXPEnvironmentOpen *)begin
{
	NSMutableArray *children = [NSMutableArray array];
	
	while(_currentToken.type != KTXPTokenTypeEnvironmentClose)
	{
		[self incrementToken];
		
		if([_currentToken.lexeme isEqualToString:@"&"])
		{
			NSString *desc = [NSString stringWithFormat:@"Unrecognized token `&` at location %lu.",
							  (unsigned long)(_currentToken.location + _currentToken.lexeme.length)];
			_parsingError = [NSError errorWithDomain:KTXPParserErrorDomain
												code:KTXPParserUnexpectedToken
											userInfo:@{NSLocalizedDescriptionKey: desc,
													   KTXPErrorLocationKey: @(_currentToken.location)}];
		}
		
		[children addObject:[self macro]];
		
		if(_lookahead == nil)
		{
			NSString *desc = [NSString stringWithFormat:@"Expected `\end{}` at index %lu but input ended.",
							  (unsigned long)(_currentToken.location + _currentToken.lexeme.length)];
			_parsingError = [NSError errorWithDomain:KTXPParserErrorDomain
												code:KTXPParserExpectedToken
											userInfo:@{NSLocalizedDescriptionKey: desc,
													   KTXPErrorLocationKey: @(_currentToken.location)}];
		}
	}
	
	return [KTXPEnvironmentNode createWithBegin:begin
									   children:children
											end:[self endEnv:begin.env]];
}

- (KTXPEnvironmentNode *) align:(KTXPEnvironmentOpen *)begin
{
	if([begin.env isEqualToString:alignat] || [begin.env isEqualToString:alignatStar])
	{
		if(_currentToken.type != KTXPTokenTypeGroupOpen)
		{
			NSString *desc = [NSString stringWithFormat:@"Expected a `{` at index %lu.",
							  (unsigned long)_lookahead.location];
			_parsingError = [NSError errorWithDomain:KTXPParserErrorDomain
												code:KTXPParserExpectedToken
											userInfo:@{NSLocalizedDescriptionKey: desc,
													   KTXPErrorLocationKey: @(_currentToken.location)}];
		}
		
		[self incrementToken];
		
		[begin setArgs:@[_currentToken.lexeme.copy]];
		
		if(_lookahead.type != KTXPTokenTypeGroupClose)
		{
			NSString *desc = [NSString stringWithFormat:@"Expected a `}` at index %lu.",
							  (unsigned long)_lookahead.location];
			_parsingError = [NSError errorWithDomain:KTXPParserErrorDomain
												code:KTXPParserExpectedToken
											userInfo:@{NSLocalizedDescriptionKey: desc,
													   KTXPErrorLocationKey: @(_currentToken.location)}];
		}
	}
	
	NSMutableArray *children = [NSMutableArray array];
	
	while(_currentToken.type != KTXPTokenTypeEnvironmentClose)
	{
		[self incrementToken];
		[children addObject:[self macro]];
		
		if(_lookahead == nil)
		{
			NSString *desc = [NSString stringWithFormat:@"Expected `\end{}` at index %lu but input ended.",
							  (unsigned long)(_currentToken.location + _currentToken.lexeme.length)];
			_parsingError = [NSError errorWithDomain:KTXPParserErrorDomain
												code:KTXPParserExpectedToken
											userInfo:@{NSLocalizedDescriptionKey: desc,
													   KTXPErrorLocationKey: @(_currentToken.location)}];
		}
	}
	
	return [KTXPEnvironmentNode createWithBegin:begin
									   children:children
											end:[self endEnv:begin.env]];
}

- (KTXPEnvironmentNode *) gather:(KTXPEnvironmentOpen *)begin
{
	NSMutableArray *children = [NSMutableArray array];
	
	while(_currentToken.type != KTXPTokenTypeEnvironmentClose)
	{
		[self incrementToken];
		
		if([_currentToken.lexeme isEqualToString:@"&"])
		{
			NSString *desc = [NSString stringWithFormat:@"Unrecognized token `&` at location %lu.",
							  (unsigned long)(_currentToken.location + _currentToken.lexeme.length)];
			_parsingError = [NSError errorWithDomain:KTXPParserErrorDomain
												code:KTXPParserUnexpectedToken
											userInfo:@{NSLocalizedDescriptionKey: desc,
													   KTXPErrorLocationKey: @(_currentToken.location)}];
		}
		
		[children addObject:[self macro]];
		
		if(_lookahead == nil)
		{
			NSString *desc = [NSString stringWithFormat:@"Expected `\end{}` at index %lu but input ended.",
							  (unsigned long)(_currentToken.location + _currentToken.lexeme.length)];
			_parsingError = [NSError errorWithDomain:KTXPParserErrorDomain
												code:KTXPParserExpectedToken
											userInfo:@{NSLocalizedDescriptionKey: desc,
													   KTXPErrorLocationKey: @(_currentToken.location)}];
		}
	}
	
	return [KTXPEnvironmentNode createWithBegin:begin
									   children:children
											end:[self endEnv:begin.env]];
}

- (KTXPEnvironmentNode *) equation:(KTXPEnvironmentOpen *)begin
{
	NSMutableArray *children = [NSMutableArray array];
	// TODO: Does not compensate for lines breaks with measurements, unsure if we need to fix that.
	NSSet *notAllowed = [NSSet setWithObjects:@"&", @"\\\\", @"\\cr", nil];
	
	while(_currentToken.type != KTXPTokenTypeEnvironmentClose)
	{
		[self incrementToken];
		
		if([notAllowed containsObject:_currentToken.lexeme])
		{
			NSString *desc = [NSString stringWithFormat:@"Unrecognized token `%@` at location %lu.",
							  _currentToken.lexeme,
							  (unsigned long)(_currentToken.location + _currentToken.lexeme.length)];
			_parsingError = [NSError errorWithDomain:KTXPParserErrorDomain
												code:KTXPParserUnexpectedToken
											userInfo:@{NSLocalizedDescriptionKey: desc,
													   KTXPErrorLocationKey: @(_currentToken.location)}];
		}
		
		[children addObject:[self macro]];
		
		if(_lookahead == nil)
		{
			NSString *desc = [NSString stringWithFormat:@"Expected `\end{}` at index %lu but input ended.",
							  (unsigned long)(_currentToken.location + _currentToken.lexeme.length)];
			_parsingError = [NSError errorWithDomain:KTXPParserErrorDomain
												code:KTXPParserExpectedToken
											userInfo:@{NSLocalizedDescriptionKey: desc,
													   KTXPErrorLocationKey: @(_currentToken.location)}];
		}
	}
	
	return [KTXPEnvironmentNode createWithBegin:begin
									   children:children
											end:[self endEnv:begin.env]];
}

- (KTXPEnvironmentClose *) endEnv:(KTXPEnvironment)env
{
	KTXPToken *endCp = _currentToken.copy;
	
	if(_lookahead.type != KTXPTokenTypeGroupOpen)
	{
		NSString *desc = [NSString stringWithFormat:@"Expected a `{` at index %lu.",
						  (unsigned long)(_currentToken.location + _currentToken.lexeme.length)];
		_parsingError = [NSError errorWithDomain:KTXPParserErrorDomain
											code:KTXPParserExpectedToken
										userInfo:@{NSLocalizedDescriptionKey: desc,
												   KTXPErrorLocationKey: @(_currentToken.location)}];
	}
	
	[self incrementToken];
	[self incrementToken];
	
	if(![_currentToken.lexeme isEqualToString:env])
	{
		NSString *desc = [NSString stringWithFormat:@"Environment Closing at index %lu does not match Environment Opening.",
						  (unsigned long)(_currentToken.location + _currentToken.lexeme.length)];
		_parsingError = [NSError errorWithDomain:KTXPParserErrorDomain
											code:KTXPParserExpectedToken
										userInfo:@{NSLocalizedDescriptionKey: desc,
												   KTXPErrorLocationKey: @(_currentToken.location)}];
	}
	
	if(_lookahead.type != KTXPTokenTypeGroupClose)
	{
		NSString *desc = [NSString stringWithFormat:@"Expected a `}` at index %lu.",
						  (unsigned long)(_currentToken.location + _currentToken.lexeme.length)];
		_parsingError = [NSError errorWithDomain:KTXPParserErrorDomain
											code:KTXPParserExpectedToken
										userInfo:@{NSLocalizedDescriptionKey: desc,
												   KTXPErrorLocationKey: @(_currentToken.location)}];
	}
	
	[self restoreStackFrame];
	
	return [KTXPEnvironmentClose createWithBoundary:endCp env:env];
}

#pragma mark - RD > Special Functions

- (__kindof KTXPTreeNode *) specialFunction
{
	NSDictionary *symbolDict = [KTXPSymbols.summon lookupLexeme:_currentToken.lexeme
														 inMode:_mode];
	KTXPMacroType mtype = ((NSNumber *)[symbolDict valueForKey:SpecialKind]).unsignedIntegerValue;
	
	switch(mtype)
	{
		case KTXPMacroTypeSupSub:
			return [self supSub:YES];
			
		case KTXPMacroTypePrePost:
			return [self prePost];
		
		/*case KTXPMacroTypePre:
			return [self pre];
			
		case KTXPMacroTypePost:
			return [self post];*/
			
		case KTXPMacroTypeGroupOpen:
			return [self macroTypeGroup];
			
		case KTXPMacroTypeNone:
		{
			// TODO: Convert to dict
			if([_currentToken.lexeme isEqualToString:@"\\sqrt"])
			{
				return [self sqrt];
			}
			else if([_currentToken.lexeme isEqualToString:@"\\verb"])
			{
				return [self verb];
			}
			else if([_currentToken.lexeme isEqualToString:@"\\kern"] ||
					[_currentToken.lexeme isEqualToString:@"\\mkern"])
			{
				return [self kern];
			}
			else if([_currentToken.lexeme isEqualToString:@"\\limits"])
			{
				return [self limits];
			}
			else if([_currentToken.lexeme isEqualToString:@"\\llap"])
			{
				return [self llap];
			}
			else if([_currentToken.lexeme isEqualToString:@"\\overbrace"])
			{
				return [self overbrace];
			}
			else if([_currentToken.lexeme isEqualToString:@"\\underbrace"])
			{
				return [self underbrace];
			}
			else if([_currentToken.lexeme isEqualToString:@"\\rlap"])
			{
				return [self rlap];
			}
			
			return nil;
		}
		
		default:
		{
			NSString *desc = [NSString stringWithFormat:@"An unexpected macro was given at index: %lu got %@. Expected a special function macro.",
							  (unsigned long)(_currentToken.location + _currentToken.lexeme.length),
							  _currentToken.lexeme];
			_parsingError = [NSError errorWithDomain:KTXPParserErrorDomain
												code:KTXPParserUnexpectedToken
											userInfo:@{NSLocalizedDescriptionKey: desc,
													   KTXPErrorLocationKey: @(_currentToken.location)}];
			
			return nil;
		}
	}
}

- (KTXPMacroGroupNode *)macroTypeGroup
{
	[self newStackFrame];
	
	KTXPToken *l = [_currentToken copy];
	
	[self incrementToken];
	
	NSDictionary *sym = [[KTXPSymbols summon] lookupLexeme:_currentToken.lexeme
													inMode:_mode];
	NSNumber *spec = [sym objectForKey:SpecialKind];
	BOOL invalidSpec = (spec == nil ||
						spec.unsignedIntegerValue != KTXPMacroTypeLeft ||
						spec.unsignedIntegerValue != KTXPMacroTypeRight);
	
	if(![_currentToken.lexeme isEqualToString:@"."] && invalidSpec)
	{
		NSString *desc = [NSString stringWithFormat:@"Expected a delimiter at index %lu, but got %@.",
						  (unsigned long)(_currentToken.location + _currentToken.lexeme.length),
						  _currentToken.lexeme];
		_parsingError = [NSError errorWithDomain:KTXPParserErrorDomain
											code:KTXPParserExpectedToken
										userInfo:@{NSLocalizedDescriptionKey: desc,
												   KTXPErrorLocationKey: @(_currentToken.location)}];
		[self restoreStackFrame];
		
		return nil;
	}
	
	KTXPFunctionNode *lFn = [KTXPFunctionNode createWithToken:l
													arguments:@[_currentToken.copy]];
	
	if([self incrementToken] == NO)
	{
		NSString *desc = [NSString stringWithFormat:@"Expected `\right` at index %lu, but got %@.",
						  (unsigned long)(_currentToken.location + _currentToken.lexeme.length),
						  _currentToken.lexeme];
		_parsingError = [NSError errorWithDomain:KTXPParserErrorDomain
											code:KTXPParserExpectedToken
										userInfo:@{NSLocalizedDescriptionKey: desc,
												   KTXPErrorLocationKey: @(_currentToken.location)}];
		
		return nil;
	}
	
	BOOL keepAdding = YES;
	
	do {
		sym = [[KTXPSymbols summon] lookupLexeme:_currentToken.lexeme
										  inMode:_mode];
		spec = [sym objectForKey:SpecialKind];
		
		if(spec != nil && spec.unsignedIntegerValue == KTXPMacroTypeRight)
		{
			keepAdding = NO;
			
			break;
		}
		
		[_currentFrame push:[self macro]];
		
		if([self incrementToken] == NO)
		{
			NSString *desc = [NSString stringWithFormat:@"Expected a `\right` at index %lu, but got %@.",
							  (unsigned long)(_currentToken.location + _currentToken.lexeme.length),
							  _currentToken.lexeme];
			_parsingError = [NSError errorWithDomain:KTXPParserErrorDomain
												code:KTXPParserExpectedToken
											userInfo:@{NSLocalizedDescriptionKey: desc,
													   KTXPErrorLocationKey: @(_currentToken.location)}];
			return nil;
		}
	} while(keepAdding);
	
	NSArray<__kindof KTXPTreeNode *> *elems = [_currentFrame copy];
	KTXPToken *r = [_currentToken copy];
	
	if([self incrementToken] == NO)
	{
		NSString *desc = [NSString stringWithFormat:@"Expected a function argument at index %lu but input ended.",
						  (unsigned long)(_currentToken.location + _currentToken.lexeme.length)];
		
		_parsingError = [NSError errorWithDomain:KTXPParserErrorDomain
											code:KTXPParserExpectedToken
										userInfo:@{NSLocalizedDescriptionKey: desc,
												   KTXPErrorLocationKey: @(_currentToken.location)}];
		
		return nil;
	}
	
	sym = [[KTXPSymbols summon] lookupLexeme:_currentToken.lexeme
													inMode:_mode];
	spec = [sym objectForKey:SpecialKind];
	invalidSpec = (spec == nil ||
				   spec.unsignedIntegerValue != KTXPMacroTypeLeft ||
				   spec.unsignedIntegerValue != KTXPMacroTypeRight);
	
	if(![_currentToken.lexeme isEqualToString:@"."] && invalidSpec)
	{
		NSString *desc = [NSString stringWithFormat:@"Expected a delimiter at index %lu, but got %@.",
						  (unsigned long)(_currentToken.location + _currentToken.lexeme.length),
						  _currentToken.lexeme];
		_parsingError = [NSError errorWithDomain:KTXPParserErrorDomain
											code:KTXPParserExpectedToken
										userInfo:@{NSLocalizedDescriptionKey: desc,
												   KTXPErrorLocationKey: @(_currentToken.location)}];
		[self restoreStackFrame];
		
		return nil;
	}
	
	KTXPFunctionNode *rFn = [KTXPFunctionNode createWithToken:r
													arguments:@[_currentToken.copy]];
	
	[self restoreStackFrame];
	
	return [KTXPMacroGroupNode createWithLeft:lFn elements:elems right:rFn];
}

- (KTXP_RLapNode *) rlap
{
	[self newStackFrame];
	[self incrementToken];
	
	__kindof KTXPTreeNode *first = [self macro];
	
	if(first == nil)
	{
		NSString *desc = [NSString stringWithFormat:@"Expected an argument for function `rlap` at index %lu, but got nothing.",
						  (unsigned long)(_currentToken.location + _currentToken.lexeme.length)];
		_parsingError = [NSError errorWithDomain:KTXPParserErrorDomain
											code:KTXPParserExpectedToken
										userInfo:@{NSLocalizedDescriptionKey: desc,
												   KTXPErrorLocationKey: @(_currentToken.location)}];
	}
	
	[self incrementToken];
	
	__kindof KTXPTreeNode *second = [self macro];
	
	[self restoreStackFrame];
	
	return [KTXP_RLapNode createWithOverlay:first Right:second];
}

- (KTXPUnderbraceNode *) underbrace
{
	__kindof KTXPTreeNode *main;
	
	[self incrementToken];
	
	switch(_currentToken.type)
	{
		case KTXPTokenTypeGroupOpen:
			main = [self group:NO];
		break;
			
		case KTXPTokenTypeAtom:
			main = [self atom];
		break;
			
		default:{
			NSString *desc = [NSString stringWithFormat:@"Expected an argument for `\\underbrace` at index %lu.",
							  (unsigned long)(_currentToken.location + _currentToken.lexeme.length)];
			_parsingError = [NSError errorWithDomain:KTXPParserErrorDomain
												code:KTXPParserExpectedToken
											userInfo:@{NSLocalizedDescriptionKey: desc,
													   KTXPErrorLocationKey: @(_currentToken.location)}];
			
			return nil;
		}
	}
	
	KTXPSupSubNode *sub;
	
	if([_lookahead.lexeme isEqualToString:@"_"])
	{
		[self incrementToken];
		
		sub = [self supSub:NO];
	}
	
	return [KTXPUnderbraceNode createWithGroup:main Under:sub];
}

- (KTXPOverbraceNode *) overbrace
{
	__kindof KTXPTreeNode *main;
	
	[self incrementToken];
	
	switch(_currentToken.type)
	{
		case KTXPTokenTypeGroupOpen:
			main = [self group:NO];
			break;
			
		case KTXPTokenTypeAtom:
			main = [self atom];
			break;
			
		default:
		{
			NSString *desc = [NSString stringWithFormat:@"Expected an argument for `\\overbrace` at index %lu.",
							  (unsigned long)(_currentToken.location + _currentToken.lexeme.length)];
			_parsingError = [NSError errorWithDomain:KTXPParserErrorDomain
												code:KTXPParserExpectedToken
											userInfo:@{NSLocalizedDescriptionKey: desc,
													   KTXPErrorLocationKey: @(_currentToken.location)}];
			
			return nil;
		}
	}
	
	KTXPSupSubNode *sup;
	
	if([_lookahead.lexeme isEqualToString:@"^"])
	{
		[self incrementToken];
		
		sup = [self supSub:NO];
	}
	
	return [KTXPOverbraceNode createWithGroup:main Over:sup];
}

- (KTXPKernNode *) kern
{
	// mkern works like kern except it only works in math mode.
	
	// The braces are optional, what matters is a measurement.
	// A measurement is a number followed by a unit string.
	// It seems that everything after the measurement (even within a brace)
	// is ignored after the measurement is parsed. Even if there is more
	// than one measurement, only the first one is recognized.
	// The following examples all work the same:
	// gfd\mkern{dkasm15mm}gfd
	// gfd\mkern{15mm16mm}gfd
	// gfd\mkern15mmgfd
	// However, this one doesn't work:
	// gfd\mkern{fgdsdf}gfd
	// Negative numbers are allowed:
	// gfd\mkern{-5mm}gfd
	// As are fractional ones:
	// gfd\mkern{5.5mm}gfd
	// gfd\mkern{.5mm}gfd
	
	[self incrementToken];
	
	id val;
	
	if(_currentToken.type == KTXPTokenTypeGroupOpen)
	{
		KTXPGroupNode *grp = [self group:NO];
		val = [NSMutableArray array];
		
		for(NSUInteger i = 0; i < grp.elements.count; i++)
		{
			KTXPAtomNode *node = [grp.elements objectAtIndex:i];
			
			if([node isKindOfClass:KTXPAtomNode.class])
			{
				[val addObject:node];
			}
		}
		
		if(![self verifyMeasurement:val])
		{
			NSString *desc = [NSString stringWithFormat:@"Expected a measurement at location %lu.",
							  (unsigned long)(_currentToken.location + _currentToken.lexeme.length)];
			_parsingError = [NSError errorWithDomain:KTXPParserErrorDomain
												code:KTXPParserExpectedToken
											userInfo:@{NSLocalizedDescriptionKey: desc,
													   KTXPErrorLocationKey: @(_currentToken.location)}];
			
			return nil;
		}
	}
	else
	{
		val = [self measurement];
	}
	
	return [KTXPKernNode createWithMeasurement:val];
}

- (KTXP_LLapNode *) llap
{
	[self incrementToken];
	
	if(_currentToken.type != KTXPTokenTypeGroupOpen)
	{
		NSString *desc = [NSString stringWithFormat:@"Expected a group argument for `\\llap` at index %lu.",
						  (unsigned long)(_currentToken.location + _currentToken.lexeme.length)];
		_parsingError = [NSError errorWithDomain:KTXPParserErrorDomain
											code:KTXPParserExpectedToken
										userInfo:@{NSLocalizedDescriptionKey: desc,
												   KTXPErrorLocationKey: @(_currentToken.location)}];
	}
	
	KTXPGroupNode *grp = [self group:NO];
	__kindof KTXPTreeNode *left = [_parsed.lastObject copy];
	
	[_parsed removeLastObject];
	
	return [KTXP_LLapNode createWithOverlay:grp Left:left];
}

- (KTXPLimitsNode *) limits
{
	/*
	 A math operator is basically just an atom macro, but this function requires just that
	 type of macro so I have to discern them.
	 */
	KTXPAtomNode *mathOp = [_currentFrame.lastObject copy];
	//KTXPAtomNode *mathOp = [[_parsed objectAtIndex:(_parsed.count - 1)] copy];
	
	if(!([mathOp isMemberOfClass:KTXPAtomNode.class] &&
		 mathOp.token.type == KTXPTokenTypeMathOp))
	{
		NSString *desc = [NSString stringWithFormat:@"Expected a math operator at index %lu, but got %@.",
						  (unsigned long)(_currentToken.location + _currentToken.lexeme.length),
						  _currentToken.lexeme];
		_parsingError = [NSError errorWithDomain:KTXPParserErrorDomain
											code:KTXPParserExpectedToken
										userInfo:@{NSLocalizedDescriptionKey: desc,
												   KTXPErrorLocationKey: @(_currentToken.location)}];
	}
	
	[self incrementToken];
	
	if(!([_currentToken.lexeme isEqualToString:@"^"] ||
		 [_currentToken.lexeme isEqualToString:@"_"]))
	{
		NSString *desc = [NSString stringWithFormat:@"Expected a `^` or `_` at index %lu, but got %@.",
						  (unsigned long)(_currentToken.location + _currentToken.lexeme.length),
						  _currentToken.lexeme];
		
		_parsingError = [NSError errorWithDomain:KTXPParserErrorDomain
											code:KTXPParserExpectedToken
										userInfo:@{NSLocalizedDescriptionKey: desc,
												   KTXPErrorLocationKey: @(_currentToken.location)}];
	}
	
	KTXPSupSubNode *ssn = [self supSub:YES];
	
	return [KTXPLimitsNode createWithMathOp:mathOp andLimits:ssn];
}

- (KTXPVerbatimNode *) verb
{
	/*
	 Takes the arguments and literally types it out as text. Means verbatim.
	 Needs a delimiting character both before and after the argument.
	 Usual delims are {(|})|.*-~_!
	 The delimiter is the same character you open with. For example, if you open with {
	 then the closing delimiter is { NOT }.
	 The argument is just literally displayed as text, not executed.
	 Linebreaks are not allowed.
	 
	 We do not care about executing macros or building a tree here. We simply care about
	 their textual value. Which means, we only need the tokens.
	 */
	NSSet <NSString *> *delims = [NSSet setWithArray:@[@"{",
													   @"(",
													   @"|",
													   @"}",
													   @")",
													   @"|",
													   @".",
													   @"*",
													   @"-",
													   @"~",
													   @"_",
													   @"!",
													   @" " /* space */]];
	
	if(_lookahead == nil || ![delims containsObject:_lookahead.lexeme])
	{
		NSString *desc = [NSString stringWithFormat:@"Expected a delimiter at index %lu but input ended.",
						  (unsigned long)(_currentToken.location + _currentToken.lexeme.length)];
		_parsingError = [NSError errorWithDomain:KTXPParserErrorDomain
											code:KTXPParserExpectedToken
										userInfo:@{NSLocalizedDescriptionKey: desc,
												   KTXPErrorLocationKey: @(_currentToken.location)}];
	}
	
	[self incrementToken];
	[self newStackFrame];
	
	KTXPToken *delim = _currentToken.copy;
	
	while(![_lookahead.lexeme isEqualToString:delim.lexeme])
	{
		if([self incrementToken] == NO)
		{
			NSString *desc = [NSString stringWithFormat:@"Ended by end of line instead of matching delimiter. Location: %lu",
							  (unsigned long)(_currentToken.location + _currentToken.lexeme.length)];
			_parsingError = [NSError errorWithDomain:KTXPParserErrorDomain
												code:KTXPParserExpectedToken
											userInfo:@{NSLocalizedDescriptionKey: desc,
													   KTXPErrorLocationKey: @(_currentToken.location)}];
			
			[self restoreStackFrame];
			
			return nil;
		}
		
		[_currentFrame push:_currentToken.copy];
	}
	
	KTXPToken *delimClose = _currentToken.copy;
	NSArray<KTXPToken *> *toks =  _currentFrame.array;
	
	[self restoreStackFrame];
	
	return [KTXPVerbatimNode createWithDelimiter:delim
										elements:toks
								   closeLocation:delimClose.location];
}

- (KTXPSquareRoot *) sqrt
{
	if(_lookahead == nil)
	{
		NSString *desc = [NSString stringWithFormat:@"Expected an argument for root function at location %lu but input ended.",
						  (unsigned long)(_currentToken.location + _currentToken.lexeme.length)];
		_parsingError = [NSError errorWithDomain:KTXPParserErrorDomain
											code:KTXPParserExpectedToken
										userInfo:@{NSLocalizedDescriptionKey: desc,
												   KTXPErrorLocationKey: @(_currentToken.location)}];
	}
	
	[self incrementToken];
	
	id power;
	id radicand;
	
	// FIXME: Look at this again. The parameter can be more than one macro long.
	
	if([_currentToken.lexeme isEqualToString:@"["])
	{
		KTXPToken *open = _currentToken.copy;
		NSMutableArray<__kindof KTXPTreeNode *> *members = [NSMutableArray new];
		
		[self incrementToken];
		
		while(![_currentToken.lexeme isEqualToString:@"]"])
		{
			[members addObject:[self macro]];
			
			if(_lookahead == nil)
			{
				NSString *desc = [NSString stringWithFormat:@"Expected a `]` for root function at index %lu.",
								  (unsigned long)(_currentToken.location + _currentToken.lexeme.length)];
				_parsingError = [NSError errorWithDomain:KTXPParserErrorDomain
													code:KTXPParserExpectedToken
												userInfo:@{NSLocalizedDescriptionKey: desc,
														   KTXPErrorLocationKey: @(_currentToken.location)}];
				
				break;
			}
			
			[self incrementToken];
		}
		
		power = [KTXPParameterNode createAtomsParameterNode:open atoms:members close:_currentToken.copy];
	}
	
	
	if([_lookahead.lexeme isEqualToString:@"{"])
	{
		radicand = [self group:NO];
	}
	else if(_lookahead != nil)
	{
		// Get the next macro after this and use that.
		[self incrementToken];
		
		radicand = [self macro];
	}
	else
	{
		NSString *desc = [NSString stringWithFormat:@"Expected an argument for root function at location %lu.",
						  (unsigned long)(_currentToken.location + _currentToken.lexeme.length)];
		_parsingError = [NSError errorWithDomain:KTXPParserErrorDomain
											code:KTXPParserExpectedToken
										userInfo:@{NSLocalizedDescriptionKey: desc,
												   KTXPErrorLocationKey: @(_currentToken.location)}];
	}
	
	return [KTXPSquareRoot createWithIndex:power radicand:radicand];
}
/*
- (KTXPPrePostNode *) pre
{
	
}

- (KTXPPrePostNode *) post
{
	
}*/

- (KTXPPrePostNode *) prePost
{
	/*
	 Something interesting to note is that there can only be 1 "infix" operator per group at a time.
	 Implied groups are usually only 1 macro long. Therefore, if we're in an implied group context,
	 then since we're already the macro that can be in it, we don't have to do much except make the
	 children in the node nil.
	 
	 If we're not in an implicit group context, we're either in a group, or in the main starting
	 context. The main starting context is treated like an implicit group but we know the bounds
	 so that's not really an issue we just go to the beginning, and then the end. If we're in an
	 explicit group, then we just move in both directions until we see a token type of
	 GroupOpen/GroupClose. We put the pre- into an array, and the post- into another array for
	 the prepost node.
	 
	 UPDATE:
	 I don't think this is going to work as parsed isn't built yet if we're inside a group.
	 Instead we have to rewrite a bunch of the parser to use stack frames and just restore them.
	 The general gist of how this is going to work now is when in a group, we're in a stack frame
	 just for the group. We can absorb whatevers in the frame at that point, and then add it to the
	 pre- part of the node. Then refill it with stuff to the end of the group. Then again, absorb
	 whats in the stack and put it in the post- part of the node. At the end of this, the group
	 node will only contain the infix operator within the stack frame / node.
	 
	 This requires we don't start a new stack frame.
	 */
	NSNumber *cNum = [_contextStack peek];
	KTXPContext c  = [cNum unsignedIntegerValue];
	KTXPToken *fnT = _currentToken.copy;
	NSArray<__kindof KTXPTreeNode *> *before = @[];
	NSArray<__kindof KTXPTreeNode *> *after  = @[];
	
	if(c == KTXPContextGroup)
	{
		before = _currentFrame.array;
		
		[_currentFrame clear];
		
		while([self incrementToken] == YES)
		{
			if(_currentToken.type == KTXPTokenTypeGroupClose)
			{
				after = _currentFrame.array;
				
				[_currentFrame clear];
					
				return [KTXPPrePostNode createWithPre:before.copy dec:fnT post:after.copy];
			}
			
			[_currentFrame push:[self macro]];
		}
		
		NSString *desc = [NSString stringWithFormat:@"Expected a `}` at index %lu, but got %@.",
						  (unsigned long)(_currentToken.location + _currentToken.lexeme.length),
						  _currentToken.lexeme];
		_parsingError = [NSError errorWithDomain:KTXPParserErrorDomain
											code:KTXPParserExpectedToken
										userInfo:@{NSLocalizedDescriptionKey: desc,
												   KTXPErrorLocationKey: @(_currentToken.location)}];
		return nil;
	}
	
	return [KTXPPrePostNode createWithPre:before.copy dec:fnT post:after.copy];
}

// After means we expect the second half after the first function (YES means _^ or ^_ instead of just ^ or _).
- (KTXPSupSubNode *) supSub:(BOOL)after
{
	const NSDictionary<NSString *, NSString *> *contDict = @{@"^": @"_",
															 @"_": @"^"};
		   BOOL wasSup = [_currentToken.lexeme isEqualToString:@"^"] ? YES : NO;
	NSString *expected = [contDict objectForKey:_currentToken.lexeme];
	
	[_contextStack push:(wasSup ? @(KTXPContextSuperscript) : @(KTXPContextSubscript))];
	
	if(_lookahead == nil ||
	  [_lookahead.lexeme isEqualToString:@"^"] ||
	  [_lookahead.lexeme isEqualToString:@"_"])
	{
		// KaTeX stops parsing upon error.
		unichar 	 c = wasSup ? '^' : '_';
		NSString *desc = [NSString stringWithFormat:@"Expected a group after '%c' at position %lu.",
						  c, (unsigned long)(_currentTokenIndex + 1)];
		
		_parsingError = [NSError errorWithDomain:KTXPParserErrorDomain
											code:KTXPParserExpectedGroup
										userInfo:@{NSLocalizedDescriptionKey: desc,
												   KTXPErrorLocationKey: @(_currentTokenIndex)}];
		
		if(wasSup) return [KTXPSupSubNode createWithSup:[KTXPGroupNode createWithOpen:nil
																			 elements:@[]
																				close:nil]
													Sub:nil];
		else return [KTXPSupSubNode createWithSup:nil
											  Sub:[KTXPGroupNode createWithOpen:nil
																	   elements:@[]
																		  close:nil]];
	}
	
	[self incrementToken];
	
	KTXPGroupNode *g1 = [self group:(_currentToken.type != KTXPTokenTypeGroupOpen)];
	
	// Just cause after is YES doesn't mean that we'll always get whats expected.
	// What if we have x^2y^2
	if(after == YES && [_lookahead.lexeme isEqualToString:expected])
	{
		if(_lookahead == nil)
		{
			// KaTeX stops parsing upon error.
			unichar c = !wasSup ? '^' : '_';
			NSString *desc = [NSString stringWithFormat:@"Expected a group after '%c' at position %lu.",
							  c, (unsigned long)(_currentTokenIndex + 1)];
			
			_parsingError = [NSError errorWithDomain:KTXPParserErrorDomain
												code:KTXPParserExpectedGroup
											userInfo:@{NSLocalizedDescriptionKey: desc,
													   KTXPErrorLocationKey: @(_currentTokenIndex)}];
			
			return (wasSup) ? [KTXPSupSubNode createWithSup:g1 Sub:nil]
							: [KTXPSupSubNode createWithSup:nil Sub:g1];
		}
		
		[self incrementToken];
		
		KTXPGroupNode *g2 = [self group:(_currentToken.type != KTXPTokenTypeGroupOpen)];
		
		return [KTXPSupSubNode createWithSup:g1 Sub:g2];
	}
	
	[_contextStack pop];
	
	return wasSup ? [KTXPSupSubNode createWithSup:g1 Sub:nil] :
					[KTXPSupSubNode createWithSup:nil Sub:g1];
}

- (NSArray<KTXPAtomNode *> *) measurement
{
	NSMutableArray<KTXPAtomNode *> *mes = [NSMutableArray array];
	
	[_contextStack push:@(KTXPContextMeasurement)];
	
	if([self incrementToken] == NO)
	{
		NSString *desc = [NSString stringWithFormat:@"Expected a measurement at location %lu.",
						  (unsigned long)(_currentToken.location + _currentToken.lexeme.length)];
		_parsingError = [NSError errorWithDomain:KTXPParserErrorDomain
											code:KTXPParserExpectedToken
										userInfo:@{NSLocalizedDescriptionKey: desc,
												   KTXPErrorLocationKey: @(_currentToken.location)}];
		
		return @[];
	}
	
	if([_currentToken.lexeme isEqualToString:@"-"] && [self incrementToken] == NO)
	{
		NSString *desc = [NSString stringWithFormat:@"Expected a measurement at location %lu.",
						  (unsigned long)(_currentToken.location + _currentToken.lexeme.length)];
		_parsingError = [NSError errorWithDomain:KTXPParserErrorDomain
											code:KTXPParserExpectedToken
										userInfo:@{NSLocalizedDescriptionKey: desc,
												   KTXPErrorLocationKey: @(_currentToken.location)}];
		
		return @[];
	}
	
	BOOL dot = NO;
	
	do {
		if([_currentToken.lexeme isEqualToString:@"."])
		{
			if(dot == YES)
			{
				// FIXME: error in measurement
				return @[];
			}
			
			dot = YES;
			
			[mes addObject:[self atom]];
		}
		else if([_currentToken.lexeme isEqualToString:@"0"] ||
				[_currentToken.lexeme isEqualToString:@"1"] ||
				[_currentToken.lexeme isEqualToString:@"2"] ||
				[_currentToken.lexeme isEqualToString:@"3"] ||
				[_currentToken.lexeme isEqualToString:@"4"] ||
				[_currentToken.lexeme isEqualToString:@"5"] ||
				[_currentToken.lexeme isEqualToString:@"6"] ||
				[_currentToken.lexeme isEqualToString:@"7"] ||
				[_currentToken.lexeme isEqualToString:@"8"] ||
				[_currentToken.lexeme isEqualToString:@"9"])
		{ [mes addObject:[self atom]]; }
		else { break; }
	} while([self incrementToken] == YES);
	
	if([_currentToken.lexeme isEqualToString:@"b"]) {
		[mes addObject:[self atom]];
		
		if([self incrementToken] == NO ||
		   ![_currentToken.lexeme isEqualToString:@"p"])
		{
			// FIXME: Error unrecognized unit
			return nil;
		}
		
		[mes addObject:[self atom]];
	}
	else if([_currentToken.lexeme isEqualToString:@"c"]) {
		[mes addObject:[self atom]];
		
		if([self incrementToken] == NO ||
		   [_currentToken.lexeme isEqualToString:@"c"] ||
		   [_currentToken.lexeme isEqualToString:@"m"])
		{
			// FIXME: Error unrecognized unit
			return nil;
		}
		
		[mes addObject:[self atom]];
	}
	else if([_currentToken.lexeme isEqualToString:@"d"]) {
		[mes addObject:[self atom]];
		
		if([self incrementToken] == NO ||
		   ![_currentToken.lexeme isEqualToString:@"d"])
		{
			// FIXME: Error unrecognized unit
			return nil;
		}
		
		[mes addObject:[self atom]];
	}
	else if([_currentToken.lexeme isEqualToString:@"e"]) {
		[mes addObject:[self atom]];
		
		if([self incrementToken] == NO ||
		   [_currentToken.lexeme isEqualToString:@"m"] ||
		   [_currentToken.lexeme isEqualToString:@"x"])
		{
			// FIXME: Error unrecognized unit
			return nil;
		}
		
		[mes addObject:[self atom]];
	}
	else if([_currentToken.lexeme isEqualToString:@"i"]) {
		[mes addObject:[self atom]];
		
		if([self incrementToken] == NO ||
		   ![_currentToken.lexeme isEqualToString:@"n"])
		{
			// FIXME: Error unrecognized unit
			return nil;
		}
		
		[mes addObject:[self atom]];
	}
	else if([_currentToken.lexeme isEqualToString:@"m"]) {
		[mes addObject:[self atom]];
		
		if([self incrementToken] == NO ||
		   [_currentToken.lexeme isEqualToString:@"m"] ||
		   [_currentToken.lexeme isEqualToString:@"u"])
		{
			// FIXME: Error unrecognized unit
			return nil;
		}
		
		[mes addObject:[self atom]];
	}
	else if([_currentToken.lexeme isEqualToString:@"n"]) {
		[mes addObject:[self atom]];
		
		if([self incrementToken] == NO ||
		   [_currentToken.lexeme isEqualToString:@"c"] ||
		   [_currentToken.lexeme isEqualToString:@"d"])
		{
			// FIXME: Error unrecognized unit
			return nil;
		}
		
		[mes addObject:[self atom]];
	}
	else if([_currentToken.lexeme isEqualToString:@"p"]) {
		[mes addObject:[self atom]];
		
		if([self incrementToken] == NO ||
		   [_currentToken.lexeme isEqualToString:@"c"] ||
		   [_currentToken.lexeme isEqualToString:@"t"])
		{
			// FIXME: Error unrecognized unit
			return nil;
		}
		
		[mes addObject:[self atom]];
	}
	else if([_currentToken.lexeme isEqualToString:@"s"]) {
		[mes addObject:[self atom]];
		
		if([self incrementToken] == NO ||
		   ![_currentToken.lexeme isEqualToString:@"p"])
		{
			// FIXME: Error unrecognized unit
			return nil;
		}
		
		[mes addObject:[self atom]];
	}
	
	[_contextStack pop];
	
	return mes;
}

- (BOOL) verifyMeasurement:(NSArray<KTXPAtomNode *> *)atoms
{
	if(atoms.count == 0) { return NO; }
	
	BOOL dot = NO;
	__block NSUInteger i = 0;
	__block KTXPAtomNode *cur = [atoms objectAtIndex:i];
	
	if([[atoms objectAtIndex:i].token.lexeme isEqualToString:@"-"])
	{
		i = 1;
	}
	
	while(i < atoms.count)
	{
		if([cur.token.lexeme isEqualToString:@"."])
		{
			if(dot == YES)
			{
				// FIXME: error
				return NO;
			}
			
			dot = YES;
			i += 1;
		}
		else if([cur.token.lexeme isEqualToString:@"0"] ||
				[cur.token.lexeme isEqualToString:@"1"] ||
				[cur.token.lexeme isEqualToString:@"2"] ||
				[cur.token.lexeme isEqualToString:@"3"] ||
				[cur.token.lexeme isEqualToString:@"4"] ||
				[cur.token.lexeme isEqualToString:@"5"] ||
				[cur.token.lexeme isEqualToString:@"6"] ||
				[cur.token.lexeme isEqualToString:@"7"] ||
				[cur.token.lexeme isEqualToString:@"8"] ||
				[cur.token.lexeme isEqualToString:@"9"])
		{
			i++;
		}
		else
		{
			break;
		}
	}
	
	BOOL (^advance)(void) = ^BOOL() {
		if(i + 1 >= atoms.count)
		{
			// FIXME: Error
			return NO;
		}
		
		i += 1;
		cur = [atoms objectAtIndex:i];
		
		return YES;
	};
	
	if([cur.token.lexeme isEqualToString:@"b"]) {
		
		if(advance() == NO || ![cur.token.lexeme isEqualToString:@"p"])
		{
			// FIXME: Error
			return NO;
		}
		
		return YES;
	}
	else if([cur.token.lexeme isEqualToString:@"c"]) {
		if(advance() == NO ||
		   [cur.token.lexeme isEqualToString:@"c"] ||
		   [cur.token.lexeme isEqualToString:@"m"])
		{
			// FIXME: Error
			return NO;
		}
		
	}
	else if([cur.token.lexeme isEqualToString:@"d"]) {
		if(advance() == NO || ![cur.token.lexeme isEqualToString:@"d"])
		{
			// FIXME: Error
			return NO;
		}
		
		return YES;
	}
	else if([cur.token.lexeme isEqualToString:@"e"]) {
		if(advance() == NO ||
		   [cur.token.lexeme isEqualToString:@"m"] ||
		   [cur.token.lexeme isEqualToString:@"x"])
		{
			// FIXME: Error
			return NO;
		}
	}
	else if([cur.token.lexeme isEqualToString:@"i"]) {
		if(advance() == NO || ![cur.token.lexeme isEqualToString:@"n"])
		{
			// FIXME: Error
			return NO;
		}
		
		return YES;
	}
	else if([cur.token.lexeme isEqualToString:@"m"]) {
		if(advance() == NO ||
		   [cur.token.lexeme isEqualToString:@"m"] ||
		   [cur.token.lexeme isEqualToString:@"u"])
		{
			// FIXME: Error
			return NO;
		}
		
		return YES;
	}
	else if([cur.token.lexeme isEqualToString:@"n"]) {
		if(advance() == NO ||
		   [cur.token.lexeme isEqualToString:@"c"] ||
		   [cur.token.lexeme isEqualToString:@"d"])
		{
			// FIXME: Error
			return NO;
		}
		
		return YES;
	}
	else if([cur.token.lexeme isEqualToString:@"p"]) {
		if(advance() == NO ||
		   [cur.token.lexeme isEqualToString:@"c"] ||
		   [cur.token.lexeme isEqualToString:@"t"])
		{
			// FIXME: Error
			return NO;
		}
		
		return YES;
	}
	else if([cur.token.lexeme isEqualToString:@"s"]) {
		if(advance() == NO || ![cur.token.lexeme isEqualToString:@"p"])
		{
			// FIXME: Error
			return NO;
		}
		
		return YES;
	}
	
	return NO;
}

@end
