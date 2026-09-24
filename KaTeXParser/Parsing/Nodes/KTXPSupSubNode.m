//
//  KTXPSupSubNode.m
//  KaTeXParser
//
//  Created by Alice Roldán on 10/20/24.
//

#import "KTXPSupSubNode.h"

@interface KTXPSupSubNode()

@property (readwrite) KTXPGroupNode *sup;
@property (readwrite) KTXPGroupNode *sub;

@end

@implementation KTXPSupSubNode

- (instancetype) init
{
	return [self initWithSup:nil Sub:nil];
}

- (instancetype) initWithSup:(KTXPGroupNode *)sup Sub:(KTXPGroupNode *) sub
{
	self = [super init];
	
	if(self)
	{
		[self setSup:sup];
		[self setSub:sub];
	}
	
	return self;
}

+ (instancetype) createWithSup:(KTXPGroupNode *)sup Sub:(KTXPGroupNode *)sub
{
	return [[KTXPSupSubNode alloc] initWithSup:sup Sub:sub];
}

- (NSUInteger)hash
{
	NSUInteger h = [_sup hash];
	h = 31 * h + [_sub hash];

	return h;
}

#pragma mark - NSCopying

- (nonnull id) copyWithZone:(nullable NSZone *)zone
{
	KTXPSupSubNode *ssn = [[self class] allocWithZone:zone];
	ssn->_sup = [_sup copy];
	ssn->_sub = [_sub copy];
	
	return ssn;
}

@end
