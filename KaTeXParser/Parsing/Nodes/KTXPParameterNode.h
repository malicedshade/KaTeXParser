//
//  KTXPParameterNode.h
//  KaTeXParser
//
//  Created by Robert F Roldan on 8/31/25.
//

#import "KTXPAtomNode.h"

NS_ASSUME_NONNULL_BEGIN

typedef NS_ENUM(NSUInteger, KTXPParameterType) {
	/// A key-value pair in TeX follows the template `name=value`.
	KTXPParameterTypeKeyValue,
	/// A flag is text that doesn't fit the definition of an atom (for example `twocolumn` is not an atom).
	KTXPParameterTypeFlag,
	/// TeX atoms that are allowed as parameters; for example `1` or `\lim`.
	KTXPParameterTypeAtoms
};

/**
 Stores one instance of an optional macro argument, which are stored with square brackets `[]`.
 If a macro takes multiple of these, then that node should store multiple instances of this class.
 */
@interface KTXPParameterNode : KTXPTreeNode <NSCopying>

@property (strong, readonly) KTXPToken *open;
// Should be either a dictionary or an array.
@property (strong, readonly) id args;
@property (strong, readonly) KTXPToken *close;

+ (instancetype) createKeyValueParameterNode:(KTXPToken *)o
										dict:(NSDictionary<NSString *, NSString *> *)d
									   close:(KTXPToken *)c;
+ (instancetype) createFlagParameterNode:(KTXPToken *)o
								   flags:(NSArray<NSString *> *)f
								   close:(KTXPToken *)c;
+ (instancetype) createAtomsParameterNode:(KTXPToken *)o
									atoms:(NSArray<KTXPAtomNode *> *)a
								    close:(KTXPToken *)c;
- (instancetype) initParameterNode:(KTXPToken *)o
							  args:(id)a
						 	 style:(KTXPParameterType)style
							 close:(KTXPToken *)c;

@end

NS_ASSUME_NONNULL_END
