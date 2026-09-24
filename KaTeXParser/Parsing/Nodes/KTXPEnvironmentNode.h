//
//  KTXPEnvironmentNode.h
//  KaTeXParser
//
//  Created by Alice Roldán on 6/11/24.
//

#import "KTXPTreeNode.h"
#import "KTXPAtomNode.h"
#import "KTXPGroupNode.h"
#import "KTXPEnvironments.h"

NS_ASSUME_NONNULL_BEGIN

@interface KTXPEnvironmentClose : NSObject <NSCopying>

@property (strong, readonly) KTXPToken *tok;
@property (strong, readonly) KTXPEnvironment env;

- (instancetype)initWithBoundary:(KTXPToken *)tok
							 env:(KTXPEnvironment)env NS_DESIGNATED_INITIALIZER;
+ (instancetype)createWithBoundary:(KTXPToken *)tok
							   env:(KTXPEnvironment)env;

@end

@interface KTXPEnvironmentOpen : KTXPEnvironmentClose

@property (strong, nullable) NSArray<NSString *> *args;

- (instancetype)initWithBoundary:(KTXPToken *)tok
							 env:(KTXPEnvironment)env
							args:(NSArray<NSString *> *)args NS_DESIGNATED_INITIALIZER;
+ (instancetype)createWithBoundary:(KTXPToken *)tok
							   env:(KTXPEnvironment)env
							  args:(NSArray<NSString *> *)args;

@end

@interface KTXPEnvironmentNode : KTXPTreeNode

@property (strong) KTXPEnvironmentOpen *begin;
@property (strong) NSArray<__kindof KTXPTreeNode *> *children;
@property (strong) KTXPEnvironmentClose *end;

- (instancetype)initWithBegin:(KTXPEnvironmentOpen *)begin
					 children:(NSArray<__kindof KTXPTreeNode *> *)children
						  end:(KTXPEnvironmentClose *)close NS_DESIGNATED_INITIALIZER;
+ (instancetype)createWithBegin:(KTXPEnvironmentOpen *)begin
					   children:(NSArray<__kindof KTXPTreeNode *> *)children
							end:(KTXPEnvironmentClose *)close;

@end

NS_ASSUME_NONNULL_END
