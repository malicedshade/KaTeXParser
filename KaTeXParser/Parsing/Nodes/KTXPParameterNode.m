//
//  KTXPParameterNode.m
//  KaTeXParser
//
//  Created by Robert F Roldan on 8/31/25.
//

#import "KTXPParameterNode.h"

@interface KTXPParameterNode()

@property (readwrite) KTXPToken *open;
@property (readwrite) id args;
@property (readwrite) KTXPToken *close;

@end

@implementation KTXPParameterNode

+ (instancetype)createAtomsParameterNode:(KTXPToken *)o atoms:(NSArray<KTXPAtomNode *> *)a close:(KTXPToken *)c
{
	return [[KTXPParameterNode alloc] initParameterNode:o
												   args:a
												  style:KTXPParameterTypeAtoms
												  close:c];
}

+ (instancetype)createFlagParameterNode:(KTXPToken *)o flags:(NSArray<NSString *> *)f close:(KTXPToken *)c
{
	return [[KTXPParameterNode alloc] initParameterNode:o
												   args:f
												  style:KTXPParameterTypeFlag
												  close:c];
}

+ (instancetype)createKeyValueParameterNode:(KTXPToken *)o
									   dict:(NSDictionary<NSString *,NSString *> *)d
									  close:(KTXPToken *)c
{
	return [[KTXPParameterNode alloc] initParameterNode:o
												   args:d
												  style:KTXPParameterTypeKeyValue
												  close:c];
}

- (instancetype) initParameterNode:(KTXPToken *)o
							  args:(id)a
							 style:(KTXPParameterType)style
							 close:(KTXPToken *)c
{
	self = [super init];
	
	if(self)
	{
		switch(style)
		{
			case KTXPParameterTypeKeyValue:
				if([a isKindOfClass:NSDictionary.class] == NO) return nil;
				break;
				
			case KTXPParameterTypeFlag:
			case KTXPParameterTypeAtoms:
				if([a isKindOfClass:NSArray.class] == NO) return nil;
				break;
		}
		
		[self setOpen:o];
		[self setArgs:a];
		[self setClose:c];
	}
	
	return self;
}

- (NSUInteger)hash { return _open.hash + _close.hash + [_args hash]; }

#pragma mark - NSCopying

- (nonnull id)copyWithZone:(nullable NSZone *)zone
{
	KTXPParameterNode *p = [[self class] allocWithZone:zone];
	p->_open = [_open copy];
	p->_args = [_args copy];
	p->_close = [_close copy];
	
	return p;
}

@end
