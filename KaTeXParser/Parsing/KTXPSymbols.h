//
//  KTXPSymbols.h
//  KaTeXParser
//
//  Created by Alice Roldán on 5/31/24.
//

#import "KTXPEnvironments.h"
#import "KTXPToken.h"

typedef NS_ENUM(NSUInteger, KTXPParserMode) {
	KTXPParserModeMath,
	KTXPParserModeText
};

typedef NS_ENUM(NSUInteger, KTXPMacroType) {
	KTXPMacroTypeNone,
	KTXPMacroTypePrePost,
	KTXPMacroTypePre,
	KTXPMacroTypePost,
	KTXPMacroTypeSupSub,
	KTXPMacroTypeLeft,
	KTXPMacroTypeRight,
	KTXPMacroTypeGroupOpen,
	KTXPMacroTypeGroupClose
};

typedef NSString * _Nonnull KTXPSymbolKey;
/// The token group this symbol belongs to. Stored as `NSNumber`.
const KTXPSymbolKey Group = @"Group";
/// The macro type this symbol is. Stored as `NSNumber`.
const KTXPSymbolKey Type = @"Type";
/// If the type is a function, then this tells how many args it's expecting. Stored as `NSNumber`.
const KTXPSymbolKey Args = @"Args";
/// Used by Special Functions to see if should look behind, ahead, or something else to be correctly formed. Stored as `NSNumber`.
const KTXPSymbolKey SpecialKind = @"SpecialKind";

/// Symbol lookup table.
@interface KTXPSymbols : NSObject

+ (nullable instancetype) summon;
- (NSDictionary * _Nullable) lookupLexeme:(NSString * _Nullable)lexeme
								   inMode:(KTXPParserMode)mode;
- (NSArray<NSString *> * _Nonnull) MEASUREMENTS;

@end
