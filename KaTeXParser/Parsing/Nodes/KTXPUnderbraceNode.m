//
//  KTXPUnderbraceNode.m
//  KaTeXParser
//
//  Created by Alice Roldán on 1/17/25.
//

#import "KTXPUnderbraceNode.h"

@interface KTXPUnderbraceNode()

@property (readwrite) __kindof KTXPTreeNode *group;
@property (readwrite) KTXPSupSubNode *under;

@end

@implementation KTXPUnderbraceNode

- (instancetype)init
{
	return [self initWithGroup:[KTXPTreeNode new] Under:nil];
}

- (instancetype) initWithGroup:(__kindof KTXPTreeNode *)grp
						 Under:(KTXPSupSubNode *)u
{
	self = [super init];
	
	if(self)
	{
		
		
		_group = grp;
		_under = u;
	}
	
	return self;
}

+ (instancetype) createWithGroup:(__kindof KTXPTreeNode *)grp
						   Under:(KTXPSupSubNode *)u
{
	return [[KTXPUnderbraceNode alloc] initWithGroup:grp Under:u];
}

- (NSUInteger)hash { return [_group hash] + [_under hash]; }

#pragma mark - NSCopying

- (nonnull id)copyWithZone:(nullable NSZone *)zone
{
	KTXPUnderbraceNode *un = [[self class] allocWithZone:zone];
	un->_group = [_group copy];
	un->_under = [_under copy];
	
	return un;
}

@end
