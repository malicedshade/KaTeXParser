//
//  KTXPFunctionNode.h
//  KaTeXParser
//
//  Created by Alice Roldán on 10/12/24.
//

#import "KTXPTreeNode.h"

NS_ASSUME_NONNULL_BEGIN

@interface KTXPFunctionNode : KTXPTreeNode <NSCopying>

@property (strong, readonly) KTXPToken *funcTok;
@property (strong, readonly) NSArray<__kindof KTXPTreeNode *> *args;

- (instancetype)initWithToken:(KTXPToken *)tok arguments:(NSArray<__kindof KTXPTreeNode *> *)args NS_DESIGNATED_INITIALIZER;
+ (instancetype)createWithToken:(KTXPToken *)tok arguments:(NSArray<__kindof KTXPTreeNode *> *)args;

@end

NS_ASSUME_NONNULL_END
