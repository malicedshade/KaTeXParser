//
//  KTXPLexer.m
//  KTXPParser
//
//  Created by Alice Roldán on 5/28/24.
//

#import "KTXPLexer.h"
#import "KTXPSymbols.h"

@interface KTXPLexer()

@property (readwrite) NSString *input;
@property (readwrite) NSDictionary<KTXPSettingsKey, id> *settings;
@property NSUInteger location;
@property NSUInteger remainder;
@property BOOL inTextMode;

@end

@implementation KTXPLexer
{
	/* The following tokenRegex
	 * - matches typical whitespace (but not NBSP etc.) using its first group
	 * - does not match any control character \x00-\x1f except whitespace
	 * - does not match a bare backslash
	 * - matches any ASCII character except those just mentioned
	 * - does not match the BMP private use area \uE000-\uF8FF
	 * - does not match bare surrogate code units
	 * - matches any BMP character except for those just described
	 * - matches any valid Unicode surrogate pair
	 * - matches a backslash followed by one or more whitespace characters
	 * - matches a backslash followed by one or more letters then whitespace
	 * - matches a backslash followed by any BMP character
	 * Capturing groups:
	 *   [1] regular whitespace
	 *   [2] backslash followed by whitespace
	 *   [3] anything else, which may include:
	 *     [4] left character of \verb*
	 *     [5] left character of \verb
	 *     [6] backslash followed by word, excluding any trailing whitespace
	 * Just because the Lexer matches something doesn't mean it's valid input:
	 * If there is no matching function or symbol definition, the Parser will
	 * still reject the input.
	 */
	NSString *spaceRegexStr;
	NSString *controlWordRegexStr;
	NSString *controlSymbolRegexStr;
	NSString *controlWordWhitespaceRegexStr;
	NSString *controlSpaceRegexStr;
	NSString *combiningDiacriticalMarkRegexStr;
	NSString *tokenRegexStr;
	NSString *commentRegexStr;
	/// Regexes require a double slash for 1 slash. NSString does the same. So you need to escape twice.
	NSString *EscapedRegexSlash;
	/// Regexes require a double slash for 1 slash. NSString does the same. So you need to escape twice.
	NSString *EscapedRegexDoubleSlash;
	/// NSString requires a double slash to escape a slash.
	NSString *EscapedSlash;
	/// NSString requires a double slash to escape a slash.
	NSString *EscapedDoubleSlash;
	NSUInteger textModeBraceCount;
}

- (instancetype)init
{
	return [self initWithString:nil settings:@{}];
}

