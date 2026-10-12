//
//  KTXPAtomNode.m
//  KaTeXParser
//
//  Created by Alice Roldán on 6/11/24.
//

#import "KTXPAtomNode.h"

@interface KTXPAtomNode ()

@property (readwrite) KTXPToken *token;

@end

@implementation KTXPAtomNode

-(instancetype)init
{
	return [self initWithToken:[KTXPToken emptyToken]];
}

- (instancetype)initWithToken:(KTXPToken *)token
{
	self = [super init];
	
	if(self)
	{
		[self setToken:token];
	}
	
	return self;
}

+ (instancetype)createWithToken:(KTXPToken *)token
{
	return [[self alloc] initWithToken:token];
}

#pragma mark - NSObject

- (BOOL) isEqual:(id)other
{
	if(other == self) return YES;
	else if(other == nil || ![super isEqual:other]) return NO;
	else return [_token isEqual:[(KTXPAtomNode *)other token]];
}

- (NSString *) description { return [_token description]; }

- (NSUInteger) hash { return [_token hash]; }

#pragma mark - NSCopying

- (nonnull id)copyWithZone:(nullable NSZone *)zone
{
	KTXPAtomNode *an = [[self class] allocWithZone:zone];
	an->_token = [_token copy];

	return an;
}

@end
