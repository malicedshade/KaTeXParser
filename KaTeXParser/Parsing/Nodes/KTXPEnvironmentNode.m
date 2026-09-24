//
//  KTXPEnvironmentNode.m
//  KaTeXParser
//
//  Created by Alice Roldán on 6/11/24.
//

#import "KTXPEnvironmentNode.h"

@interface KTXPEnvironmentClose()

@property (readwrite) KTXPToken *tok;
@property (readwrite) KTXPEnvironment env;

@end

@implementation KTXPEnvironmentOpen

- (instancetype)init
{
	return [self initWithBoundary:[KTXPToken emptyToken] env:@""];
}

- (instancetype)initWithBoundary:(KTXPToken *)tok
							 env:(KTXPEnvironment)env
{
	return [self initWithBoundary:tok env:env args:@[]];
}

- (instancetype)initWithBoundary:(KTXPToken *)tok
							 env:(KTXPEnvironment)env
							args:(NSArray<NSString *> *)args
{
	self = [super initWithBoundary:tok env:env];
	
	if(self)
	{
		[self setTok:tok];
		[self setEnv:env];
		[self setArgs:args];
	}
	
	return self;
}

+ (instancetype)createWithBoundary:(KTXPToken *)tok 
							   env:(KTXPEnvironment)env
{
	return [[KTXPEnvironmentOpen alloc] initWithBoundary:tok env:env args:@[]];
}

+ (instancetype)createWithBoundary:(KTXPToken *)tok 
							   env:(KTXPEnvironment)env
							  args:(NSArray<NSString *> *)args
{
	return [[KTXPEnvironmentOpen alloc] initWithBoundary:tok env:env args:args];
}

- (NSUInteger)hash { return [[super tok] hash] + [[super env] hash] + [_args hash]; }

@end

@implementation KTXPEnvironmentClose

- (instancetype)init
{
	return [self initWithBoundary:[KTXPToken emptyToken] env:@""];
}

- (instancetype)initWithBoundary:(KTXPToken *)tok env:(KTXPEnvironment)env
{
	self = [super init];
	
	if(self)
	{
		[self setEnv:env];
		[self setTok:tok];
	}
	
	return self;
}

+ (instancetype)createWithBoundary:(KTXPToken *)tok env:(KTXPEnvironment)env
{
	return [[KTXPEnvironmentClose alloc] initWithBoundary:tok env:env];
}


- (NSUInteger)hash { return [_tok hash] + [_env hash]; }

@end

@implementation KTXPEnvironmentNode

- (instancetype)init
{
	return [self initWithBegin:[KTXPEnvironmentOpen createWithBoundary:[KTXPToken emptyToken]
																   env:@""]
					  children:@[]
						   end:[KTXPEnvironmentClose createWithBoundary:[KTXPToken emptyToken]
																	env:@""]];
}

+ (nonnull instancetype)createWithBegin:(nonnull KTXPEnvironmentOpen *)begin 
							   children:(nonnull NSArray<__kindof KTXPTreeNode *> *)children
									end:(nonnull KTXPEnvironmentClose *)close
{
	return [[KTXPEnvironmentNode alloc] initWithBegin:begin children:children end:close];
}

- (nonnull instancetype)initWithBegin:(nonnull KTXPEnvironmentOpen *)begin 
							 children:(nonnull NSArray<__kindof KTXPTreeNode *> *)children
								  end:(nonnull KTXPEnvironmentClose *)close
{
	self = [super init];
	
	if(self)
	{
		[self setBegin:begin];
		[self setChildren:children];
		[self setEnd:close];
	}
	
	return self;
}

#pragma mark - NSObject

- (BOOL)isEqual:(id)other
{
	if(other == self)
	{
		return YES;
	}
	else if(![super isEqual:other])
	{
		return NO;
	}
	else
	{
		return [self hash] == [other hash];
	}
}

- (NSUInteger)hash { return [_begin hash] + [_end hash] + [_children hash]; }

#pragma mark - NSCopying

- (nonnull id)copyWithZone:(nullable NSZone *)zone
{
	KTXPEnvironmentNode *en = [[self class] allocWithZone:zone];
	en->_begin = [_begin copy];
	en->_children = [_children copy];
	en->_end = [_end copy];
	
	return en;
}

@end
