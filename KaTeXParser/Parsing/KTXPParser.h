//
//  KTXPParser.h
//  KaTeXParser
//
//  Created by Alice Roldán on 5/30/24.
//

#import <Foundation/Foundation.h>
#import "KTXPToken.h"
#import "KTXPSymbols.h"
#import "KTXPErrorDomain.h"
#import "KTXPStack.h"
#import "KTXPLexer.h"

#import "KTXPRootNode.h"
#import "KTXPWhitespaceNode.h"
#import "KTXPPrePostNode.h"
#import "KTXPSupSubNode.h"
#import "KTXPOpenNode.h"
#import "KTXPCloseNode.h"
#import "KTXPEnvironmentNode.h"
#import "KTXPSquareRoot.h"
#import "KTXP_RLapNode.h"
#import "KTXP_LLapNode.h"
#import "KTXPUnderbraceNode.h"
#import "KTXPOverbraceNode.h"
#import "KTXPKernNode.h"
#import "KTXPVerbatimNode.h"
#import "KTXPLimitsNode.h"
#import "KTXPMacroGroupNode.h"

NS_ASSUME_NONNULL_BEGIN

@interface KTXPParser : NSObject

@property (readonly, strong) NSString *input;
@property (readonly, strong) NSDictionary *settings;

- (instancetype)initWithInput:(NSString *)str
					 settings:(NSDictionary *)settings NS_DESIGNATED_INITIALIZER;
+ (instancetype)createWithInput:(NSString *)str
					   settings:(NSDictionary *)settings;

+ (NSDictionary<KTXPSettingsKey, id> *)DEFAULT_SETTINGS;
- (KTXPRootNode * _Nullable)parse:(NSError * _Nullable *)err;

@end

NS_ASSUME_NONNULL_END
