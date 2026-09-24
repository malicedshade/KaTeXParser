//
//  KTXPVerbatimNode.h
//  KaTeXParser
//
//  Created by Alice Roldán on 3/2/25.
//

#import "KTXPTreeNode.h"

NS_ASSUME_NONNULL_BEGIN

/**
 The Verbatim macro just prints out its contents as text.
 Since we don't care about macros being executed in this context, we simply
 want to collect tokens so we can just print them out.
 */
@interface KTXPVerbatimNode : KTXPTreeNode <NSCopying>

/// The opening delimiter.
@property (strong, readonly) KTXPToken *delimiter;
@property (strong, readonly) NSArray<KTXPToken *> *elems;
/// The closing delimiter is the same lexeme, so we only care about the closing tokens location.
@property (readonly) NSUInteger closeLocation;

- (instancetype) initWithDelimiter:(KTXPToken *)d
						  elements:(NSArray<KTXPToken *> *) e
					 closeLocation:(NSUInteger)cl NS_DESIGNATED_INITIALIZER;
+ (instancetype) createWithDelimiter:(KTXPToken *)d
							elements:(NSArray<KTXPToken *> *) e
					   closeLocation:(NSUInteger)cl;

@end

NS_ASSUME_NONNULL_END
