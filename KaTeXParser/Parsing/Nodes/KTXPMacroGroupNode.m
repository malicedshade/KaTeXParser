//
//  KTXPMacroGroupNode.m
//  KaTeXParser
//
//  Created by Alice Roldán on 3/9/25.
//

#import "KTXPMacroGroupNode.h"

@interface KTXPMacroGroupNode()

@property (readwrite) KTXPFunctionNode *left;
@property (readwrite) NSArray<__kindof KTXPTreeNode *> *elements;
@property (readwrite) KTXPFunctionNode *right;

@end

@implementation KTXPMacroGroupNode

- (instancetype)init
{
	return [self initWithLeft:[KTXPFunctionNode createWithToken:[KTXPToken emptyToken]
													  arguments:@[]]
					 elements:@[]
						right:[KTXPFunctionNode createWithToken:[KTXPToken emptyToken]
													  arguments:@[]]];
}

- (instancetype)initWithLeft:(KTXPFunctionNode *)l
					elements:(NSArray<__kindof KTXPTreeNode *> *)e
					   right:(KTXPFunctionNode *)r
{
	self = [super init];
	
	if(self)
	{
		[self setLeft:l];
		[self setElements:e];
		[self setRight:r];
	}
	
	return self;
}

+ (instancetype)createWithLeft:(KTXPFunctionNode *)l
					  elements:(NSArray<__kindof KTXPTreeNode *> *)e
						 right:(KTXPFunctionNode *)r
{
	return [[KTXPMacroGroupNode alloc] initWithLeft:l elements:e right:r];
}

- (NSUInteger)hash { return [_left hash] + [_elements hash] + [_right hash]; }

#pragma mark - NSCopying

- (nonnull id)copyWithZone:(nullable NSZone *)zone
{
	KTXPMacroGroupNode *gn = [[self class] allocWithZone:zone];
	gn->_elements = [_elements copy];
	gn->_left = [_left copy];
	gn->_right = [_right copy];
	
	return gn;
}

@end
