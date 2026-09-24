//
//  KTXPLimitsNode.m
//  KaTeXParser
//
//  Created by Alice Roldán on 3/2/25.
//

#import "KTXPLimitsNode.h"

@interface KTXPLimitsNode()

@property (readwrite) KTXPAtomNode *mathOp;
@property (readwrite) KTXPSupSubNode *ss;

@end

@implementation KTXPLimitsNode

- (instancetype)init
{
	return [self initWithMathOp:[KTXPAtomNode createWithToken:[KTXPToken emptyToken]]
					  andLimits:nil];
}

- (instancetype)initWithMathOp:(KTXPAtomNode *)op andLimits:(KTXPSupSubNode *)ss
{
	self = [super init];
	
	if(self)
	{
		[self setMathOp:op];
		[self setSs:ss];
	}
	
	return self;
}

+ (instancetype)createWithMathOp:(KTXPAtomNode *)op andLimits:(KTXPSupSubNode *)ss
{
	return [[KTXPLimitsNode alloc] initWithMathOp:op andLimits:ss];
}

- (NSUInteger)hash { return [_mathOp hash] + [_ss hash]; }

#pragma mark - NSCopying

- (nonnull id)copyWithZone:(nullable NSZone *)zone
{
	KTXPLimitsNode *ln = [[self class] allocWithZone:zone];
	ln->_mathOp = [_mathOp copy];
	ln->_ss = [_ss copy];
	
	return ln;
}

@end
