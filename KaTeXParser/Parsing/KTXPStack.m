//
//  KTXPStack.m
//  KaTeXParser
//
//  Created by Alice Roldán on 6/21/24.
//

#import "KTXPStack.h"

@implementation KTXPStack
{
	// lastObject will always be the top of the stack.
	NSArray *_storage;
}

#pragma mark - Init

+ (instancetype) createWithArray:(NSArray *)arr
{
	return [[self alloc] initWithArray:arr];
}

- (instancetype) initWithArray:(NSArray *)arr
{
	self = [super init];
	
	if(self)
	{
		_storage = [arr copy];
	}
	
	return self;
}

- (instancetype)init
{
	return [self initWithArray:@[]];
}

#pragma mark - Interaction

- (void) push:(nonnull id)obj
{
	NSArray *newArr = [_storage arrayByAddingObject:obj];
	_storage = newArr;
}

- (void) pushObjects:(NSArray *)objs
{
	NSArray *newArr = [_storage arrayByAddingObjectsFromArray:objs];
	_storage = newArr;
}

- (void) pushObjects:(NSArray *)objs atIndex:(NSUInteger)index
{
	NSUInteger fixedIndex = (index > _storage.count) ? (_storage.count - 1) : index;
	NSMutableArray *newArr = [NSMutableArray new];
	NSIndexSet *inSet = [NSIndexSet indexSetWithIndexesInRange:NSMakeRange(fixedIndex, objs.count)];
	
	[newArr insertObjects:objs atIndexes:inSet];
	
	_storage = newArr;
}

- (nonnull id) pop
{
	NSRange subrange = NSMakeRange(0, _storage.count - 1);
	NSArray *newArr = [_storage subarrayWithRange:subrange];
	id last = [_storage.lastObject copy];
	_storage = newArr;
	
	return last;
}

- (NSArray *) popAmount:(NSUInteger)amt
{
	if(amt == 0)
	{
		return @[];
	}
	else if(amt > _storage.count)
	{
		NSArray *cpy = [_storage copy];
		_storage = @[];
		
		return cpy;
	}
	
	NSUInteger indx = (_storage.count - amt);
	NSRange remRng = NSMakeRange(0, indx);
	NSRange popRng = NSMakeRange(indx, amt);
	NSArray *rem = [_storage subarrayWithRange:remRng];
	NSArray *ret = [[_storage subarrayWithRange:popRng] reverseObjectEnumerator].allObjects;
	_storage = rem;
	
	return ret;
}

- (id) peek
{
	return (_storage.count == 0 ? nil : _storage.lastObject);
}

- (id) shift
{
	NSRange subrange = NSMakeRange(1, _storage.count - 1);
	NSArray *newArr = [_storage subarrayWithRange:subrange];
	id first = [_storage.firstObject copy];
	_storage = newArr;
	
	return first;
}

- (NSArray *) shiftAmount:(NSUInteger)amt
{
	if(amt == 0)
	{
		return @[];
	}
	else if(amt > _storage.count)
	{
		NSArray *cpy = [_storage copy];
		_storage = @[];
		
		return cpy;
	}
	
	NSRange shiftRng = NSMakeRange(0, amt - 1);
	NSRange popRng = NSMakeRange(amt, _storage.count - amt);
	NSArray *shift = [_storage subarrayWithRange:shiftRng];
	NSArray *rem = [[_storage subarrayWithRange:popRng] reverseObjectEnumerator].allObjects;
	_storage = rem;
	
	return shift;
}

- (void)spliceAtIndex:(NSUInteger)index removeAmount:(NSUInteger)amt insert:(NSArray *)objs
{
	
}

#pragma mark - Array Methods

- (NSUInteger)count
{
	return _storage.count;
}

- (id) lastObject
{
	return [_storage objectAtIndex:(_storage.count - 1)];
}

- (id) objectAtIndex:(NSUInteger)index
{
	return [_storage objectAtIndex:index];
}

- (NSArray *)array
{
	return _storage.copy;
}

- (void) clear
{
	_storage = [NSArray new];
}

#pragma mark - NSObject

- (NSString *)description
{
	return [NSString stringWithFormat:@"Elements: %lu  Last Added: %@", (unsigned long)_storage.count, _storage.lastObject];
}

#pragma mark - NSCopying

- (nonnull id)copyWithZone:(nullable NSZone *)zone
{
	KTXPStack *st = [[self class] allocWithZone:zone];
	st->_storage = [_storage copy];
	
	return st;
}

@end
