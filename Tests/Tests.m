//
//  Tests.m
//  Tests
//
//  Created by Alice Roldán on 6/9/24.
//

#import <XCTest/XCTest.h>
#import "KTXPParser.h"
#import "KTXPSquareRoot.h"
#import "KTXPFunctionNode.h"
#import "KTXPGroupNode.h"

@interface Tests : XCTestCase

@property (strong) KTXPLexer *lexer;
@property (strong) KTXPParser *parser;

@end

@implementation Tests

- (void) setUp
{
    // Put setup code here. This method is called before the invocation of each test method in the class.
}

- (void) tearDown
{
    // Put teardown code here. This method is called after the invocation of each test method in the class.
}

//- (void) testPerformanceExample
//{
//    // This is an example of a performance test case.
//    [self measureBlock:^{
//        // Put the code you want to measure the time of here.
//    }];
//}

#pragma mark - Lexer

- (void) testLexSingleToken
{
	[self setLexer:[KTXPLexer createWithString:@"\\test" settings:@{}]];

	NSArray<KTXPToken *> *toks = [_lexer lex:nil];
	BOOL size = (toks.count == 1);
	BOOL test = [[KTXPToken createWithLexeme:@"\\test"
									location:0
										type:KTXPTokenTypeAtom]
				 isEqualTo:toks.firstObject];

	XCTAssertTrue(size && test);
}

- (void) testLexEmpty
{
	[self setLexer:[KTXPLexer createWithString:@"" settings:@{}]];

	NSError *e;
	NSArray<KTXPToken *> *toks = [_lexer lex:&e];

	NSLog(@"%@", e.localizedDescription);

	XCTAssertTrue(toks.count == 0);
}

- (void) testLexEmptyErr
{
	[self setLexer:[KTXPLexer createWithString:@"" settings:@{}]];

	NSArray<KTXPToken *> *toks = [_lexer lex:nil];

	XCTAssertTrue(toks.count == 0);
}

- (void) testFunctionMacro
{
	[self setLexer:[KTXPLexer createWithString:@"\\sqrt12" settings:@{}]];

	NSArray<KTXPToken *> *toks = [_lexer lex:nil];
	NSArray<KTXPToken *> *comp = @[[KTXPToken createWithLexeme:@"\\sqrt" location:0 type:KTXPTokenTypeSpecialFunction],
								   [KTXPToken createWithLexeme:@"1" location:5 type:KTXPTokenTypeAtom],
								   [KTXPToken createWithLexeme:@"2" location:6 type:KTXPTokenTypeAtom]];
	BOOL correct = YES;

	for(NSUInteger i = 0; i < toks.count; i++)
	{
		KTXPToken *o = [toks objectAtIndex:i];
		KTXPToken *c = [comp objectAtIndex:i];
		correct = correct && [o isEqual:c];
		//NSLog(@"%@", tok.description);
	}

	XCTAssertTrue(correct);
}

- (void)testWhitespace
{
	[self setLexer:[KTXPLexer createWithString:@"   \\n\\\\ " settings:@{}]];

	NSArray<KTXPToken *> *toks = [_lexer lex:nil];
	NSArray<KTXPToken *> *comp = @[[KTXPToken createWithLexeme:@"   " location:0 type:KTXPTokenTypeAtom],
								   [KTXPToken createWithLexeme:@"\\n" location:3 type:KTXPTokenTypeAtom],
								   [KTXPToken createWithLexeme:@"\\\\" location:5 type:KTXPTokenTypeAtom],
								   [KTXPToken createWithLexeme:@" " location:7 type:KTXPTokenTypeAtom]];
	BOOL correct = YES;

	for(NSUInteger i = 0; i < toks.count; i++)
	{
		KTXPToken *o = [toks objectAtIndex:i];
		KTXPToken *c = [comp objectAtIndex:i];
		correct = correct && [o isEqual:c];
		//NSLog(@"%@", tok.description);
	}

	XCTAssertTrue(correct);
}

#pragma mark - Parser

- (void) testEmptyParse
{
	[self setParser:[KTXPParser createWithInput:@""
									   settings:[KTXPParser DEFAULT_SETTINGS]]];

	KTXPRootNode *r = [_parser parse:nil];
	KTXPRootNode *c = [KTXPRootNode createWithChildren:@[]];

	XCTAssert([r isEqual:c]);
}

- (void) testAtomParse
{
	[self setParser:[KTXPParser createWithInput:@"a"
									   settings:[KTXPParser DEFAULT_SETTINGS]]];

	KTXPRootNode *r = [_parser parse:nil];
	KTXPRootNode *c = [KTXPRootNode createWithChildren:@[
		[KTXPAtomNode createWithToken:[KTXPToken createWithLexeme:@"a"
														 location:0
															 type:KTXPTokenTypeAtom]]
	]];

	XCTAssert([r isEqual:c]);
}

- (void) testErrorParse
{
	[self setParser:[KTXPParser createWithInput:@"\\frac"
									   settings:[KTXPParser DEFAULT_SETTINGS]]];

	NSError *err;
	__unused KTXPRootNode *r = [_parser parse:&err];

	if(err)
	{
		NSDictionary *ud = [err userInfo];

		NSLog(@"%@", [ud objectForKey:NSLocalizedDescriptionKey]);
	}

	XCTAssert(err.code == KTXPParserExpectedToken && err.domain == KTXPParserErrorDomain);
}

- (void) testFracParse
{
	[self setParser:[KTXPParser createWithInput:@"\\frac12"
									   settings:[KTXPParser DEFAULT_SETTINGS]]];

	KTXPRootNode *r = [_parser parse:nil];
	KTXPRootNode *c = [KTXPRootNode createWithChildren:@[
		[KTXPFunctionNode createWithToken:[KTXPToken createWithLexeme:@"\\frac"
													 		 location:0
																 type:KTXPTokenTypeFunction]
								arguments:@[
			[KTXPAtomNode createWithToken:[KTXPToken createWithLexeme:@"1"
															 location:1
																 type:KTXPTokenTypeAtom]],
			[KTXPAtomNode createWithToken:[KTXPToken createWithLexeme:@"2"
															 location:2
																 type:KTXPTokenTypeAtom]]
		]]
	]];

	XCTAssert([r isEqual:c]);
}

- (void) testSquareParse
{
	[self setParser:[KTXPParser createWithInput:@"\\sqrt{a}"
									   settings:[KTXPParser DEFAULT_SETTINGS]]];

	KTXPRootNode *r = [_parser parse:nil];
	KTXPRootNode *c = [KTXPRootNode createWithChildren:@[
		[KTXPSquareRoot createWithIndex:nil
							   radicand:[KTXPGroupNode
							createWithOpen:[KTXPToken createWithLexeme:@"{"
															  location:4
																  type:KTXPTokenTypeGroupOpen]
								  elements:@[
												[KTXPAtomNode createWithToken:[KTXPToken
																		createWithLexeme:@"a"
																			    location:2
																					type:KTXPTokenTypeAtom]]
							   ]
									 close:[KTXPToken createWithLexeme:@"}"
															  location:6
																  type:KTXPTokenTypeGroupClose]]]
		]
	];

	XCTAssert([r isEqual:c]);
}

- (void) testSquareEmptyParse
{
	[self setParser:[KTXPParser createWithInput:@"\\sqrt{}"
									   settings:[KTXPParser DEFAULT_SETTINGS]]];

	KTXPRootNode *r = [_parser parse:nil];
	KTXPRootNode *c = [KTXPRootNode createWithChildren:@[
		[KTXPSquareRoot createWithIndex:nil
							   radicand:[KTXPGroupNode
										  createWithOpen:[KTXPToken createWithLexeme:@"{"
																			location:4
																				type:KTXPTokenTypeGroupOpen]
												elements:@[]
												   close:[KTXPToken createWithLexeme:@"}"
																			location:6
																				type:KTXPTokenTypeGroupClose]]
		]]];

	XCTAssert([r isEqual:c]);
}

- (void) testSquareMissingParse
{
	[self setParser:[KTXPParser createWithInput:@"\\sqrt"
									   settings:[KTXPParser DEFAULT_SETTINGS]]];
	NSError *err;
	__unused KTXPRootNode *r = [_parser parse:&err];

	if(err)
	{
		NSDictionary *ud = [err userInfo];

		NSLog(@"%@", [ud objectForKey:NSLocalizedDescriptionKey]);
	}

	XCTAssertNotNil(err);
}

- (void) testSquareIndexParse
{
	[self setParser:[KTXPParser createWithInput:@"\\sqrt[3]{a}"
									   settings:[KTXPParser DEFAULT_SETTINGS]]];

	KTXPRootNode *r = [_parser parse:nil];
	KTXPParameterNode *p = [KTXPParameterNode
								createAtomsParameterNode:[KTXPToken
															createWithLexeme:@"["
																	location:1
																		type:KTXPTokenTypeGroupOpen]
													atoms:@[
											[KTXPAtomNode
												createWithToken:[KTXPToken
																	createWithLexeme:@"3"
																			location:2
																				type:KTXPTokenTypeAtom]]]
												   close:[KTXPToken
															createWithLexeme:@"]"
																	location:3
																		type:KTXPTokenTypeGroupClose]];
	KTXPRootNode *c = [KTXPRootNode createWithChildren:@[
		[KTXPSquareRoot createWithIndex:p
							   radicand:[KTXPGroupNode
											createWithOpen:[KTXPToken createWithLexeme:@"{"
																			  location:4
																				  type:KTXPTokenTypeGroupOpen]
												  elements:@[
						[KTXPAtomNode createWithToken:[KTXPToken createWithLexeme:@"a"
																		 location:5
																			 type:KTXPTokenTypeAtom]]
					]
													 close:[KTXPToken
																createWithLexeme:@"}"
																		location:6
																			type:KTXPTokenTypeGroupClose]]]
		]
	];

	XCTAssert([r isEqual:c]);
}

- (void) testSoloGroup
{
	[self setParser:[KTXPParser createWithInput:@"{\\frac12}"
									   settings:[KTXPParser DEFAULT_SETTINGS]]];

	KTXPRootNode *r = [_parser parse:nil];
	KTXPRootNode *c = [KTXPRootNode createWithChildren:@[
		[KTXPGroupNode createWithOpen:[KTXPToken createWithLexeme:@"{"
														 location:0
															 type:KTXPTokenTypeGroupOpen]
							 elements:@[
			[KTXPFunctionNode createWithToken:[KTXPToken createWithLexeme:@"\\frac"
																 location:1
																	 type:KTXPTokenTypeFunction]
									arguments:@[
				[KTXPAtomNode createWithToken:[KTXPToken createWithLexeme:@"1"
																 location:6
																	 type:KTXPTokenTypeAtom]],
				[KTXPAtomNode createWithToken:[KTXPToken createWithLexeme:@"2"
																 location:7
																	 type:KTXPTokenTypeAtom]]
				]]
			]
								close:[KTXPToken createWithLexeme:@"}"
														 location:1
															 type:KTXPTokenTypeGroupClose]
	]]];

	XCTAssert([r isEqual:c]);
}

- (void) testEmptyGroup
{
	[self setParser:[KTXPParser createWithInput:@"{}"
									   settings:[KTXPParser DEFAULT_SETTINGS]]];

	KTXPRootNode *r = [_parser parse:nil];
	KTXPRootNode *c = [KTXPRootNode createWithChildren:@[
		[KTXPGroupNode createWithOpen:[KTXPToken createWithLexeme:@"{"
														 location:0
															 type:KTXPTokenTypeGroupOpen]
							 elements:@[]
								close:[KTXPToken createWithLexeme:@"}"
														 location:1
															 type:KTXPTokenTypeGroupClose]]
	]];

	XCTAssert([r isEqual:c]);
}

- (void) testSupSub
{
	[self setParser:[KTXPParser createWithInput:@"_a^b"
									   settings:[KTXPParser DEFAULT_SETTINGS]]];

	KTXPRootNode *r = [_parser parse:nil];
	KTXPAtomNode *a = [KTXPAtomNode createWithToken:[KTXPToken createWithLexeme:@"a"
																	   location:1
																		   type:KTXPTokenTypeAtom]];
	KTXPAtomNode *b = [KTXPAtomNode createWithToken:[KTXPToken createWithLexeme:@"b"
																	   location:3
																		   type:KTXPTokenTypeAtom]];
	KTXPGroupNode *sub = [KTXPGroupNode createWithOpen:nil elements:@[a] close:nil];
	KTXPGroupNode *sup = [KTXPGroupNode createWithOpen:nil elements:@[b] close:nil];
	KTXPSupSubNode *ss = [KTXPSupSubNode createWithSup:sup Sub:sub];
	KTXPRootNode *c = [KTXPRootNode createWithChildren:@[ss]];

	XCTAssert([c isEqual:r]);
}

- (void) testSupSubGroup
{
	[self setParser:[KTXPParser createWithInput:@"_{a}^{b}"
									   settings:[KTXPParser DEFAULT_SETTINGS]]];

	KTXPRootNode *r = [_parser parse:nil];
	KTXPAtomNode *a = [KTXPAtomNode createWithToken:[KTXPToken createWithLexeme:@"a"
																	   location:1
																		   type:KTXPTokenTypeAtom]];
	KTXPGroupNode *sub = [KTXPGroupNode createWithOpen:[KTXPToken createWithLexeme:@"{"
																		  location:1
																			  type:KTXPTokenTypeGroupOpen]
											 elements:@[a]
												close:[KTXPToken createWithLexeme:@"}"
																		 location:3
																			 type:KTXPTokenTypeGroupClose]];
	KTXPAtomNode *b = [KTXPAtomNode createWithToken:[KTXPToken createWithLexeme:@"b"
																	   location:3
																		   type:KTXPTokenTypeAtom]];
	KTXPGroupNode *sup = [KTXPGroupNode createWithOpen:[KTXPToken createWithLexeme:@"{"
																		  location:5
																			  type:KTXPTokenTypeGroupOpen]
											 elements:@[b]
												close:[KTXPToken createWithLexeme:@"}"
																		 location:7
																			 type:KTXPTokenTypeGroupClose]];
	KTXPSupSubNode *ss = [KTXPSupSubNode createWithSup:sup Sub:sub];
	KTXPRootNode *c = [KTXPRootNode createWithChildren:@[ss]];

	XCTAssert([c isEqual:r]);
}

