//
//  KTXPSymbols.m
//  KaTeXParser
//
//  Created by Alice Roldán on 5/31/24.
//

#import "KTXPSymbols.h"

/*
	Something interesting here, this is purely symbols rather than "functions".
	For instance there is no `\begin{matrix}` stuff in here, even though these are supported.
*/
@implementation KTXPSymbols
{
	/*
	 LaTeX handles unicode characters. They are all considered atoms. If we reach a glyph that isn't in these dictionaries, we'll just assume its an Atom.
	 */
	NSDictionary<NSString *, NSDictionary *> *_MATH_SYMBOLS;
	NSDictionary<NSString *, NSDictionary *> *_TEXT_SYMBOLS;
}

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
		_MATH_SYMBOLS= @{
			// Symbols
			@"!"  : @{
				Type: @(KTXPTokenTypeAtom)
			},
			@"\\!" : @{
				Type: @(KTXPTokenTypeWhitespace)
			},
			// No support for defined stuff. So # is skipped.
			@"\\#" : @{
				Type: @(KTXPTokenTypeAtom)
			},
			@"%"  : @{
				Type: @(KTXPTokenTypeComment)
			},
			@"\\%" : @{
				Type: @(KTXPTokenTypeAtom)
			},
			// This one only works in certain environments.
			@"&"  : @{
				Type: @(KTXPTokenTypeAtom)
			},
			@"\\&" : @{
				Type: @(KTXPTokenTypeAtom)
			},
			@"'"  : @{
				Type: @(KTXPTokenTypeAtom)
			},
			@"("  : @{
				Type: @(KTXPTokenTypeAtom),
				SpecialKind: @(KTXPMacroTypeLeft)
			},
			@")"  : @{
				Type: @(KTXPTokenTypeAtom),
				SpecialKind: @(KTXPMacroTypeRight)
			},
			@"\\ " : @{
				Type: @(KTXPTokenTypeAtom)
			},
			@"\\$" : @{
				Type: @(KTXPTokenTypeAtom)
			},
			@"\\," : @{
				Type: @(KTXPTokenTypeWhitespace)
			},
			@"\\:" : @{
				Type: @(KTXPTokenTypeWhitespace)
			},
			@"\\;" : @{
				Type: @(KTXPTokenTypeWhitespace)
			},
			@"_"  : @{
				Type: @(KTXPTokenTypeSpecialFunction),
				SpecialKind: @(KTXPMacroTypeSupSub)
			},
			@"\\_" : @{
				Type: @(KTXPTokenTypeAtom)
			},
			@"<"  : @{
				Type: @(KTXPTokenTypeAtom),
				SpecialKind: @(KTXPMacroTypeLeft)
			},
			@">"  : @{
				Type: @(KTXPTokenTypeAtom),
				SpecialKind: @(KTXPMacroTypeRight)
			},
			@"\\>" : @{
				Type: @(KTXPTokenTypeWhitespace)
			},
			@"["  : @{
				Type: @(KTXPTokenTypeAtom),
				SpecialKind: @(KTXPMacroTypeLeft)
			},
			@"]"  : @{
				Type: @(KTXPTokenTypeAtom),
				SpecialKind: @(KTXPMacroTypeRight)
			},
			@"{"  : @{
				Type: @(KTXPTokenTypeGroupOpen),
				SpecialKind: @(KTXPMacroTypeLeft)
			},
			@"}"  : @{
				Type: @(KTXPTokenTypeGroupClose),
				SpecialKind: @(KTXPMacroTypeRight)
			},
			@"\\{" : @{
				Type: @(KTXPTokenTypeAtom),
				SpecialKind: @(KTXPMacroTypeLeft)
			},
			@"\\}" : @{
				Type: @(KTXPTokenTypeAtom),
				SpecialKind: @(KTXPMacroTypeRight)
			},
			@"|"  : @{
				Type: @(KTXPTokenTypeAtom),
				SpecialKind: @(KTXPMacroTypeLeft)
			},
			@"\\|" : @{
				Type: @(KTXPTokenTypeAtom),
				SpecialKind: @(KTXPMacroTypeLeft)
			},
			@"~"  : @{
				Type: @(KTXPTokenTypeWhitespace)
			},
			@"\\\\" : @{
				Type: @(KTXPTokenTypeAtom)
			},
			@"^"  : @{
				Type: @(KTXPTokenTypeSpecialFunction),
				SpecialKind: @(KTXPMacroTypeSupSub)
			},
			
			// A
			@"\\above" : @{
				Type: @(KTXPTokenTypeSpecialFunction),
				Args: @(1),
				SpecialKind: @(KTXPMacroTypePrePost)
			},
			@"\\acute" : @{
				Type: @(KTXPTokenTypeFunction),
				Args: @(1)
			},
			@"\\allowbreak" : @{
				Type: @(KTXPTokenTypeAtom)
			},
			@"\\Alpha" : @{
				Type: @(KTXPTokenTypeAtom)
			},
			@"\\alpha" : @{
				Type: @(KTXPTokenTypeAtom)
			},
			@"\\amalg" : @{
				Type: @(KTXPTokenTypeAtom)
			},
			@"\\And" : @{
				Type: @(KTXPTokenTypeAtom)
			},
			@"\\angl" : @{
				Type: @(KTXPTokenTypeFunction),
				Args: @(1)
			},
			@"\\angle" : @{
				Type: @(KTXPTokenTypeAtom)
			},
			@"\\approx" : @{
				Type: @(KTXPTokenTypeAtom)
			},
			@"\\approxeq" : @{
				Type: @(KTXPTokenTypeAtom)
			},
			@"\\approxcolon" : @{
				Type: @(KTXPTokenTypeAtom)
			},
			@"\\approxcoloncolon" : @{
				Type: @(KTXPTokenTypeAtom)
			},
			@"\\arccos" : @{
				Type: @(KTXPTokenTypeMathOp)
			},
			@"\\arcctg" : @{
				Type: @(KTXPTokenTypeMathOp)
			},
			@"\\arcsin" : @{
				Type: @(KTXPTokenTypeMathOp)
			},
			@"\\arctan" : @{
				Type: @(KTXPTokenTypeMathOp)
			},
			@"\\arctg" : @{
				Type: @(KTXPTokenTypeMathOp)
			},
			@"\\arg" : @{
				Type: @(KTXPTokenTypeMathOp)
			},
			@"\\argmax" : @{
				Type: @(KTXPTokenTypeMathOp)
			},
			@"\\argmin" : @{
				Type: @(KTXPTokenTypeMathOp)
			},
			@"\\ast" : @{
				Type: @(KTXPTokenTypeAtom)
			},
			@"\\asymp" : @{
				Type: @(KTXPTokenTypeAtom)
			},
			@"\\atop" : @{
				// Puts the contexts on top of each other <- is top -> is bottom.
				Type: @(KTXPTokenTypeSpecialFunction),
				SpecialKind: @(KTXPMacroTypePrePost)
			},
			
			// B
			@"\\backepsilon" : @{
				Type: @(KTXPTokenTypeAtom)
			},
			@"\\backprime" : @{
				Type: @(KTXPTokenTypeAtom)
			},
			@"\\backsim" : @{
				Type: @(KTXPTokenTypeAtom)
			},
			@"\\backsimeq" : @{
				Type: @(KTXPTokenTypeAtom)
			},
			@"\\backslash" : @{
				Type: @(KTXPTokenTypeAtom),
				SpecialKind: @(KTXPMacroTypeLeft)
			},
			@"\\bar" : @{
				Type: @(KTXPTokenTypeFunction),
				Args: @(1)
			},
			@"\\barwedge" : @{
				Type: @(KTXPTokenTypeAtom)
			},
			@"\\Bbb" : @{
				Type: @(KTXPTokenTypeAtom),
				Args: @(1)
			},
			@"\\Bbbk" : @{
				Type: @(KTXPTokenTypeAtom)
			},
			@"\\bcancel" : @{
				Type: @(KTXPTokenTypeFunction),
				Args: @(1)
			},
			@"\\because" : @{
				Type: @(KTXPTokenTypeAtom)
			},
			@"\\begin" : @{
				Type: @(KTXPTokenTypeEnvironmentOpen)
			},
			@"\\begingroup" : @{
				Type: @(KTXPTokenTypeGroupOpen)
			},
			@"\\Beta" : @{
				Type: @(KTXPTokenTypeAtom)
			},
			@"\\beta" : @{
				Type: @(KTXPTokenTypeAtom)
			},
			@"\\beth" : @{
				Type: @(KTXPTokenTypeAtom)
			},
			@"\\between" : @{
				Type: @(KTXPTokenTypeAtom)
			},
			@"\\big" : @{
				Type: @(KTXPTokenTypeFunction),
				Args: @(1)
			},
			@"\\Big" : @{
				Type: @(KTXPTokenTypeFunction),
				Args: @(1)
			},
			@"\\bigcap" : @{
				Type: @(KTXPTokenTypeFunction),
				Args: @(1)
			},
			@"\\bigcirc" : @{
				Type: @(KTXPTokenTypeFunction),
				Args: @(1)
			},
			@"\\bigcup" : @{
				Type: @(KTXPTokenTypeFunction),
				Args: @(1)
			},
			@"\\bigg" : @{
				Type: @(KTXPTokenTypeFunction),
				Args: @(1)
			},
			@"\\Bigg" : @{
				Type: @(KTXPTokenTypeFunction),
				Args: @(1)
			},
			@"\\biggl" : @{
				Type: @(KTXPTokenTypeFunction),
				Args: @(1)
			},
			@"\\Biggl" : @{
				Type: @(KTXPTokenTypeFunction),
				Args: @(1)
			},
			@"\\biggm" : @{
				Type: @(KTXPTokenTypeFunction),
				Args: @(1)
			},
			@"\\Biggm" : @{
				Type: @(KTXPTokenTypeFunction),
				Args: @(1)
			},
			@"\\biggr" : @{
				Type: @(KTXPTokenTypeFunction),
				Args: @(1)
			},
			@"\\Biggr" : @{
				Type: @(KTXPTokenTypeFunction),
				Args: @(1)
			},
			@"\\bigl" : @{
				Type: @(KTXPTokenTypeFunction),
				Args: @(1)
			},
			@"\\Bigl" : @{
				Type: @(KTXPTokenTypeFunction),
				Args: @(1)
			},
			@"\\bigm" : @{
				Type: @(KTXPTokenTypeFunction),
				Args: @(1)
			},
			@"\\Bigm" : @{
				Type: @(KTXPTokenTypeFunction),
				Args: @(1)
			},
			@"\\bigodot" : @{
				Type: @(KTXPTokenTypeAtom)
			},
			@"\\bigoplus" : @{
				Type: @(KTXPTokenTypeAtom)
			},
			@"\\bigotimes" : @{
				Type: @(KTXPTokenTypeAtom)
			},
			@"\\bigr" : @{
				Type: @(KTXPTokenTypeFunction),
				Args: @(1)
			},
			@"\\Bigr" : @{
				Type: @(KTXPTokenTypeFunction),
				Args: @(1)
			},
			@"\\bigsqcup" : @{
				Type: @(KTXPTokenTypeAtom)
			},
			@"\\bigstar" : @{
				Type: @(KTXPTokenTypeAtom)
			},
			@"\\bigtriangledown" : @{
				Type: @(KTXPTokenTypeAtom)
			},
			@"\\bigtriangleup" : @{
				Type: @(KTXPTokenTypeAtom)
			},
			@"\\biguplus" : @{
				Type: @(KTXPTokenTypeAtom)
			},
			@"\\bigvee" : @{
				Type: @(KTXPTokenTypeAtom)
			},
			@"\\bigwedge" : @{
				Type: @(KTXPTokenTypeAtom)
			},
			@"\\binom" : @{
				Type: @(KTXPTokenTypeFunction),
				Args: @(2)
			},
			@"\\blacklozenge" : @{
				Type: @(KTXPTokenTypeAtom)
			},
			@"\\blacksquare" : @{
				Type: @(KTXPTokenTypeAtom)
			},
			@"\\blacktriangle" : @{
				Type: @(KTXPTokenTypeAtom)
			},
			@"\\blacktriangledown" : @{
				Type: @(KTXPTokenTypeAtom)
			},
			@"\\blacktriangleleft" : @{
				Type: @(KTXPTokenTypeAtom)
			},
			@"\\blacktriangleright" : @{
				Type: @(KTXPTokenTypeAtom)
			},
			@"\\bm" : @{
				Type: @(KTXPTokenTypeFunction),
				Args: @(1)
			},
			@"\\bmod" : @{
				Type: @(KTXPTokenTypeMathOp)
			},
			@"\\bold" : @{
				Type: @(KTXPTokenTypeFunction),
				Args: @(1)
			},
			@"\\boldsymbol" : @{
				Type: @(KTXPTokenTypeFunction),
				Args: @(1)
			},
			@"\\bot" : @{
				Type: @(KTXPTokenTypeAtom)
			},
			@"\\bowtie" : @{
				Type: @(KTXPTokenTypeAtom)
			},
			@"\\Box" : @{
				Type: @(KTXPTokenTypeAtom)
			},
			@"\\boxdot" : @{
				Type: @(KTXPTokenTypeAtom)
			},
			@"\\boxed" : @{
				Type: @(KTXPTokenTypeFunction),
				Args: @(1)
			},
			@"\\boxminus" : @{
				Type: @(KTXPTokenTypeAtom)
			},
			@"\\boxplus" : @{
				Type: @(KTXPTokenTypeAtom)
			},
			@"\\boxtimes" : @{
				Type: @(KTXPTokenTypeAtom)
			},
			@"\\Bra" : @{
				Type: @(KTXPTokenTypeFunction),
				Args: @(1)
			},
			@"\\bra" : @{
				Type: @(KTXPTokenTypeFunction),
				Args: @(1)
			},
			@"\\braket" : @{
				Type: @(KTXPTokenTypeFunction),
				Args: @(1)
			},
			@"\\Braket" : @{
				Type: @(KTXPTokenTypeFunction),
				Args: @(1)
			},
			@"\\brace" : @{
				// Encloses the context within braces.
				Type: @(KTXPTokenTypeSpecialFunction),
				SpecialKind: @(KTXPMacroTypePrePost)
			},
			@"\\brack" : @{
				// Encloses the context within brackets.
				Type: @(KTXPTokenTypeSpecialFunction),
				SpecialKind: @(KTXPMacroTypePrePost)
			},
			@"\\breve" : @{
				Type: @(KTXPTokenTypeFunction),
				Args: @(1)
			},
			@"\\bull" : @{
				Type: @(KTXPTokenTypeAtom)
			},
			@"\\bullet" : @{
				Type: @(KTXPTokenTypeAtom)
			},
			@"\\Bumpeq" : @{
				Type: @(KTXPTokenTypeAtom)
			},
			@"\\bumpeq" : @{
				Type: @(KTXPTokenTypeAtom)
			},
			
			// C
			@"\\cancel" : @{
				Type: @(KTXPTokenTypeFunction),
				Args: @(1)
			},
			@"\\cap" : @{
				Type: @(KTXPTokenTypeAtom)
			},
			@"\\Cap" : @{
				Type: @(KTXPTokenTypeAtom)
			},
			@"\\cdot" : @{
				Type: @(KTXPTokenTypeAtom)
			},
			@"\\cdotp" : @{
				Type: @(KTXPTokenTypeAtom)
			},
			@"\\cdots" : @{
				Type: @(KTXPTokenTypeAtom)
			},
			@"\\centerdot" : @{
				Type: @(KTXPTokenTypeAtom)
			},
			@"\\cfrac" : @{
				Type: @(KTXPTokenTypeFunction),
				Args: @(2)
			},
			@"\\char" : @{
				Type: @(KTXPTokenTypeFunction),
				Args: @(1)
			},
			@"\\check" : @{
				Type: @(KTXPTokenTypeFunction),
				Args: @(1)
			},
			@"\\ch" : @{
				Type: @(KTXPTokenTypeMathOp)
			},
			@"\\checkmark" : @{
				Type: @(KTXPTokenTypeAtom)
			},
			@"\\Chi" : @{
				Type: @(KTXPTokenTypeAtom)
			},
			@"\\chi" : @{
				Type: @(KTXPTokenTypeAtom)
			},
			@"\\choose" : @{
				// Works like \atop but puts the result within ().
				Type: @(KTXPTokenTypeSpecialFunction),
				SpecialKind: @(KTXPMacroTypePrePost)
			},
			@"\\circ" : @{
				Type: @(KTXPTokenTypeAtom)
			},
			@"\\circeq" : @{
				Type: @(KTXPTokenTypeAtom)
			},
			@"\\circlearrowleft" : @{
				Type: @(KTXPTokenTypeAtom)
			},
			@"\\circlearrowright" : @{
				Type: @(KTXPTokenTypeAtom)
			},
			@"\\circledast" : @{
				Type: @(KTXPTokenTypeAtom)
			},
			@"\\circledcirc" : @{
				Type: @(KTXPTokenTypeAtom)
			},
			@"\\circleddash" : @{
				Type: @(KTXPTokenTypeAtom)
			},
			@"\\circledR" : @{
				Type: @(KTXPTokenTypeAtom)
			},
			@"\\circledS" : @{
				Type: @(KTXPTokenTypeAtom)
			},
			@"\\clubs" : @{
				Type: @(KTXPTokenTypeAtom)
			},
			@"\\slubsuit" : @{
				Type: @(KTXPTokenTypeAtom)
			},
			@"\\cnums" : @{
				Type: @(KTXPTokenTypeAtom)
			},
			@"\\colon" : @{
				Type: @(KTXPTokenTypeAtom)
			},
			@"\\Colonapprox" : @{
				Type: @(KTXPTokenTypeAtom)
			},
			@"\\colonapprox" : @{
				Type: @(KTXPTokenTypeAtom)
			},
			@"\\coloncolon" : @{
				Type: @(KTXPTokenTypeAtom)
			},
			@"\\coloncolonapprox" : @{
				Type: @(KTXPTokenTypeAtom)
			},
			@"\\coloncolonequals" : @{
				Type: @(KTXPTokenTypeAtom)
			},
			@"\\coloncolonminus" : @{
				Type: @(KTXPTokenTypeAtom)
			},
			@"\\coloncolonsim" : @{
				Type: @(KTXPTokenTypeAtom)
			},
			@"\\Coloneq" : @{
				Type: @(KTXPTokenTypeAtom)
			},
			@"\\coloneq" : @{
				Type: @(KTXPTokenTypeAtom)
			},
			@"\\colonequals" : @{
				Type: @(KTXPTokenTypeAtom)
			},
			@"\\Coloneqq" : @{
				Type: @(KTXPTokenTypeAtom)
			},
			@"\\coloneqq" : @{
				Type: @(KTXPTokenTypeAtom)
			},
			@"\\colonminus" : @{
				Type: @(KTXPTokenTypeAtom)
			},
			@"\\Colonsim" : @{
				Type: @(KTXPTokenTypeAtom)
			},
			@"\\colonsim" : @{
				Type: @(KTXPTokenTypeAtom)
			},
			@"\\color" : @{
				Type: @(KTXPTokenTypeFunction),
				Args: @(1)
			},
			@"\\colorbox" : @{
				Type: @(KTXPTokenTypeFunction),
				Args: @(2)
			},
			@"\\complement" : @{
				Type: @(KTXPTokenTypeAtom)
			},
			@"\\Complex" : @{
				Type: @(KTXPTokenTypeAtom)
			},
			@"\\cong" : @{
				Type: @(KTXPTokenTypeAtom)
			},
			@"\\coprod" : @{
				Type: @(KTXPTokenTypeAtom)
			},
			@"\\copyright" : @{
				Type: @(KTXPTokenTypeAtom)
			},
			@"\\cos" : @{
				Type: @(KTXPTokenTypeMathOp)
			},
			@"\\cosec" : @{
				Type: @(KTXPTokenTypeMathOp)
			},
			@"\\cosh" : @{
				Type: @(KTXPTokenTypeMathOp)
			},
			@"\\cot" : @{
				Type: @(KTXPTokenTypeMathOp)
			},
			@"\\cotg" : @{
				Type: @(KTXPTokenTypeMathOp)
			},
			@"\\coth" : @{
				Type: @(KTXPTokenTypeMathOp)
			},
			@"\\csc" : @{
				Type: @(KTXPTokenTypeMathOp)
			},
			@"\\ctg" : @{
				Type: @(KTXPTokenTypeMathOp)
			},
			@"\\cth" : @{
				Type: @(KTXPTokenTypeMathOp)
			},
			@"\\Cup" : @{
				Type: @(KTXPTokenTypeAtom)
			},
			@"\\cup" : @{
				Type: @(KTXPTokenTypeAtom)
			},
			@"\\curlyeqprec" : @{
				Type: @(KTXPTokenTypeAtom)
			},
			@"\\curlyeqsucc" : @{
				Type: @(KTXPTokenTypeAtom)
			},
			@"\\curlyvee" : @{
				Type: @(KTXPTokenTypeAtom)
			},
			@"\\curlywedge" : @{
				Type: @(KTXPTokenTypeAtom)
			},
			@"\\curvearrowleft" : @{
				Type: @(KTXPTokenTypeAtom)
			},
			@"\\curvearrowright" : @{
				Type: @(KTXPTokenTypeAtom)
			},
			
			// D
			@"\\dag" : @{
				Type: @(KTXPTokenTypeAtom)
			},
			@"\\Dagger" : @{
				Type: @(KTXPTokenTypeAtom)
			},
			@"\\dagger" : @{
				Type: @(KTXPTokenTypeAtom)
			},
			@"\\daleth" : @{
				Type: @(KTXPTokenTypeAtom)
			},
			@"\\Darr" : @{
				Type: @(KTXPTokenTypeAtom)
			},
			@"\\dArr" : @{
				Type: @(KTXPTokenTypeAtom)
			},
			@"\\darr" : @{
				Type: @(KTXPTokenTypeAtom)
			},
			@"\\dashleftarrow" : @{
				Type: @(KTXPTokenTypeAtom)
			},
			@"\\dashrightarrow" : @{
				Type: @(KTXPTokenTypeAtom)
			},
			@"\\dashv" : @{
				Type: @(KTXPTokenTypeAtom)
			},
			@"\\dbinom" : @{
				Type: @(KTXPTokenTypeFunction),
				Args: @(2)
			},
			@"\\dblcolon" : @{
				Type: @(KTXPTokenTypeAtom)
			},
			@"\\ddag" : @{
				Type: @(KTXPTokenTypeAtom)
			},
			@"\\ddagger" : @{
				Type: @(KTXPTokenTypeAtom)
			},
			@"\\ddot" : @{
				Type: @(KTXPTokenTypeFunction),
				Args: @(1)
			},
			@"\\ddots" : @{
				Type: @(KTXPTokenTypeAtom)
			},
			@"\\deg" : @{
				Type: @(KTXPTokenTypeMathOp)
			},
			@"\\degree" : @{
				Type: @(KTXPTokenTypeAtom)
			},
			@"\\delta" : @{
				Type: @(KTXPTokenTypeAtom)
			},
			@"\\Delta" : @{
				Type: @(KTXPTokenTypeAtom)
			},
			@"\\det" : @{
				Type: @(KTXPTokenTypeMathOp)
			},
			@"\\digamma" : @{
				Type: @(KTXPTokenTypeAtom)
			},
			@"\\dfrac" : @{
				Type: @(KTXPTokenTypeFunction),
				Args: @(2)
			},
			@"\\diagdown" : @{
				Type: @(KTXPTokenTypeAtom)
			},
			@"\\diagup" : @{
				Type: @(KTXPTokenTypeAtom)
			},
			@"\\Diamond" : @{
				Type: @(KTXPTokenTypeAtom)
			},
			@"\\diamond" : @{
				Type: @(KTXPTokenTypeAtom)
			},
			@"\\diamonds" : @{
				Type: @(KTXPTokenTypeAtom)
			},
			@"\\diamondsuit" : @{
				Type: @(KTXPTokenTypeAtom)
			},
			@"\\dim" : @{
				Type: @(KTXPTokenTypeMathOp)
			},
			@"\\displaystyle" : @{
				// A command that switches the render mode from hence it's parsed.
				// You can also limit it to within a group.
				Type: @(KTXPTokenTypeSpecialFunction),
				SpecialKind: @(KTXPMacroTypePost)
			},
			@"\\div" : @{
				Type: @(KTXPTokenTypeAtom)
			},
			@"\\divideontimes" : @{
				Type: @(KTXPTokenTypeAtom)
			},
			@"\\dot" : @{
				Type: @(KTXPTokenTypeFunction),
				Args: @(1)
			},
			@"\\Doteq" : @{
				Type: @(KTXPTokenTypeAtom)
			},
			@"\\doteq" : @{
				Type: @(KTXPTokenTypeAtom)
			},
			@"\\doteqdot" : @{
				Type: @(KTXPTokenTypeAtom)
			},
			@"\\dotplus" : @{
				Type: @(KTXPTokenTypeAtom)
			},
			@"\\dots" : @{
				Type: @(KTXPTokenTypeAtom)
			},
			@"\\dotsb" : @{
				Type: @(KTXPTokenTypeAtom)
			},
			@"\\dotsc" : @{
				Type: @(KTXPTokenTypeAtom)
			},
			@"\\dotsi" : @{
				Type: @(KTXPTokenTypeAtom)
			},
			@"\\dotsm" : @{
				Type: @(KTXPTokenTypeAtom)
			},
			@"\\dotso" : @{
				Type: @(KTXPTokenTypeAtom)
			},
			@"\\doublebarwedge" : @{
				Type: @(KTXPTokenTypeAtom)
			},
			@"\\doublecap" : @{
				Type: @(KTXPTokenTypeAtom)
			},
			@"\\doublecup" : @{
				Type: @(KTXPTokenTypeAtom)
			},
			@"\\Downarrow" : @{
				Type: @(KTXPTokenTypeAtom)
			},
			@"\\downarrow" : @{
				Type: @(KTXPTokenTypeAtom)
			},
			@"\\downdownarrows" : @{
				Type: @(KTXPTokenTypeAtom)
			},
			@"\\downharpoonleft" : @{
				Type: @(KTXPTokenTypeAtom)
			},
			@"\\downharpoonright" : @{
				Type: @(KTXPTokenTypeAtom)
			},
			
			// E
			@"\\ell" : @{
				Type: @(KTXPTokenTypeAtom)
			},
			@"\\emph" : @{
				Type: @(KTXPTokenTypeFunction),
				Args: @(1)
			},
			@"\\empty" : @{
				Type: @(KTXPTokenTypeAtom)
			},
			@"\\emptyset" : @{
				Type: @(KTXPTokenTypeAtom)
			},
			@"\\end" : @{
				Type: @(KTXPTokenTypeEnvironmentClose),
				Args: @(1)
			},
			@"\\endgroup" : @{
				Type: @(KTXPTokenTypeGroupClose)
			},
			@"\\enspace" : @{
				Type: @(KTXPTokenTypeAtom)
			},
			@"\\Epsilon" : @{
				Type: @(KTXPTokenTypeAtom)
			},
			@"\\epsilon" : @{
				Type: @(KTXPTokenTypeAtom)
			},
			@"\\eqcirc" : @{
				Type: @(KTXPTokenTypeAtom)
			},
			@"\\Eqcolon" : @{
				Type: @(KTXPTokenTypeAtom)
			},
			@"\\eqcolon" : @{
				Type: @(KTXPTokenTypeAtom)
			},
			@"\\Eqqcolon" : @{
				Type: @(KTXPTokenTypeAtom)
			},
			@"\\eqqcolon" : @{
				Type: @(KTXPTokenTypeAtom)
			},
			@"\\eqsim" : @{
				Type: @(KTXPTokenTypeAtom)
			},
			@"\\eqslantgtr" : @{
				Type: @(KTXPTokenTypeAtom)
			},
			@"\\eqslantless" : @{
				Type: @(KTXPTokenTypeAtom)
			},
			@"\\equalscolon" : @{
				Type: @(KTXPTokenTypeAtom)
			},
			@"\\equalscoloncolon" : @{
				Type: @(KTXPTokenTypeAtom)
			},
			@"\\equiv" : @{
				Type: @(KTXPTokenTypeAtom)
			},
			@"\\Eta" : @{
				Type: @(KTXPTokenTypeAtom)
			},
			@"\\eta" : @{
				Type: @(KTXPTokenTypeAtom)
			},
			@"\\eth" : @{
				Type: @(KTXPTokenTypeAtom)
			},
			@"\\euro" : @{
				Type: @(KTXPTokenTypeAtom)
			},
			@"\\exist" : @{
				Type: @(KTXPTokenTypeAtom)
			},
			@"\\exists" : @{
				Type: @(KTXPTokenTypeAtom)
			},
			@"\\exp" : @{
				Type: @(KTXPTokenTypeMathOp)
			},
			
			// F
			@"\\fallingdotseq" : @{
				Type: @(KTXPTokenTypeAtom)
			},
			@"\\fbox" : @{
				Type: @(KTXPTokenTypeFunction),
				Args: @(1)
			},
			@"\\fcolorbox" : @{
				Type: @(KTXPTokenTypeFunction),
				Args: @(3)
			},
			@"\\Finv" : @{
				Type: @(KTXPTokenTypeAtom)
			},
			@"\\flat" : @{
				Type: @(KTXPTokenTypeAtom)
			},
			@"\\footnotesize" : @{
				// A command that switches the render mode from hence it's parsed.
				// You can also limit it to within a group.
				Type: @(KTXPTokenTypeSpecialFunction),
				SpecialKind: @(KTXPMacroTypePost)
			},
			@"\\forall" : @{
				Type: @(KTXPTokenTypeAtom)
			},
			@"\\frac" : @{
				Type: @(KTXPTokenTypeFunction),
				Args: @(2)
			},
			@"\\frak" : @{
				Type: @(KTXPTokenTypeFunction),
				Args: @(1)
			},
			@"\\frown" : @{
				Type: @(KTXPTokenTypeAtom)
			},
			
			// G
			@"\\Game" : @{
				Type: @(KTXPTokenTypeAtom)
			},
			@"\\Gamma" : @{
				Type: @(KTXPTokenTypeAtom)
			},
			@"\\gamma" : @{
				Type: @(KTXPTokenTypeAtom)
			},
			@"\\gcd" : @{
				Type: @(KTXPTokenTypeMathOp)
			},
			@"\\ge" : @{
				Type: @(KTXPTokenTypeAtom)
			},
			@"\\genfrac" : @{
				Type: @(KTXPTokenTypeFunction),
				Args: @(6)
			},
			@"\\geq" : @{
				Type: @(KTXPTokenTypeAtom)
			},
			@"\\geqq" : @{
				Type: @(KTXPTokenTypeAtom)
			},
			@"\\geqslant" : @{
				Type: @(KTXPTokenTypeAtom)
			},
			@"\\gets" : @{
				Type: @(KTXPTokenTypeAtom)
			},
			@"\\gg" : @{
				Type: @(KTXPTokenTypeAtom)
			},
			@"\\ggg" : @{
				Type: @(KTXPTokenTypeAtom)
			},
			@"\\gggtr" : @{
				Type: @(KTXPTokenTypeAtom)
			},
			@"\\gimel" : @{
				Type: @(KTXPTokenTypeAtom)
			},
			@"\\gnapprox" : @{
				Type: @(KTXPTokenTypeAtom)
			},
			@"\\gneq" : @{
				Type: @(KTXPTokenTypeAtom)
			},
			@"\\gneqq" : @{
				Type: @(KTXPTokenTypeAtom)
			},
			@"\\gnsim" : @{
				Type: @(KTXPTokenTypeAtom)
			},
			@"\\grave" : @{
				Type: @(KTXPTokenTypeAtom)
			},
			@"\\gt" : @{
				Type: @(KTXPTokenTypeAtom)
			},
			@"\\gtrdot" : @{
				Type: @(KTXPTokenTypeAtom)
			},
			@"\\gtrapprox" : @{
				Type: @(KTXPTokenTypeAtom)
			},
			@"\\gtreqless" : @{
				Type: @(KTXPTokenTypeAtom)
			},
			@"\\gtreqqless" : @{
				Type: @(KTXPTokenTypeAtom)
			},
			@"\\gtrless" : @{
				Type: @(KTXPTokenTypeAtom)
			},
			@"\\gtrsim" : @{
				Type: @(KTXPTokenTypeAtom)
			},
			@"\\gvertneqq" : @{
				Type: @(KTXPTokenTypeAtom)
			},
			
			// H
			@"\\Harr" : @{
				Type: @(KTXPTokenTypeAtom)
			},
			@"\\hArr" : @{
				Type: @(KTXPTokenTypeAtom)
			},
			@"\\harr" : @{
				Type: @(KTXPTokenTypeAtom)
			},
			@"\\hat" : @{
				Type: @(KTXPTokenTypeFunction),
				Args: @(1)
			},
			@"\\hbar" : @{
				Type: @(KTXPTokenTypeAtom)
			},
			@"\\hbox" : @{
				Type: @(KTXPTokenTypeFunction),
				Args: @(1)
			},
			@"\\hearts" : @{
				Type: @(KTXPTokenTypeAtom)
			},
			@"\\heartsuit" : @{
				Type: @(KTXPTokenTypeAtom)
			},
			@"\\hom" : @{
				Type: @(KTXPTokenTypeMathOp)
			},
			@"\\hookleftarrow" : @{
				Type: @(KTXPTokenTypeAtom)
			},
			@"\\hookrightarrow" : @{
				Type: @(KTXPTokenTypeAtom)
			},
			@"\\hphantom" : @{
				Type: @(KTXPTokenTypeFunction),
				Args: @(1)
			},
			@"\\hskip" : @{
				Type: @(KTXPTokenTypeFunction),
				Args: @(1)
			},
			@"\\hslash" : @{
				Type: @(KTXPTokenTypeAtom)
			},
			@"\\hspace" : @{
				Type: @(KTXPTokenTypeFunction),
				Args: @(1)
			},
			@"\\huge" : @{
				Type: @(KTXPTokenTypeAtom)
			},
			@"\\Huge" : @{
				Type: @(KTXPTokenTypeAtom)
			},
			
			// I
			@"\\iff" : @{
				Type: @(KTXPTokenTypeAtom)
			},
			@"\\iiint" : @{
				Type: @(KTXPTokenTypeAtom)
			},
			@"\\iint" : @{
				Type: @(KTXPTokenTypeAtom)
			},
			@"\\Im" : @{
				Type: @(KTXPTokenTypeAtom)
			},
			@"\\image" : @{
				Type: @(KTXPTokenTypeAtom)
			},
			@"\\imageof" : @{
				Type: @(KTXPTokenTypeAtom)
			},
			@"\\imath" : @{
				Type: @(KTXPTokenTypeAtom)
			},
			@"\\impliedby" : @{
				Type: @(KTXPTokenTypeAtom)
			},
			@"\\implies" : @{
				Type: @(KTXPTokenTypeAtom)
			},
			@"\\in" : @{
				Type: @(KTXPTokenTypeAtom)
			},
			@"\\inf" : @{
				Type: @(KTXPTokenTypeMathOp)
			},
			@"\\infin" : @{
				Type: @(KTXPTokenTypeAtom)
			},
			@"\\infty" : @{
				Type: @(KTXPTokenTypeAtom)
			},
			@"\\injlim" : @{
				Type: @(KTXPTokenTypeMathOp)
			},
			@"\\int" : @{
				Type: @(KTXPTokenTypeAtom)
			},
			@"\\intercal" : @{
				Type: @(KTXPTokenTypeAtom)
			},
			@"\\intop" : @{
				Type: @(KTXPTokenTypeAtom)
			},
			@"\\Iota" : @{
				Type: @(KTXPTokenTypeAtom)
			},
			@"\\iota" : @{
				Type: @(KTXPTokenTypeAtom)
			},
			@"\\isin" : @{
				Type: @(KTXPTokenTypeAtom)
			},
			@"\\it" : @{
				// A command that switches the render mode from hence it's parsed.
				// You can also limit it to within a group.
				Type: @(KTXPTokenTypeSpecialFunction),
				SpecialKind: @(KTXPMacroTypePost)
			},
			
			// JK
			@"\\jmath" : @{
				Type: @(KTXPTokenTypeAtom)
			},
			@"\\Join" : @{
				Type: @(KTXPTokenTypeAtom)
			},
			@"\\Kappa" : @{
				Type: @(KTXPTokenTypeAtom)
			},
			@"\\kappa" : @{
				Type: @(KTXPTokenTypeAtom)
			},
			@"\\KaTeX" : @{
				Type: @(KTXPTokenTypeAtom)
			},
			@"\\ker" : @{
				Type: @(KTXPTokenTypeMathOp)
			},
			@"\\kern" : @{
				// Argument is a measurement.
				Type: @(KTXPTokenTypeSpecialFunction),
				Args: @(1)
			},
			@"\\Ket" : @{
				Type: @(KTXPTokenTypeFunction),
				Args: @(1)
			},
			@"\\ket" : @{
				Type: @(KTXPTokenTypeFunction),
				Args: @(1)
			},
			
			// L
			@"\\Lambda" : @{
				Type: @(KTXPTokenTypeAtom)
			},
			@"\\lambda" : @{
				Type: @(KTXPTokenTypeAtom)
			},
			@"\\land" : @{
				Type: @(KTXPTokenTypeAtom)
			},
			@"\\lang" : @{
				Type: @(KTXPTokenTypeAtom)
			},
			@"\\langle" : @{
				Type: @(KTXPTokenTypeAtom)
			},
			@"\\Larr" : @{
				Type: @(KTXPTokenTypeAtom)
			},
			@"\\lArr" : @{
				Type: @(KTXPTokenTypeAtom)
			},
			@"\\larr" : @{
				Type: @(KTXPTokenTypeAtom)
			},
			@"\\large" : @{
				Type: @(KTXPTokenTypeFunction)
			},
			@"\\LARGE" : @{
				Type: @(KTXPTokenTypeFunction)
			},
			@"\\LaTeX" : @{
				Type: @(KTXPTokenTypeAtom)
			},
			@"\\lBrace" : @{
				Type: @(KTXPTokenTypeAtom)
			},
			@"\\lbrace" : @{
				Type: @(KTXPTokenTypeAtom)
			},
			@"\\lbrack" : @{
				Type: @(KTXPTokenTypeAtom)
			},
			@"\\lceil" : @{
				Type: @(KTXPTokenTypeAtom)
			},
			@"\\ldotp" : @{
				Type: @(KTXPTokenTypeAtom)
			},
			@"\\ldots" : @{
				Type: @(KTXPTokenTypeAtom)
			},
			@"\\le" : @{
				Type: @(KTXPTokenTypeAtom)
			},
			@"\\leadsto" : @{
				Type: @(KTXPTokenTypeAtom)
			},
			@"\\left" : @{
				// Acts like a group, requires a close with `\right`.
				// The argument needs to be some kind of lr atom like `({[||]}).`
				// An argument of `.` means no render.
				Type: @(KTXPTokenTypeSpecialFunction),
				Args: @(1),
				SpecialKind: @(KTXPMacroTypeGroupOpen)
			},
			@"\\leftarrow" : @{
				Type: @(KTXPTokenTypeAtom)
			},
			@"\\Leftarrow" : @{
				Type: @(KTXPTokenTypeAtom)
			},
			@"\\leftarrowtail" : @{
				Type: @(KTXPTokenTypeAtom)
			},
			@"\\leftharpoondown" : @{
				Type: @(KTXPTokenTypeAtom)
			},
			@"\\leftharpoonup" : @{
				Type: @(KTXPTokenTypeAtom)
			},
			@"\\leftleftarrows" : @{
				Type: @(KTXPTokenTypeAtom)
			},
			@"\\Leftrightarrow" : @{
				Type: @(KTXPTokenTypeAtom)
			},
			@"\\leftrightarrow" : @{
				Type: @(KTXPTokenTypeAtom)
			},
			@"\\leftrightarrows" : @{
				Type: @(KTXPTokenTypeAtom)
			},
			@"\\leftrightharpoons" : @{
				Type: @(KTXPTokenTypeAtom)
			},
			@"\\leftrightsquigarrow" : @{
				Type: @(KTXPTokenTypeAtom)
			},
			@"\\leftthreetimes" : @{
				Type: @(KTXPTokenTypeAtom)
			},
			@"\\leq" : @{
				Type: @(KTXPTokenTypeAtom)
			},
			@"\\leqq" : @{
				Type: @(KTXPTokenTypeAtom)
			},
			@"\\leqslant" : @{
				Type: @(KTXPTokenTypeAtom)
			},
			@"\\lessapprox" : @{
				Type: @(KTXPTokenTypeAtom)
			},
			@"\\lessdot" : @{
				Type: @(KTXPTokenTypeAtom)
			},
			@"\\lesseqgtr" : @{
				Type: @(KTXPTokenTypeAtom)
			},
			@"\\lesseqqgtr" : @{
				Type: @(KTXPTokenTypeAtom)
			},
			@"\\lessgtr" : @{
				Type: @(KTXPTokenTypeAtom)
			},
			@"\\lesssim" : @{
				Type: @(KTXPTokenTypeAtom)
			},
			/* DISABLED
			 @"\\let" : @{
				Type: @(KTXPTokenTypeSpecialFunction)
			},*/
			@"\\lfloor" : @{
				Type: @(KTXPTokenTypeAtom)
			},
			@"\\lg" : @{
				Type: @(KTXPTokenTypeFunction)
			},
			@"\\lgroup" : @{
				Type: @(KTXPTokenTypeAtom)
			},
			@"\\lhd" : @{
				Type: @(KTXPTokenTypeAtom)
			},
			@"\\lim" : @{
				Type: @(KTXPTokenTypeMathOp)
			},
			@"\\liminf" : @{
				Type: @(KTXPTokenTypeMathOp)
			},
			@"\\limits" : @{
				// Needs to follow a math operator macro (which seem to be atoms that make text that's normal looking in math mode like \ln or \lim.)
				// Has to be followed by _ or ^ or _^.
				// The output of this macro puts the _ underneath the preceding macro, and puts the ^ over the preceding macro.
				Type: @(KTXPTokenTypeSpecialFunction),
				SpecialKind: @(KTXPMacroTypeNone)
			},
			@"\\limsup" : @{
				Type: @(KTXPTokenTypeMathOp)
			},
			@"\\ll" : @{
				Type: @(KTXPTokenTypeAtom)
			},
			@"\\llap" : @{
				// Makes a left overlap.
				// Needs a group after it.
				// This is a special function becuase it affects whatever is
				// to the left of it.
				// {=}\llap{/}
				Type: @(KTXPTokenTypeSpecialFunction),
				Args: @(1)
			},
			@"\\llbracket" : @{
				Type: @(KTXPTokenTypeAtom)
			},
			@"\\llcorner" : @{
				Type: @(KTXPTokenTypeAtom)
			},
			@"\\Lleftarrow" : @{
				Type: @(KTXPTokenTypeAtom)
			},
			@"\\lll" : @{
				Type: @(KTXPTokenTypeAtom)
			},
			@"\\llless" : @{
				Type: @(KTXPTokenTypeAtom)
			},
			@"\\lmoustache" : @{
				Type: @(KTXPTokenTypeAtom)
			},
			@"\\ln" : @{
				Type: @(KTXPTokenTypeMathOp)
			},
			@"\\lnapprox" : @{
				Type: @(KTXPTokenTypeAtom)
			},
			@"\\lneq" : @{
				Type: @(KTXPTokenTypeAtom)
			},
			@"\\lneqq" : @{
				Type: @(KTXPTokenTypeAtom)
			},
			@"\\lnot" : @{
				Type: @(KTXPTokenTypeAtom)
			},
			@"\\lnsim" : @{
				Type: @(KTXPTokenTypeAtom)
			},
			@"\\log" : @{
				Type: @(KTXPTokenTypeMathOp)
			},
			/* DISABLED
			 @"\\long" : @{
				Type: @(KTXPTokenTypeSpecialFunction)
			},*/
			@"\\Longleftarrow" : @{
				Type: @(KTXPTokenTypeAtom)
			},
			@"\\longleftarrow" : @{
				Type: @(KTXPTokenTypeAtom)
			},
			@"\\Longleftrightarrow" : @{
				Type: @(KTXPTokenTypeAtom)
			},
			@"\\longleftrightarrow" : @{
				Type: @(KTXPTokenTypeAtom)
			},
			@"\\longmapsto" : @{
				Type: @(KTXPTokenTypeAtom)
			},
			@"\\Longrightarrow" : @{
				Type: @(KTXPTokenTypeAtom)
			},
			@"\\longrightarrow" : @{
				Type: @(KTXPTokenTypeAtom)
			},
			@"\\looparrowleft" : @{
				Type: @(KTXPTokenTypeAtom)
			},
			@"\\looparrowright" : @{
				Type: @(KTXPTokenTypeAtom)
			},
			@"\\lor" : @{
				Type: @(KTXPTokenTypeAtom)
			},
			@"\\lozenge" : @{
				Type: @(KTXPTokenTypeAtom)
			},
			@"\\lparen" : @{
				Type: @(KTXPTokenTypeAtom)
			},
			@"\\Lrarr" : @{
				Type: @(KTXPTokenTypeAtom)
			},
			@"\\lrArr" : @{
				Type: @(KTXPTokenTypeAtom)
			},
			@"\\lrarr" : @{
				Type: @(KTXPTokenTypeAtom)
			},
			@"\\lrcorner" : @{
				Type: @(KTXPTokenTypeAtom)
			},
			@"\\lq" : @{
				Type: @(KTXPTokenTypeAtom)
			},
			@"\\Lsh" : @{
				Type: @(KTXPTokenTypeAtom)
			},
			@"\\lt" : @{
				Type: @(KTXPTokenTypeAtom)
			},
			@"\\ltimes" : @{
				Type: @(KTXPTokenTypeAtom)
			},
			@"\\lVert" : @{
				Type: @(KTXPTokenTypeAtom)
			},
			@"\\lvert" : @{
				Type: @(KTXPTokenTypeAtom)
			},
			@"\\lvertneqq" : @{
				Type: @(KTXPTokenTypeAtom)
			},
			
			// M
			@"\\maltese" : @{
				Type: @(KTXPTokenTypeAtom)
			},
			@"\\mapsto" : @{
				Type: @(KTXPTokenTypeAtom)
			},
			@"\\mathbb" : @{
				Type: @(KTXPTokenTypeFunction)
			},
			@"\\mathbf" : @{
				Type: @(KTXPTokenTypeFunction)
			},
			@"\\mathbin" : @{
				Type: @(KTXPTokenTypeFunction)
			},
			@"\\mathbcal" : @{
				Type: @(KTXPTokenTypeFunction)
			},
			@"\\mathchoice" : @{
				Type: @(KTXPTokenTypeFunction)
			},
			@"\\mathclap" : @{
				Type: @(KTXPTokenTypeFunction)
			},
			@"\\mathclose" : @{
				Type: @(KTXPTokenTypeFunction)
			},
			@"\\mathellipsis" : @{
				Type: @(KTXPTokenTypeAtom)
			},
			@"\\mathfrak" : @{
				Type: @(KTXPTokenTypeFunction)
			},
			@"\\mathinner" : @{
				Type: @(KTXPTokenTypeFunction)
			},
			@"\\mathit" : @{
				Type: @(KTXPTokenTypeFunction)
			},
			@"\\mathllap" : @{
				Type: @(KTXPTokenTypeFunction)
			},
			@"\\mathnormal" : @{
				Type: @(KTXPTokenTypeFunction)
			},
			@"\\mathop" : @{
				Type: @(KTXPTokenTypeFunction)
			},
			@"\\mathopen" : @{
				Type: @(KTXPTokenTypeFunction)
			},
			@"\\mathord" : @{
				Type: @(KTXPTokenTypeFunction)
			},
			@"\\mathpunct" : @{
				Type: @(KTXPTokenTypeFunction)
			},
			@"\\mathrel" : @{
				Type: @(KTXPTokenTypeFunction)
			},
			@"\\mathrlap" : @{
				Type: @(KTXPTokenTypeFunction)
			},
			@"\\mathring" : @{
				Type: @(KTXPTokenTypeFunction)
			},
			@"\\mathrm" : @{
				Type: @(KTXPTokenTypeFunction)
			},
			@"\\mathscr" : @{
				Type: @(KTXPTokenTypeFunction)
			},
			@"\\mathsf" : @{
				Type: @(KTXPTokenTypeFunction)
			},
			@"\\mathsterling" : @{
				Type: @(KTXPTokenTypeAtom)
			},
			@"\\mathstrut" : @{
				Type: @(KTXPTokenTypeFunction)
			},
			@"\\mathtt" : @{
				Type: @(KTXPTokenTypeFunction)
			},
			@"\\matrix" : @{
				Type: @(KTXPTokenTypeAtom)
			},
			@"matrix*" : @{
				Type: @(KTXPTokenTypeAtom)
			},
			@"\\max" : @{
				Type: @(KTXPTokenTypeMathOp)
			},
			@"\\measuredangle" : @{
				Type: @(KTXPTokenTypeAtom)
			},
			@"\\medspace" : @{
				Type: @(KTXPTokenTypeAtom)
			},
			@"\\mho" : @{
				Type: @(KTXPTokenTypeAtom)
			},
			@"\\mid" : @{
				Type: @(KTXPTokenTypeAtom)
			},
			@"\\middle" : @{
				Type: @(KTXPTokenTypeAtom)
			},
			@"\\min" : @{
				Type: @(KTXPTokenTypeMathOp)
			},
			@"\\minuscolon" : @{
				Type: @(KTXPTokenTypeAtom)
			},
			@"\\minuscoloncolon" : @{
				Type: @(KTXPTokenTypeAtom)
			},
			@"\\minuso" : @{
				Type: @(KTXPTokenTypeAtom)
			},
			@"\\mkern" : @{
				// Needs a measurement
				Type: @(KTXPTokenTypeSpecialFunction),
				Args: @(1)
			},
			@"\\mod" : @{
				Type: @(KTXPTokenTypeFunction)
			},
			@"\\models" : @{
				Type: @(KTXPTokenTypeAtom)
			},
			@"\\mp" : @{
				Type: @(KTXPTokenTypeAtom)
			},
			@"\\mskip" : @{
				Type: @(KTXPTokenTypeAtom)
			},
			@"\\Mu" : @{
				Type: @(KTXPTokenTypeAtom)
			},
			@"\\mu" : @{
				Type: @(KTXPTokenTypeAtom)
			},
			@"\\multimap" : @{
				Type: @(KTXPTokenTypeAtom)
			},
			
			// N
			@"\\N" : @{
				Type: @(KTXPTokenTypeAtom)
			},
			@"\\nabla" : @{
				Type: @(KTXPTokenTypeAtom)
			},
			@"\\natnums" : @{
				Type: @(KTXPTokenTypeAtom)
			},
			@"\\natural" : @{
				Type: @(KTXPTokenTypeAtom)
			},
			@"\\negmedspace" : @{
				Type: @(KTXPTokenTypeAtom)
			},
			@"\\ncong" : @{
				Type: @(KTXPTokenTypeAtom)
			},
			@"\\ne" : @{
				Type: @(KTXPTokenTypeAtom)
			},
			@"\\nearrow" : @{
				Type: @(KTXPTokenTypeAtom)
			},
			@"\\neg" : @{
				Type: @(KTXPTokenTypeAtom)
			},
			@"\\negthickspace" : @{
				Type: @(KTXPTokenTypeAtom)
			},
			@"\\negthinspace" : @{
				Type: @(KTXPTokenTypeAtom)
			},
			@"\\neq" : @{
				Type: @(KTXPTokenTypeAtom)
			},
			@"\\newline" : @{
				Type: @(KTXPTokenTypeAtom)
			},
			@"\\nexists" : @{
				Type: @(KTXPTokenTypeAtom)
			},
			@"\\ngeq" : @{
				Type: @(KTXPTokenTypeAtom)
			},
			@"\\ngeqq" : @{
				Type: @(KTXPTokenTypeAtom)
			},
			@"\\ngeqslant" : @{
				Type: @(KTXPTokenTypeAtom)
			},
			@"\\ngtr" : @{
				Type: @(KTXPTokenTypeAtom)
			},
			@"\\ni" : @{
				Type: @(KTXPTokenTypeAtom)
			},
			@"\\nleftarrow" : @{
				Type: @(KTXPTokenTypeAtom)
			},
			@"\\nLeftrightarrow" : @{
				Type: @(KTXPTokenTypeAtom)
			},
			@"\\nleftrightarrow" : @{
				Type: @(KTXPTokenTypeAtom)
			},
			@"\\nleq" : @{
				Type: @(KTXPTokenTypeAtom)
			},
			@"\\nleqq" : @{
				Type: @(KTXPTokenTypeAtom)
			},
			@"\\nleqslant" : @{
				Type: @(KTXPTokenTypeAtom)
			},
			@"\\nless" : @{
				Type: @(KTXPTokenTypeAtom)
			},
			@"\\nmid" : @{
				Type: @(KTXPTokenTypeAtom)
			},
			@"\\nobreak" : @{
				Type: @(KTXPTokenTypeAtom)
			},
			@"\\nobreakspace" : @{
				Type: @(KTXPTokenTypeAtom)
			},
			@"\\noexpand" : @{
				Type: @(KTXPTokenTypeAtom)
			},
			@"\\nolimits" : @{
				Type: @(KTXPTokenTypeAtom)
			},
			@"\\nonumber" : @{
				Type: @(KTXPTokenTypeAtom)
			},
			@"\\normalsize" : @{
				Type: @(KTXPTokenTypeFunction)
			},
			@"\\not" : @{
				Type: @(KTXPTokenTypeAtom)
			},
			@"\\notag" : @{
				Type: @(KTXPTokenTypeAtom)
			},
			@"\\notin" : @{
				Type: @(KTXPTokenTypeAtom)
			},
			@"\\notni" : @{
				Type: @(KTXPTokenTypeAtom)
			},
			@"\\nparallel" : @{
				Type: @(KTXPTokenTypeAtom)
			},
			@"\\nprec" : @{
				Type: @(KTXPTokenTypeAtom)
			},
			@"\\npreceq" : @{
				Type: @(KTXPTokenTypeAtom)
			},
			@"\\nRightarrow" : @{
				Type: @(KTXPTokenTypeAtom)
			},
			@"\\nrightarrow" : @{
				Type: @(KTXPTokenTypeAtom)
			},
			@"\\nshortmid" : @{
				Type: @(KTXPTokenTypeAtom)
			},
			@"\\nshortparallel" : @{
				Type: @(KTXPTokenTypeAtom)
			},
			@"\\nsim" : @{
				Type: @(KTXPTokenTypeAtom)
			},
			@"\\nsubseteq" : @{
				Type: @(KTXPTokenTypeAtom)
			},
			@"\\nsubseteqq" : @{
				Type: @(KTXPTokenTypeAtom)
			},
			@"\\nsucc" : @{
				Type: @(KTXPTokenTypeAtom)
			},
			@"\\nsucceq" : @{
				Type: @(KTXPTokenTypeAtom)
			},
			@"\\nsupseteq" : @{
				Type: @(KTXPTokenTypeAtom)
			},
			@"\\nsupseteqq" : @{
				Type: @(KTXPTokenTypeAtom)
			},
			@"\\ntriangleleft" : @{
				Type: @(KTXPTokenTypeAtom)
			},
			@"\\ntrianglelefteq" : @{
				Type: @(KTXPTokenTypeAtom)
			},
			@"\\ntriangleright" : @{
				Type: @(KTXPTokenTypeAtom)
			},
			@"\\ntrianglerighteq" : @{
				Type: @(KTXPTokenTypeAtom)
			},
			@"\\Nu" : @{
				Type: @(KTXPTokenTypeAtom)
			},
			@"\\nu" : @{
				Type: @(KTXPTokenTypeAtom)
			},
			@"\\nVDash" : @{
				Type: @(KTXPTokenTypeAtom)
			},
			@"\\nVdash" : @{
				Type: @(KTXPTokenTypeAtom)
			},
			@"\\nvDash" : @{
				Type: @(KTXPTokenTypeAtom)
			},
			@"\\nvdash" : @{
				Type: @(KTXPTokenTypeAtom)
			},
			@"\\nwarrow" : @{
				Type: @(KTXPTokenTypeAtom)
			},
			
			// O
			@"\\odot" : @{
				Type: @(KTXPTokenTypeAtom)
			},
			@"\\oiiint" : @{
				Type: @(KTXPTokenTypeAtom)
			},
			@"\\oiint" : @{
				Type: @(KTXPTokenTypeAtom)
			},
			@"\\oint" : @{
				Type: @(KTXPTokenTypeAtom)
			},
			@"\\omega" : @{
				Type: @(KTXPTokenTypeAtom)
			},
			@"\\Omega" : @{
				Type: @(KTXPTokenTypeAtom)
			},
			@"\\Omicron" : @{
				Type: @(KTXPTokenTypeAtom)
			},
			@"\\omicron" : @{
				Type: @(KTXPTokenTypeAtom)
			},
			@"\\ominus" : @{
				Type: @(KTXPTokenTypeAtom)
			},
			@"\\oplus" : @{
				Type: @(KTXPTokenTypeAtom)
			},
			@"\\origof" : @{
				Type: @(KTXPTokenTypeAtom)
			},
			@"\\oslash" : @{
				Type: @(KTXPTokenTypeAtom)
			},
			@"\\otimes" : @{
				Type: @(KTXPTokenTypeAtom)
			},
			@"\\over" : @{
				// Puts whats prior to this macro in the numerator of a fraction and puts whats after into the denominator.
				// You can also limit it to within a group.
				Type: @(KTXPTokenTypeSpecialFunction),
				SpecialKind: @(KTXPMacroTypePrePost)
			},
			@"\\overbrace" : @{
				// Requires an atom/group after and ^ optionally after.
				Type: @(KTXPTokenTypeSpecialFunction),
				Args: @(1)
			},
			@"\\overgroup" : @{
				Type: @(KTXPTokenTypeFunction)
			},
			@"\\overleftarrow" : @{
				Type: @(KTXPTokenTypeFunction)
			},
			@"\\overleftharpoon" : @{
				Type: @(KTXPTokenTypeFunction)
			},
			@"\\overleftrightarrow" : @{
				Type: @(KTXPTokenTypeFunction)
			},
			@"\\overline" : @{
				Type: @(KTXPTokenTypeFunction)
			},
			@"\\overlinesegment" : @{
				Type: @(KTXPTokenTypeFunction)
			},
			@"\\Overrightarrow" : @{
				Type: @(KTXPTokenTypeFunction)
			},
			@"\\overrightarrow" : @{
				Type: @(KTXPTokenTypeFunction)
			},
			@"\\overrightharpoon" : @{
				Type: @(KTXPTokenTypeFunction)
			},
			@"\\overset" : @{
				Type: @(KTXPTokenTypeFunction),
				Args: @(2)
			},
			@"\\owns" : @{
				Type: @(KTXPTokenTypeAtom)
			},
			
			// P
			@"\\parallel" : @{
				Type: @(KTXPTokenTypeAtom)
			},
			@"\\partial" : @{
				Type: @(KTXPTokenTypeAtom)
			},
			@"\\perp" : @{
				Type: @(KTXPTokenTypeAtom)
			},
			@"\\phantom" : @{
				Type: @(KTXPTokenTypeFunction)
			},
			@"\\phase" : @{
				Type: @(KTXPTokenTypeFunction)
			},
			@"\\Phi" : @{
				Type: @(KTXPTokenTypeAtom)
			},
			@"\\phi" : @{
				Type: @(KTXPTokenTypeAtom)
			},
			@"\\Pi" : @{
				Type: @(KTXPTokenTypeAtom)
			},
			@"\\pi" : @{
				Type: @(KTXPTokenTypeAtom)
			},
			@"\\pitchfork" : @{
				Type: @(KTXPTokenTypeAtom)
			},
			@"\\plim" : @{
				Type: @(KTXPTokenTypeMathOp)
			},
			@"\\plusmn" : @{
				Type: @(KTXPTokenTypeAtom)
			},
			@"\\pm" : @{
				Type: @(KTXPTokenTypeAtom)
			},
			@"\\pmb" : @{
				Type: @(KTXPTokenTypeFunction)
			},
			@"\\pmod" : @{
				Type: @(KTXPTokenTypeFunction)
			},
			@"\\pod" : @{
				Type: @(KTXPTokenTypeFunction)
			},
			@"\\pounds" : @{
				Type: @(KTXPTokenTypeAtom)
			},
			@"\\Pr" : @{
				Type: @(KTXPTokenTypeMathOp)
			},
			@"\\prec" : @{
				Type: @(KTXPTokenTypeAtom)
			},
			@"\\precapprox" : @{
				Type: @(KTXPTokenTypeAtom)
			},
			@"\\preccurlyeq" : @{
				Type: @(KTXPTokenTypeAtom)
			},
			@"\\precneqq" : @{
				Type: @(KTXPTokenTypeAtom)
			},
			@"\\precnsim" : @{
				Type: @(KTXPTokenTypeAtom)
			},
			@"\\precsim" : @{
				Type: @(KTXPTokenTypeAtom)
			},
			@"\\prime" : @{
				Type: @(KTXPTokenTypeAtom)
			},
			@"\\prod" : @{
				Type: @(KTXPTokenTypeAtom)
			},
			@"\\projlim" : @{
				Type: @(KTXPTokenTypeMathOp)
			},
			@"\\propto" : @{
				Type: @(KTXPTokenTypeAtom)
			},
			@"\\psi" : @{
				Type: @(KTXPTokenTypeAtom)
			},
			@"\\Psi" : @{
				Type: @(KTXPTokenTypeAtom)
			},
			@"\\pu" : @{
				Type: @(KTXPTokenTypeAtom)
			},
			
			// QR
			@"\\qquad" : @{
				Type: @(KTXPTokenTypeAtom)
			},
			@"\\quad" : @{
				Type: @(KTXPTokenTypeAtom)
			},
			@"\\R" : @{
				Type: @(KTXPTokenTypeAtom)
			},
			@"\\raisebox" : @{
				Type: @(KTXPTokenTypeFunction),
				Args: @(2)
			},
			@"\\rang" : @{
				Type: @(KTXPTokenTypeAtom)
			},
			@"\\rangle" : @{
				Type: @(KTXPTokenTypeAtom)
			},
			@"\\Rarr" : @{
				Type: @(KTXPTokenTypeAtom)
			},
			@"\\rarr" : @{
				Type: @(KTXPTokenTypeAtom)
			},
			@"\\ratio" : @{
				Type: @(KTXPTokenTypeAtom)
			},
			@"\\rBrace" : @{
				Type: @(KTXPTokenTypeAtom)
			},
			@"\\rbrace" : @{
				Type: @(KTXPTokenTypeAtom)
			},
			@"\\rbrack" : @{
				Type: @(KTXPTokenTypeAtom)
			},
			@"\\rceil" : @{
				Type: @(KTXPTokenTypeAtom)
			},
			@"\\Re" : @{
				Type: @(KTXPTokenTypeAtom)
			},
			@"\\real" : @{
				Type: @(KTXPTokenTypeAtom)
			},
			@"\\Reals" : @{
				Type: @(KTXPTokenTypeAtom)
			},
			@"\\reals" : @{
				Type: @(KTXPTokenTypeAtom)
			},
			@"\\relax" : @{
				Type: @(KTXPTokenTypeAtom)
			},
			@"\\restriction" : @{
				Type: @(KTXPTokenTypeAtom)
			},
			@"\\rfloor" : @{
				Type: @(KTXPTokenTypeAtom)
			},
			@"\\rgroup" : @{
				Type: @(KTXPTokenTypeAtom)
			},
			@"\\rhd" : @{
				Type: @(KTXPTokenTypeAtom)
			},
			@"\\Rho" : @{
				Type: @(KTXPTokenTypeAtom)
			},
			@"\\rho" : @{
				Type: @(KTXPTokenTypeAtom)
			},
			@"\\right" : @{
				Type: @(KTXPTokenTypeFunction),
				SpecialKind: @(KTXPMacroTypeGroupClose)
			},
			@"\\Rightarrow" : @{
				Type: @(KTXPTokenTypeAtom)
			},
			@"\\rightarrow" : @{
				Type: @(KTXPTokenTypeAtom)
			},
			@"\\rightarrowtail" : @{
				Type: @(KTXPTokenTypeAtom)
			},
			@"\\rightharpoondown" : @{
				Type: @(KTXPTokenTypeAtom)
			},
			@"\\rightharpoonup" : @{
				Type: @(KTXPTokenTypeAtom)
			},
			@"\\rightleftarrows" : @{
				Type: @(KTXPTokenTypeAtom)
			},
			@"\\rightleftharpoons" : @{
				Type: @(KTXPTokenTypeAtom)
			},
			@"\\rightrightarrows" : @{
				Type: @(KTXPTokenTypeAtom)
			},
			@"\\rightsquigarrow" : @{
				Type: @(KTXPTokenTypeAtom)
			},
			@"\\rightthreetimes" : @{
				Type: @(KTXPTokenTypeAtom)
			},
			@"\\risingdotseq" : @{
				Type: @(KTXPTokenTypeAtom)
			},
			@"\\rlap" : @{
				// Makes a right overlap.
				// The arg is basically any macro.
				// This makes a box thats zero width around the arg.
				// Then everything after it is rendered under the arg.
				// This is a special function becuase it affects whatever is
				// to the right of it, though in practice this appears normal.
				// \rlap{/}{=}
				Type: @(KTXPTokenTypeSpecialFunction),
				Args: @(2)
			},
			@"\\rm" : @{
				Type: @(KTXPTokenTypeFunction)
			},
			@"\\rmoustache" : @{
				Type: @(KTXPTokenTypeAtom)
			},
			@"\\rparen" : @{
				Type: @(KTXPTokenTypeAtom)
			},
			@"\\rq" : @{
				Type: @(KTXPTokenTypeAtom)
			},
			@"\\rrbracket" : @{
				Type: @(KTXPTokenTypeAtom)
			},
			@"\\Rrightarrow" : @{
				Type: @(KTXPTokenTypeAtom)
			},
			@"\\Rsh" : @{
				Type: @(KTXPTokenTypeAtom)
			},
			@"\\rtimes" : @{
				Type: @(KTXPTokenTypeAtom)
			},
			/* DISABLED
			@"\\rule" : @{
				Type: @(KTXPTokenTypeSpecialFunction)
			},*/
			@"\\rVert" : @{
				Type: @(KTXPTokenTypeAtom)
			},
			@"\\rvert" : @{
				Type: @(KTXPTokenTypeAtom)
			},
			
			// S
			@"\\scriptscriptstyle" : @{
				Type: @(KTXPTokenTypeFunction)
			},
			@"\\scriptsize" : @{
				Type: @(KTXPTokenTypeFunction)
			},
			@"\\scriptstyle" : @{
				Type: @(KTXPTokenTypeFunction)
			},
			@"\\sdot" : @{
				Type: @(KTXPTokenTypeAtom)
			},
			@"\\searrow" : @{
				Type: @(KTXPTokenTypeAtom)
			},
			@"\\sec" : @{
				Type: @(KTXPTokenTypeMathOp)
			},
			@"\\set" : @{
				Type: @(KTXPTokenTypeFunction)
			},
			@"\\Set" : @{
				Type: @(KTXPTokenTypeFunction)
			},
			@"\\setminus" : @{
				Type: @(KTXPTokenTypeAtom)
			},
			@"\\sf" : @{
				Type: @(KTXPTokenTypeFunction)
			},
			@"\\sharp" : @{
				Type: @(KTXPTokenTypeAtom)
			},
			@"\\shortmid" : @{
				Type: @(KTXPTokenTypeAtom)
			},
			@"\\shotparallel" : @{
				Type: @(KTXPTokenTypeAtom)
			},
			@"\\Sigma" : @{
				Type: @(KTXPTokenTypeAtom)
			},
			@"\\sigma" : @{
				Type: @(KTXPTokenTypeAtom)
			},
			@"\\sim" : @{
				Type: @(KTXPTokenTypeAtom)
			},
			@"\\simcolon" : @{
				Type: @(KTXPTokenTypeAtom)
			},
			@"\\simcoloncolon" : @{
				Type: @(KTXPTokenTypeAtom)
			},
			@"\\simeq" : @{
				Type: @(KTXPTokenTypeAtom)
			},
			@"\\sin" : @{
				Type: @(KTXPTokenTypeMathOp)
			},
			@"\\sinh" : @{
				Type: @(KTXPTokenTypeMathOp)
			},
			@"\\sixptsize" : @{
				Type: @(KTXPTokenTypeFunction)
			},
			@"\\sh" : @{
				Type: @(KTXPTokenTypeMathOp)
			},
			@"\\small" : @{
				Type: @(KTXPTokenTypeFunction)
			},
			@"\\smallfrown" : @{
				Type: @(KTXPTokenTypeAtom)
			},
			@"\\smallint" : @{
				Type: @(KTXPTokenTypeAtom)
			},
			@"\\smallsetminus" : @{
				Type: @(KTXPTokenTypeAtom)
			},
			@"\\smallsmile" : @{
				Type: @(KTXPTokenTypeAtom)
			},
			@"\\smash" : @{
				Type: @(KTXPTokenTypeFunction)
			},
			@"\\smile" : @{
				Type: @(KTXPTokenTypeAtom)
			},
			@"\\sout" : @{
				Type: @(KTXPTokenTypeFunction)
			},
			@"\\space" : @{
				Type: @(KTXPTokenTypeAtom)
			},
			@"\\spades" : @{
				Type: @(KTXPTokenTypeAtom)
			},
			@"\\spadesuit" : @{
				Type: @(KTXPTokenTypeAtom)
			},
			@"\\sphericalangle" : @{
				Type: @(KTXPTokenTypeAtom)
			},
			@"\\sqcap" : @{
				Type: @(KTXPTokenTypeAtom)
			},
			@"\\sqcup" : @{
				Type: @(KTXPTokenTypeAtom)
			},
			@"\\square" : @{
				Type: @(KTXPTokenTypeAtom)
			},
			@"\\sqrt" : @{
				// Makes a square root with with atom/group given.
				// You can also enclose some expressions within [] before the argument to make it that power.
				Type: @(KTXPTokenTypeSpecialFunction),
				Args: @(1),
				SpecialKind:@(KTXPMacroTypeNone)
			},
			@"\\sqsubset" : @{
				Type: @(KTXPTokenTypeAtom)
			},
			@"\\sqsubseteq" : @{
				Type: @(KTXPTokenTypeAtom)
			},
			@"\\sqsupset" : @{
				Type: @(KTXPTokenTypeAtom)
			},
			@"\\sqsupseteq" : @{
				Type: @(KTXPTokenTypeAtom)
			},
			@"\\stackrel" : @{
				Type: @(KTXPTokenTypeFunction),
				Args: @(2)
			},
			@"\\star" : @{
				Type: @(KTXPTokenTypeAtom)
			},
			@"\\sub" : @{
				Type: @(KTXPTokenTypeAtom)
			},
			@"\\sube" : @{
				Type: @(KTXPTokenTypeAtom)
			},
			@"\\Subset" : @{
				Type: @(KTXPTokenTypeAtom)
			},
			@"\\subseteq" : @{
				Type: @(KTXPTokenTypeAtom)
			},
			@"\\subseteqq" : @{
				Type: @(KTXPTokenTypeAtom)
			},
			@"\\subsetneq" : @{
				Type: @(KTXPTokenTypeAtom)
			},
			@"\\subsetneqq" : @{
				Type: @(KTXPTokenTypeAtom)
			},
			@"\\substack" : @{
				Type: @(KTXPTokenTypeFunction)
			},
			@"\\succ" : @{
				Type: @(KTXPTokenTypeAtom)
			},
			@"\\succapprox" : @{
				Type: @(KTXPTokenTypeAtom)
			},
			@"\\succcurlyeq" : @{
				Type: @(KTXPTokenTypeAtom)
			},
			@"\\succeq" : @{
				Type: @(KTXPTokenTypeAtom)
			},
			@"\\succnapprox" : @{
				Type: @(KTXPTokenTypeAtom)
			},
			@"\\succneqq" : @{
				Type: @(KTXPTokenTypeAtom)
			},
			@"\\succnsim" : @{
				Type: @(KTXPTokenTypeAtom)
			},
			@"\\succsim" : @{
				Type: @(KTXPTokenTypeAtom)
			},
			@"\\sum" : @{
				Type: @(KTXPTokenTypeAtom)
			},
			@"\\sup" : @{
				Type: @(KTXPTokenTypeMathOp)
			},
			@"\\supe" : @{
				Type: @(KTXPTokenTypeAtom)
			},
			@"\\Supset" : @{
				Type: @(KTXPTokenTypeAtom)
			},
			@"\\supset" : @{
				Type: @(KTXPTokenTypeAtom)
			},
			@"\\supseteq" : @{
				Type: @(KTXPTokenTypeAtom)
			},
			@"\\supseteqq" : @{
				Type: @(KTXPTokenTypeAtom)
			},
			@"\\supsetneq" : @{
				Type: @(KTXPTokenTypeAtom)
			},
			@"\\supsurd" : @{
				Type: @(KTXPTokenTypeAtom)
			},
			@"\\swarrow" : @{
				Type: @(KTXPTokenTypeAtom)
			},
			
			// T
			@"\\tag" : @{
				Type: @(KTXPTokenTypeFunction)
			},
			@"tag*" : @{
				Type: @(KTXPTokenTypeFunction)
			},
			@"\\tan" : @{
				Type: @(KTXPTokenTypeMathOp)
			},
			@"\\tanh" : @{
				Type: @(KTXPTokenTypeMathOp)
			},
			@"\\Tau" : @{
				Type: @(KTXPTokenTypeAtom)
			},
			@"\\tau" : @{
				Type: @(KTXPTokenTypeAtom)
			},
			@"\\tbinom" : @{
				Type: @(KTXPTokenTypeFunction),
				Args: @(2)
			},
			@"\\TeX" : @{
				Type: @(KTXPTokenTypeAtom)
			},
			@"\\text" : @{
				// Toggles to text mode.
				// FIXME: Make it so the other text mode toggles work, right now they do nothing.
				Type: @(KTXPTokenTypeFunction)
			},
			@"\\textbf" : @{
				// Toggles to bold text mode.
				Type: @(KTXPTokenTypeFunction)
			},
			@"\\textcolor" : @{
				Type: @(KTXPTokenTypeFunction),
				Args: @(2)
			},
			@"\\textit" : @{
				// Toggles to italic text mode.
				Type: @(KTXPTokenTypeFunction)
			},
			@"\\textmd" : @{
				// Toggles to text mode.
				Type: @(KTXPTokenTypeFunction)
			},
			@"\\textnormal" : @{
				// Toggles to text mode.
				Type: @(KTXPTokenTypeFunction)
			},
			@"\\textrm" : @{
				// Toggles to text mode.
				Type: @(KTXPTokenTypeFunction)
			},
			@"\\textsf" : @{
				// Toggles to text mode.
				Type: @(KTXPTokenTypeFunction)
			},
			@"\\textstyle" : @{
				// A command that switches the render mode from hence it's parsed.
				// You can also limit it to within a group.
				Type: @(KTXPTokenTypeSpecialFunction),
				SpecialKind: @(KTXPMacroTypePost)
			},
			@"\\texttt" : @{
				// Toggles to typewriter text mode.
				Type: @(KTXPTokenTypeFunction)
			},
			@"\\textup" : @{
				// Toggles to text mode.
				Type: @(KTXPTokenTypeFunction)
			},
			@"\\tfrac" : @{
				// Works like \frac but is tiny.
				Type: @(KTXPTokenTypeFunction),
				Args: @(2)
			},
			@"\\tg" : @{
				Type: @(KTXPTokenTypeMathOp)
			},
			@"\\th" : @{
				Type: @(KTXPTokenTypeMathOp)
			},
			@"\\therefore" : @{
				Type: @(KTXPTokenTypeAtom)
			},
			@"\\Theta" : @{
				Type: @(KTXPTokenTypeAtom)
			},
			@"\\theta" : @{
				Type: @(KTXPTokenTypeAtom)
			},
			@"\\thetasym" : @{
				Type: @(KTXPTokenTypeAtom)
			},
			@"\\thickapprox" : @{
				Type: @(KTXPTokenTypeAtom)
			},
			@"\\thicksim" : @{
				Type: @(KTXPTokenTypeAtom)
			},
			@"\\thickspace" : @{
				Type: @(KTXPTokenTypeAtom)
			},
			@"\\thinspace" : @{
				Type: @(KTXPTokenTypeAtom)
			},
			@"\\tilde" : @{
				Type: @(KTXPTokenTypeFunction)
			},
			@"\\times" : @{
				Type: @(KTXPTokenTypeAtom)
			},
			@"\\tiny" : @{
				Type: @(KTXPTokenTypeFunction)
			},
			@"\\to" : @{
				Type: @(KTXPTokenTypeAtom)
			},
			@"\\top" : @{
				Type: @(KTXPTokenTypeAtom)
			},
			@"\\triangle" : @{
				Type: @(KTXPTokenTypeAtom)
			},
			@"\\triangledown" : @{
				Type: @(KTXPTokenTypeAtom)
			},
			@"\\triangleleft" : @{
				Type: @(KTXPTokenTypeAtom)
			},
			@"\\trianglelefteq" : @{
				Type: @(KTXPTokenTypeAtom)
			},
			@"\\triangleq" : @{
				Type: @(KTXPTokenTypeAtom)
			},
			@"\\triangleright" : @{
				Type: @(KTXPTokenTypeAtom)
			},
			@"\\trianglerighteq" : @{
				Type: @(KTXPTokenTypeAtom)
			},
			@"\\tt" : @{
				// A command that switches the render mode from hence it's parsed.
				// You can also limit it to within a group.
				Type: @(KTXPTokenTypeSpecialFunction),
				SpecialKind: @(KTXPMacroTypePost)
			},
			@"\\twoheadleftarrow" : @{
				Type: @(KTXPTokenTypeAtom)
			},
			@"\\twoheadrightarrow" : @{
				Type: @(KTXPTokenTypeAtom)
			},
			
			// U
			@"\\Uarr" : @{
				Type: @(KTXPTokenTypeAtom)
			},
			@"\\uArr" : @{
				Type: @(KTXPTokenTypeAtom)
			},
			@"\\uarr" : @{
				Type: @(KTXPTokenTypeAtom)
			},
			@"\\ulcorner" : @{
				Type: @(KTXPTokenTypeAtom)
			},
			@"\\underbar" : @{
				Type: @(KTXPTokenTypeFunction)
			},
			@"\\underbrace" : @{
				// Requires an atom/group after and _ optionally after.
				Type: @(KTXPTokenTypeSpecialFunction),
				Args: @(1)
			},
			@"\\undergroup" : @{
				Type: @(KTXPTokenTypeFunction)
			},
			@"\\underleftarrow" : @{
				Type: @(KTXPTokenTypeFunction)
			},
			@"\\underleftrightarrow" : @{
				Type: @(KTXPTokenTypeFunction)
			},
			@"\\underrightarrow" : @{
				Type: @(KTXPTokenTypeFunction)
			},
			@"\\underline" : @{
				Type: @(KTXPTokenTypeFunction)
			},
			@"\\underlinesegment" : @{
				Type: @(KTXPTokenTypeFunction)
			},
			@"\\underset" : @{
				Type: @(KTXPTokenTypeFunction),
				Args: @(2)
			},
			@"\\unlhd" : @{
				Type: @(KTXPTokenTypeAtom)
			},
			@"\\unrhd" : @{
				Type: @(KTXPTokenTypeAtom)
			},
			@"\\Uparrow" : @{
				Type: @(KTXPTokenTypeAtom)
			},
			@"\\uparrow" : @{
				Type: @(KTXPTokenTypeAtom)
			},
			@"\\Updownarrow" : @{
				Type: @(KTXPTokenTypeAtom)
			},
			@"\\updownarrow" : @{
				Type: @(KTXPTokenTypeAtom)
			},
			@"\\upharpoonleft" : @{
				Type: @(KTXPTokenTypeAtom)
			},
			@"\\upharpoonright" : @{
				Type: @(KTXPTokenTypeAtom)
			},
			@"\\uplus" : @{
				Type: @(KTXPTokenTypeAtom)
			},
			@"\\Upsilon" : @{
				Type: @(KTXPTokenTypeAtom)
			},
			@"\\upsilon" : @{
				Type: @(KTXPTokenTypeAtom)
			},
			@"\\upuparrows" : @{
				Type: @(KTXPTokenTypeAtom)
			},
			@"\\urcorner" : @{
				Type: @(KTXPTokenTypeAtom)
			},
			@"\\url" : @{
				Type: @(KTXPTokenTypeFunction)
			},
			@"\\utilde" : @{
				Type: @(KTXPTokenTypeFunction)
			},
			
			// V
			@"\\varDelta" : @{
				Type: @(KTXPTokenTypeAtom)
			},
			@"\\varepsilon" : @{
				Type: @(KTXPTokenTypeAtom)
			},
			@"\\varGamma" : @{
				Type: @(KTXPTokenTypeAtom)
			},
			@"\\varinjlim" : @{
				Type: @(KTXPTokenTypeMathOp)
			},
			@"\\varkappa" : @{
				Type: @(KTXPTokenTypeAtom)
			},
			@"\\varLambda" : @{
				Type: @(KTXPTokenTypeAtom)
			},
			@"\\varliminf" : @{
				Type: @(KTXPTokenTypeMathOp)
			},
			@"\\varlimsup" : @{
				Type: @(KTXPTokenTypeMathOp)
			},
			@"\\varnothing" : @{
				Type: @(KTXPTokenTypeAtom)
			},
			@"\\varOmega" : @{
				Type: @(KTXPTokenTypeAtom)
			},
			@"\\varPhi" : @{
				Type: @(KTXPTokenTypeAtom)
			},
			@"\\varphi" : @{
				Type: @(KTXPTokenTypeAtom)
			},
			@"\\varPi" : @{
				Type: @(KTXPTokenTypeAtom)
			},
			@"\\varpi" : @{
				Type: @(KTXPTokenTypeAtom)
			},
			@"\\varprojlim" : @{
				Type: @(KTXPTokenTypeMathOp)
			},
			@"\\varpropto" : @{
				Type: @(KTXPTokenTypeAtom)
			},
			@"\\varPsi" : @{
				Type: @(KTXPTokenTypeAtom)
			},
			@"\\varho" : @{
				Type: @(KTXPTokenTypeAtom)
			},
			@"\\varSigma" : @{
				Type: @(KTXPTokenTypeAtom)
			},
			@"\\varsigma" : @{
				Type: @(KTXPTokenTypeAtom)
			},
			@"\\varstigma" : @{
				Type: @(KTXPTokenTypeAtom)
			},
			@"\\varsubsetneq" : @{
				Type: @(KTXPTokenTypeAtom)
			},
			@"\\varsubsetneqq" : @{
				Type: @(KTXPTokenTypeAtom)
			},
			@"\\varsupsetneq" : @{
				Type: @(KTXPTokenTypeAtom)
			},
			@"\\varsupsetneqq" : @{
				Type: @(KTXPTokenTypeAtom)
			},
			@"\\varTheta" : @{
				Type: @(KTXPTokenTypeAtom)
			},
			@"\\vartheta" : @{
				Type: @(KTXPTokenTypeAtom)
			},
			@"\\vartriangle" : @{
				Type: @(KTXPTokenTypeAtom)
			},
			@"\\vartriangleleft" : @{
				Type: @(KTXPTokenTypeAtom)
			},
			@"\\vartriangleright" : @{
				Type: @(KTXPTokenTypeAtom)
			},
			@"\\varUpsilon" : @{
				Type: @(KTXPTokenTypeAtom)
			},
			@"\\varXi" : @{
				Type: @(KTXPTokenTypeAtom)
			},
			@"\\varcentcolon" : @{
				Type: @(KTXPTokenTypeFunction)
			},
			@"\\vcenter" : @{
				Type: @(KTXPTokenTypeFunction)
			},
			@"\\Vdash" : @{
				Type: @(KTXPTokenTypeAtom)
			},
			@"\\vDash" : @{
				Type: @(KTXPTokenTypeAtom)
			},
			@"\\vdash" : @{
				Type: @(KTXPTokenTypeAtom)
			},
			@"\\vdots" : @{
				Type: @(KTXPTokenTypeAtom)
			},
			@"\\vec" : @{
				Type: @(KTXPTokenTypeFunction)
			},
			@"\\vee" : @{
				Type: @(KTXPTokenTypeAtom)
			},
			@"\\veebar" : @{
				Type: @(KTXPTokenTypeAtom)
			},
			@"\\verb" : @{
				// Takes the arguments and literally types it out as text. Means verbatim.
				// Needs a delimiting character both before and after the argument.
				// Delim is a single character that is some set that I don't know.
				// Usual delims are {(|})|.*-~_
				// The argument is just literally displayed as text, not executed.
				// Linebreaks are not allowed.
				Type: @(KTXPTokenTypeSpecialFunction),
				Args: @(1)
			},
			@"\\Vert" : @{
				Type: @(KTXPTokenTypeAtom)
			},
			@"\\vert" : @{
				Type: @(KTXPTokenTypeAtom)
			},
			@"\\vphantom" : @{
				Type: @(KTXPTokenTypeFunction)
			},
			@"\\Vvdash" : @{
				Type: @(KTXPTokenTypeAtom)
			},
			
			// W
			@"\\wedge" : @{
				Type: @(KTXPTokenTypeAtom)
			},
			@"\\weierp" : @{
				Type: @(KTXPTokenTypeAtom)
			},
			@"\\widecheck" : @{
				Type: @(KTXPTokenTypeFunction)
			},
			@"\\widehat" : @{
				Type: @(KTXPTokenTypeFunction)
			},
			@"\\wideparen" : @{
				Type: @(KTXPTokenTypeFunction)
			},
			@"\\widetilde" : @{
				Type: @(KTXPTokenTypeFunction)
			},
			@"\\wp" : @{
				Type: @(KTXPTokenTypeAtom)
			},
			@"\\wr" : @{
				Type: @(KTXPTokenTypeAtom)
			},
			
			// X
			@"\\xcancel" : @{
				Type: @(KTXPTokenTypeFunction)
			},
			@"\\Xi" : @{
				Type: @(KTXPTokenTypeAtom)
			},
			@"\\xi" : @{
				Type: @(KTXPTokenTypeAtom)
			},
			@"\\xhookleftarrow" : @{
				Type: @(KTXPTokenTypeFunction)
			},
			@"\\xhookrightarrow" : @{
				Type: @(KTXPTokenTypeFunction)
			},
			@"\\xLeftarrow" : @{
				Type: @(KTXPTokenTypeFunction)
			},
			@"\\xleftarrow" : @{
				Type: @(KTXPTokenTypeFunction)
			},
			@"\\xleftharpoondown" : @{
				Type: @(KTXPTokenTypeFunction)
			},
			@"\\xleftharpoonup" : @{
				Type: @(KTXPTokenTypeFunction)
			},
			@"\\xLeftrightarrow" : @{
				Type: @(KTXPTokenTypeFunction)
			},
			@"\\xleftrightarrow" : @{
				Type: @(KTXPTokenTypeFunction)
			},
			@"\\xleftrightharpoons" : @{
				Type: @(KTXPTokenTypeFunction)
			},
			@"\\xlongequal" : @{
				Type: @(KTXPTokenTypeFunction)
			},
			@"\\xmapsto" : @{
				Type: @(KTXPTokenTypeFunction)
			},
			@"\\xRightarrow" : @{
				Type: @(KTXPTokenTypeFunction)
			},
			@"\\xrightarrow" : @{
				Type: @(KTXPTokenTypeFunction)
			},
			@"\\xrightharpoondown" : @{
				Type: @(KTXPTokenTypeFunction)
			},
			@"\\xrightharpoonup" : @{
				Type: @(KTXPTokenTypeFunction)
			},
			@"\\xtofrom" : @{
				Type: @(KTXPTokenTypeFunction)
			},
			@"\\xtwoheadleftarrow" : @{
				Type: @(KTXPTokenTypeFunction)
			},
			@"\\xtwoheadrightarrow" : @{
				Type: @(KTXPTokenTypeFunction)
			},
			
			// YZ
			@"\\yen" : @{
				Type: @(KTXPTokenTypeAtom)
			},
			@"\\Z" : @{
				Type: @(KTXPTokenTypeAtom)
			},
			@"\\Zeta" : @{
				Type: @(KTXPTokenTypeAtom)
			},
			@"\\zeta" : @{
				Type: @(KTXPTokenTypeAtom)
			}

		};
		
		_TEXT_SYMBOLS = @{
			// Symbols
			@"\\'" : @{
				Type: @(KTXPTokenTypeFunction),
				Args: @(1)
			},
			@"\\\"" : @{
				Type: @(KTXPTokenTypeFunction),
				Args: @(1)
			},
			@"\\(" : @{
				Type: @(KTXPTokenTypeGroupOpen)
			},
			@"\\)" : @{
				Type: @(KTXPTokenTypeGroupClose)
			},
			@"\\." : @{
				Type: @(KTXPTokenTypeWhitespace)
			},
			@"\\`" : @{
				Type: @(KTXPTokenTypeFunction),
				Args: @(1)
			},
			@"\\=" : @{
				Type: @(KTXPTokenTypeFunction),
				Args: @(1)
			},
			@"\\~" : @{
				Type: @(KTXPTokenTypeFunction),
				Args: @(1)
			},
			@"\\^" : @{
				Type: @(KTXPTokenTypeFunction),
				Args: @(1)
			},
			
			// A
			@"\\AA" : @{
				Type: @(KTXPTokenTypeAtom)
			},
			@"\\aa" : @{
				Type: @(KTXPTokenTypeAtom)
			},
			@"\\AE" : @{
				Type: @(KTXPTokenTypeAtom)
			},
			@"\\ae" : @{
				Type: @(KTXPTokenTypeAtom)
			},
			@"\\alef" : @{
				Type: @(KTXPTokenTypeAtom)
			},
			@"\\alefsym" : @{
				Type: @(KTXPTokenTypeAtom)
			},
			@"\\aleph" : @{
				Type: @(KTXPTokenTypeAtom)
			},
			
			// H
			@"\\H" : @{
				Type: @(KTXPTokenTypeFunction),
				Args: @(1)
			},
			
			// I
			@"\\i" : @{
				Type: @(KTXPTokenTypeAtom)
			},
			
			// JK
			@"\\j" : @{
				Type: @(KTXPTokenTypeAtom)
			},
			
			// O
			@"\\O" : @{
				Type: @(KTXPTokenTypeAtom)
			},
			@"\\o" : @{
				Type: @(KTXPTokenTypeAtom)
			},
			@"\\OE" : @{
				Type: @(KTXPTokenTypeAtom)
			},
			@"\\oe" : @{
				Type: @(KTXPTokenTypeAtom)
			},
			
			// P
			@"\\P" : @{
				Type: @(KTXPTokenTypeAtom)
			},
			
			// QR
			@"\\r" : @{
				Type: @(KTXPTokenTypeFunction)
			},
			
			// S
			@"\\S" : @{
				Type: @(KTXPTokenTypeFunction)
			},
			@"\\sect" : @{
				Type: @(KTXPTokenTypeAtom)
			},
			@"\\ss" : @{
				Type: @(KTXPTokenTypeAtom)
			},
			
			// T
			@"\\textasciitilde" : @{
				Type: @(KTXPTokenTypeAtom)
			},
			@"\\textasciicircum" : @{
				Type: @(KTXPTokenTypeAtom)
			},
			@"\\textbackslash" : @{
				Type: @(KTXPTokenTypeAtom)
			},
			@"\\textbar" : @{
				Type: @(KTXPTokenTypeAtom)
			},
			@"\\textbardbl" : @{
				Type: @(KTXPTokenTypeAtom)
			},
			@"\\textbraceleft" : @{
				Type: @(KTXPTokenTypeAtom)
			},
			@"\\textbraceright" : @{
				Type: @(KTXPTokenTypeAtom)
			},
			@"\\textcircled" : @{
				Type: @(KTXPTokenTypeFunction)
			},
			@"\\textdagger" : @{
				Type: @(KTXPTokenTypeAtom)
			},
			@"\\textdaggerdbl" : @{
				Type: @(KTXPTokenTypeAtom)
			},
			@"\\textdegree" : @{
				Type: @(KTXPTokenTypeAtom)
			},
			@"\\textdollar" : @{
				Type: @(KTXPTokenTypeAtom)
			},
			@"\\textellipsis" : @{
				Type: @(KTXPTokenTypeAtom)
			},
			@"\\textemdash" : @{
				Type: @(KTXPTokenTypeAtom)
			},
			@"\\textendash" : @{
				Type: @(KTXPTokenTypeAtom)
			},
			@"\\textgreater" : @{
				Type: @(KTXPTokenTypeAtom)
			},
			@"\\textless" : @{
				Type: @(KTXPTokenTypeAtom)
			},
			@"\\textquotedblleft" : @{
				Type: @(KTXPTokenTypeAtom)
			},
			@"\\textquotedblright" : @{
				Type: @(KTXPTokenTypeAtom)
			},
			@"\\textquoteleft" : @{
				Type: @(KTXPTokenTypeAtom)
			},
			@"\\textquoteright" : @{
				Type: @(KTXPTokenTypeAtom)
			},
			@"\\textregistered" : @{
				Type: @(KTXPTokenTypeAtom)
			},
			@"\\textsterling" : @{
				Type: @(KTXPTokenTypeAtom)
			},
			@"\\textunderscore" : @{
				Type: @(KTXPTokenTypeAtom)
			},
			
			// U
			@"\\u" : @{
				Type: @(KTXPTokenTypeFunction)
			},
			
			// V
			@"\\v" : @{
				Type: @(KTXPTokenTypeFunction)
			}
		};
	}
	
	return self;
}

