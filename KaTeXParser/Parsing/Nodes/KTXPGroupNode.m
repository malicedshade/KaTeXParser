//
//  KTXPGroupNode.m
//  KaTeXParser
//
//  Created by Alice Roldán on 10/7/24.
//

#import "KTXPGroupNode.h"

@interface KTXPGroupNode()

@property (readwrite) KTXPToken *open;
@property (readwrite) NSArray<__kindof KTXPTreeNode *> *elements;
@property (readwrite) KTXPToken *close;

@end

@implementation KTXPGroupNode

- (instancetype) init
{
	return [self initWithOpen:[KTXPToken emptyToken]
					 elements:@[]
						close:[KTXPToken emptyToken]];
}

- (instancetype) initWithOpen:(nullable KTXPToken *)op
				 	 elements:(nonnull NSArray *)elem
					    close:(nullable KTXPToken *)cl
{
	self = [super init];
	
	if(self)
	{
		[self setOpen:op];
		[self setElements:elem];
		[self setClose:cl];
	}
	
	return self;
}

+ (nonnull instancetype) createWithOpen:(nullable KTXPToken *)op
							   elements:(nonnull NSArray *)elem
								  close:(nullable KTXPToken *)cl
{
	return [[KTXPGroupNode alloc] initWithOpen:op elements:elem close:cl];
}

- (BOOL) isEqual:(id)other
{
	if(other == self) return YES;
	if(other == nil || ![super isEqual:other]) return NO;
	
	BOOL nilOp = (_open == [(KTXPGroupNode *)other open]);
	BOOL   opE = [_open isEqual:[(KTXPGroupNode *)other open]];
	BOOL   elE = [_elements isEqual:[(KTXPGroupNode *)other elements]];
	BOOL nilCl = (_close == [(KTXPGroupNode *)other close]);
	BOOL   clE = [_close isEqual:[(KTXPGroupNode *)other close]];
	
	return (nilOp || opE) && elE && (nilCl || clE);
}

- (NSUInteger) hash
{
	NSUInteger h = [_open hash];
			   h = 31 * h + [_elements hash];
			   h = 31 * h + [_close hash];
	
	return h;
}

#pragma mark - NSCopying

- (nonnull id) copyWithZone:(nullable NSZone *)zone
{
	KTXPGroupNode *gn = [[self class] allocWithZone:zone];
	gn->_close = [_close copy];
	gn->_elements = [_elements copy];
	gn->_open = [_open copy];
	
	return gn;
}

@end
