//
//  KTXPLexer.h
//  KTXPParser
//
//  Created by Alice Roldán on 5/28/24.
//

#import <Foundation/Foundation.h>
#import "KTXPToken.h"
#import "KTXPErrorDomain.h"
#import "KTXPSettingsKeys.h"

@class KTXPMacroExpander;

NS_ASSUME_NONNULL_BEGIN

/**
  The Lexer class handles tokenizing the input in various ways. Since our
  parser expects us to be able to backtrack, the lexer allows lexing from any
  given starting point.
 
  Its main exposed function is the `lex` function, which takes a position to
  lex from and a type of token to lex. It defers to the appropriate `innerLex`
  function.
 
  The various `innerLex` functions perform the actual lexing of different
  kinds.
 */
@interface KTXPLexer : NSObject

@property (strong, readonly) NSString *input;
@property (strong, readonly) NSDictionary<KTXPSettingsKey, id> *settings;
@property (strong) NSDictionary<NSString *, NSNumber *> *catcodes;

- (instancetype)initWithString:(nullable NSString *)str
					  settings:(NSDictionary<KTXPSettingsKey, id> *)settings NS_DESIGNATED_INITIALIZER;
+ (instancetype)createWithString:(nullable NSString *)str
						settings:(NSDictionary<KTXPSettingsKey, id> *)settings;
+ (NSDictionary<KTXPSettingsKey, id> *)DEFAULT_SETTINGS;
- (NSArray<KTXPToken *> * _Nullable)lex:(NSError * _Nullable *)err;

@end

NS_ASSUME_NONNULL_END