- (NSDictionary *)lookupLexeme:(NSString *)lexeme inMode:(KTXPParserMode)mode
{
	/* 
	 How do we figure out to use either Macro or Unicode lookup?
	 We don't actually need 2 dictionaries at all.
	 
	 As far as I can tell, Unicode characters basically don't map to functions. There's probably some way that they do, but I haven't really heard of it, nor ran into it.
	 So what we'll do is we just need to make sure that all the supported Macro stuff is in the dictionary and look up that type. If the lexeme doesn't exist in the dictionary, it either isn't supported, doesn't exist, or is a Unicode symbol. In all cases, we'll treat it as an atom.
	 */
	switch(mode)
	{
		case KTXPParserModeMath:
		{
			return [_MATH_SYMBOLS objectForKey:lexeme];
		}
			
		case KTXPParserModeText:
		{
			return [_TEXT_SYMBOLS objectForKey:lexeme];
		}
	}
}

- (NSArray<NSString *> *)MEASUREMENTS
{
	return @[@"bp",
			 @"cc",
			 @"cm",
			 @"dd",
			 @"em",
			 @"ex",
			 @"in",
			 @"mm",
			 @"mu",
			 @"nc",
			 @"nd",
			 @"pc",
			 @"pt",
			 @"sp"];
}

@end
