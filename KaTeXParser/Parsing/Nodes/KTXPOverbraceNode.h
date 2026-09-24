//
//  KTXPOverbraceNode.h
//  KaTeXParser
//
//  Created by Alice Roldán on 1/17/25.
//

#import "KTXPGroupNode.h"
#import "KTXPSupSubNode.h"

NS_ASSUME_NONNULL_BEGIN

@interface KTXPOverbraceNode : KTXPTreeNode <NSCopying>

/// Must be either \c KTXPAtomNode or \c KTXPGroupNode.
@property (strong, readonly) __kindof KTXPTreeNode *group;
@property (strong, nullable, readonly) KTXPSupSubNode *over;

- (instancetype) initWithGroup:(__kindof KTXPTreeNode *)grp
						 Over:(nullable KTXPSupSubNode *)o NS_DESIGNATED_INITIALIZER;
+ (instancetype) createWithGroup:(__kindof KTXPTreeNode *)grp
						   Over:(nullable KTXPSupSubNode *)o;

@end

NS_ASSUME_NONNULL_END