- (instancetype)initWithString:(NSString *)str settings:(NSDictionary *)settings
{
	self = [super init];

	if(self)
	{
		/*
		 FIXME: I need to move these to their own constants file.
		 These regex's are taken from the KaTeX js library.
		 
		 The complete js regex is:
		 
		 ([ \r\n\t]+)|\\(\n|[ \r\t]+\n?)[ \r\t]*|([!-\[\]-\u2027\u202a-\ud7ff\uf900-\uffff][\u0300-\u036f]*|\\verb\\*([^]).*?\\4|\\verb([^*a-zA-Z]).*?\\5|(\\[a-zA-Z@]+)[ \r\n\t]*|\\[^\uD800-\uDFFF])
		 
		 \verb means verbatim, which allows you to type latex commands without them being executed for display. For example, `\verb|\frac|` will display the text "\frac" in code type.
		 */
		spaceRegexStr = @"[ \\r\\n\\t]";
		controlWordRegexStr = @"\\\\[a-zA-Z@]+";
		controlSymbolRegexStr = @"\\\\[^\\uD800-\\uDFFF]";
		controlSpaceRegexStr = @"\\\\(\n|[ \r\t]+\n?)[ \r\t]*";
		combiningDiacriticalMarkRegexStr = @"[\\u0300-\\u036f]";
		controlWordWhitespaceRegexStr = [NSString stringWithFormat:@"(%@)%@*", controlWordRegexStr, spaceRegexStr];
		commentRegexStr = @"(%.*\\n?)";
		EscapedSlash = @"\\";
		EscapedDoubleSlash = @"\\\\";
		EscapedRegexSlash = EscapedDoubleSlash;
		EscapedRegexDoubleSlash = @"\\\\\\\\";
		
//		// whitespace
//		NSMutableString *tempTokRegexStr = [NSMutableString stringWithFormat:@"(%@+)|", spaceRegexStr];
//		// \whitespace
//		[tempTokRegexStr appendFormat:@"%@|", controlSpaceRegexStr];
//		// single codepoint
//		[tempTokRegexStr appendString:@"([!-\\[\\]-\u2027\u202a-\ud7ff\uf900-\uffff]"];
//		// plus accents
//		[tempTokRegexStr appendFormat:@"%@*", combiningDiacriticalMarkRegexStr];
//		// surrogate pair REMOVED (those code points only work in utf16)
//		// plus accents again REMOVED (duplicate of the above accents)
//		// \verb*
//		[tempTokRegexStr appendString:@"|\\\\verb\\*([.\\s]).*?\\4"];
//		// \verb unstarred
//		[tempTokRegexStr appendString:@"|\\\\verb([^*a-zA-Z]).*?\\5"];
//		// \macroName + spaces
//		[tempTokRegexStr appendFormat:@"|%@", controlWordWhitespaceRegexStr];
//		// \\, \', etc.
//		[tempTokRegexStr appendFormat:@"|%@)", controlSymbolRegexStr];
//		
//		tokenRegexStr = tempTokRegexStr;
		
		/*
		 Real regex:
		 (%.*\n?)|([ \r\n\t]+)|(\\(?:\n|[ \r\t]+\n?)[ \r\t]*)|(([!-\[\]-\u2027\u202a-\ud7ff\uf900-\uffff][\u0300-\u036f]*)|(\\verb\\*[.\s].*?\\4)|(\\verb[^*a-zA-Z].*?\\5)|(\\[a-zA-Z@]+[ \r\n\t]*)|(\\[^\uD800-\uDFFF]))
		 
		 The above is slightly modified from KaTeX source.
		 
		 This one has that group taken out so it's easier to check groups:
		 (%.*\n?)|([ \r\n\t]+)|(\\(?:\n|[ \r\t]+\n?)[ \r\t]*)|([!-\[\]-\u2027\u202a-\ud7ff\uf900-\uffff][\u0300-\u036f]*)|(\\verb\\*[.\s].*?\\4)|(\\verb[^*a-zA-Z].*?\\5)|(\\[a-zA-Z@]+[ \r\n\t]*)|(\\[^\uD800-\uDFFF])
		 
		 (%.*\n?) matches comments
		 */
		tokenRegexStr = @"(%.*\\n?)|([ \\r\\n\\t]+)|\\\\(\\n|[ \\r\\t]+\\n?)[ \\r\\t]*|([!-\\[\\]-\\u2027\\u202a-\\ud7ff\\uf900-\\uffff][\\u0300-\\u036f]*|\\\\verb\\\\*([.\\s]).*?\\\\4|\\\\verb([^*a-zA-Z]).*?\\\\5|(\\\\[a-zA-Z@]+)[ \\r\\n\\t]*|\\\\[^\\uD800-\\uDFFF])";
		textModeBraceCount = 0;
		
		[self setInput:str];
		[self setLocation:0];
		[self setRemainder:str.length];
		[self setInTextMode:NO];
		[self setSettings:settings];
		[self setCatcodes:self.DEFAULT_CATCODES];
	}

	return self;
}

+ (instancetype)createWithString:(NSString *)str settings:(NSDictionary<KTXPSettingsKey,id> *)settings
{
	return [[KTXPLexer alloc] initWithString:str settings:settings];
}

+ (NSDictionary<KTXPSettingsKey, id> *)DEFAULT_SETTINGS
{
	return @{
		FixEscapeSlashesKey: @(NO),
		ThrowOnErrorKey: @(YES)
	};
}