- (void) testSupSubFrac
{
	[self setParser:[KTXPParser createWithInput:@"_\\frac{1}{2}^\\frac{3}{4}"
									   settings:[KTXPParser DEFAULT_SETTINGS]]];

	KTXPRootNode *r = [_parser parse:nil];

	KTXPToken *brOp1 = [KTXPToken createWithLexeme:@"{" location:2 type:KTXPTokenTypeGroupOpen];
	KTXPAtomNode *one = [KTXPAtomNode createWithToken:[KTXPToken createWithLexeme:@"1"
																	   location:3
																		   type:KTXPTokenTypeAtom]];
	KTXPToken *brCl1 = [KTXPToken createWithLexeme:@"}" location:4 type:KTXPTokenTypeGroupClose];
	KTXPGroupNode *fg1 = [KTXPGroupNode createWithOpen:brOp1 elements:@[one] close:brCl1];

	KTXPToken *brOp2 = [KTXPToken createWithLexeme:@"{" location:5 type:KTXPTokenTypeGroupOpen];
	KTXPAtomNode *two = [KTXPAtomNode createWithToken:[KTXPToken createWithLexeme:@"2"
																		 location:6
																			 type:KTXPTokenTypeAtom]];
	KTXPToken *brCl2 = [KTXPToken createWithLexeme:@"}" location:7 type:KTXPTokenTypeGroupClose];
	KTXPGroupNode *fg2 = [KTXPGroupNode createWithOpen:brOp2 elements:@[two] close:brCl2];

	KTXPToken *fracT1 = [KTXPToken createWithLexeme:@"\\frac" location:9 type:KTXPTokenTypeSpecialFunction];
	KTXPFunctionNode *frac1 = [KTXPFunctionNode createWithToken:fracT1 arguments:@[fg1, fg2]];
	KTXPGroupNode *g1 = [KTXPGroupNode createWithOpen:nil elements:@[frac1] close:nil];

	KTXPToken *brOp3 = [KTXPToken createWithLexeme:@"{" location:10 type:KTXPTokenTypeGroupOpen];
	KTXPAtomNode *three = [KTXPAtomNode createWithToken:[KTXPToken createWithLexeme:@"3"
																		 location:11
																			 type:KTXPTokenTypeAtom]];
	KTXPToken *brCl3 = [KTXPToken createWithLexeme:@"}" location:12 type:KTXPTokenTypeGroupClose];
	KTXPGroupNode *sg1 = [KTXPGroupNode createWithOpen:brOp3 elements:@[three] close:brCl3];

	KTXPToken *brOp4 = [KTXPToken createWithLexeme:@"{" location:13 type:KTXPTokenTypeGroupOpen];
	KTXPAtomNode *four = [KTXPAtomNode createWithToken:[KTXPToken createWithLexeme:@"4"
																		 location:14
																			 type:KTXPTokenTypeAtom]];
	KTXPToken *brCl4 = [KTXPToken createWithLexeme:@"}" location:15 type:KTXPTokenTypeGroupClose];
	KTXPGroupNode *sg2 = [KTXPGroupNode createWithOpen:brOp4 elements:@[four] close:brCl4];

	KTXPToken *fracT2 = [KTXPToken createWithLexeme:@"\\frac" location:9 type:KTXPTokenTypeSpecialFunction];
	KTXPFunctionNode *frac2 = [KTXPFunctionNode createWithToken:fracT2 arguments:@[sg1, sg2]];
	KTXPGroupNode *g2 = [KTXPGroupNode createWithOpen:nil elements:@[frac2] close:nil];

	KTXPSupSubNode *ss = [KTXPSupSubNode createWithSup:g2 Sub:g1];
	KTXPRootNode *c = [KTXPRootNode createWithChildren:@[ss]];

	XCTAssert([c isEqual:r]);
}

- (void) testSupSubGroupFrac
{
	[self setParser:[KTXPParser createWithInput:@"_{\\frac{1}{2}}^{\\frac{3}{4}}"
									   settings:[KTXPParser DEFAULT_SETTINGS]]];

	KTXPRootNode *r = [_parser parse:nil];

	KTXPToken *grBrOp = [KTXPToken createWithLexeme:@"{" location:1 type:KTXPTokenTypeGroupOpen];
	KTXPToken *brOp1 = [KTXPToken createWithLexeme:@"{" location:3 type:KTXPTokenTypeGroupOpen];
	KTXPAtomNode *one = [KTXPAtomNode createWithToken:[KTXPToken createWithLexeme:@"1"
																		 location:4
																			 type:KTXPTokenTypeAtom]];
	KTXPToken *brCl1 = [KTXPToken createWithLexeme:@"}" location:5 type:KTXPTokenTypeGroupClose];
	KTXPGroupNode *fg1 = [KTXPGroupNode createWithOpen:brOp1 elements:@[one] close:brCl1];

	KTXPToken *brOp2 = [KTXPToken createWithLexeme:@"{" location:6 type:KTXPTokenTypeGroupOpen];
	KTXPAtomNode *two = [KTXPAtomNode createWithToken:[KTXPToken createWithLexeme:@"2"
																		 location:7
																			 type:KTXPTokenTypeAtom]];
	KTXPToken *brCl2 = [KTXPToken createWithLexeme:@"}" location:8 type:KTXPTokenTypeGroupClose];
	KTXPGroupNode *fg2 = [KTXPGroupNode createWithOpen:brOp2 elements:@[two] close:brCl2];

	KTXPToken *fracT1 = [KTXPToken createWithLexeme:@"\\frac" location:9 type:KTXPTokenTypeSpecialFunction];
	KTXPFunctionNode *frac1 = [KTXPFunctionNode createWithToken:fracT1 arguments:@[fg1, fg2]];
	KTXPToken *gr1BrCl = [KTXPToken createWithLexeme:@"}" location:1 type:KTXPTokenTypeGroupClose];
	KTXPGroupNode *g1 = [KTXPGroupNode createWithOpen:nil elements:@[frac1] close:nil];

	KTXPToken *brOp3 = [KTXPToken createWithLexeme:@"{" location:10 type:KTXPTokenTypeGroupOpen];
	KTXPAtomNode *three = [KTXPAtomNode createWithToken:[KTXPToken createWithLexeme:@"3"
																		   location:11
																			   type:KTXPTokenTypeAtom]];
	KTXPToken *brCl3 = [KTXPToken createWithLexeme:@"}" location:12 type:KTXPTokenTypeGroupClose];
	KTXPGroupNode *sg1 = [KTXPGroupNode createWithOpen:brOp3 elements:@[three] close:brCl3];

	KTXPToken *brOp4 = [KTXPToken createWithLexeme:@"{" location:13 type:KTXPTokenTypeGroupOpen];
	KTXPAtomNode *four = [KTXPAtomNode createWithToken:[KTXPToken createWithLexeme:@"4"
																		  location:14
																			  type:KTXPTokenTypeAtom]];
	KTXPToken *brCl4 = [KTXPToken createWithLexeme:@"}" location:15 type:KTXPTokenTypeGroupClose];
	KTXPGroupNode *sg2 = [KTXPGroupNode createWithOpen:brOp4 elements:@[four] close:brCl4];

	KTXPToken *fracT2 = [KTXPToken createWithLexeme:@"\\frac" location:9 type:KTXPTokenTypeSpecialFunction];
	KTXPFunctionNode *frac2 = [KTXPFunctionNode createWithToken:fracT2 arguments:@[sg1, sg2]];
	KTXPGroupNode *g2 = [KTXPGroupNode createWithOpen:nil elements:@[frac2] close:nil];

	KTXPSupSubNode *ss = [KTXPSupSubNode createWithSup:g2 Sub:g1];
	KTXPRootNode *c = [KTXPRootNode createWithChildren:@[ss]];

	XCTAssert([c isEqual:r]);
}

- (void) testSubSupEmpty
{
	[self setParser:[KTXPParser createWithInput:@"_^"
									   settings:[KTXPParser DEFAULT_SETTINGS]]];

	NSError *err;
	__unused KTXPRootNode *r = [_parser parse:&err];
	NSInteger errLoc = [[err.userInfo valueForKey:KTXPErrorLocationKey] unsignedIntegerValue];

	XCTAssert(err != nil);
	XCTAssert(err.domain == KTXPParserErrorDomain);
	XCTAssert(err.code == KTXPParserExpectedGroup);
	XCTAssert(errLoc == 1);
}

- (void) testSupSubEmpty
{
	[self setParser:[KTXPParser createWithInput:@"^_"
									   settings:[KTXPParser DEFAULT_SETTINGS]]];

	NSError *err;
	__unused KTXPRootNode *r = [_parser parse:&err];
	NSInteger errLoc = [[err.userInfo valueForKey:KTXPErrorLocationKey] unsignedIntegerValue];

	XCTAssert(err != nil);
	XCTAssert(err.domain == KTXPParserErrorDomain);
	XCTAssert(err.code == KTXPParserExpectedGroup);
	XCTAssert(errLoc == 1);
}

- (void) testSupSubEmptyGroup
{
	[self setParser:[KTXPParser createWithInput:@"_{}^{}"
									   settings:[KTXPParser DEFAULT_SETTINGS]]];

	KTXPRootNode *r = [_parser parse:nil];
	KTXPGroupNode *sub = [KTXPGroupNode createWithOpen:[KTXPToken createWithLexeme:@"{"
																		  location:1
																			  type:KTXPTokenTypeGroupOpen]
											 elements:@[]
												close:[KTXPToken createWithLexeme:@"}"
																		 location:2
																			 type:KTXPTokenTypeGroupClose]];
	KTXPGroupNode *sup = [KTXPGroupNode createWithOpen:[KTXPToken createWithLexeme:@"{"
																		  location:4
																			  type:KTXPTokenTypeGroupOpen]
											 elements:@[]
												close:[KTXPToken createWithLexeme:@"}"
																		 location:5
																			 type:KTXPTokenTypeGroupClose]];
	KTXPSupSubNode *ss = [KTXPSupSubNode createWithSup:sup Sub:sub];
	KTXPRootNode *c = [KTXPRootNode createWithChildren:@[ss]];

	XCTAssert([c isEqual:r]);
}

- (void) testSubEmpty
{
	[self setParser:[KTXPParser createWithInput:@"_^b"
									   settings:[KTXPParser DEFAULT_SETTINGS]]];

	NSError *err;
	__unused KTXPRootNode *r = [_parser parse:&err];
	NSInteger errLoc = [[err.userInfo valueForKey:KTXPErrorLocationKey] unsignedIntegerValue];

	XCTAssert(err != nil);
	XCTAssert(err.domain == KTXPParserErrorDomain);
	XCTAssert(err.code == KTXPParserExpectedGroup);
	XCTAssert(errLoc == 1);
}

- (void) testSupEmpty
{
	[self setParser:[KTXPParser createWithInput:@"_a^"
									   settings:[KTXPParser DEFAULT_SETTINGS]]];

	NSError *err;
	__unused KTXPRootNode *r = [_parser parse:&err];
	NSInteger errLoc = [[err.userInfo valueForKey:KTXPErrorLocationKey] unsignedIntegerValue];

	XCTAssert(err != nil);
	XCTAssert(err.domain == KTXPParserErrorDomain);
	XCTAssert(err.code == KTXPParserExpectedGroup);
	XCTAssert(errLoc == 3);
}

// The following tests are from Mozilla's MathML Torture Test.

- (void) testStress1
{
	[self setParser:[KTXPParser createWithInput:@"x^2y^2"
									   settings:[KTXPParser DEFAULT_SETTINGS]]];

	KTXPRootNode *r = [_parser parse:nil];

	KTXPToken *xTok    = [KTXPToken createWithLexeme:@"x" location:0 type:KTXPTokenTypeAtom];
	KTXPAtomNode *x    = [KTXPAtomNode createWithToken:xTok];
	KTXPToken *twoTok1 = [KTXPToken createWithLexeme:@"2" location:2 type:KTXPTokenTypeAtom];
	KTXPAtomNode *two1 = [KTXPAtomNode createWithToken:twoTok1];
	KTXPGroupNode *g1  = [KTXPGroupNode createWithOpen:nil elements:@[two1] close:nil];

	KTXPToken *yTok    = [KTXPToken createWithLexeme:@"y" location:3 type:KTXPTokenTypeAtom];
	KTXPAtomNode *y    = [KTXPAtomNode createWithToken:yTok];
	KTXPToken *twoTok2 = [KTXPToken createWithLexeme:@"2" location:5 type:KTXPTokenTypeAtom];
	KTXPAtomNode *two2 = [KTXPAtomNode createWithToken:twoTok2];
	KTXPGroupNode *g2  = [KTXPGroupNode createWithOpen:nil elements:@[two2] close:nil];

	KTXPSupSubNode *s1 = [KTXPSupSubNode createWithSup:g1 Sub:nil];
	KTXPSupSubNode *s2 = [KTXPSupSubNode createWithSup:g2 Sub:nil];

	KTXPRootNode *c = [KTXPRootNode createWithChildren:@[x, s1, y, s2]];

	XCTAssert([c isEqual:r]);
}

- (void) testStress2
{
	[self setParser:[KTXPParser createWithInput:@"_2F_3"
									   settings:[KTXPParser DEFAULT_SETTINGS]]];

	KTXPRootNode *r = [_parser parse:nil];
	KTXPRootNode *c = [KTXPRootNode createWithChildren:@[
	[KTXPSupSubNode createWithSup:nil Sub:[KTXPGroupNode createWithOpenLocation:NSNotFound closeLocation:NSNotFound elements:@[
			[KTXPAtomNode createWithString:@"2" atLocation:1 type:KTXPTokenTypeAtom]
		]]],
	[KTXPAtomNode createWithString:@"F" atLocation:2 type:KTXPTokenTypeAtom],
	[KTXPSupSubNode createWithSup:nil Sub:[KTXPGroupNode createWithOpenLocation:NSNotFound closeLocation:NSNotFound elements:@[
			[KTXPAtomNode createWithString:@"3" atLocation:4 type:KTXPTokenTypeAtom]
		]]]
]];

	XCTAssert([c isEqual:r]);
}

- (void) testStress3
{
	[self setParser: [KTXPParser createWithInput:@"\\frac{x+y^2}{k+1}"
										settings:[KTXPParser DEFAULT_SETTINGS]]];

	KTXPRootNode *r = [_parser parse:nil];
	KTXPRootNode *c = [KTXPRootNode createWithChildren:@[
	[KTXPFunctionNode createWithString:@"\\frac" atLocation:0 type:KTXPTokenTypeFunction arguments:@[
		[KTXPGroupNode createWithOpenLocation:5 closeLocation:11 elements:@[
			[KTXPAtomNode createWithString:@"x" atLocation:6 type:KTXPTokenTypeAtom],
			[KTXPAtomNode createWithString:@"+" atLocation:7 type:KTXPTokenTypeAtom],
			[KTXPAtomNode createWithString:@"y" atLocation:8 type:KTXPTokenTypeAtom],
			[KTXPSupSubNode createWithSup:[KTXPGroupNode createWithOpenLocation:NSNotFound closeLocation:NSNotFound elements:@[
					[KTXPAtomNode createWithString:@"2" atLocation:10 type:KTXPTokenTypeAtom]
				]] Sub:nil]
		]],
		[KTXPGroupNode createWithOpenLocation:12 closeLocation:16 elements:@[
			[KTXPAtomNode createWithString:@"k" atLocation:13 type:KTXPTokenTypeAtom],
			[KTXPAtomNode createWithString:@"+" atLocation:14 type:KTXPTokenTypeAtom],
			[KTXPAtomNode createWithString:@"1" atLocation:15 type:KTXPTokenTypeAtom]
		]]
	]]
]];

	XCTAssert([c isEqual:r]);
}

- (void) testStress4
{
	[self setParser: [KTXPParser createWithInput:@"x+y^{\\frac{2}{k+1}}"
										settings:[KTXPParser DEFAULT_SETTINGS]]];

	KTXPRootNode *r = [_parser parse:nil];
	KTXPGroupNode *numerator = [KTXPGroupNode createWithOpenLocation:10 closeLocation:12 elements:@[
		[KTXPAtomNode createWithString:@"2" atLocation:11 type:KTXPTokenTypeAtom]
	]];
	KTXPGroupNode *denominator = [KTXPGroupNode createWithOpenLocation:13 closeLocation:17 elements:@[
		[KTXPAtomNode createWithString:@"k" atLocation:14 type:KTXPTokenTypeAtom],
		[KTXPAtomNode createWithString:@"+" atLocation:15 type:KTXPTokenTypeAtom],
		[KTXPAtomNode createWithString:@"1" atLocation:16 type:KTXPTokenTypeAtom]
	]];
	KTXPFunctionNode *fraction = [KTXPFunctionNode createWithString:@"\\frac" atLocation:5 type:KTXPTokenTypeFunction arguments:@[numerator, denominator]];
	KTXPGroupNode *exponent = [KTXPGroupNode createWithOpenLocation:4 closeLocation:18 elements:@[fraction]];
	KTXPRootNode *c = [KTXPRootNode createWithChildren:@[
		[KTXPAtomNode createWithString:@"x" atLocation:0 type:KTXPTokenTypeAtom],
		[KTXPAtomNode createWithString:@"+" atLocation:1 type:KTXPTokenTypeAtom],
		[KTXPAtomNode createWithString:@"y" atLocation:2 type:KTXPTokenTypeAtom],
		[KTXPSupSubNode createWithSup:exponent Sub:nil]
	]];

	XCTAssert([c isEqual:r]);
}

