//
//  KTXPGroupNode.h
//  KaTeXParser
//
//  Created by Alice Roldán on 10/7/24.
//

#import "KTXPTreeNode.h"
#import "KTXPAtomNode.h"

NS_ASSUME_NONNULL_BEGIN

@interface KTXPGroupNode : KTXPTreeNode <NSCopying>

@property (strong, nullable, readonly) KTXPToken *open;
@property (strong, readonly) NSArray<__kindof KTXPTreeNode *> *elements;
@property (strong, nullable, readonly) KTXPToken *close;

- (instancetype)initWithOpen:(KTXPToken * _Nullable)op
					elements:(NSArray *)elem
					   close:(KTXPToken * _Nullable)cl NS_DESIGNATED_INITIALIZER;
+ (instancetype)createWithOpen:(KTXPToken * _Nullable)op
					  elements:(NSArray *)elem
						 close:(KTXPToken * _Nullable)cl;

@end

NS_ASSUME_NONNULL_END
