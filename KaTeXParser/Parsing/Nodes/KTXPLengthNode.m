//
//  KTXPLengthNode.m
//  KaTeXParser
//
//  Created by Alice Roldán on 10/20/24.
//

#import "KTXPLengthNode.h"

@implementation KTXPLengthNode

#pragma mark - NSCopying

- (nonnull id)copyWithZone:(nullable NSZone *)zone
{
	KTXPLengthNode *ln = [[self class] allocWithZone:zone];
	
	return ln;
}

@end