- (void) testStress5
{
	[self setParser: [KTXPParser createWithInput:@"\\frac{a}{b/2}"
										settings:[KTXPParser DEFAULT_SETTINGS]]];

	KTXPRootNode *r = [_parser parse:nil];
	KTXPRootNode *c = [KTXPRootNode createWithChildren:@[
	[KTXPFunctionNode createWithString:@"\\frac" atLocation:0 type:KTXPTokenTypeFunction arguments:@[
		[KTXPGroupNode createWithOpenLocation:5 closeLocation:7 elements:@[
			[KTXPAtomNode createWithString:@"a" atLocation:6 type:KTXPTokenTypeAtom]
		]],
		[KTXPGroupNode createWithOpenLocation:8 closeLocation:12 elements:@[
			[KTXPAtomNode createWithString:@"b" atLocation:9 type:KTXPTokenTypeAtom],
			[KTXPAtomNode createWithString:@"/" atLocation:10 type:KTXPTokenTypeAtom],
			[KTXPAtomNode createWithString:@"2" atLocation:11 type:KTXPTokenTypeAtom]
		]]
	]]
]];

	XCTAssert([c isEqual:r]);
}

- (void) testStress6
{
	[self setParser: [KTXPParser createWithInput:@"a_0+\\frac{1}{ a_1+\\frac{1}{a_2+{1}{\\frac{1}{a_3+\\frac{1}{a_4}}}}}"
										settings:[KTXPParser DEFAULT_SETTINGS]]];

	KTXPRootNode *r = [_parser parse:nil];
	KTXPRootNode *c = [KTXPRootNode createWithChildren:@[
	[KTXPAtomNode createWithString:@"a" atLocation:0 type:KTXPTokenTypeAtom],
	[KTXPSupSubNode createWithSup:nil Sub:[KTXPGroupNode createWithOpenLocation:NSNotFound closeLocation:NSNotFound elements:@[
			[KTXPAtomNode createWithString:@"0" atLocation:2 type:KTXPTokenTypeAtom]
		]]],
	[KTXPAtomNode createWithString:@"+" atLocation:3 type:KTXPTokenTypeAtom],
	[KTXPFunctionNode createWithString:@"\\frac" atLocation:4 type:KTXPTokenTypeFunction arguments:@[
		[KTXPGroupNode createWithOpenLocation:9 closeLocation:11 elements:@[
			[KTXPAtomNode createWithString:@"1" atLocation:10 type:KTXPTokenTypeAtom]
		]],
		[KTXPGroupNode createWithOpenLocation:12 closeLocation:64 elements:@[
			[KTXPAtomNode createWithString:@" " atLocation:13 type:KTXPTokenTypeAtom],
			[KTXPAtomNode createWithString:@"a" atLocation:14 type:KTXPTokenTypeAtom],
			[KTXPSupSubNode createWithSup:nil Sub:[KTXPGroupNode createWithOpenLocation:NSNotFound closeLocation:NSNotFound elements:@[
					[KTXPAtomNode createWithString:@"1" atLocation:16 type:KTXPTokenTypeAtom]
				]]],
			[KTXPAtomNode createWithString:@"+" atLocation:17 type:KTXPTokenTypeAtom],
			[KTXPFunctionNode createWithString:@"\\frac" atLocation:18 type:KTXPTokenTypeFunction arguments:@[
				[KTXPGroupNode createWithOpenLocation:23 closeLocation:25 elements:@[
					[KTXPAtomNode createWithString:@"1" atLocation:24 type:KTXPTokenTypeAtom]
				]],
				[KTXPGroupNode createWithOpenLocation:26 closeLocation:63 elements:@[
					[KTXPAtomNode createWithString:@"a" atLocation:27 type:KTXPTokenTypeAtom],
					[KTXPSupSubNode createWithSup:nil Sub:[KTXPGroupNode createWithOpenLocation:NSNotFound closeLocation:NSNotFound elements:@[
							[KTXPAtomNode createWithString:@"2" atLocation:29 type:KTXPTokenTypeAtom]
						]]],
					[KTXPAtomNode createWithString:@"+" atLocation:30 type:KTXPTokenTypeAtom],
					[KTXPGroupNode createWithOpenLocation:31 closeLocation:33 elements:@[
						[KTXPAtomNode createWithString:@"1" atLocation:32 type:KTXPTokenTypeAtom]
					]],
					[KTXPGroupNode createWithOpenLocation:34 closeLocation:62 elements:@[
						[KTXPFunctionNode createWithString:@"\\frac" atLocation:35 type:KTXPTokenTypeFunction arguments:@[
							[KTXPGroupNode createWithOpenLocation:40 closeLocation:42 elements:@[
								[KTXPAtomNode createWithString:@"1" atLocation:41 type:KTXPTokenTypeAtom]
							]],
							[KTXPGroupNode createWithOpenLocation:43 closeLocation:61 elements:@[
								[KTXPAtomNode createWithString:@"a" atLocation:44 type:KTXPTokenTypeAtom],
								[KTXPSupSubNode createWithSup:nil Sub:[KTXPGroupNode createWithOpenLocation:NSNotFound closeLocation:NSNotFound elements:@[
										[KTXPAtomNode createWithString:@"3" atLocation:46 type:KTXPTokenTypeAtom]
									]]],
								[KTXPAtomNode createWithString:@"+" atLocation:47 type:KTXPTokenTypeAtom],
								[KTXPFunctionNode createWithString:@"\\frac" atLocation:48 type:KTXPTokenTypeFunction arguments:@[
									[KTXPGroupNode createWithOpenLocation:53 closeLocation:55 elements:@[
										[KTXPAtomNode createWithString:@"1" atLocation:54 type:KTXPTokenTypeAtom]
									]],
									[KTXPGroupNode createWithOpenLocation:56 closeLocation:60 elements:@[
										[KTXPAtomNode createWithString:@"a" atLocation:57 type:KTXPTokenTypeAtom],
										[KTXPSupSubNode createWithSup:nil Sub:[KTXPGroupNode createWithOpenLocation:NSNotFound closeLocation:NSNotFound elements:@[
												[KTXPAtomNode createWithString:@"4" atLocation:59 type:KTXPTokenTypeAtom]
											]]]
									]]
								]]
							]]
						]]
					]]
				]]
			]]
		]]
	]]
]];

	XCTAssert([c isEqual:r]);
}

- (void) testStress7
{
	[self setParser: [KTXPParser createWithInput:@"a_{0}+\\cfrac{1}{a_{1}+\\cfrac{1}{a_{2}+\\cfrac{1}{a_{3}+\\cfrac{1}{a_{4}}}}}"
										settings:[KTXPParser DEFAULT_SETTINGS]]];

	KTXPRootNode *r = [_parser parse:nil];
	KTXPRootNode *c = [KTXPRootNode createWithChildren:@[
	[KTXPAtomNode createWithString:@"a" atLocation:0 type:KTXPTokenTypeAtom],
	[KTXPSupSubNode createWithSup:nil Sub:[KTXPGroupNode createWithOpenLocation:2 closeLocation:4 elements:@[
			[KTXPAtomNode createWithString:@"0" atLocation:3 type:KTXPTokenTypeAtom]
		]]],
	[KTXPAtomNode createWithString:@"+" atLocation:5 type:KTXPTokenTypeAtom],
	[KTXPFunctionNode createWithString:@"\\cfrac" atLocation:6 type:KTXPTokenTypeFunction arguments:@[
		[KTXPGroupNode createWithOpenLocation:12 closeLocation:14 elements:@[
			[KTXPAtomNode createWithString:@"1" atLocation:13 type:KTXPTokenTypeAtom]
		]],
		[KTXPGroupNode createWithOpenLocation:15 closeLocation:72 elements:@[
			[KTXPAtomNode createWithString:@"a" atLocation:16 type:KTXPTokenTypeAtom],
			[KTXPSupSubNode createWithSup:nil Sub:[KTXPGroupNode createWithOpenLocation:18 closeLocation:20 elements:@[
					[KTXPAtomNode createWithString:@"1" atLocation:19 type:KTXPTokenTypeAtom]
				]]],
			[KTXPAtomNode createWithString:@"+" atLocation:21 type:KTXPTokenTypeAtom],
			[KTXPFunctionNode createWithString:@"\\cfrac" atLocation:22 type:KTXPTokenTypeFunction arguments:@[
				[KTXPGroupNode createWithOpenLocation:28 closeLocation:30 elements:@[
					[KTXPAtomNode createWithString:@"1" atLocation:29 type:KTXPTokenTypeAtom]
				]],
				[KTXPGroupNode createWithOpenLocation:31 closeLocation:71 elements:@[
					[KTXPAtomNode createWithString:@"a" atLocation:32 type:KTXPTokenTypeAtom],
					[KTXPSupSubNode createWithSup:nil Sub:[KTXPGroupNode createWithOpenLocation:34 closeLocation:36 elements:@[
							[KTXPAtomNode createWithString:@"2" atLocation:35 type:KTXPTokenTypeAtom]
						]]],
					[KTXPAtomNode createWithString:@"+" atLocation:37 type:KTXPTokenTypeAtom],
					[KTXPFunctionNode createWithString:@"\\cfrac" atLocation:38 type:KTXPTokenTypeFunction arguments:@[
						[KTXPGroupNode createWithOpenLocation:44 closeLocation:46 elements:@[
							[KTXPAtomNode createWithString:@"1" atLocation:45 type:KTXPTokenTypeAtom]
						]],
						[KTXPGroupNode createWithOpenLocation:47 closeLocation:70 elements:@[
							[KTXPAtomNode createWithString:@"a" atLocation:48 type:KTXPTokenTypeAtom],
							[KTXPSupSubNode createWithSup:nil Sub:[KTXPGroupNode createWithOpenLocation:50 closeLocation:52 elements:@[
									[KTXPAtomNode createWithString:@"3" atLocation:51 type:KTXPTokenTypeAtom]
								]]],
							[KTXPAtomNode createWithString:@"+" atLocation:53 type:KTXPTokenTypeAtom],
							[KTXPFunctionNode createWithString:@"\\cfrac" atLocation:54 type:KTXPTokenTypeFunction arguments:@[
								[KTXPGroupNode createWithOpenLocation:60 closeLocation:62 elements:@[
									[KTXPAtomNode createWithString:@"1" atLocation:61 type:KTXPTokenTypeAtom]
								]],
								[KTXPGroupNode createWithOpenLocation:63 closeLocation:69 elements:@[
									[KTXPAtomNode createWithString:@"a" atLocation:64 type:KTXPTokenTypeAtom],
									[KTXPSupSubNode createWithSup:nil Sub:[KTXPGroupNode createWithOpenLocation:66 closeLocation:68 elements:@[
											[KTXPAtomNode createWithString:@"4" atLocation:67 type:KTXPTokenTypeAtom]
										]]]
								]]
							]]
						]]
					]]
				]]
			]]
		]]
	]]
]];

	XCTAssert([c isEqual:r]);
}

- (void) testStress8
{
	[self setParser: [KTXPParser createWithInput:@"\\binom{n}{k/2}"
										settings:[KTXPParser DEFAULT_SETTINGS]]];

	KTXPRootNode *r = [_parser parse:nil];
	KTXPRootNode *c = [KTXPRootNode createWithChildren:@[
	[KTXPFunctionNode createWithString:@"\\binom" atLocation:0 type:KTXPTokenTypeFunction arguments:@[
		[KTXPGroupNode createWithOpenLocation:6 closeLocation:8 elements:@[
			[KTXPAtomNode createWithString:@"n" atLocation:7 type:KTXPTokenTypeAtom]
		]],
		[KTXPGroupNode createWithOpenLocation:9 closeLocation:13 elements:@[
			[KTXPAtomNode createWithString:@"k" atLocation:10 type:KTXPTokenTypeAtom],
			[KTXPAtomNode createWithString:@"/" atLocation:11 type:KTXPTokenTypeAtom],
			[KTXPAtomNode createWithString:@"2" atLocation:12 type:KTXPTokenTypeAtom]
		]]
	]]
]];

	XCTAssert([c isEqual:r]);
}

- (void) testStress9
{
	[self setParser: [KTXPParser createWithInput:@"\\binom{p}{2} x^{2}y^{p-2}-\\frac{1}{1-x}\\frac{1}{1-x^{2}}"
										settings:[KTXPParser DEFAULT_SETTINGS]]];

	KTXPRootNode *r = [_parser parse:nil];
	KTXPRootNode *c = [KTXPRootNode createWithChildren:@[
	[KTXPFunctionNode createWithString:@"\\binom" atLocation:0 type:KTXPTokenTypeFunction arguments:@[
		[KTXPGroupNode createWithOpenLocation:6 closeLocation:8 elements:@[
			[KTXPAtomNode createWithString:@"p" atLocation:7 type:KTXPTokenTypeAtom]
		]],
		[KTXPGroupNode createWithOpenLocation:9 closeLocation:11 elements:@[
			[KTXPAtomNode createWithString:@"2" atLocation:10 type:KTXPTokenTypeAtom]
		]]
	]],
	[KTXPAtomNode createWithString:@" " atLocation:12 type:KTXPTokenTypeAtom],
	[KTXPAtomNode createWithString:@"x" atLocation:13 type:KTXPTokenTypeAtom],
	[KTXPSupSubNode createWithSup:[KTXPGroupNode createWithOpenLocation:15 closeLocation:17 elements:@[
			[KTXPAtomNode createWithString:@"2" atLocation:16 type:KTXPTokenTypeAtom]
		]] Sub:nil],
	[KTXPAtomNode createWithString:@"y" atLocation:18 type:KTXPTokenTypeAtom],
	[KTXPSupSubNode createWithSup:[KTXPGroupNode createWithOpenLocation:20 closeLocation:24 elements:@[
			[KTXPAtomNode createWithString:@"p" atLocation:21 type:KTXPTokenTypeAtom],
			[KTXPAtomNode createWithString:@"-" atLocation:22 type:KTXPTokenTypeAtom],
			[KTXPAtomNode createWithString:@"2" atLocation:23 type:KTXPTokenTypeAtom]
		]] Sub:nil],
	[KTXPAtomNode createWithString:@"-" atLocation:25 type:KTXPTokenTypeAtom],
	[KTXPFunctionNode createWithString:@"\\frac" atLocation:26 type:KTXPTokenTypeFunction arguments:@[
		[KTXPGroupNode createWithOpenLocation:31 closeLocation:33 elements:@[
			[KTXPAtomNode createWithString:@"1" atLocation:32 type:KTXPTokenTypeAtom]
		]],
		[KTXPGroupNode createWithOpenLocation:34 closeLocation:38 elements:@[
			[KTXPAtomNode createWithString:@"1" atLocation:35 type:KTXPTokenTypeAtom],
			[KTXPAtomNode createWithString:@"-" atLocation:36 type:KTXPTokenTypeAtom],
			[KTXPAtomNode createWithString:@"x" atLocation:37 type:KTXPTokenTypeAtom]
		]]
	]],
	[KTXPFunctionNode createWithString:@"\\frac" atLocation:39 type:KTXPTokenTypeFunction arguments:@[
		[KTXPGroupNode createWithOpenLocation:44 closeLocation:46 elements:@[
			[KTXPAtomNode createWithString:@"1" atLocation:45 type:KTXPTokenTypeAtom]
		]],
		[KTXPGroupNode createWithOpenLocation:47 closeLocation:55 elements:@[
			[KTXPAtomNode createWithString:@"1" atLocation:48 type:KTXPTokenTypeAtom],
			[KTXPAtomNode createWithString:@"-" atLocation:49 type:KTXPTokenTypeAtom],
			[KTXPAtomNode createWithString:@"x" atLocation:50 type:KTXPTokenTypeAtom],
			[KTXPSupSubNode createWithSup:[KTXPGroupNode createWithOpenLocation:52 closeLocation:54 elements:@[
					[KTXPAtomNode createWithString:@"2" atLocation:53 type:KTXPTokenTypeAtom]
				]] Sub:nil]
		]]
	]]
]];

	XCTAssert([c isEqual:r]);
}

