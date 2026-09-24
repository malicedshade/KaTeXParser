//
//  KTXPWhitespaceNode.m
//  KaTeXParser
//
//  Created by Alice Roldán on 10/13/24.
//

#import "KTXPWhitespaceNode.h"

@interface KTXPWhitespaceNode()

@property (readwrite) NSArray<__kindof KTXPToken *> *spaceTokens;

@end

@implementation KTXPWhitespaceNode

- (instancetype)init
{
	return [self initWithTokens:@[]];
}

- (instancetype)initWithTokens:(NSArray<__kindof KTXPToken *> *)toks
{
	self = [super init];
	
	if(self)
	{
		[self setSpaceTokens:toks];
	}
	
	return self;
}

+ (instancetype)createWithTokens:(NSArray<__kindof KTXPToken *> *)toks
{
	return [[KTXPWhitespaceNode alloc] initWithTokens:toks];
}

- (NSUInteger)hash {
	NSUInteger h = 17;
	
	for(KTXPToken *tok in _spaceTokens) {
		h = h + [tok hash];
	}
	
	return h;
}

#pragma mark - NSCopying

- (nonnull id)copyWithZone:(nullable NSZone *)zone
{
	KTXPWhitespaceNode *wn = [[self class] allocWithZone:zone];
	wn->_spaceTokens = [_spaceTokens copy];
	
	return wn;
}

@end
