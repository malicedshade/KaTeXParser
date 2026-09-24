//
//  KTXP_RLapNode.h
//  KaTeXParser
//
//  Created by Alice Roldán on 1/16/25.
//

#import "KTXPTreeNode.h"

NS_ASSUME_NONNULL_BEGIN

@interface KTXP_RLapNode : KTXPTreeNode <NSCopying>

@property (strong, readonly) __kindof KTXPTreeNode *overlay;
@property (strong, readonly, nullable) __kindof KTXPTreeNode *right;

- (instancetype) initWithOverlay:(__kindof KTXPTreeNode *)ol
						   Right:(nullable __kindof KTXPTreeNode *)r NS_DESIGNATED_INITIALIZER;
+ (instancetype) createWithOverlay:(__kindof KTXPTreeNode *)ol
							 Right:(nullable __kindof KTXPTreeNode *)r;

@end

NS_ASSUME_NONNULL_END
