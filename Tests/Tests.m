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
	
	KTXPToken *xTok = [KTXPToken createWithLexeme:@"x" location:0 type:KTXPTokenTypeAtom];
	KTXPAtomNode *x = [KTXPAtomNode createWithToken:xTok];
	KTXPToken *twoTok1 = [KTXPToken createWithLexeme:@"2" location:2 type:KTXPTokenTypeAtom];
	KTXPAtomNode *two1 = [KTXPAtomNode createWithToken:twoTok1];
	KTXPGroupNode *g1 = [KTXPGroupNode createWithOpen:nil elements:@[two1] close:nil];
	
	KTXPToken *yTok = [KTXPToken createWithLexeme:@"y" location:3 type:KTXPTokenTypeAtom];
	KTXPAtomNode *y = [KTXPAtomNode createWithToken:yTok];
	KTXPToken *twoTok2 = [KTXPToken createWithLexeme:@"2" location:5 type:KTXPTokenTypeAtom];
	KTXPAtomNode *two2 = [KTXPAtomNode createWithToken:twoTok2];
	KTXPGroupNode *g2 = [KTXPGroupNode createWithOpen:nil elements:@[two2] close:nil];
	
	KTXPSupSubNode *s1 = [KTXPSupSubNode createWithSup:g1 Sub:nil];
	KTXPSupSubNode *s2 = [KTXPSupSubNode createWithSup:g2 Sub:nil];
	
	KTXPRootNode *c = [KTXPRootNode createWithChildren:@[x, s1, y, s2]];
	
	XCTAssert(([r isEqual:c]));
}

- (void) testStress2
{
	[self setParser:[KTXPParser createWithInput:@"_2F_3"
									   settings:[KTXPParser DEFAULT_SETTINGS]]];
	
	KTXPRootNode *r = [_parser parse:nil];
	KTXPRootNode *c;
	
	XCTAssert(([r isEqual:c]));
}

- (void) testStress3
{
	[self setParser: [KTXPParser createWithInput:@"\\frac{x+y^2}{k+1}"
										settings:[KTXPParser DEFAULT_SETTINGS]]];
	
	KTXPRootNode *r = [_parser parse:nil];
	KTXPRootNode *c;
	
	XCTAssert(([r isEqual:c]));
}

- (void) testStress4
{
	[self setParser: [KTXPParser createWithInput:@"x+y^{\\frac{2}{k+1}}"
										settings:[KTXPParser DEFAULT_SETTINGS]]];
	
	KTXPRootNode *r = [_parser parse:nil];
	KTXPRootNode *c;
	
	XCTAssert(([r isEqual:c]));
}

- (void) testStress5
{
	[self setParser: [KTXPParser createWithInput:@"\\frac{a}{b/2}"
										settings:[KTXPParser DEFAULT_SETTINGS]]];
	
	KTXPRootNode *r = [_parser parse:nil];
	KTXPRootNode *c;
	
	XCTAssert(([r isEqual:c]));
}

- (void) testStress6
{
	[self setParser: [KTXPParser createWithInput:@"a_0+\\frac{1}{ a_1+\\frac{1}{a_2+{1}{\\frac{1}{a_3+\\frac{1}{a_4}}}}}"
										settings:[KTXPParser DEFAULT_SETTINGS]]];
	
	KTXPRootNode *r = [_parser parse:nil];
	KTXPRootNode *c;
	
	XCTAssert(([r isEqual:c]));
}

- (void) testStress7
{
	[self setParser: [KTXPParser createWithInput:@"a_{0}+\\cfrac{1}{a_{1}+\\cfrac{1}{a_{2}+\\cfrac{1}{a_{3}+\\cfrac{1}{a_{4}}}}}"
										settings:[KTXPParser DEFAULT_SETTINGS]]];
	
	KTXPRootNode *r = [_parser parse:nil];
	KTXPRootNode *c;
	
	XCTAssert(([r isEqual:c]));
}

- (void) testStress8
{
	[self setParser: [KTXPParser createWithInput:@"\\binom{n}{k/2}"
										settings:[KTXPParser DEFAULT_SETTINGS]]];
	
	KTXPRootNode *r = [_parser parse:nil];
	KTXPRootNode *c;
	
	XCTAssert(([r isEqual:c]));
}

