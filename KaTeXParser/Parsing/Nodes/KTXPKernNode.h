//
//  KTXPMKernNode.h
//  KaTeXParser
//
//  Created by Alice Roldán on 2/2/25.
//

#import "KTXPAtomNode.h"

NS_ASSUME_NONNULL_BEGIN

@interface KTXPKernNode : KTXPTreeNode <NSCopying>

@property (strong, readonly) NSArray<KTXPAtomNode *> *measurement;

- (instancetype) initWithMeasurement:(NSArray<KTXPAtomNode *> *)m NS_DESIGNATED_INITIALIZER;

+ (instancetype) createWithMeasurement:(NSArray<KTXPAtomNode *> *)m;

@end

NS_ASSUME_NONNULL_END
