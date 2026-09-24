//
//  KTXPUnderbraceNode.h
//  KaTeXParser
//
//  Created by Alice Roldán on 1/17/25.
//

#import "KTXPGroupNode.h"
#import "KTXPSupSubNode.h"

NS_ASSUME_NONNULL_BEGIN

@interface KTXPUnderbraceNode : KTXPTreeNode <NSCopying>

/// Must be either \c KTXPAtomNode or \c KTXPGroupNode.
@property (strong, readonly) __kindof KTXPTreeNode *group;
@property (strong, nullable, readonly) KTXPSupSubNode *under;

- (instancetype) initWithGroup:(__kindof KTXPTreeNode *)grp
						 Under:(nullable KTXPSupSubNode *)u NS_DESIGNATED_INITIALIZER;
+ (instancetype) createWithGroup:(__kindof KTXPTreeNode *)grp
						   Under:(nullable KTXPSupSubNode *)u;

@end

NS_ASSUME_NONNULL_END
