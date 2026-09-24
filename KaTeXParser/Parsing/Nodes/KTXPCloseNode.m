//
//  KTXPCloseNode.m
//  KaTeXParser
//
//  Created by Alice Roldán on 10/27/24.
//

#import "KTXPCloseNode.h"

@implementation KTXPCloseNode

#pragma mark - NSCopying

- (nonnull id)copyWithZone:(nullable NSZone *)zone
{
	KTXPCloseNode *cn = [[self class] allocWithZone:zone];
	
	return cn;
}

@end
