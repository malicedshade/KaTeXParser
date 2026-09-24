//
//  KTXPRootNode.h
//  KaTeXParser
//
//  Created by Alice Roldán on 10/7/24.
//

#import <Cocoa/Cocoa.h>
#import "KTXPTreeNode.h"

NS_ASSUME_NONNULL_BEGIN

@interface KTXPRootNode : KTXPTreeNode <NSCopying>

@property (strong, readonly) NSArray<__kindof KTXPTreeNode *> *children;

- (instancetype)initWithChildren:(NSArray<__kindof KTXPTreeNode *> *)children NS_DESIGNATED_INITIALIZER;
+ (instancetype)createWithChildren:(NSArray<__kindof KTXPTreeNode *> *)children;

@end

NS_ASSUME_NONNULL_END