- (void) testStress10
{
	[self setParser: [KTXPParser createWithInput:@"\\sum_{\\substack{0 \\le i \\le m \\\\ 0 < j < n}} P(i,j)"
										settings:[KTXPParser DEFAULT_SETTINGS]]];

	KTXPRootNode *r = [_parser parse:nil];
	KTXPRootNode *c = [KTXPRootNode createWithChildren:@[
	[KTXPAtomNode createWithString:@"\\sum" atLocation:0 type:KTXPTokenTypeAtom],
	[KTXPSupSubNode createWithSup:nil Sub:[KTXPGroupNode createWithOpenLocation:5 closeLocation:43 elements:@[
			[KTXPFunctionNode createWithString:@"\\substack" atLocation:6 type:KTXPTokenTypeFunction arguments:@[]],
			[KTXPGroupNode createWithOpenLocation:15 closeLocation:42 elements:@[
				[KTXPAtomNode createWithString:@"0" atLocation:16 type:KTXPTokenTypeAtom],
				[KTXPAtomNode createWithString:@" " atLocation:17 type:KTXPTokenTypeAtom],
				[KTXPAtomNode createWithString:@"\\le " atLocation:18 type:KTXPTokenTypeAtom],
				[KTXPAtomNode createWithString:@"i" atLocation:22 type:KTXPTokenTypeAtom],
				[KTXPAtomNode createWithString:@" " atLocation:23 type:KTXPTokenTypeAtom],
				[KTXPAtomNode createWithString:@"\\le " atLocation:24 type:KTXPTokenTypeAtom],
				[KTXPAtomNode createWithString:@"m" atLocation:28 type:KTXPTokenTypeAtom],
				[KTXPAtomNode createWithString:@" " atLocation:29 type:KTXPTokenTypeAtom],
				[KTXPAtomNode createWithString:@"\\\\" atLocation:30 type:KTXPTokenTypeAtom],
				[KTXPAtomNode createWithString:@" " atLocation:32 type:KTXPTokenTypeAtom],
				[KTXPAtomNode createWithString:@"0" atLocation:33 type:KTXPTokenTypeAtom],
				[KTXPAtomNode createWithString:@" " atLocation:34 type:KTXPTokenTypeAtom],
				[KTXPAtomNode createWithString:@"<" atLocation:35 type:KTXPTokenTypeAtom],
				[KTXPAtomNode createWithString:@" " atLocation:36 type:KTXPTokenTypeAtom],
				[KTXPAtomNode createWithString:@"j" atLocation:37 type:KTXPTokenTypeAtom],
				[KTXPAtomNode createWithString:@" " atLocation:38 type:KTXPTokenTypeAtom],
				[KTXPAtomNode createWithString:@"<" atLocation:39 type:KTXPTokenTypeAtom],
				[KTXPAtomNode createWithString:@" " atLocation:40 type:KTXPTokenTypeAtom],
				[KTXPAtomNode createWithString:@"n" atLocation:41 type:KTXPTokenTypeAtom]
			]]
		]]],
	[KTXPAtomNode createWithString:@" " atLocation:44 type:KTXPTokenTypeAtom],
	[KTXPAtomNode createWithString:@"P" atLocation:45 type:KTXPTokenTypeAtom],
	[KTXPAtomNode createWithString:@"(" atLocation:46 type:KTXPTokenTypeAtom],
	[KTXPAtomNode createWithString:@"i" atLocation:47 type:KTXPTokenTypeAtom],
	[KTXPAtomNode createWithString:@"," atLocation:48 type:KTXPTokenTypeAtom],
	[KTXPAtomNode createWithString:@"j" atLocation:49 type:KTXPTokenTypeAtom],
	[KTXPAtomNode createWithString:@")" atLocation:50 type:KTXPTokenTypeAtom]
]];

	XCTAssert([c isEqual:r]);
}

- (void) testStress11
{
	[self setParser: [KTXPParser createWithInput:@"x^{2y}"
										settings:[KTXPParser DEFAULT_SETTINGS]]];

	KTXPRootNode *r = [_parser parse:nil];
	KTXPRootNode *c = [KTXPRootNode createWithChildren:@[
	[KTXPAtomNode createWithString:@"x" atLocation:0 type:KTXPTokenTypeAtom],
	[KTXPSupSubNode createWithSup:[KTXPGroupNode createWithOpenLocation:2 closeLocation:5 elements:@[
			[KTXPAtomNode createWithString:@"2" atLocation:3 type:KTXPTokenTypeAtom],
			[KTXPAtomNode createWithString:@"y" atLocation:4 type:KTXPTokenTypeAtom]
		]] Sub:nil]
]];

	XCTAssert([c isEqual:r]);
}

- (void) testStress12
{
	[self setParser: [KTXPParser createWithInput:@"\\sum_{i=1}^{p} \\sum_{j=1}^{q} \\sum_{k=1}^{r} a_{ij} b_{jk} c_{ki}"
										settings:[KTXPParser DEFAULT_SETTINGS]]];

	KTXPRootNode *r = [_parser parse:nil];
	KTXPRootNode *c = [KTXPRootNode createWithChildren:@[
	[KTXPAtomNode createWithString:@"\\sum" atLocation:0 type:KTXPTokenTypeAtom],
	[KTXPSupSubNode createWithSup:[KTXPGroupNode createWithOpenLocation:11 closeLocation:13 elements:@[
			[KTXPAtomNode createWithString:@"p" atLocation:12 type:KTXPTokenTypeAtom]
		]] Sub:[KTXPGroupNode createWithOpenLocation:5 closeLocation:9 elements:@[
			[KTXPAtomNode createWithString:@"i" atLocation:6 type:KTXPTokenTypeAtom],
			[KTXPAtomNode createWithString:@"=" atLocation:7 type:KTXPTokenTypeAtom],
			[KTXPAtomNode createWithString:@"1" atLocation:8 type:KTXPTokenTypeAtom]
		]]],
	[KTXPAtomNode createWithString:@" " atLocation:14 type:KTXPTokenTypeAtom],
	[KTXPAtomNode createWithString:@"\\sum" atLocation:15 type:KTXPTokenTypeAtom],
	[KTXPSupSubNode createWithSup:[KTXPGroupNode createWithOpenLocation:26 closeLocation:28 elements:@[
			[KTXPAtomNode createWithString:@"q" atLocation:27 type:KTXPTokenTypeAtom]
		]] Sub:[KTXPGroupNode createWithOpenLocation:20 closeLocation:24 elements:@[
			[KTXPAtomNode createWithString:@"j" atLocation:21 type:KTXPTokenTypeAtom],
			[KTXPAtomNode createWithString:@"=" atLocation:22 type:KTXPTokenTypeAtom],
			[KTXPAtomNode createWithString:@"1" atLocation:23 type:KTXPTokenTypeAtom]
		]]],
	[KTXPAtomNode createWithString:@" " atLocation:29 type:KTXPTokenTypeAtom],
	[KTXPAtomNode createWithString:@"\\sum" atLocation:30 type:KTXPTokenTypeAtom],
	[KTXPSupSubNode createWithSup:[KTXPGroupNode createWithOpenLocation:41 closeLocation:43 elements:@[
			[KTXPAtomNode createWithString:@"r" atLocation:42 type:KTXPTokenTypeAtom]
		]] Sub:[KTXPGroupNode createWithOpenLocation:35 closeLocation:39 elements:@[
			[KTXPAtomNode createWithString:@"k" atLocation:36 type:KTXPTokenTypeAtom],
			[KTXPAtomNode createWithString:@"=" atLocation:37 type:KTXPTokenTypeAtom],
			[KTXPAtomNode createWithString:@"1" atLocation:38 type:KTXPTokenTypeAtom]
		]]],
	[KTXPAtomNode createWithString:@" " atLocation:44 type:KTXPTokenTypeAtom],
	[KTXPAtomNode createWithString:@"a" atLocation:45 type:KTXPTokenTypeAtom],
	[KTXPSupSubNode createWithSup:nil Sub:[KTXPGroupNode createWithOpenLocation:47 closeLocation:50 elements:@[
			[KTXPAtomNode createWithString:@"i" atLocation:48 type:KTXPTokenTypeAtom],
			[KTXPAtomNode createWithString:@"j" atLocation:49 type:KTXPTokenTypeAtom]
		]]],
	[KTXPAtomNode createWithString:@" " atLocation:51 type:KTXPTokenTypeAtom],
	[KTXPAtomNode createWithString:@"b" atLocation:52 type:KTXPTokenTypeAtom],
	[KTXPSupSubNode createWithSup:nil Sub:[KTXPGroupNode createWithOpenLocation:54 closeLocation:57 elements:@[
			[KTXPAtomNode createWithString:@"j" atLocation:55 type:KTXPTokenTypeAtom],
			[KTXPAtomNode createWithString:@"k" atLocation:56 type:KTXPTokenTypeAtom]
		]]],
	[KTXPAtomNode createWithString:@" " atLocation:58 type:KTXPTokenTypeAtom],
	[KTXPAtomNode createWithString:@"c" atLocation:59 type:KTXPTokenTypeAtom],
	[KTXPSupSubNode createWithSup:nil Sub:[KTXPGroupNode createWithOpenLocation:61 closeLocation:64 elements:@[
			[KTXPAtomNode createWithString:@"k" atLocation:62 type:KTXPTokenTypeAtom],
			[KTXPAtomNode createWithString:@"i" atLocation:63 type:KTXPTokenTypeAtom]
		]]]
]];

	XCTAssert([c isEqual:r]);
}

- (void) testStress13
{
	[self setParser: [KTXPParser createWithInput:@"\\sqrt{1+\\sqrt{1+\\sqrt{1+\\sqrt{1+\\sqrt{1+\\sqrt{1+\\sqrt{1+x}}}}}}}"
										settings:[KTXPParser DEFAULT_SETTINGS]]];

	KTXPRootNode *r = [_parser parse:nil];
	KTXPRootNode *c = [KTXPRootNode createWithChildren:@[
	[KTXPSquareRoot createWithIndex:nil radicand:[KTXPGroupNode createWithOpenLocation:5 closeLocation:63 elements:@[
			[KTXPAtomNode createWithString:@"1" atLocation:6 type:KTXPTokenTypeAtom],
			[KTXPAtomNode createWithString:@"+" atLocation:7 type:KTXPTokenTypeAtom],
			[KTXPSquareRoot createWithIndex:nil radicand:[KTXPGroupNode createWithOpenLocation:13 closeLocation:62 elements:@[
					[KTXPAtomNode createWithString:@"1" atLocation:14 type:KTXPTokenTypeAtom],
					[KTXPAtomNode createWithString:@"+" atLocation:15 type:KTXPTokenTypeAtom],
					[KTXPSquareRoot createWithIndex:nil radicand:[KTXPGroupNode createWithOpenLocation:21 closeLocation:61 elements:@[
							[KTXPAtomNode createWithString:@"1" atLocation:22 type:KTXPTokenTypeAtom],
							[KTXPAtomNode createWithString:@"+" atLocation:23 type:KTXPTokenTypeAtom],
							[KTXPSquareRoot createWithIndex:nil radicand:[KTXPGroupNode createWithOpenLocation:29 closeLocation:60 elements:@[
									[KTXPAtomNode createWithString:@"1" atLocation:30 type:KTXPTokenTypeAtom],
									[KTXPAtomNode createWithString:@"+" atLocation:31 type:KTXPTokenTypeAtom],
									[KTXPSquareRoot createWithIndex:nil radicand:[KTXPGroupNode createWithOpenLocation:37 closeLocation:59 elements:@[
											[KTXPAtomNode createWithString:@"1" atLocation:38 type:KTXPTokenTypeAtom],
											[KTXPAtomNode createWithString:@"+" atLocation:39 type:KTXPTokenTypeAtom],
											[KTXPSquareRoot createWithIndex:nil radicand:[KTXPGroupNode createWithOpenLocation:45 closeLocation:58 elements:@[
													[KTXPAtomNode createWithString:@"1" atLocation:46 type:KTXPTokenTypeAtom],
													[KTXPAtomNode createWithString:@"+" atLocation:47 type:KTXPTokenTypeAtom],
													[KTXPSquareRoot createWithIndex:nil radicand:[KTXPGroupNode createWithOpenLocation:53 closeLocation:57 elements:@[
															[KTXPAtomNode createWithString:@"1" atLocation:54 type:KTXPTokenTypeAtom],
															[KTXPAtomNode createWithString:@"+" atLocation:55 type:KTXPTokenTypeAtom],
															[KTXPAtomNode createWithString:@"x" atLocation:56 type:KTXPTokenTypeAtom]
														]]]
												]]]
										]]]
								]]]
						]]]
				]]]
		]]]
]];

	XCTAssert([c isEqual:r]);
}

- (void) testStress14
{
	[self setParser: [KTXPParser createWithInput:@"\\left( \\frac{\\partial^2}{\\partial x^2} + \\frac{\\partial^2}{\\partial y^2} \\right) |\\varphi(x+iy)|^2 = 0"
										settings:[KTXPParser DEFAULT_SETTINGS]]];

	KTXPRootNode *r = [_parser parse:nil];
	KTXPRootNode *c = [KTXPRootNode createWithChildren:@[
	[KTXPMacroGroupNode createWithLeft:[KTXPFunctionNode createWithString:@"\\left" atLocation:0 type:KTXPTokenTypeSpecialFunction arguments:@[[KTXPToken createWithLexeme:@"(" location:5 type:KTXPTokenTypeAtom]]] elements:@[
		[KTXPAtomNode createWithString:@" " atLocation:6 type:KTXPTokenTypeAtom],
		[KTXPFunctionNode createWithString:@"\\frac" atLocation:7 type:KTXPTokenTypeFunction arguments:@[
			[KTXPGroupNode createWithOpenLocation:12 closeLocation:23 elements:@[
				[KTXPAtomNode createWithString:@"\\partial" atLocation:13 type:KTXPTokenTypeAtom],
				[KTXPSupSubNode createWithSup:[KTXPGroupNode createWithOpenLocation:NSNotFound closeLocation:NSNotFound elements:@[
						[KTXPAtomNode createWithString:@"2" atLocation:22 type:KTXPTokenTypeAtom]
					]] Sub:nil]
			]],
			[KTXPGroupNode createWithOpenLocation:24 closeLocation:37 elements:@[
				[KTXPAtomNode createWithString:@"\\partial " atLocation:25 type:KTXPTokenTypeAtom],
				[KTXPAtomNode createWithString:@"x" atLocation:34 type:KTXPTokenTypeAtom],
				[KTXPSupSubNode createWithSup:[KTXPGroupNode createWithOpenLocation:NSNotFound closeLocation:NSNotFound elements:@[
						[KTXPAtomNode createWithString:@"2" atLocation:36 type:KTXPTokenTypeAtom]
					]] Sub:nil]
			]]
		]],
		[KTXPAtomNode createWithString:@" " atLocation:38 type:KTXPTokenTypeAtom],
		[KTXPAtomNode createWithString:@"+" atLocation:39 type:KTXPTokenTypeAtom],
		[KTXPAtomNode createWithString:@" " atLocation:40 type:KTXPTokenTypeAtom],
		[KTXPFunctionNode createWithString:@"\\frac" atLocation:41 type:KTXPTokenTypeFunction arguments:@[
			[KTXPGroupNode createWithOpenLocation:46 closeLocation:57 elements:@[
				[KTXPAtomNode createWithString:@"\\partial" atLocation:47 type:KTXPTokenTypeAtom],
				[KTXPSupSubNode createWithSup:[KTXPGroupNode createWithOpenLocation:NSNotFound closeLocation:NSNotFound elements:@[
						[KTXPAtomNode createWithString:@"2" atLocation:56 type:KTXPTokenTypeAtom]
					]] Sub:nil]
			]],
			[KTXPGroupNode createWithOpenLocation:58 closeLocation:71 elements:@[
				[KTXPAtomNode createWithString:@"\\partial " atLocation:59 type:KTXPTokenTypeAtom],
				[KTXPAtomNode createWithString:@"y" atLocation:68 type:KTXPTokenTypeAtom],
				[KTXPSupSubNode createWithSup:[KTXPGroupNode createWithOpenLocation:NSNotFound closeLocation:NSNotFound elements:@[
						[KTXPAtomNode createWithString:@"2" atLocation:70 type:KTXPTokenTypeAtom]
					]] Sub:nil]
			]]
		]],
		[KTXPAtomNode createWithString:@" " atLocation:72 type:KTXPTokenTypeAtom]
	] right:[KTXPFunctionNode createWithString:@"\\right" atLocation:73 type:KTXPTokenTypeSpecialFunction arguments:@[[KTXPToken createWithLexeme:@")" location:79 type:KTXPTokenTypeAtom]]]],
	[KTXPAtomNode createWithString:@" " atLocation:80 type:KTXPTokenTypeAtom],
	[KTXPAtomNode createWithString:@"|" atLocation:81 type:KTXPTokenTypeAtom],
	[KTXPAtomNode createWithString:@"\\varphi" atLocation:82 type:KTXPTokenTypeAtom],
	[KTXPAtomNode createWithString:@"(" atLocation:89 type:KTXPTokenTypeAtom],
	[KTXPAtomNode createWithString:@"x" atLocation:90 type:KTXPTokenTypeAtom],
	[KTXPAtomNode createWithString:@"+" atLocation:91 type:KTXPTokenTypeAtom],
	[KTXPAtomNode createWithString:@"i" atLocation:92 type:KTXPTokenTypeAtom],
	[KTXPAtomNode createWithString:@"y" atLocation:93 type:KTXPTokenTypeAtom],
	[KTXPAtomNode createWithString:@")" atLocation:94 type:KTXPTokenTypeAtom],
	[KTXPAtomNode createWithString:@"|" atLocation:95 type:KTXPTokenTypeAtom],
	[KTXPSupSubNode createWithSup:[KTXPGroupNode createWithOpenLocation:NSNotFound closeLocation:NSNotFound elements:@[
			[KTXPAtomNode createWithString:@"2" atLocation:97 type:KTXPTokenTypeAtom]
		]] Sub:nil],
	[KTXPAtomNode createWithString:@" " atLocation:98 type:KTXPTokenTypeAtom],
	[KTXPAtomNode createWithString:@"=" atLocation:99 type:KTXPTokenTypeAtom],
	[KTXPAtomNode createWithString:@" " atLocation:100 type:KTXPTokenTypeAtom],
	[KTXPAtomNode createWithString:@"0" atLocation:101 type:KTXPTokenTypeAtom]
]];

	XCTAssert([c isEqual:r]);
}

