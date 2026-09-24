//
//  KTXP_RLapNode.m
//  KaTeXParser
//
//  Created by Alice Roldán on 1/16/25.
//

#import "KTXP_RLapNode.h"

@interface KTXP_RLapNode()

@property (readwrite) __kindof KTXPTreeNode *overlay;
@property (readwrite) __kindof KTXPTreeNode *right;

@end

@implementation KTXP_RLapNode

- (instancetype)init
{
	return [self initWithOverlay:[KTXPTreeNode new]
						   Right:nil];
}

- (instancetype)initWithOverlay:(__kindof KTXPTreeNode *)ol
						  Right:(__kindof KTXPTreeNode *)r
{
	self = [super init];
	
	if(self)
	{
		_overlay = ol;
		_right = r;
	}
	
	return self;
}

+ (instancetype)createWithOverlay:(__kindof KTXPTreeNode *)ol
							Right:(__kindof KTXPTreeNode *)r
{
	return [[KTXP_RLapNode alloc] initWithOverlay:ol Right:r];
}

- (NSUInteger)hash { return [_overlay hash] + [_right hash]; }

#pragma mark - NSCopying

- (nonnull id)copyWithZone:(nullable NSZone *)zone
{
	KTXP_RLapNode *rln = [[self class] allocWithZone:zone];
	rln->_overlay = [_overlay copy];
	rln->_right = [_right copy];
	
	return rln;
}

@end
