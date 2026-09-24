//
//  KTXPOpenNode.m
//  KaTeXParser
//
//  Created by Alice Roldán on 10/27/24.
//

#import "KTXPOpenNode.h"

@implementation KTXPOpenNode

#pragma mark - NSCopying

- (nonnull id)copyWithZone:(nullable NSZone *)zone
{
	KTXPOpenNode *on = [[self class] allocWithZone:zone];
	
	
	return on;
}

@end
