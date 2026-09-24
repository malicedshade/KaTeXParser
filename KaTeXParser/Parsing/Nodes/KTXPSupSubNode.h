//
//  KTXPSupSubNode.h
//  KaTeXParser
//
//  Created by Alice Roldán on 10/20/24.
//

#import "KTXPGroupNode.h"

@interface KTXPSupSubNode : KTXPTreeNode <NSCopying>

@property (strong, readonly) KTXPGroupNode *sup;
@property (strong, readonly) KTXPGroupNode *sub;

- (instancetype)initWithSup:(KTXPGroupNode *)sup Sub:(KTXPGroupNode *)sub NS_DESIGNATED_INITIALIZER;
+ (instancetype)createWithSup:(KTXPGroupNode *)sup Sub:(KTXPGroupNode *)sub;

@end