- (void) testStress9
{
	[self setParser: [KTXPParser createWithInput:@"\\binom{p}{2} x^{2}y^{p-2}-\\frac{1}{1-x}\\frac{1}{1-x^{2}}"
										settings:[KTXPParser DEFAULT_SETTINGS]]];
	
	KTXPRootNode *r = [_parser parse:nil];
	KTXPRootNode *c;
	
	XCTAssert(([r isEqual:c]));
}

- (void) testStress10
{
	[self setParser: [KTXPParser createWithInput:@"\\sum_{\\substack{0 \\le i \\le m \\\\ 0 < j < n}} P(i,j)"
										settings:[KTXPParser DEFAULT_SETTINGS]]];
	
	KTXPRootNode *r = [_parser parse:nil];
	KTXPRootNode *c;
	
	XCTAssert(([r isEqual:c]));
}

- (void) testStress11
{
	[self setParser: [KTXPParser createWithInput:@"x^{2y}"
										settings:[KTXPParser DEFAULT_SETTINGS]]];
	
	KTXPRootNode *r = [_parser parse:nil];
	KTXPRootNode *c;
	
	XCTAssert(([r isEqual:c]));
}

- (void) testStress12
{
	[self setParser: [KTXPParser createWithInput:@"\\sum_{i=1}^{p} \\sum_{j=1}^{q} \\sum_{k=1}^{r} a_{ij} b_{jk} c_{ki}"
										settings:[KTXPParser DEFAULT_SETTINGS]]];
	
	KTXPRootNode *r = [_parser parse:nil];
	KTXPRootNode *c;
	
	XCTAssert(([r isEqual:c]));
}

- (void) testStress13
{
	[self setParser: [KTXPParser createWithInput:@"\\sqrt{1+\\sqrt{1+\\sqrt{1+\\sqrt{1+\\sqrt{1+\\sqrt{1+\\sqrt{1+x}}}}}}}"
										settings:[KTXPParser DEFAULT_SETTINGS]]];
	
	KTXPRootNode *r = [_parser parse:nil];
	KTXPRootNode *c;
	
	XCTAssert(([r isEqual:c]));
}

- (void) testStress14
{
	[self setParser: [KTXPParser createWithInput:@"\\left( \\frac{\\partial^2}{\\partial x^2} + \\frac{\\partial^2}{\\partial y^2} \\right) |\\varphi(x+iy)|^2 = 0"
										settings:[KTXPParser DEFAULT_SETTINGS]]];
	
	KTXPRootNode *r = [_parser parse:nil];
	KTXPRootNode *c;
	
	XCTAssert(([r isEqual:c]));
}

- (void) testStress15
{
	[self setParser: [KTXPParser createWithInput:@"2^{2^{2^x}}"
										settings:[KTXPParser DEFAULT_SETTINGS]]];

	KTXPRootNode *r = [_parser parse:nil];
	KTXPRootNode *c;
	
	XCTAssert(([r isEqual:c]));
}

- (void) testStress16
{
	[self setParser: [KTXPParser createWithInput:@"\\int_1^x \\frac{dt}{t}"
										settings:[KTXPParser DEFAULT_SETTINGS]]];
	
	KTXPRootNode *r = [_parser parse:nil];
	KTXPRootNode *c;
	
	XCTAssert(([r isEqual:c]));
}

- (void) testStress17
{
	[self setParser: [KTXPParser createWithInput:@"\\iint_D dx \\, dy"
										settings:[KTXPParser DEFAULT_SETTINGS]]];
	
	KTXPRootNode *r = [_parser parse:nil];
	KTXPRootNode *c;
	
	XCTAssert(([r isEqual:c]));
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
	KTXPRootNode *c;
	
	XCTAssert(([r isEqual:c]));
}

- (void) testStress19
{
	[self setParser: [KTXPParser createWithInput:@"\\overbrace{x + \\dots + x}^{k \\text{ times}}"
										settings:[KTXPParser DEFAULT_SETTINGS]]];
	
	KTXPRootNode *r = [_parser parse:nil];
	KTXPRootNode *c;
	
	XCTAssert(([r isEqual:c]));
}

- (void) testStress20
{
	[self setParser: [KTXPParser createWithInput:@"y_{x^2}"
										settings:[KTXPParser DEFAULT_SETTINGS]]];
	
	KTXPRootNode *r = [_parser parse:nil];
	KTXPRootNode *c;
	
	XCTAssert(([r isEqual:c]));
}

