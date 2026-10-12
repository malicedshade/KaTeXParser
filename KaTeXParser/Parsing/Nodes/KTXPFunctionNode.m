//
//  KTXPFunctionNode.m
//  KaTeXParser
//
//  Created by Alice Roldán on 10/12/24.
//

#import "KTXPFunctionNode.h"

@interface KTXPFunctionNode()

@property (readwrite) KTXPToken *funcTok;
@property (readwrite) NSArray<__kindof KTXPTreeNode *> *args;

@end

@implementation KTXPFunctionNode

- (instancetype)init
{
	return [self initWithToken:[KTXPToken emptyToken] arguments:@[]];
}

- (instancetype)initWithToken:(KTXPToken *)tok arguments:(NSArray<__kindof KTXPTreeNode *> *)args
{
	self = [super init];
	
	if(self)
	{
		[self setFuncTok:tok];
		[self setArgs:args];
	}
	
	return self;
}

+ (instancetype)createWithToken:(KTXPToken *)tok arguments:(NSArray<__kindof KTXPTreeNode *> *)args
{
	return [[KTXPFunctionNode alloc] initWithToken:tok arguments:args];
}

- (NSUInteger)hash
{
	NSUInteger h = [_funcTok hash];
	h = 31 * h + [_args hash];
	
	return h;
}

#pragma mark - NSCopying

- (nonnull id)copyWithZone:(nullable NSZone *)zone
{
	KTXPFunctionNode *fn = [[self class] allocWithZone:zone];
	fn->_args = [_args copy];
	fn->_funcTok = [_funcTok copy];
	
	return fn;
}

@end
