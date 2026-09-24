//
//  KTXPKernNode.m
//  KaTeXParser
//
//  Created by Alice Roldán on 2/2/25.
//

#import "KTXPKernNode.h"

@interface KTXPKernNode()

@property (readwrite) NSArray<KTXPAtomNode *> *measurement;

@end

@implementation KTXPKernNode

- (instancetype)init
{
	return [self initWithMeasurement:@[]];
}

- (instancetype)initWithMeasurement:(NSArray<KTXPAtomNode *> *)m
{
	self = [super init];
	
	if(self)
	{
		[self setMeasurement:m];
	}
	
	return self;
}

+ (instancetype)createWithMeasurement:(NSArray<KTXPAtomNode *> *)m
{
	return [[KTXPKernNode alloc] initWithMeasurement:m];
}

- (NSUInteger)hash { return [_measurement hash]; }

#pragma mark - NSCopying

- (nonnull id)copyWithZone:(nullable NSZone *)zone
{
	KTXPKernNode *kn = [[self class] allocWithZone:zone];
	kn->_measurement = [_measurement copy];
	
	return kn;
}

@end
