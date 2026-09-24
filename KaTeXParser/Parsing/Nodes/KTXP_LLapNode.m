//
//  KTXP_LLapNode.m
//  KaTeXParser
//
//  Created by Alice Roldán on 1/17/25.
//

#import "KTXP_LLapNode.h"

@interface KTXP_LLapNode()

@property (readwrite) __kindof KTXPTreeNode *overlay;
@property (readwrite) __kindof KTXPTreeNode *left;

@end

@implementation KTXP_LLapNode

- (instancetype)init
{
	return [self initWithOverlay:[KTXPTreeNode new]
							Left:nil];
}

- (instancetype)initWithOverlay:(__kindof KTXPTreeNode *)ol
						   Left:(__kindof KTXPTreeNode *)l
{
	self = [super init];
	
	if(self)
	{
		_overlay = ol;
		_left = l;
	}
	
	return self;
}

+ (instancetype)createWithOverlay:(__kindof KTXPTreeNode *)ol
							 Left:(__kindof KTXPTreeNode *)l
{
	return [[KTXP_LLapNode alloc] initWithOverlay:ol Left:l];
}

- (NSUInteger)hash { return [_overlay hash] + [_left hash]; }

#pragma mark - NSCopying

- (nonnull id)copyWithZone:(nullable NSZone *)zone
{
	KTXP_LLapNode *lln = [[self class] allocWithZone:zone];
	lln->_left = [_left copy];
	lln->_overlay = [_overlay copy];
	
	return lln;
}

@end
