//
//  KTXPVerbatimNode.m
//  KaTeXParser
//
//  Created by Alice Roldán on 3/2/25.
//

#import "KTXPVerbatimNode.h"

@interface KTXPVerbatimNode()

@property (readwrite) KTXPToken *delimiter;
@property (readwrite) NSArray<KTXPToken *> *elems;
@property (readwrite) NSUInteger closeLocation;

@end

@implementation KTXPVerbatimNode

- (instancetype)init
{
	return [self initWithDelimiter:[KTXPToken emptyToken] elements:@[] closeLocation:NSNotFound];
}

- (instancetype)initWithDelimiter:(KTXPToken *)d
						 elements:(NSArray<KTXPToken *> *)e
					closeLocation:(NSUInteger)cl
{
	self = [super init];
	
	if(self)
	{
		[self setDelimiter:d];
		[self setElems:e];
		[self setCloseLocation:cl];
	}
	
	return self;
}

+ (instancetype)createWithDelimiter:(KTXPToken *)d
						   elements:(NSArray<KTXPToken *> *)e
					  closeLocation:(NSUInteger)cl
{
	return [[KTXPVerbatimNode alloc] initWithDelimiter:d elements:e closeLocation:cl];
}

- (NSUInteger)hash { return [_delimiter hash] + [_elems hash] + _closeLocation; }

#pragma mark - NSCopying

- (nonnull id)copyWithZone:(nullable NSZone *)zone
{
	KTXPVerbatimNode *vn = [[self class] allocWithZone:zone];
	vn->_closeLocation = _closeLocation;
	vn->_delimiter = [_delimiter copy];
	vn->_elems = [_elems copy];
	
	return vn;
}

@end
