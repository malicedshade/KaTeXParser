//
//  KTXPLimitsNode.h
//  KaTeXParser
//
//  Created by Alice Roldán on 3/2/25.
//

#import "KTXPSupSubNode.h"
#import "KTXPAtomNode.h"

NS_ASSUME_NONNULL_BEGIN

@interface KTXPLimitsNode : KTXPTreeNode <NSCopying>

@property (strong, readonly) KTXPAtomNode *mathOp;
@property (strong, readonly, nullable) KTXPSupSubNode *ss;

- (instancetype) initWithMathOp:(KTXPAtomNode *)op
					  andLimits:(nullable KTXPSupSubNode *)ss NS_DESIGNATED_INITIALIZER;
+ (instancetype) createWithMathOp:(KTXPAtomNode *)op
						andLimits:(nullable KTXPSupSubNode *)ss;

@end

NS_ASSUME_NONNULL_END
