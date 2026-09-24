//
//  KTXPErrorDomain.h
//  KaTeXParser
//
//  Created by Alice Roldán on 6/9/24.
//

#ifndef Domain_h
#define Domain_h

const NSErrorDomain KTXPLexerErrorDomain = @"KTXPLexerErrorDomain";
/// Empty input string.
const NSInteger KTXPLexerNoInput = 0;
/// Unknown error caused a halt.
const NSInteger KTXPLexerUnexpectedHalt = 1;
/// Ran into a character that was not expected.
const NSInteger KTXPLexerUnexpectedChar = 2;

const NSErrorDomain KTXPParserErrorDomain = @"KTXPParserErrorDomain";
/// Empty input string.
const NSInteger KTXPParserNoInput = 0;
/// Unknown error caused a halt.
const NSInteger KTXPParserUnexpectedHalt = 1;
/// Ran into a token that was not expected in that context.
const NSInteger KTXPParserUnexpectedToken = 2;
/// Hit the end of the input but expected a token.
const NSInteger KTXPParserExpectedToken = 3;
/// Hit the end of the input but expected a group.
const NSInteger KTXPParserExpectedGroup = 4;

typedef NSString * KTXPErrorDomainKey;
/// NSNumber containing the NSUInteger index of where the error occurred.
const KTXPErrorDomainKey KTXPErrorLocationKey = @"KTXPErrorLocation";

const NSString * KTXPUnknownErrorReason = @"Unknown error occurred. Perhaps you're missing a `}` somewhere?";
const NSString * KTXPExpectedTokenReason = @"Expected a token, but input ended.";

#endif /* Domain_h */
