//
//  KTXPRootNode.m
//  KaTeXParser
//
//  Created by Alice Roldán on 10/7/24.
//

#import "KTXPRootNode.h"
#import "KTXPTreeNode.h"

@interface KTXPRootNode()

@property (readwrite) NSArray<__kindof KTXPTreeNode *> *children;

@end

@implementation KTXPRootNode

- (instancetype)init
{
	return [self initWithChildren:@[]];
}

- (instancetype) initWithChildren:(NSArray<__kindof KTXPTreeNode *> *)children
{
	self = [super init];
	
	if(self)
	{
		[self setChildren:children];
	}
	
	return self;
}

+ (instancetype) createWithChildren:(NSArray<__kindof KTXPTreeNode *> *)children
{
	return [[KTXPRootNode alloc] initWithChildren:children];
}

#pragma mark - NSObject

- (BOOL) isEqual:(id)other
{
	if(other == self)
	{
		return YES;
	}
	else if(![other isKindOfClass:self.class])
	{
		return NO;
	}
	else
	{
		return [self hash] == [other hash];
	}
}

- (NSUInteger) hash { return _children.hash; }

- (NSString *) description
{
	NSMutableString *builtString;
	
	for (__kindof KTXPTreeNode *n in _children) {
		[builtString appendFormat:@"%@\n", n.description];
	}
	
	return builtString;
}

#pragma mark - NSCopying

- (nonnull id)copyWithZone:(nullable NSZone *)zone
{
	KTXPRootNode *rn = [[self class] allocWithZone:zone];
	rn->_children = [_children copy];
	
	return rn;
}

@end
