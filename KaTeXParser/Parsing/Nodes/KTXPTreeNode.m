//
//  KTXPTreeNode.m
//  KaTeXParser
//
//  Created by Alice Roldán on 5/30/24.
//

#import "KTXPTreeNode.h"

@implementation KTXPTreeNode

- (instancetype)init
{
	self = [super init];
	NSAssert(self.class != [KTXPTreeNode class], @"KTXPTreeNode is an abstract class. Init subclasses instead.");
	
	return self;
}

@end
