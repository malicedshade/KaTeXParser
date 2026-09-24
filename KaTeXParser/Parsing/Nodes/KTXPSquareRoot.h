//
//  KTXPSquareRoot.h
//  KaTeXParser
//
//  Created by Alice Roldán on 10/27/24.
//

#import "KTXPParameterNode.h"

@interface KTXPSquareRoot : KTXPTreeNode <NSCopying>

@property (strong, readonly, nullable) KTXPParameterNode *index;
@property (strong, readonly, nullable) __kindof KTXPTreeNode *radicand;

- (nonnull instancetype)initWithIndex:(nullable KTXPParameterNode *)p
							   radicand:(nullable __kindof KTXPTreeNode *)r NS_DESIGNATED_INITIALIZER;
+ (nonnull instancetype)createWithIndex:(nullable KTXPParameterNode *)p
					   radicand:(nullable __kindof KTXPTreeNode *)r;

@end
