//
//  KTXPOverbraceNode.m
//  KaTeXParser
//
//  Created by Alice Roldán on 1/17/25.
//

#import "KTXPOverbraceNode.h"

@interface KTXPOverbraceNode()

@property (readwrite) __kindof KTXPTreeNode *group;
@property (readwrite) KTXPSupSubNode *over;

@end

@implementation KTXPOverbraceNode

- (instancetype)init
{
	return [self initWithGroup:[KTXPTreeNode new] Over:nil];
}

- (instancetype) initWithGroup:(__kindof KTXPTreeNode *)grp
						 Over:(KTXPSupSubNode *)o
{
	self = [super init];
	
	if(self)
	{
		
		
		_group = grp;
		_over = o;
	}
	
	return self;
}

+ (instancetype) createWithGroup:(__kindof KTXPTreeNode *)grp
						   Over:(KTXPSupSubNode *)o
{
	return [[KTXPOverbraceNode alloc] initWithGroup:grp Over:o];
}

- (NSUInteger)hash { return [_group hash] + [_over hash]; }

#pragma mark - NSCopying

- (nonnull id)copyWithZone:(nullable NSZone *)zone
{
	KTXPOverbraceNode *on = [[self class] allocWithZone:zone];
	on->_group = [_group copy];
	on->_over = [_over copy];
	
	return on;
}

@end
