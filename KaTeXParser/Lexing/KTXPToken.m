//
//  KTXPToken.m
//  KTXPParser
//
//  Created by Alice Roldán on 5/28/24.
//

#import "KTXPToken.h"

@interface KTXPToken()

@property (readwrite) NSUInteger location;
@property (readwrite) KTXPTokenType type;

@end

@implementation KTXPToken

- (instancetype) init
{
	return [self initWithLexeme:@""
						 location:NSNotFound
							 type:KTXPTokenTypeAtom];
}

- (instancetype) initWithLexeme:(NSString *)lm
					   location:(NSUInteger)loc
						   type:(KTXPTokenType)type
{
	self = [super init];
	
	if(self)
	{
		[self setLexeme:lm];
		[self setLocation:loc];
		[self setType:type];
	}
	
	return self;
}

+ (instancetype) createWithLexeme:(NSString *)gm
						 location:(NSUInteger)loc
							 type:(KTXPTokenType)type
{
	return [[KTXPToken alloc] initWithLexeme:gm
									location:loc
										type:type];
}

+ (instancetype) emptyToken
{
	return [KTXPToken createWithLexeme:@"" location:NSNotFound type:KTXPTokenTypeAtom];
}

+ (NSString *) typeString:(KTXPTokenType)type
{
	switch (type)
	{
		case KTXPTokenTypeFunction:
			return @"Function";
			
		case KTXPTokenTypeSpecialFunction:
			return @"Special Function";
			
		case KTXPTokenTypeGroupOpen:
			return @"Group Open";
			
		case KTXPTokenTypeGroupClose:
			return @"Group Close";
			
		case KTXPTokenTypeWhitespace:
			return @"Whitespace";
			
		case KTXPTokenTypeAtom:
			return @"Atom";
			
		case KTXPTokenTypeMathOp:
			return @"Math Operator";
			
		case KTXPTokenTypeComment:
			return @"Comment";
			
		case KTXPTokenTypeEnvironmentOpen:
			return @"Environment Open";
			
		case KTXPTokenTypeEnvironmentClose:
			return @"Environment Close";
	}
}

- (NSString *) typeDescription
{
	return [KTXPToken typeString:self.type];
}

- (NSString *) description
{
	return [NSString stringWithFormat:@"Lexeme: %@ Location: %lu Type:%@",
			_lexeme,
			(unsigned long)_location,
			[KTXPToken typeString:_type]];
}

- (BOOL) isEqual:(id)object
{
	if(object == nil || ![object isKindOfClass:self.class]) return NO;
	if(object == self) return YES;
	
	BOOL locEq = ([object location] == self.location);
	BOOL grfmEq = ([[object lexeme] isEqualToString:self.lexeme]);
	BOOL typeEq = ([(KTXPToken *)object type] == self.type);
	
	return locEq && grfmEq && typeEq;
}

- (NSUInteger) hash
{
	NSUInteger jumble = _location ^ _type;
	
	return 31 * jumble + [_lexeme hash];
}

- (nonnull id) copyWithZone:(nullable NSZone *)zone
{
	KTXPToken *t = [[self class] allocWithZone:zone];
	t->_lexeme   = [_lexeme copy];
	t->_location = _location;
	t->_type 	 = _type;
	
	return t;
}

@end