- (void) testStress15
{
	[self setParser: [KTXPParser createWithInput:@"2^{2^{2^x}}"
										settings:[KTXPParser DEFAULT_SETTINGS]]];

	KTXPRootNode *r = [_parser parse:nil];
	KTXPRootNode *c = [KTXPRootNode createWithChildren:@[
	[KTXPAtomNode createWithString:@"2" atLocation:0 type:KTXPTokenTypeAtom],
	[KTXPSupSubNode createWithSup:[KTXPGroupNode createWithOpenLocation:2 closeLocation:10 elements:@[
			[KTXPAtomNode createWithString:@"2" atLocation:3 type:KTXPTokenTypeAtom],
			[KTXPSupSubNode createWithSup:[KTXPGroupNode createWithOpenLocation:5 closeLocation:9 elements:@[
					[KTXPAtomNode createWithString:@"2" atLocation:6 type:KTXPTokenTypeAtom],
					[KTXPSupSubNode createWithSup:[KTXPGroupNode createWithOpenLocation:NSNotFound closeLocation:NSNotFound elements:@[
							[KTXPAtomNode createWithString:@"x" atLocation:8 type:KTXPTokenTypeAtom]
						]] Sub:nil]
				]] Sub:nil]
		]] Sub:nil]
]];

	XCTAssert([c isEqual:r]);
}

- (void) testStress16
{
	[self setParser: [KTXPParser createWithInput:@"\\int_1^x \\frac{dt}{t}"
										settings:[KTXPParser DEFAULT_SETTINGS]]];

	KTXPRootNode *r = [_parser parse:nil];
	KTXPRootNode *c = [KTXPRootNode createWithChildren:@[
	[KTXPAtomNode createWithString:@"\\int" atLocation:0 type:KTXPTokenTypeAtom],
	[KTXPSupSubNode createWithSup:[KTXPGroupNode createWithOpenLocation:NSNotFound closeLocation:NSNotFound elements:@[
			[KTXPAtomNode createWithString:@"x" atLocation:7 type:KTXPTokenTypeAtom]
		]] Sub:[KTXPGroupNode createWithOpenLocation:NSNotFound closeLocation:NSNotFound elements:@[
			[KTXPAtomNode createWithString:@"1" atLocation:5 type:KTXPTokenTypeAtom]
		]]],
	[KTXPAtomNode createWithString:@" " atLocation:8 type:KTXPTokenTypeAtom],
	[KTXPFunctionNode createWithString:@"\\frac" atLocation:9 type:KTXPTokenTypeFunction arguments:@[
		[KTXPGroupNode createWithOpenLocation:14 closeLocation:17 elements:@[
			[KTXPAtomNode createWithString:@"d" atLocation:15 type:KTXPTokenTypeAtom],
			[KTXPAtomNode createWithString:@"t" atLocation:16 type:KTXPTokenTypeAtom]
		]],
		[KTXPGroupNode createWithOpenLocation:18 closeLocation:20 elements:@[
			[KTXPAtomNode createWithString:@"t" atLocation:19 type:KTXPTokenTypeAtom]
		]]
	]]
]];

	XCTAssert([c isEqual:r]);
}

- (void) testStress17
{
	[self setParser: [KTXPParser createWithInput:@"\\iint_D dx \\, dy"
										settings:[KTXPParser DEFAULT_SETTINGS]]];

	KTXPRootNode *r = [_parser parse:nil];
	KTXPRootNode *c = [KTXPRootNode createWithChildren:@[
	[KTXPAtomNode createWithString:@"\\iint" atLocation:0 type:KTXPTokenTypeAtom],
	[KTXPSupSubNode createWithSup:nil Sub:[KTXPGroupNode createWithOpenLocation:NSNotFound closeLocation:NSNotFound elements:@[
			[KTXPAtomNode createWithString:@"D" atLocation:6 type:KTXPTokenTypeAtom]
		]]],
	[KTXPAtomNode createWithString:@" " atLocation:7 type:KTXPTokenTypeAtom],
	[KTXPAtomNode createWithString:@"d" atLocation:8 type:KTXPTokenTypeAtom],
	[KTXPAtomNode createWithString:@"x" atLocation:9 type:KTXPTokenTypeAtom],
	[KTXPAtomNode createWithString:@" " atLocation:10 type:KTXPTokenTypeAtom],
	[KTXPWhitespaceNode createWithString:@"\\," atLocation:11],
	[KTXPAtomNode createWithString:@" " atLocation:13 type:KTXPTokenTypeAtom],
	[KTXPAtomNode createWithString:@"d" atLocation:14 type:KTXPTokenTypeAtom],
	[KTXPAtomNode createWithString:@"y" atLocation:15 type:KTXPTokenTypeAtom]
]];

	XCTAssert([c isEqual:r]);
}

- (void) testStress18
{
	NSString *l1 = @"f(x) = \\begin{cases}";
	NSString *l2 = @"1/3 & \\text{if } 0 \\le x \\le 1; \\\\";
	NSString *l3 = @"2/3 & \\text{if } 3 \\le x \\le 4; \\\\";
	NSString *l4 = @"0 & \\text{elsewhere.}";
	NSString *l5 = @"\\end{cases}";
	NSString *testStr = [NSString stringWithFormat:@"%@ %@ %@ %@ %@", l1, l2, l3, l4, l5];

	[self setParser: [KTXPParser createWithInput:testStr
										settings:[KTXPParser DEFAULT_SETTINGS]]];

	KTXPRootNode *r = [_parser parse:nil];
	KTXPRootNode *c = [KTXPRootNode createWithChildren:@[
	[KTXPAtomNode createWithString:@"f" atLocation:0 type:KTXPTokenTypeAtom],
	[KTXPAtomNode createWithString:@"(" atLocation:1 type:KTXPTokenTypeAtom],
	[KTXPAtomNode createWithString:@"x" atLocation:2 type:KTXPTokenTypeAtom],
	[KTXPAtomNode createWithString:@")" atLocation:3 type:KTXPTokenTypeAtom],
	[KTXPAtomNode createWithString:@" " atLocation:4 type:KTXPTokenTypeAtom],
	[KTXPAtomNode createWithString:@"=" atLocation:5 type:KTXPTokenTypeAtom],
	[KTXPAtomNode createWithString:@" " atLocation:6 type:KTXPTokenTypeAtom],
	[KTXPEnvironmentNode createWithBegin:[KTXPEnvironmentOpen createWithBoundary:[KTXPToken createWithLexeme:@"\\begin" location:7 type:KTXPTokenTypeEnvironmentOpen] env:@"cases"] children:@[
		[KTXPAtomNode createWithString:@" " atLocation:20 type:KTXPTokenTypeAtom],
		[KTXPAtomNode createWithString:@"1" atLocation:21 type:KTXPTokenTypeAtom],
		[KTXPAtomNode createWithString:@"/" atLocation:22 type:KTXPTokenTypeAtom],
		[KTXPAtomNode createWithString:@"3" atLocation:23 type:KTXPTokenTypeAtom],
		[KTXPAtomNode createWithString:@" " atLocation:24 type:KTXPTokenTypeAtom],
		[KTXPAtomNode createWithString:@"&" atLocation:25 type:KTXPTokenTypeAtom],
		[KTXPAtomNode createWithString:@" " atLocation:26 type:KTXPTokenTypeAtom],
		[KTXPFunctionNode createWithString:@"\\text" atLocation:27 type:KTXPTokenTypeFunction arguments:@[]],
		[KTXPGroupNode createWithOpenLocation:32 closeLocation:36 elements:@[
			[KTXPAtomNode createWithString:@"i" atLocation:33 type:KTXPTokenTypeAtom],
			[KTXPAtomNode createWithString:@"f" atLocation:34 type:KTXPTokenTypeAtom],
			[KTXPAtomNode createWithString:@" " atLocation:35 type:KTXPTokenTypeAtom]
		]],
		[KTXPAtomNode createWithString:@" " atLocation:37 type:KTXPTokenTypeAtom],
		[KTXPAtomNode createWithString:@"0" atLocation:38 type:KTXPTokenTypeAtom],
		[KTXPAtomNode createWithString:@" " atLocation:39 type:KTXPTokenTypeAtom],
		[KTXPAtomNode createWithString:@"\\le " atLocation:40 type:KTXPTokenTypeAtom],
		[KTXPAtomNode createWithString:@"x" atLocation:44 type:KTXPTokenTypeAtom],
		[KTXPAtomNode createWithString:@" " atLocation:45 type:KTXPTokenTypeAtom],
		[KTXPAtomNode createWithString:@"\\le " atLocation:46 type:KTXPTokenTypeAtom],
		[KTXPAtomNode createWithString:@"1" atLocation:50 type:KTXPTokenTypeAtom],
		[KTXPAtomNode createWithString:@";" atLocation:51 type:KTXPTokenTypeAtom],
		[KTXPAtomNode createWithString:@" " atLocation:52 type:KTXPTokenTypeAtom],
		[KTXPAtomNode createWithString:@"\\\\" atLocation:53 type:KTXPTokenTypeAtom],
		[KTXPAtomNode createWithString:@" " atLocation:55 type:KTXPTokenTypeAtom],
		[KTXPAtomNode createWithString:@"2" atLocation:56 type:KTXPTokenTypeAtom],
		[KTXPAtomNode createWithString:@"/" atLocation:57 type:KTXPTokenTypeAtom],
		[KTXPAtomNode createWithString:@"3" atLocation:58 type:KTXPTokenTypeAtom],
		[KTXPAtomNode createWithString:@" " atLocation:59 type:KTXPTokenTypeAtom],
		[KTXPAtomNode createWithString:@"&" atLocation:60 type:KTXPTokenTypeAtom],
		[KTXPAtomNode createWithString:@" " atLocation:61 type:KTXPTokenTypeAtom],
		[KTXPFunctionNode createWithString:@"\\text" atLocation:62 type:KTXPTokenTypeFunction arguments:@[]],
		[KTXPGroupNode createWithOpenLocation:67 closeLocation:71 elements:@[
			[KTXPAtomNode createWithString:@"i" atLocation:68 type:KTXPTokenTypeAtom],
			[KTXPAtomNode createWithString:@"f" atLocation:69 type:KTXPTokenTypeAtom],
			[KTXPAtomNode createWithString:@" " atLocation:70 type:KTXPTokenTypeAtom]
		]],
		[KTXPAtomNode createWithString:@" " atLocation:72 type:KTXPTokenTypeAtom],
		[KTXPAtomNode createWithString:@"3" atLocation:73 type:KTXPTokenTypeAtom],
		[KTXPAtomNode createWithString:@" " atLocation:74 type:KTXPTokenTypeAtom],
		[KTXPAtomNode createWithString:@"\\le " atLocation:75 type:KTXPTokenTypeAtom],
		[KTXPAtomNode createWithString:@"x" atLocation:79 type:KTXPTokenTypeAtom],
		[KTXPAtomNode createWithString:@" " atLocation:80 type:KTXPTokenTypeAtom],
		[KTXPAtomNode createWithString:@"\\le " atLocation:81 type:KTXPTokenTypeAtom],
		[KTXPAtomNode createWithString:@"4" atLocation:85 type:KTXPTokenTypeAtom],
		[KTXPAtomNode createWithString:@";" atLocation:86 type:KTXPTokenTypeAtom],
		[KTXPAtomNode createWithString:@" " atLocation:87 type:KTXPTokenTypeAtom],
		[KTXPAtomNode createWithString:@"\\\\" atLocation:88 type:KTXPTokenTypeAtom],
		[KTXPAtomNode createWithString:@" " atLocation:90 type:KTXPTokenTypeAtom],
		[KTXPAtomNode createWithString:@"0" atLocation:91 type:KTXPTokenTypeAtom],
		[KTXPAtomNode createWithString:@" " atLocation:92 type:KTXPTokenTypeAtom],
		[KTXPAtomNode createWithString:@"&" atLocation:93 type:KTXPTokenTypeAtom],
		[KTXPAtomNode createWithString:@" " atLocation:94 type:KTXPTokenTypeAtom],
		[KTXPFunctionNode createWithString:@"\\text" atLocation:95 type:KTXPTokenTypeFunction arguments:@[]],
		[KTXPGroupNode createWithOpenLocation:100 closeLocation:111 elements:@[
			[KTXPAtomNode createWithString:@"e" atLocation:101 type:KTXPTokenTypeAtom],
			[KTXPAtomNode createWithString:@"l" atLocation:102 type:KTXPTokenTypeAtom],
			[KTXPAtomNode createWithString:@"s" atLocation:103 type:KTXPTokenTypeAtom],
			[KTXPAtomNode createWithString:@"e" atLocation:104 type:KTXPTokenTypeAtom],
			[KTXPAtomNode createWithString:@"w" atLocation:105 type:KTXPTokenTypeAtom],
			[KTXPAtomNode createWithString:@"h" atLocation:106 type:KTXPTokenTypeAtom],
			[KTXPAtomNode createWithString:@"e" atLocation:107 type:KTXPTokenTypeAtom],
			[KTXPAtomNode createWithString:@"r" atLocation:108 type:KTXPTokenTypeAtom],
			[KTXPAtomNode createWithString:@"e" atLocation:109 type:KTXPTokenTypeAtom],
			[KTXPAtomNode createWithString:@"." atLocation:110 type:KTXPTokenTypeAtom]
		]],
		[KTXPAtomNode createWithString:@" " atLocation:112 type:KTXPTokenTypeAtom]
	] end:[KTXPEnvironmentClose createWithBoundary:[KTXPToken createWithLexeme:@"\\end" location:113 type:KTXPTokenTypeEnvironmentClose] env:@"cases"]]
]];

	XCTAssert([c isEqual:r]);
}

