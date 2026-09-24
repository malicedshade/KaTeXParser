//
//  KTXPToken.h
//  KTXPParser
//
//  Created by Alice Roldán on 5/28/24.
//

#import <Foundation/Foundation.h>

NS_ASSUME_NONNULL_BEGIN

typedef NS_ENUM(NSUInteger, KTXPTokenType) {
	KTXPTokenTypeFunction,
	KTXPTokenTypeSpecialFunction,
	KTXPTokenTypeGroupOpen,
	KTXPTokenTypeGroupClose,
	KTXPTokenTypeWhitespace,
	KTXPTokenTypeAtom,
	KTXPTokenTypeMathOp,
	KTXPTokenTypeComment,
	KTXPTokenTypeEnvironmentOpen,
	KTXPTokenTypeEnvironmentClose
};

// TODO: Don't think I need this.
typedef NS_ENUM(NSUInteger, KTXPGroup) {
	KTXPGroupAccent,
	KTXPGroupBin,
	KTXPGroupClose,
	KTXPGroupInner,
	KTXPGroupMathOrd,
	KTXPGroupOp,
	KTXPGroupOpen,
	KTXPGroupPunct,
	KTXPGroupRel,
	KTXPGroupSpacing,
	KTXPGroupTextOrd
};

@interface KTXPToken : NSObject <NSCopying>

@property (readonly) NSUInteger location;
@property (strong) NSString *lexeme;
@property (readonly) KTXPTokenType type;

+ (instancetype)createWithLexeme:(NSString *)lm
						  location:(NSUInteger)loc
							  type:(KTXPTokenType)type;
- (instancetype)initWithLexeme:(NSString *)lm
						location:(NSUInteger)loc
							type:(KTXPTokenType)type NS_DESIGNATED_INITIALIZER;
+ (instancetype)emptyToken;
+ (NSString *)typeString:(KTXPTokenType)type;
- (NSString *)typeDescription;

@end

NS_ASSUME_NONNULL_END
