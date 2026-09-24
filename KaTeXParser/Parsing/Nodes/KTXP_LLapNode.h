//
//  KTXP_LLapNode.h
//  KaTeXParser
//
//  Created by Alice Roldán on 1/17/25.
//

#import "KTXPTreeNode.h"

NS_ASSUME_NONNULL_BEGIN

@interface KTXP_LLapNode : KTXPTreeNode <NSCopying>

@property (strong, readonly) __kindof KTXPTreeNode *overlay;
@property (strong, readonly, nullable) __kindof KTXPTreeNode *left;

- (instancetype) initWithOverlay:(__kindof KTXPTreeNode *)ol
							Left:(nullable __kindof KTXPTreeNode *)l NS_DESIGNATED_INITIALIZER;
+ (instancetype) createWithOverlay:(__kindof KTXPTreeNode *)ol
							  Left:(nullable __kindof KTXPTreeNode *)l;

@end

NS_ASSUME_NONNULL_END