- (void) testStress19
{
	[self setParser: [KTXPParser createWithInput:@"\\overbrace{x + \\dots + x}^{k \\text{ times}}"
										settings:[KTXPParser DEFAULT_SETTINGS]]];

	KTXPRootNode *r = [_parser parse:nil];
	KTXPRootNode *c = [KTXPRootNode createWithChildren:@[
	[KTXPOverbraceNode createWithGroup:[KTXPGroupNode createWithOpenLocation:10 closeLocation:24 elements:@[
			[KTXPAtomNode createWithString:@"x" atLocation:11 type:KTXPTokenTypeAtom],
			[KTXPAtomNode createWithString:@" " atLocation:12 type:KTXPTokenTypeAtom],
			[KTXPAtomNode createWithString:@"+" atLocation:13 type:KTXPTokenTypeAtom],
			[KTXPAtomNode createWithString:@" " atLocation:14 type:KTXPTokenTypeAtom],
			[KTXPAtomNode createWithString:@"\\dots " atLocation:15 type:KTXPTokenTypeAtom],
			[KTXPAtomNode createWithString:@"+" atLocation:21 type:KTXPTokenTypeAtom],
			[KTXPAtomNode createWithString:@" " atLocation:22 type:KTXPTokenTypeAtom],
			[KTXPAtomNode createWithString:@"x" atLocation:23 type:KTXPTokenTypeAtom]
		]] Over:[KTXPSupSubNode createWithSup:[KTXPGroupNode createWithOpenLocation:26 closeLocation:42 elements:@[
				[KTXPAtomNode createWithString:@"k" atLocation:27 type:KTXPTokenTypeAtom],
				[KTXPAtomNode createWithString:@" " atLocation:28 type:KTXPTokenTypeAtom],
				[KTXPFunctionNode createWithString:@"\\text" atLocation:29 type:KTXPTokenTypeFunction arguments:@[]],
				[KTXPGroupNode createWithOpenLocation:34 closeLocation:41 elements:@[
					[KTXPAtomNode createWithString:@" " atLocation:35 type:KTXPTokenTypeAtom],
					[KTXPAtomNode createWithString:@"t" atLocation:36 type:KTXPTokenTypeAtom],
					[KTXPAtomNode createWithString:@"i" atLocation:37 type:KTXPTokenTypeAtom],
					[KTXPAtomNode createWithString:@"m" atLocation:38 type:KTXPTokenTypeAtom],
					[KTXPAtomNode createWithString:@"e" atLocation:39 type:KTXPTokenTypeAtom],
					[KTXPAtomNode createWithString:@"s" atLocation:40 type:KTXPTokenTypeAtom]
				]]
			]] Sub:nil]]
]];

	XCTAssert([c isEqual:r]);
}

- (void) testStress20
{
	[self setParser: [KTXPParser createWithInput:@"y_{x^2}"
										settings:[KTXPParser DEFAULT_SETTINGS]]];

	KTXPRootNode *r = [_parser parse:nil];
	KTXPRootNode *c = [KTXPRootNode createWithChildren:@[
	[KTXPAtomNode createWithString:@"y" atLocation:0 type:KTXPTokenTypeAtom],
	[KTXPSupSubNode createWithSup:nil Sub:[KTXPGroupNode createWithOpenLocation:2 closeLocation:6 elements:@[
			[KTXPAtomNode createWithString:@"x" atLocation:3 type:KTXPTokenTypeAtom],
			[KTXPSupSubNode createWithSup:[KTXPGroupNode createWithOpenLocation:NSNotFound closeLocation:NSNotFound elements:@[
					[KTXPAtomNode createWithString:@"2" atLocation:5 type:KTXPTokenTypeAtom]
				]] Sub:nil]
		]]]
]];

	XCTAssert([c isEqual:r]);
}

- (void) testStress21
{
	[self setParser: [KTXPParser createWithInput:@"\\sum_{p \\text{ prime}} f(p) = \\int_{t>1} f(t) d\\pi(t)"
										settings:[KTXPParser DEFAULT_SETTINGS]]];

	KTXPRootNode *r = [_parser parse:nil];
	KTXPRootNode *c = [KTXPRootNode createWithChildren:@[
	[KTXPAtomNode createWithString:@"\\sum" atLocation:0 type:KTXPTokenTypeAtom],
	[KTXPSupSubNode createWithSup:nil Sub:[KTXPGroupNode createWithOpenLocation:5 closeLocation:21 elements:@[
			[KTXPAtomNode createWithString:@"p" atLocation:6 type:KTXPTokenTypeAtom],
			[KTXPAtomNode createWithString:@" " atLocation:7 type:KTXPTokenTypeAtom],
			[KTXPFunctionNode createWithString:@"\\text" atLocation:8 type:KTXPTokenTypeFunction arguments:@[]],
			[KTXPGroupNode createWithOpenLocation:13 closeLocation:20 elements:@[
				[KTXPAtomNode createWithString:@" " atLocation:14 type:KTXPTokenTypeAtom],
				[KTXPAtomNode createWithString:@"p" atLocation:15 type:KTXPTokenTypeAtom],
				[KTXPAtomNode createWithString:@"r" atLocation:16 type:KTXPTokenTypeAtom],
				[KTXPAtomNode createWithString:@"i" atLocation:17 type:KTXPTokenTypeAtom],
				[KTXPAtomNode createWithString:@"m" atLocation:18 type:KTXPTokenTypeAtom],
				[KTXPAtomNode createWithString:@"e" atLocation:19 type:KTXPTokenTypeAtom]
			]]
		]]],
	[KTXPAtomNode createWithString:@" " atLocation:22 type:KTXPTokenTypeAtom],
	[KTXPAtomNode createWithString:@"f" atLocation:23 type:KTXPTokenTypeAtom],
	[KTXPAtomNode createWithString:@"(" atLocation:24 type:KTXPTokenTypeAtom],
	[KTXPAtomNode createWithString:@"p" atLocation:25 type:KTXPTokenTypeAtom],
	[KTXPAtomNode createWithString:@")" atLocation:26 type:KTXPTokenTypeAtom],
	[KTXPAtomNode createWithString:@" " atLocation:27 type:KTXPTokenTypeAtom],
	[KTXPAtomNode createWithString:@"=" atLocation:28 type:KTXPTokenTypeAtom],
	[KTXPAtomNode createWithString:@" " atLocation:29 type:KTXPTokenTypeAtom],
	[KTXPAtomNode createWithString:@"\\int" atLocation:30 type:KTXPTokenTypeAtom],
	[KTXPSupSubNode createWithSup:nil Sub:[KTXPGroupNode createWithOpenLocation:35 closeLocation:39 elements:@[
			[KTXPAtomNode createWithString:@"t" atLocation:36 type:KTXPTokenTypeAtom],
			[KTXPAtomNode createWithString:@">" atLocation:37 type:KTXPTokenTypeAtom],
			[KTXPAtomNode createWithString:@"1" atLocation:38 type:KTXPTokenTypeAtom]
		]]],
	[KTXPAtomNode createWithString:@" " atLocation:40 type:KTXPTokenTypeAtom],
	[KTXPAtomNode createWithString:@"f" atLocation:41 type:KTXPTokenTypeAtom],
	[KTXPAtomNode createWithString:@"(" atLocation:42 type:KTXPTokenTypeAtom],
	[KTXPAtomNode createWithString:@"t" atLocation:43 type:KTXPTokenTypeAtom],
	[KTXPAtomNode createWithString:@")" atLocation:44 type:KTXPTokenTypeAtom],
	[KTXPAtomNode createWithString:@" " atLocation:45 type:KTXPTokenTypeAtom],
	[KTXPAtomNode createWithString:@"d" atLocation:46 type:KTXPTokenTypeAtom],
	[KTXPAtomNode createWithString:@"\\pi" atLocation:47 type:KTXPTokenTypeAtom],
	[KTXPAtomNode createWithString:@"(" atLocation:50 type:KTXPTokenTypeAtom],
	[KTXPAtomNode createWithString:@"t" atLocation:51 type:KTXPTokenTypeAtom],
	[KTXPAtomNode createWithString:@")" atLocation:52 type:KTXPTokenTypeAtom]
]];

	XCTAssert([c isEqual:r]);
}

- (void) testStress22
{
	[self setParser: [KTXPParser createWithInput:@"\\underbrace{\\overbrace{a, \\dots, a}^{k \\text{ } a\\text{'s}}, \\overbrace{b, \\dots, b}^{\\ell \\text{ } b\\text{'s}}}_{k+\\ell \\text{ elements}}"
										settings:[KTXPParser DEFAULT_SETTINGS]]];

	KTXPRootNode *r = [_parser parse:nil];
	KTXPRootNode *c = [KTXPRootNode createWithChildren:@[
	[KTXPUnderbraceNode createWithGroup:[KTXPGroupNode createWithOpenLocation:11 closeLocation:111 elements:@[
			[KTXPOverbraceNode createWithGroup:[KTXPGroupNode createWithOpenLocation:22 closeLocation:34 elements:@[
					[KTXPAtomNode createWithString:@"a" atLocation:23 type:KTXPTokenTypeAtom],
					[KTXPAtomNode createWithString:@"," atLocation:24 type:KTXPTokenTypeAtom],
					[KTXPAtomNode createWithString:@" " atLocation:25 type:KTXPTokenTypeAtom],
					[KTXPAtomNode createWithString:@"\\dots" atLocation:26 type:KTXPTokenTypeAtom],
					[KTXPAtomNode createWithString:@"," atLocation:31 type:KTXPTokenTypeAtom],
					[KTXPAtomNode createWithString:@" " atLocation:32 type:KTXPTokenTypeAtom],
					[KTXPAtomNode createWithString:@"a" atLocation:33 type:KTXPTokenTypeAtom]
				]] Over:[KTXPSupSubNode createWithSup:[KTXPGroupNode createWithOpenLocation:36 closeLocation:58 elements:@[
						[KTXPAtomNode createWithString:@"k" atLocation:37 type:KTXPTokenTypeAtom],
						[KTXPAtomNode createWithString:@" " atLocation:38 type:KTXPTokenTypeAtom],
						[KTXPFunctionNode createWithString:@"\\text" atLocation:39 type:KTXPTokenTypeFunction arguments:@[]],
						[KTXPGroupNode createWithOpenLocation:44 closeLocation:46 elements:@[
							[KTXPAtomNode createWithString:@" " atLocation:45 type:KTXPTokenTypeAtom]
						]],
						[KTXPAtomNode createWithString:@" " atLocation:47 type:KTXPTokenTypeAtom],
						[KTXPAtomNode createWithString:@"a" atLocation:48 type:KTXPTokenTypeAtom],
						[KTXPFunctionNode createWithString:@"\\text" atLocation:49 type:KTXPTokenTypeFunction arguments:@[]],
						[KTXPGroupNode createWithOpenLocation:54 closeLocation:57 elements:@[
							[KTXPAtomNode createWithString:@"'" atLocation:55 type:KTXPTokenTypeAtom],
							[KTXPAtomNode createWithString:@"s" atLocation:56 type:KTXPTokenTypeAtom]
						]]
					]] Sub:nil]],
			[KTXPAtomNode createWithString:@"," atLocation:59 type:KTXPTokenTypeAtom],
			[KTXPAtomNode createWithString:@" " atLocation:60 type:KTXPTokenTypeAtom],
			[KTXPOverbraceNode createWithGroup:[KTXPGroupNode createWithOpenLocation:71 closeLocation:83 elements:@[
					[KTXPAtomNode createWithString:@"b" atLocation:72 type:KTXPTokenTypeAtom],
					[KTXPAtomNode createWithString:@"," atLocation:73 type:KTXPTokenTypeAtom],
					[KTXPAtomNode createWithString:@" " atLocation:74 type:KTXPTokenTypeAtom],
					[KTXPAtomNode createWithString:@"\\dots" atLocation:75 type:KTXPTokenTypeAtom],
					[KTXPAtomNode createWithString:@"," atLocation:80 type:KTXPTokenTypeAtom],
					[KTXPAtomNode createWithString:@" " atLocation:81 type:KTXPTokenTypeAtom],
					[KTXPAtomNode createWithString:@"b" atLocation:82 type:KTXPTokenTypeAtom]
				]] Over:[KTXPSupSubNode createWithSup:[KTXPGroupNode createWithOpenLocation:85 closeLocation:110 elements:@[
						[KTXPAtomNode createWithString:@"\\ell " atLocation:86 type:KTXPTokenTypeAtom],
						[KTXPFunctionNode createWithString:@"\\text" atLocation:91 type:KTXPTokenTypeFunction arguments:@[]],
						[KTXPGroupNode createWithOpenLocation:96 closeLocation:98 elements:@[
							[KTXPAtomNode createWithString:@" " atLocation:97 type:KTXPTokenTypeAtom]
						]],
						[KTXPAtomNode createWithString:@" " atLocation:99 type:KTXPTokenTypeAtom],
						[KTXPAtomNode createWithString:@"b" atLocation:100 type:KTXPTokenTypeAtom],
						[KTXPFunctionNode createWithString:@"\\text" atLocation:101 type:KTXPTokenTypeFunction arguments:@[]],
						[KTXPGroupNode createWithOpenLocation:106 closeLocation:109 elements:@[
							[KTXPAtomNode createWithString:@"'" atLocation:107 type:KTXPTokenTypeAtom],
							[KTXPAtomNode createWithString:@"s" atLocation:108 type:KTXPTokenTypeAtom]
						]]
					]] Sub:nil]]
		]] Under:[KTXPSupSubNode createWithSup:nil Sub:[KTXPGroupNode createWithOpenLocation:113 closeLocation:137 elements:@[
				[KTXPAtomNode createWithString:@"k" atLocation:114 type:KTXPTokenTypeAtom],
				[KTXPAtomNode createWithString:@"+" atLocation:115 type:KTXPTokenTypeAtom],
				[KTXPAtomNode createWithString:@"\\ell " atLocation:116 type:KTXPTokenTypeAtom],
				[KTXPFunctionNode createWithString:@"\\text" atLocation:121 type:KTXPTokenTypeFunction arguments:@[]],
				[KTXPGroupNode createWithOpenLocation:126 closeLocation:136 elements:@[
					[KTXPAtomNode createWithString:@" " atLocation:127 type:KTXPTokenTypeAtom],
					[KTXPAtomNode createWithString:@"e" atLocation:128 type:KTXPTokenTypeAtom],
					[KTXPAtomNode createWithString:@"l" atLocation:129 type:KTXPTokenTypeAtom],
					[KTXPAtomNode createWithString:@"e" atLocation:130 type:KTXPTokenTypeAtom],
					[KTXPAtomNode createWithString:@"m" atLocation:131 type:KTXPTokenTypeAtom],
					[KTXPAtomNode createWithString:@"e" atLocation:132 type:KTXPTokenTypeAtom],
					[KTXPAtomNode createWithString:@"n" atLocation:133 type:KTXPTokenTypeAtom],
					[KTXPAtomNode createWithString:@"t" atLocation:134 type:KTXPTokenTypeAtom],
					[KTXPAtomNode createWithString:@"s" atLocation:135 type:KTXPTokenTypeAtom]
				]]
			]]]]
]];

	XCTAssert([c isEqual:r]);
}

