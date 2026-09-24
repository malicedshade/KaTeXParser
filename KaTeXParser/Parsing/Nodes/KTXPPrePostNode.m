//
//  KTXPPrePostNode.m
//  KaTeXParser
//
//  Created by Alice Roldán on 10/20/24.
//

#import "KTXPPrePostNode.h"

@interface KTXPPrePostNode()

@property (readwrite) NSArray<__kindof KTXPTreeNode *> *pre;
@property (readwrite) KTXPToken *dec;
@property (readwrite) NSArray<__kindof KTXPTreeNode *> *post;

@end

@implementation KTXPPrePostNode

- (instancetype)init
{
	return [self initWithPreArray:@[] dec:[KTXPToken emptyToken] postArray:@[]];
}

- (instancetype)initWithPreArray:(NSArray<__kindof KTXPTreeNode *> *)pre
							 dec:(KTXPToken *)dec
					   postArray:(NSArray<__kindof KTXPTreeNode *> *)post
{
	self = [super init];
	
	if(self)
	{
		[self setPre:pre];
		[self setDec:dec];
		[self setPost:post];
	}
	
	return self;
}

- (instancetype)initWithPre:(__kindof KTXPTreeNode *)pre
						dec:(KTXPToken *)dec
					   post:(__kindof KTXPTreeNode *)post
{
	return [self initWithPreArray:@[pre] dec:dec postArray:@[post]];
}

+ (instancetype)createWithPreArray:(NSArray<__kindof KTXPTreeNode *> *)pre
							   dec:(KTXPToken *)dec
						 postArray:(NSArray<__kindof KTXPTreeNode *> *)post
{
	return [[KTXPPrePostNode alloc] initWithPreArray:pre dec:dec postArray:post];
}

+ (instancetype)createWithPre:(__kindof KTXPTreeNode *)pre
						  dec:(KTXPToken *)dec
						 post:(__kindof KTXPTreeNode *)post
{
	return [[KTXPPrePostNode alloc] initWithPre:pre dec:dec post:post];
}

- (NSUInteger)hash { return [_pre hash] + [_dec hash] + [_post hash]; }

#pragma mark - NSCopying

- (nonnull id)copyWithZone:(nullable NSZone *)zone
{
	KTXPPrePostNode *ppn = [[self class] allocWithZone:zone];
	ppn->_dec = [_dec copy];
	ppn->_post = [_post copy];
	ppn->_pre = [_pre copy];
	
	return ppn;
}

@end
