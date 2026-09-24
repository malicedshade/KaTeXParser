//
//  KTXPStack.h
//  KaTeXParser
//
//  Created by Alice Roldán on 6/21/24.
//

#import <Foundation/Foundation.h>

NS_ASSUME_NONNULL_BEGIN

@interface KTXPStack : NSObject <NSCopying>

+ (instancetype) createWithArray:(NSArray *)arr;
- (instancetype) initWithArray:(NSArray *)arr NS_DESIGNATED_INITIALIZER;

- (void) push:(id)obj;
- (void) pushObjects:(NSArray *)objs;
- (void) pushObjects:(NSArray *)objs atIndex:(NSUInteger)index;
- (id) peek;
- (id) pop;
- (NSArray *) popAmount:(NSUInteger)amt;
- (id) shift;
- (void) spliceAtIndex:(NSUInteger)index removeAmount:(NSUInteger)amt insert:(nullable NSArray *)objs;

- (nullable id) lastObject;
- (nullable id) objectAtIndex:(NSUInteger)index;
- (NSUInteger) count;
- (void) clear;
- (NSArray *) array;

@end

NS_ASSUME_NONNULL_END