- (void) testStress23
{
	NSString *l1 = @"\\begin{pmatrix}";
	NSString *l2 = @"\\begin{pmatrix} a & b \\\\ c & d \\end{pmatrix} & \\begin{pmatrix} e & f \\\\ g & h \\end{pmatrix} \\\\";
	NSString *l3 = @"0 & \\begin{pmatrix} i & j \\\\ k & l \\end{pmatrix}";
	NSString *l4 = @"\\end{pmatrix}";
	NSString *testStr = [NSString stringWithFormat:@"%@ %@ %@ %@", l1, l2, l3, l4];

	[self setParser: [KTXPParser createWithInput:testStr
										settings:[KTXPParser DEFAULT_SETTINGS]]];

	KTXPRootNode *r = [_parser parse:nil];
	KTXPRootNode *c = [KTXPRootNode createWithChildren:@[
	[KTXPEnvironmentNode createWithBegin:[KTXPEnvironmentOpen createWithBoundary:[KTXPToken createWithLexeme:@"\\begin" location:0 type:KTXPTokenTypeEnvironmentOpen] env:@"pmatrix"] children:@[
		[KTXPAtomNode createWithString:@" " atLocation:15 type:KTXPTokenTypeAtom],
		[KTXPEnvironmentNode createWithBegin:[KTXPEnvironmentOpen createWithBoundary:[KTXPToken createWithLexeme:@"\\begin" location:16 type:KTXPTokenTypeEnvironmentOpen] env:@"pmatrix"] children:@[
			[KTXPAtomNode createWithString:@" " atLocation:31 type:KTXPTokenTypeAtom],
			[KTXPAtomNode createWithString:@"a" atLocation:32 type:KTXPTokenTypeAtom],
			[KTXPAtomNode createWithString:@" " atLocation:33 type:KTXPTokenTypeAtom],
			[KTXPAtomNode createWithString:@"&" atLocation:34 type:KTXPTokenTypeAtom],
			[KTXPAtomNode createWithString:@" " atLocation:35 type:KTXPTokenTypeAtom],
			[KTXPAtomNode createWithString:@"b" atLocation:36 type:KTXPTokenTypeAtom],
			[KTXPAtomNode createWithString:@" " atLocation:37 type:KTXPTokenTypeAtom],
			[KTXPAtomNode createWithString:@"\\\\" atLocation:38 type:KTXPTokenTypeAtom],
			[KTXPAtomNode createWithString:@" " atLocation:40 type:KTXPTokenTypeAtom],
			[KTXPAtomNode createWithString:@"c" atLocation:41 type:KTXPTokenTypeAtom],
			[KTXPAtomNode createWithString:@" " atLocation:42 type:KTXPTokenTypeAtom],
			[KTXPAtomNode createWithString:@"&" atLocation:43 type:KTXPTokenTypeAtom],
			[KTXPAtomNode createWithString:@" " atLocation:44 type:KTXPTokenTypeAtom],
			[KTXPAtomNode createWithString:@"d" atLocation:45 type:KTXPTokenTypeAtom],
			[KTXPAtomNode createWithString:@" " atLocation:46 type:KTXPTokenTypeAtom]
		] end:[KTXPEnvironmentClose createWithBoundary:[KTXPToken createWithLexeme:@"\\end" location:47 type:KTXPTokenTypeEnvironmentClose] env:@"pmatrix"]],
		[KTXPAtomNode createWithString:@" " atLocation:60 type:KTXPTokenTypeAtom],
		[KTXPAtomNode createWithString:@"&" atLocation:61 type:KTXPTokenTypeAtom],
		[KTXPAtomNode createWithString:@" " atLocation:62 type:KTXPTokenTypeAtom],
		[KTXPEnvironmentNode createWithBegin:[KTXPEnvironmentOpen createWithBoundary:[KTXPToken createWithLexeme:@"\\begin" location:63 type:KTXPTokenTypeEnvironmentOpen] env:@"pmatrix"] children:@[
			[KTXPAtomNode createWithString:@" " atLocation:78 type:KTXPTokenTypeAtom],
			[KTXPAtomNode createWithString:@"e" atLocation:79 type:KTXPTokenTypeAtom],
			[KTXPAtomNode createWithString:@" " atLocation:80 type:KTXPTokenTypeAtom],
			[KTXPAtomNode createWithString:@"&" atLocation:81 type:KTXPTokenTypeAtom],
			[KTXPAtomNode createWithString:@" " atLocation:82 type:KTXPTokenTypeAtom],
			[KTXPAtomNode createWithString:@"f" atLocation:83 type:KTXPTokenTypeAtom],
			[KTXPAtomNode createWithString:@" " atLocation:84 type:KTXPTokenTypeAtom],
			[KTXPAtomNode createWithString:@"\\\\" atLocation:85 type:KTXPTokenTypeAtom],
			[KTXPAtomNode createWithString:@" " atLocation:87 type:KTXPTokenTypeAtom],
			[KTXPAtomNode createWithString:@"g" atLocation:88 type:KTXPTokenTypeAtom],
			[KTXPAtomNode createWithString:@" " atLocation:89 type:KTXPTokenTypeAtom],
			[KTXPAtomNode createWithString:@"&" atLocation:90 type:KTXPTokenTypeAtom],
			[KTXPAtomNode createWithString:@" " atLocation:91 type:KTXPTokenTypeAtom],
			[KTXPAtomNode createWithString:@"h" atLocation:92 type:KTXPTokenTypeAtom],
			[KTXPAtomNode createWithString:@" " atLocation:93 type:KTXPTokenTypeAtom]
		] end:[KTXPEnvironmentClose createWithBoundary:[KTXPToken createWithLexeme:@"\\end" location:94 type:KTXPTokenTypeEnvironmentClose] env:@"pmatrix"]],
		[KTXPAtomNode createWithString:@" " atLocation:107 type:KTXPTokenTypeAtom],
		[KTXPAtomNode createWithString:@"\\\\" atLocation:108 type:KTXPTokenTypeAtom],
		[KTXPAtomNode createWithString:@" " atLocation:110 type:KTXPTokenTypeAtom],
		[KTXPAtomNode createWithString:@"0" atLocation:111 type:KTXPTokenTypeAtom],
		[KTXPAtomNode createWithString:@" " atLocation:112 type:KTXPTokenTypeAtom],
		[KTXPAtomNode createWithString:@"&" atLocation:113 type:KTXPTokenTypeAtom],
		[KTXPAtomNode createWithString:@" " atLocation:114 type:KTXPTokenTypeAtom],
		[KTXPEnvironmentNode createWithBegin:[KTXPEnvironmentOpen createWithBoundary:[KTXPToken createWithLexeme:@"\\begin" location:115 type:KTXPTokenTypeEnvironmentOpen] env:@"pmatrix"] children:@[
			[KTXPAtomNode createWithString:@" " atLocation:130 type:KTXPTokenTypeAtom],
			[KTXPAtomNode createWithString:@"i" atLocation:131 type:KTXPTokenTypeAtom],
			[KTXPAtomNode createWithString:@" " atLocation:132 type:KTXPTokenTypeAtom],
			[KTXPAtomNode createWithString:@"&" atLocation:133 type:KTXPTokenTypeAtom],
			[KTXPAtomNode createWithString:@" " atLocation:134 type:KTXPTokenTypeAtom],
			[KTXPAtomNode createWithString:@"j" atLocation:135 type:KTXPTokenTypeAtom],
			[KTXPAtomNode createWithString:@" " atLocation:136 type:KTXPTokenTypeAtom],
			[KTXPAtomNode createWithString:@"\\\\" atLocation:137 type:KTXPTokenTypeAtom],
			[KTXPAtomNode createWithString:@" " atLocation:139 type:KTXPTokenTypeAtom],
			[KTXPAtomNode createWithString:@"k" atLocation:140 type:KTXPTokenTypeAtom],
			[KTXPAtomNode createWithString:@" " atLocation:141 type:KTXPTokenTypeAtom],
			[KTXPAtomNode createWithString:@"&" atLocation:142 type:KTXPTokenTypeAtom],
			[KTXPAtomNode createWithString:@" " atLocation:143 type:KTXPTokenTypeAtom],
			[KTXPAtomNode createWithString:@"l" atLocation:144 type:KTXPTokenTypeAtom],
			[KTXPAtomNode createWithString:@" " atLocation:145 type:KTXPTokenTypeAtom]
		] end:[KTXPEnvironmentClose createWithBoundary:[KTXPToken createWithLexeme:@"\\end" location:146 type:KTXPTokenTypeEnvironmentClose] env:@"pmatrix"]],
		[KTXPAtomNode createWithString:@" " atLocation:159 type:KTXPTokenTypeAtom]
	] end:[KTXPEnvironmentClose createWithBoundary:[KTXPToken createWithLexeme:@"\\end" location:160 type:KTXPTokenTypeEnvironmentClose] env:@"pmatrix"]]
]];

	XCTAssert([c isEqual:r]);
}

