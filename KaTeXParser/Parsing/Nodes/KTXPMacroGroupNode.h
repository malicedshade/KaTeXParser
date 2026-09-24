//
//  KTXPMacroGroupNode.h
//  KaTeXParser
//
//  Created by Alice Roldán on 3/9/25.
//

#import "KTXPAtomNode.h"
#import "KTXPFunctionNode.h"

NS_ASSUME_NONNULL_BEGIN

@interface KTXPMacroGroupNode : KTXPTreeNode <NSCopying>

@property (strong, nonnull, readonly) KTXPFunctionNode *left;
@property (strong, nonnull, readonly) NSArray<__kindof KTXPTreeNode *> *elements;
@property (strong, nonnull, readonly) KTXPFunctionNode *right;

- (instancetype)initWithLeft:(KTXPFunctionNode *)l
					elements:(NSArray<__kindof KTXPTreeNode *> *)e
					   right:(KTXPFunctionNode *)r NS_DESIGNATED_INITIALIZER;
+ (instancetype)createWithLeft:(KTXPFunctionNode *)l
					  elements:(NSArray<__kindof KTXPTreeNode *> *)e
						 right:(KTXPFunctionNode *)r;

@end

NS_ASSUME_NONNULL_END
