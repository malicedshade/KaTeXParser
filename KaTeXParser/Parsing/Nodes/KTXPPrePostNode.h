//
//  KTXPPrePostNode.h
//  KaTeXParser
//
//  Created by Alice Roldán on 10/20/24.
//

#import "KTXPTreeNode.h"

NS_ASSUME_NONNULL_BEGIN

/**
 For special functions that have a pre post macro type.
 
 Pre- is a macro that has an argument before it.
 Post- is a macro that has an argument after it.
 Pre-post- has both.
 
 However these specifically work with groups.
 Example: \brack
 {n \brack k}
 The front and back need to be in a group, becuase otherwise it's up to the
 end of the group. If there's no group the lexer counts the code itself
 with no braces as a group. So `abc \brack def` would include abcdef while
 `ab{c \brack d}ef` would only have cd.
 
 Here's something interesting. `\frac a \brack b`. This does \frac{a}{\brack}b.
 this means the brack is empty from the implied group.
 */
@interface KTXPPrePostNode : KTXPTreeNode <NSCopying>

@property (strong, readonly) NSArray<__kindof KTXPTreeNode *> *pre;
@property (strong, readonly) KTXPToken *dec;
@property (strong, readonly) NSArray<__kindof KTXPTreeNode *> *post;

- (instancetype)initWithPreArray:(NSArray<__kindof KTXPTreeNode *> *)pre
							 dec:(KTXPToken *)dec
					   postArray:(NSArray<__kindof KTXPTreeNode *> *)post NS_DESIGNATED_INITIALIZER;
- (instancetype)initWithPre:(__kindof KTXPTreeNode *)pre
						dec:(KTXPToken *)dec
					   post:(__kindof KTXPTreeNode *)post;
+ (instancetype)createWithPreArray:(NSArray<__kindof KTXPTreeNode *> *)pre
							   dec:(KTXPToken *)dec
						 postArray:(NSArray<__kindof KTXPTreeNode *> *)post;
+ (instancetype)createWithPre:(__kindof KTXPTreeNode *)pre
						  dec:(KTXPToken *)dec
						 post:(__kindof KTXPTreeNode *)post;

@end

NS_ASSUME_NONNULL_END