- (void) testStress21
{
	[self setParser: [KTXPParser createWithInput:@"\\sum_{p \\text{ prime}} f(p) = \\int_{t>1} f(t) d\\pi(t)"
										settings:[KTXPParser DEFAULT_SETTINGS]]];
	
	KTXPRootNode *r = [_parser parse:nil];
	KTXPRootNode *c;
	
	XCTAssert(([r isEqual:c]));
}

- (void) testStress22
{
	[self setParser: [KTXPParser createWithInput:@"\\underbrace{\\overbrace{a, \\dots, a}^{k \\text{ } a\\text{'s}}, \\overbrace{b, \\dots, b}^{\\ell \\text{ } b\\text{'s}}}_{k+\\ell \\text{ elements}}"
										settings:[KTXPParser DEFAULT_SETTINGS]]];
	
	KTXPRootNode *r = [_parser parse:nil];
	KTXPRootNode *c;
	
	XCTAssert(([r isEqual:c]));
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
	KTXPRootNode *c;
	
	XCTAssert(([r isEqual:c]));
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
	KTXPRootNode *c;
	
	XCTAssert(([r isEqual:c]));
}

- (void) testStress25
{
	[self setParser: [KTXPParser createWithInput:@"y_{x_2}"
										settings:[KTXPParser DEFAULT_SETTINGS]]];
	
	KTXPRootNode *r = [_parser parse:nil];
	KTXPRootNode *c;
	
	XCTAssert(([r isEqual:c]));
}

- (void) testStress26
{
	[self setParser: [KTXPParser createWithInput:@"x_{92}^{31415} + \\pi"
										settings:[KTXPParser DEFAULT_SETTINGS]]];
	
	KTXPRootNode *r = [_parser parse:nil];
	KTXPRootNode *c;
	
	XCTAssert(([r isEqual:c]));
}

- (void) testStress27
{
	[self setParser: [KTXPParser createWithInput:@"x_{y}^{b} a_{z}^{c} d"
										settings:[KTXPParser DEFAULT_SETTINGS]]];
	
	KTXPRootNode *r = [_parser parse:nil];
	KTXPRootNode *c;
	
	XCTAssert(([r isEqual:c]));
}

- (void) testStress28
{
	[self setParser: [KTXPParser createWithInput:@"y_{3}'''"
										settings:[KTXPParser DEFAULT_SETTINGS]]];
	
	KTXPRootNode *r = [_parser parse:nil];
	KTXPAtomNode *y = [KTXPAtomNode createWithToken:[KTXPToken createWithLexeme:@"y"
																	   location:0
																		   type:KTXPTokenTypeAtom]];
	
	KTXPToken *und = [KTXPToken createWithLexeme:@"_" location:1 type:KTXPTokenTypeFunction];
	
	KTXPAtomNode *p1 = [KTXPAtomNode createWithToken:[KTXPToken createWithLexeme:@"'"
																		location:5
																			type:KTXPTokenTypeAtom]];
	KTXPAtomNode *p2 = [KTXPAtomNode createWithToken:[KTXPToken createWithLexeme:@"'"
																		location:6
																			type:KTXPTokenTypeAtom]];
	KTXPAtomNode *p3 = [KTXPAtomNode createWithToken:[KTXPToken createWithLexeme:@"'"
																		location:7
																			type:KTXPTokenTypeAtom]];
	
	KTXPToken *op = [KTXPToken createWithLexeme:@"{" location:2 type:KTXPTokenTypeGroupOpen];
	KTXPToken *tre = [KTXPToken createWithLexeme:@"3" location:3 type:KTXPTokenTypeAtom];
	KTXPToken *cl = [KTXPToken createWithLexeme:@"}" location:4 type:KTXPTokenTypeAtom];
	KTXPGroupNode *gr = [KTXPGroupNode createWithOpen:op
											 elements:@[tre]
												close:cl];
	KTXPFunctionNode *fn = [KTXPFunctionNode createWithToken:und
												   arguments:@[gr]];
	KTXPSupSubNode *sub = [KTXPSupSubNode createWithSup:nil Sub:fn];
	
	KTXPRootNode *c = [KTXPRootNode createWithChildren:@[y, sub, p1, p2, p3]];
	
	XCTAssert([r isEqual:c]);
}

@end