- (void) testStress24
{
	NSString *l1 = @"\\det \\begin{vmatrix}";
	NSString *l2 = @"c_0 & c_1 & c_2 & \\dots & c_n \\\\";
	NSString *l3 = @"c_1 & c_2 & c_3 & \\dots & c_{n+1} \\\\";
	NSString *l4 = @"c_2 & c_3 & c_4 & \\dots & c_{n+2} \\\\";
	NSString *l5 = @"\\vdots & \\vdots & \\vdots & \\ddots & \\vdots \\\\";
	NSString *l6 = @"c_n & c_{n+1} & c_{n+2} & \\dots & c_{2n}";
	NSString *l7 = @"\\end{vmatrix} > 0";
	NSString *testStr = [NSString stringWithFormat:@"%@ %@ %@ %@ %@ %@ %@", l1, l2, l3, l4, l5, l6, l7];

	[self setParser: [KTXPParser createWithInput:testStr
										settings:[KTXPParser DEFAULT_SETTINGS]]];

	KTXPRootNode *r = [_parser parse:nil];
	KTXPRootNode *c = [KTXPRootNode createWithChildren:@[
	[KTXPAtomNode createWithString:@"\\det " atLocation:0 type:KTXPTokenTypeAtom],
	[KTXPEnvironmentNode createWithBegin:[KTXPEnvironmentOpen createWithBoundary:[KTXPToken createWithLexeme:@"\\begin" location:5 type:KTXPTokenTypeEnvironmentOpen] env:@"vmatrix"] children:@[
		[KTXPAtomNode createWithString:@" " atLocation:20 type:KTXPTokenTypeAtom],
		[KTXPAtomNode createWithString:@"c" atLocation:21 type:KTXPTokenTypeAtom],
		[KTXPSupSubNode createWithSup:nil Sub:[KTXPGroupNode createWithOpenLocation:NSNotFound closeLocation:NSNotFound elements:@[
				[KTXPAtomNode createWithString:@"0" atLocation:23 type:KTXPTokenTypeAtom]
			]]],
		[KTXPAtomNode createWithString:@" " atLocation:24 type:KTXPTokenTypeAtom],
		[KTXPAtomNode createWithString:@"&" atLocation:25 type:KTXPTokenTypeAtom],
		[KTXPAtomNode createWithString:@" " atLocation:26 type:KTXPTokenTypeAtom],
		[KTXPAtomNode createWithString:@"c" atLocation:27 type:KTXPTokenTypeAtom],
		[KTXPSupSubNode createWithSup:nil Sub:[KTXPGroupNode createWithOpenLocation:NSNotFound closeLocation:NSNotFound elements:@[
				[KTXPAtomNode createWithString:@"1" atLocation:29 type:KTXPTokenTypeAtom]
			]]],
		[KTXPAtomNode createWithString:@" " atLocation:30 type:KTXPTokenTypeAtom],
		[KTXPAtomNode createWithString:@"&" atLocation:31 type:KTXPTokenTypeAtom],
		[KTXPAtomNode createWithString:@" " atLocation:32 type:KTXPTokenTypeAtom],
		[KTXPAtomNode createWithString:@"c" atLocation:33 type:KTXPTokenTypeAtom],
		[KTXPSupSubNode createWithSup:nil Sub:[KTXPGroupNode createWithOpenLocation:NSNotFound closeLocation:NSNotFound elements:@[
				[KTXPAtomNode createWithString:@"2" atLocation:35 type:KTXPTokenTypeAtom]
			]]],
		[KTXPAtomNode createWithString:@" " atLocation:36 type:KTXPTokenTypeAtom],
		[KTXPAtomNode createWithString:@"&" atLocation:37 type:KTXPTokenTypeAtom],
		[KTXPAtomNode createWithString:@" " atLocation:38 type:KTXPTokenTypeAtom],
		[KTXPAtomNode createWithString:@"\\dots " atLocation:39 type:KTXPTokenTypeAtom],
		[KTXPAtomNode createWithString:@"&" atLocation:45 type:KTXPTokenTypeAtom],
		[KTXPAtomNode createWithString:@" " atLocation:46 type:KTXPTokenTypeAtom],
		[KTXPAtomNode createWithString:@"c" atLocation:47 type:KTXPTokenTypeAtom],
		[KTXPSupSubNode createWithSup:nil Sub:[KTXPGroupNode createWithOpenLocation:NSNotFound closeLocation:NSNotFound elements:@[
				[KTXPAtomNode createWithString:@"n" atLocation:49 type:KTXPTokenTypeAtom]
			]]],
		[KTXPAtomNode createWithString:@" " atLocation:50 type:KTXPTokenTypeAtom],
		[KTXPAtomNode createWithString:@"\\\\" atLocation:51 type:KTXPTokenTypeAtom],
		[KTXPAtomNode createWithString:@" " atLocation:53 type:KTXPTokenTypeAtom],
		[KTXPAtomNode createWithString:@"c" atLocation:54 type:KTXPTokenTypeAtom],
		[KTXPSupSubNode createWithSup:nil Sub:[KTXPGroupNode createWithOpenLocation:NSNotFound closeLocation:NSNotFound elements:@[
				[KTXPAtomNode createWithString:@"1" atLocation:56 type:KTXPTokenTypeAtom]
			]]],
		[KTXPAtomNode createWithString:@" " atLocation:57 type:KTXPTokenTypeAtom],
		[KTXPAtomNode createWithString:@"&" atLocation:58 type:KTXPTokenTypeAtom],
		[KTXPAtomNode createWithString:@" " atLocation:59 type:KTXPTokenTypeAtom],
		[KTXPAtomNode createWithString:@"c" atLocation:60 type:KTXPTokenTypeAtom],
		[KTXPSupSubNode createWithSup:nil Sub:[KTXPGroupNode createWithOpenLocation:NSNotFound closeLocation:NSNotFound elements:@[
				[KTXPAtomNode createWithString:@"2" atLocation:62 type:KTXPTokenTypeAtom]
			]]],
		[KTXPAtomNode createWithString:@" " atLocation:63 type:KTXPTokenTypeAtom],
		[KTXPAtomNode createWithString:@"&" atLocation:64 type:KTXPTokenTypeAtom],
		[KTXPAtomNode createWithString:@" " atLocation:65 type:KTXPTokenTypeAtom],
		[KTXPAtomNode createWithString:@"c" atLocation:66 type:KTXPTokenTypeAtom],
		[KTXPSupSubNode createWithSup:nil Sub:[KTXPGroupNode createWithOpenLocation:NSNotFound closeLocation:NSNotFound elements:@[
				[KTXPAtomNode createWithString:@"3" atLocation:68 type:KTXPTokenTypeAtom]
			]]],
		[KTXPAtomNode createWithString:@" " atLocation:69 type:KTXPTokenTypeAtom],
		[KTXPAtomNode createWithString:@"&" atLocation:70 type:KTXPTokenTypeAtom],
		[KTXPAtomNode createWithString:@" " atLocation:71 type:KTXPTokenTypeAtom],
		[KTXPAtomNode createWithString:@"\\dots " atLocation:72 type:KTXPTokenTypeAtom],
		[KTXPAtomNode createWithString:@"&" atLocation:78 type:KTXPTokenTypeAtom],
		[KTXPAtomNode createWithString:@" " atLocation:79 type:KTXPTokenTypeAtom],
		[KTXPAtomNode createWithString:@"c" atLocation:80 type:KTXPTokenTypeAtom],
		[KTXPSupSubNode createWithSup:nil Sub:[KTXPGroupNode createWithOpenLocation:82 closeLocation:86 elements:@[
				[KTXPAtomNode createWithString:@"n" atLocation:83 type:KTXPTokenTypeAtom],
				[KTXPAtomNode createWithString:@"+" atLocation:84 type:KTXPTokenTypeAtom],
				[KTXPAtomNode createWithString:@"1" atLocation:85 type:KTXPTokenTypeAtom]
			]]],
		[KTXPAtomNode createWithString:@" " atLocation:87 type:KTXPTokenTypeAtom],
		[KTXPAtomNode createWithString:@"\\\\" atLocation:88 type:KTXPTokenTypeAtom],
		[KTXPAtomNode createWithString:@" " atLocation:90 type:KTXPTokenTypeAtom],
		[KTXPAtomNode createWithString:@"c" atLocation:91 type:KTXPTokenTypeAtom],
		[KTXPSupSubNode createWithSup:nil Sub:[KTXPGroupNode createWithOpenLocation:NSNotFound closeLocation:NSNotFound elements:@[
				[KTXPAtomNode createWithString:@"2" atLocation:93 type:KTXPTokenTypeAtom]
			]]],
		[KTXPAtomNode createWithString:@" " atLocation:94 type:KTXPTokenTypeAtom],
		[KTXPAtomNode createWithString:@"&" atLocation:95 type:KTXPTokenTypeAtom],
		[KTXPAtomNode createWithString:@" " atLocation:96 type:KTXPTokenTypeAtom],
		[KTXPAtomNode createWithString:@"c" atLocation:97 type:KTXPTokenTypeAtom],
		[KTXPSupSubNode createWithSup:nil Sub:[KTXPGroupNode createWithOpenLocation:NSNotFound closeLocation:NSNotFound elements:@[
				[KTXPAtomNode createWithString:@"3" atLocation:99 type:KTXPTokenTypeAtom]
			]]],
		[KTXPAtomNode createWithString:@" " atLocation:100 type:KTXPTokenTypeAtom],
		[KTXPAtomNode createWithString:@"&" atLocation:101 type:KTXPTokenTypeAtom],
		[KTXPAtomNode createWithString:@" " atLocation:102 type:KTXPTokenTypeAtom],
		[KTXPAtomNode createWithString:@"c" atLocation:103 type:KTXPTokenTypeAtom],
		[KTXPSupSubNode createWithSup:nil Sub:[KTXPGroupNode createWithOpenLocation:NSNotFound closeLocation:NSNotFound elements:@[
				[KTXPAtomNode createWithString:@"4" atLocation:105 type:KTXPTokenTypeAtom]
			]]],
		[KTXPAtomNode createWithString:@" " atLocation:106 type:KTXPTokenTypeAtom],
		[KTXPAtomNode createWithString:@"&" atLocation:107 type:KTXPTokenTypeAtom],
		[KTXPAtomNode createWithString:@" " atLocation:108 type:KTXPTokenTypeAtom],
		[KTXPAtomNode createWithString:@"\\dots " atLocation:109 type:KTXPTokenTypeAtom],
		[KTXPAtomNode createWithString:@"&" atLocation:115 type:KTXPTokenTypeAtom],
		[KTXPAtomNode createWithString:@" " atLocation:116 type:KTXPTokenTypeAtom],
		[KTXPAtomNode createWithString:@"c" atLocation:117 type:KTXPTokenTypeAtom],
		[KTXPSupSubNode createWithSup:nil Sub:[KTXPGroupNode createWithOpenLocation:119 closeLocation:123 elements:@[
				[KTXPAtomNode createWithString:@"n" atLocation:120 type:KTXPTokenTypeAtom],
				[KTXPAtomNode createWithString:@"+" atLocation:121 type:KTXPTokenTypeAtom],
				[KTXPAtomNode createWithString:@"2" atLocation:122 type:KTXPTokenTypeAtom]
			]]],
		[KTXPAtomNode createWithString:@" " atLocation:124 type:KTXPTokenTypeAtom],
		[KTXPAtomNode createWithString:@"\\\\" atLocation:125 type:KTXPTokenTypeAtom],
		[KTXPAtomNode createWithString:@" " atLocation:127 type:KTXPTokenTypeAtom],
		[KTXPAtomNode createWithString:@"\\vdots " atLocation:128 type:KTXPTokenTypeAtom],
		[KTXPAtomNode createWithString:@"&" atLocation:135 type:KTXPTokenTypeAtom],
		[KTXPAtomNode createWithString:@" " atLocation:136 type:KTXPTokenTypeAtom],
		[KTXPAtomNode createWithString:@"\\vdots " atLocation:137 type:KTXPTokenTypeAtom],
		[KTXPAtomNode createWithString:@"&" atLocation:144 type:KTXPTokenTypeAtom],
		[KTXPAtomNode createWithString:@" " atLocation:145 type:KTXPTokenTypeAtom],
		[KTXPAtomNode createWithString:@"\\vdots " atLocation:146 type:KTXPTokenTypeAtom],
		[KTXPAtomNode createWithString:@"&" atLocation:153 type:KTXPTokenTypeAtom],
		[KTXPAtomNode createWithString:@" " atLocation:154 type:KTXPTokenTypeAtom],
		[KTXPAtomNode createWithString:@"\\ddots " atLocation:155 type:KTXPTokenTypeAtom],
		[KTXPAtomNode createWithString:@"&" atLocation:162 type:KTXPTokenTypeAtom],
		[KTXPAtomNode createWithString:@" " atLocation:163 type:KTXPTokenTypeAtom],
		[KTXPAtomNode createWithString:@"\\vdots " atLocation:164 type:KTXPTokenTypeAtom],
		[KTXPAtomNode createWithString:@"\\\\" atLocation:171 type:KTXPTokenTypeAtom],
		[KTXPAtomNode createWithString:@" " atLocation:173 type:KTXPTokenTypeAtom],
		[KTXPAtomNode createWithString:@"c" atLocation:174 type:KTXPTokenTypeAtom],
		[KTXPSupSubNode createWithSup:nil Sub:[KTXPGroupNode createWithOpenLocation:NSNotFound closeLocation:NSNotFound elements:@[
				[KTXPAtomNode createWithString:@"n" atLocation:176 type:KTXPTokenTypeAtom]
			]]],
		[KTXPAtomNode createWithString:@" " atLocation:177 type:KTXPTokenTypeAtom],
		[KTXPAtomNode createWithString:@"&" atLocation:178 type:KTXPTokenTypeAtom],
		[KTXPAtomNode createWithString:@" " atLocation:179 type:KTXPTokenTypeAtom],
		[KTXPAtomNode createWithString:@"c" atLocation:180 type:KTXPTokenTypeAtom],
		[KTXPSupSubNode createWithSup:nil Sub:[KTXPGroupNode createWithOpenLocation:182 closeLocation:186 elements:@[
				[KTXPAtomNode createWithString:@"n" atLocation:183 type:KTXPTokenTypeAtom],
				[KTXPAtomNode createWithString:@"+" atLocation:184 type:KTXPTokenTypeAtom],
				[KTXPAtomNode createWithString:@"1" atLocation:185 type:KTXPTokenTypeAtom]
			]]],
		[KTXPAtomNode createWithString:@" " atLocation:187 type:KTXPTokenTypeAtom],
		[KTXPAtomNode createWithString:@"&" atLocation:188 type:KTXPTokenTypeAtom],
		[KTXPAtomNode createWithString:@" " atLocation:189 type:KTXPTokenTypeAtom],
		[KTXPAtomNode createWithString:@"c" atLocation:190 type:KTXPTokenTypeAtom],
		[KTXPSupSubNode createWithSup:nil Sub:[KTXPGroupNode createWithOpenLocation:192 closeLocation:196 elements:@[
				[KTXPAtomNode createWithString:@"n" atLocation:193 type:KTXPTokenTypeAtom],
				[KTXPAtomNode createWithString:@"+" atLocation:194 type:KTXPTokenTypeAtom],
				[KTXPAtomNode createWithString:@"2" atLocation:195 type:KTXPTokenTypeAtom]
			]]],
		[KTXPAtomNode createWithString:@" " atLocation:197 type:KTXPTokenTypeAtom],
		[KTXPAtomNode createWithString:@"&" atLocation:198 type:KTXPTokenTypeAtom],
		[KTXPAtomNode createWithString:@" " atLocation:199 type:KTXPTokenTypeAtom],
		[KTXPAtomNode createWithString:@"\\dots " atLocation:200 type:KTXPTokenTypeAtom],
		[KTXPAtomNode createWithString:@"&" atLocation:206 type:KTXPTokenTypeAtom],
		[KTXPAtomNode createWithString:@" " atLocation:207 type:KTXPTokenTypeAtom],
		[KTXPAtomNode createWithString:@"c" atLocation:208 type:KTXPTokenTypeAtom],
		[KTXPSupSubNode createWithSup:nil Sub:[KTXPGroupNode createWithOpenLocation:210 closeLocation:213 elements:@[
				[KTXPAtomNode createWithString:@"2" atLocation:211 type:KTXPTokenTypeAtom],
				[KTXPAtomNode createWithString:@"n" atLocation:212 type:KTXPTokenTypeAtom]
			]]],
		[KTXPAtomNode createWithString:@" " atLocation:214 type:KTXPTokenTypeAtom]
	] end:[KTXPEnvironmentClose createWithBoundary:[KTXPToken createWithLexeme:@"\\end" location:215 type:KTXPTokenTypeEnvironmentClose] env:@"vmatrix"]],
	[KTXPAtomNode createWithString:@" " atLocation:228 type:KTXPTokenTypeAtom],
	[KTXPAtomNode createWithString:@">" atLocation:229 type:KTXPTokenTypeAtom],
	[KTXPAtomNode createWithString:@" " atLocation:230 type:KTXPTokenTypeAtom],
	[KTXPAtomNode createWithString:@"0" atLocation:231 type:KTXPTokenTypeAtom]
]];

	XCTAssert([c isEqual:r]);
}

- (void) testStress25
{
	[self setParser: [KTXPParser createWithInput:@"y_{x_2}"
										settings:[KTXPParser DEFAULT_SETTINGS]]];

	KTXPRootNode *r = [_parser parse:nil];
	KTXPRootNode *c = [KTXPRootNode createWithChildren:@[
	[KTXPAtomNode createWithString:@"y" atLocation:0 type:KTXPTokenTypeAtom],
	[KTXPSupSubNode createWithSup:nil Sub:[KTXPGroupNode createWithOpenLocation:2 closeLocation:6 elements:@[
			[KTXPAtomNode createWithString:@"x" atLocation:3 type:KTXPTokenTypeAtom],
			[KTXPSupSubNode createWithSup:nil Sub:[KTXPGroupNode createWithOpenLocation:NSNotFound closeLocation:NSNotFound elements:@[
					[KTXPAtomNode createWithString:@"2" atLocation:5 type:KTXPTokenTypeAtom]
				]]]
		]]]
]];

	XCTAssert([c isEqual:r]);
}

- (void) testStress26
{
	[self setParser: [KTXPParser createWithInput:@"x_{92}^{31415} + \\pi"
										settings:[KTXPParser DEFAULT_SETTINGS]]];

	KTXPRootNode *r = [_parser parse:nil];
	KTXPRootNode *c = [KTXPRootNode createWithChildren:@[
	[KTXPAtomNode createWithString:@"x" atLocation:0 type:KTXPTokenTypeAtom],
	[KTXPSupSubNode createWithSup:[KTXPGroupNode createWithOpenLocation:7 closeLocation:13 elements:@[
			[KTXPAtomNode createWithString:@"3" atLocation:8 type:KTXPTokenTypeAtom],
			[KTXPAtomNode createWithString:@"1" atLocation:9 type:KTXPTokenTypeAtom],
			[KTXPAtomNode createWithString:@"4" atLocation:10 type:KTXPTokenTypeAtom],
			[KTXPAtomNode createWithString:@"1" atLocation:11 type:KTXPTokenTypeAtom],
			[KTXPAtomNode createWithString:@"5" atLocation:12 type:KTXPTokenTypeAtom]
		]] Sub:[KTXPGroupNode createWithOpenLocation:2 closeLocation:5 elements:@[
			[KTXPAtomNode createWithString:@"9" atLocation:3 type:KTXPTokenTypeAtom],
			[KTXPAtomNode createWithString:@"2" atLocation:4 type:KTXPTokenTypeAtom]
		]]],
	[KTXPAtomNode createWithString:@" " atLocation:14 type:KTXPTokenTypeAtom],
	[KTXPAtomNode createWithString:@"+" atLocation:15 type:KTXPTokenTypeAtom],
	[KTXPAtomNode createWithString:@" " atLocation:16 type:KTXPTokenTypeAtom],
	[KTXPAtomNode createWithString:@"\\pi" atLocation:17 type:KTXPTokenTypeAtom]
]];

	XCTAssert([c isEqual:r]);
}

- (void) testStress27
{
	[self setParser: [KTXPParser createWithInput:@"x_{y}^{b} a_{z}^{c} d"
										settings:[KTXPParser DEFAULT_SETTINGS]]];

	KTXPRootNode *r = [_parser parse:nil];
	KTXPRootNode *c = [KTXPRootNode createWithChildren:@[
	[KTXPAtomNode createWithString:@"x" atLocation:0 type:KTXPTokenTypeAtom],
	[KTXPSupSubNode createWithSup:[KTXPGroupNode createWithOpenLocation:6 closeLocation:8 elements:@[
			[KTXPAtomNode createWithString:@"b" atLocation:7 type:KTXPTokenTypeAtom]
		]] Sub:[KTXPGroupNode createWithOpenLocation:2 closeLocation:4 elements:@[
			[KTXPAtomNode createWithString:@"y" atLocation:3 type:KTXPTokenTypeAtom]
		]]],
	[KTXPAtomNode createWithString:@" " atLocation:9 type:KTXPTokenTypeAtom],
	[KTXPAtomNode createWithString:@"a" atLocation:10 type:KTXPTokenTypeAtom],
	[KTXPSupSubNode createWithSup:[KTXPGroupNode createWithOpenLocation:16 closeLocation:18 elements:@[
			[KTXPAtomNode createWithString:@"c" atLocation:17 type:KTXPTokenTypeAtom]
		]] Sub:[KTXPGroupNode createWithOpenLocation:12 closeLocation:14 elements:@[
			[KTXPAtomNode createWithString:@"z" atLocation:13 type:KTXPTokenTypeAtom]
		]]],
	[KTXPAtomNode createWithString:@" " atLocation:19 type:KTXPTokenTypeAtom],
	[KTXPAtomNode createWithString:@"d" atLocation:20 type:KTXPTokenTypeAtom]
]];

	XCTAssert([c isEqual:r]);
}

- (void) testStress28
{
	[self setParser: [KTXPParser createWithInput:@"y_{3}'''"
										settings:[KTXPParser DEFAULT_SETTINGS]]];

	KTXPRootNode *r = [_parser parse:nil];
	KTXPGroupNode *group = [KTXPGroupNode createWithOpenLocation:2 closeLocation:4 elements:@[
		[KTXPAtomNode createWithString:@"3" atLocation:3 type:KTXPTokenTypeAtom]
	]];
	KTXPRootNode *c = [KTXPRootNode createWithChildren:@[
		[KTXPAtomNode createWithString:@"y" atLocation:0 type:KTXPTokenTypeAtom],
		[KTXPSupSubNode createWithSup:nil Sub:group],
		[KTXPAtomNode createWithString:@"'" atLocation:5 type:KTXPTokenTypeAtom],
		[KTXPAtomNode createWithString:@"'" atLocation:6 type:KTXPTokenTypeAtom],
		[KTXPAtomNode createWithString:@"'" atLocation:7 type:KTXPTokenTypeAtom]
	]];

	XCTAssert([c isEqual:r]);
}

@end