- (NSArray<KTXPToken *> *)lex:(NSError * _Nullable __autoreleasing *)err
{
	if(_input.length == 0 || _remainder == 0)
	{
		NSError *e = [NSError errorWithDomain:KTXPLexerErrorDomain
										 code:KTXPLexerNoInput
									 userInfo:@{NSLocalizedDescriptionKey: @"Nothing to lex.",
												KTXPErrorLocationKey: @(_location)}];
		if(err) { *err = e; };
		
		return @[];
	}
	
	if(((NSNumber *)[_settings objectForKey:FixEscapeSlashesKey]).boolValue == YES)
	{
		NSMutableString *strcopy = _input.mutableCopy;
		NSMatchingOptions regOpts = kNilOptions;
		NSRegularExpression *slashesRegex = [NSRegularExpression regularExpressionWithPattern:EscapedRegexSlash
																					  options:kNilOptions
																						error:err];
		
		if(slashesRegex == nil)
		{
			[[NSException exceptionWithName:[*err domain]
									 reason:[*err localizedFailureReason]
								   userInfo:[*err userInfo]] raise];
			
			return nil;
		}
		
		NSArray<NSTextCheckingResult *> *matches = [slashesRegex matchesInString:_input
																		 options:regOpts
																		   range:NSMakeRange(0, _input.length)];
		
		if(matches.count > 0)
		{
			NSEnumerationOptions eOpts = NSEnumerationReverse;
			__block NSUInteger padding = 0;
			
			[matches enumerateObjectsWithOptions:eOpts
									  usingBlock:^(NSTextCheckingResult * _Nonnull obj,
												   NSUInteger idx,
												   BOOL * _Nonnull stop) {
				[strcopy replaceCharactersInRange:obj.range withString:EscapedDoubleSlash];
				padding++;
			}];
			
			[self setInput:strcopy];
			[self setRemainder:_remainder + padding];
		}
	}

	
	NSRegularExpressionOptions regexOpts = (NSRegularExpressionDotMatchesLineSeparators |
											NSRegularExpressionAnchorsMatchLines);
	NSRegularExpression *regex = [NSRegularExpression regularExpressionWithPattern:tokenRegexStr
																		   options:regexOpts
																			 error:err];
	
	if(regex == nil)
	{
		if(((NSNumber *)[_settings objectForKey:ThrowOnErrorKey]).boolValue == YES)
		{
			[[NSException exceptionWithName:NSGenericException 
									 reason:@"Unknown lexing error."
								   userInfo:@{KTXPErrorLocationKey: @(_location)}] raise];
		}
		
		return nil;
	}
		
	NSMutableArray *toks = [NSMutableArray new];
	NSMatchingOptions matchOpts = (NSMatchingAnchored);
	NSTextCheckingResult *res;
	KTXPToken *tok;
	
	while(_remainder > 0)
	{
		res = [regex firstMatchInString:_input
								options:matchOpts
								  range:NSMakeRange(_location, _remainder)];
		NSRange nextTokRange = (res.range.location != NSNotFound) ? res.range :
									[_input rangeOfComposedCharacterSequenceAtIndex:_location];
		NSString *lexeme = [_input substringWithRange:nextTokRange];
		
		if(_inTextMode == YES)
		{
			if([lexeme isEqualToString:@"{"]) 		{ textModeBraceCount++; }
			else if ([lexeme isEqualToString:@"}"]) { textModeBraceCount--; }
			if (textModeBraceCount == 0) 			{ [self setInTextMode:NO]; }
		}
		else
		{
			if([lexeme isEqualToString:@"\\text"]) { [self setInTextMode:YES]; }
		}
		
		KTXPParserMode mode = (_inTextMode ? KTXPParserModeText : KTXPParserModeMath);
		NSDictionary *lookupDict = [[KTXPSymbols summon] lookupLexeme:lexeme
															   inMode:mode];
		NSNumber *typeLookup = (lookupDict != nil ? [lookupDict valueForKey:Type] : @(KTXPTokenTypeAtom));
		KTXPTokenType ttype = ([lexeme characterAtIndex:0] == '%' ? KTXPTokenTypeComment :
																	typeLookup.unsignedIntegerValue);
		tok = [KTXPToken createWithLexeme:lexeme
								   location:_location
									   type:ttype];
		
		[toks addObject:tok];
		_location += nextTokRange.length;
		_remainder -= nextTokRange.length;
	}
	
	return toks;
}

#pragma mark - Constants
- (NSDictionary<NSString *, id> *)DEFAULT_CATCODES
{
	return @{
		@"\%": @(14),
		@"~": @(13)
	};
}

@end
