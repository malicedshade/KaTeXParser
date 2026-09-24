//
//  KTXPSquareRoot.m
//  KaTeXParser
//
//  Created by Alice Roldán on 10/27/24.
//

#import "KTXPSquareRoot.h"
#import "KTXPParameterNode.h"

@interface KTXPSquareRoot()

/// If this is nil, then the default is assumed to be 2.
@property (readwrite) KTXPParameterNode *index;
@property (readwrite) __kindof KTXPTreeNode *radicand;

@end

@implementation KTXPSquareRoot

- (instancetype)init
{
	return [self initWithIndex:nil radicand:nil];
}

- (instancetype)initWithIndex:(KTXPParameterNode *)p radicand:(__kindof KTXPTreeNode *)r
{
	self = [super init];
	
	if(self)
	{
		[self setIndex:p];
		[self setRadicand:r];
	}
	
	return self;
}

+ (instancetype)createWithIndex:(KTXPParameterNode *)p radicand:(__kindof KTXPTreeNode *)r
{
	return [[KTXPSquareRoot alloc] initWithIndex:p radicand:r];
}

- (NSUInteger)hash { return [_index hash] + [_radicand hash]; }

#pragma mark - NSCopying

- (nonnull id)copyWithZone:(nullable NSZone *)zone
{
	KTXPSquareRoot *sr = [[self class] allocWithZone:zone];
	sr->_index = [_index copy];
	sr->_radicand = [_radicand copy];
	
	return sr;
}

@end
