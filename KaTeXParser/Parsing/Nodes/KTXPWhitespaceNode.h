//
//  KTXPWhitespaceNode.h
//  KaTeXParser
//
//  Created by Alice Roldán on 10/13/24.
//

#import "KTXPTreeNode.h"

NS_ASSUME_NONNULL_BEGIN

@interface KTXPWhitespaceNode : KTXPTreeNode <NSCopying>

@property (strong, readonly) NSArray<__kindof KTXPToken *> *spaceTokens;

- (instancetype)initWithTokens:(NSArray<__kindof KTXPToken *> *)toks NS_DESIGNATED_INITIALIZER;
+ (instancetype)createWithTokens:(NSArray<__kindof KTXPToken *> *)toks;
 
@end

NS_ASSUME_NONNULL_END
