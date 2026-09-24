//
//  KTXPFunctions.m
//  KaTeXParser
//
//  Created by Alice Roldán on 6/23/24.
//

#import "KTXPFunctions.h"

@implementation KTXPFunctions

+ (instancetype) summon
{
	static dispatch_once_t onceToken = 0;
	static id _helper = nil;
	dispatch_once(&onceToken, ^{
		_helper = [self new];
	});
	
	return _helper;
}

- (instancetype) init
{
	self = [super init];
	
	if(self)
	{
		
	}
	
	return self;
}

@end
