//
//  KTXPAtomNode.h
//  KaTeXParser
//
//  Created by Alice Roldán on 6/11/24.
//

#import "KTXPTreeNode.h"

NS_ASSUME_NONNULL_BEGIN

@interface KTXPAtomNode : KTXPTreeNode <NSCopying>

@property (strong, readonly) KTXPToken *token;

- (instancetype)initWithToken:(KTXPToken *)token NS_DESIGNATED_INITIALIZER;
+ (instancetype)createWithToken:(KTXPToken *)token;

@end

NS_ASSUME_NONNULL_END
