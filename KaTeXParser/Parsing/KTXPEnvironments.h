//
//  KTXPEnvironments.h
//  KaTeXParser
//
//  Created by Alice Roldán on 6/29/24.
//

#import <Foundation/Foundation.h>

#ifndef KTXPEnvironments_h
#define KTXPEnvironments_h

typedef NSString * _Nonnull KTXPEnvironment;

// Misc
/**
 Allows for weird cell drawing.
 */
const KTXPEnvironment CD = @"CD";

/*
 IMPORTANT NOTE: Line separators are defined as
 - `\\`
 - `\cr`
 - `\\[measurement]
 - `\cr[measurement]`
 */

#pragma mark - Matrix
typedef KTXPEnvironment KTXPMatrixEnv;
/**
 Always centered. Cannot specify alignment so no args.
 Columns must be < 10.
 Use `&` to designate columns and `\\` to designate rows.
 */
const KTXPMatrixEnv matrix = @"matrix";
/// Like matrix but with small font.
const KTXPMatrixEnv smallmatrix = @"smallmatrix";
/// Like matrix but with parenthesis.
const KTXPMatrixEnv pmatrix = @"pmatrix";
/// Like matrix but with brackets.
const KTXPMatrixEnv bmatrix = @"bmatrix";
/// Like matrix but with braces.
const KTXPMatrixEnv Bmatrix = @"Bmatrix";
/// Like matrix but with vertical bars.
const KTXPMatrixEnv vmatrix = @"vmatrix";
/// Like matrix but with double vertical bars.
const KTXPMatrixEnv Vmatrix = @"Vmatrix";

/**
 Works like matrix.
 Has an optional argument, which are:
 `[r]` for right alignment
 `[c]` for center alignment
 `[l]` for left alignment
 By default is left aligned.
 Columns must be < 10.
 */
const KTXPMatrixEnv matrixStar = @"matrix*";
/// Like matrix* but with parenthesis.
const KTXPMatrixEnv pmatrixStar = @"pmatrix*";
/// Like matrix* but with brackets.
const KTXPMatrixEnv bmatrixStar = @"bmatrix*";
/// Like matrix* but with braces.
const KTXPMatrixEnv BmatrixStar = @"Bmatrix*";
/// Like matrix* but with vertical bars.
const KTXPMatrixEnv vmatrixStar = @"vmatrix*";
/// Like matrix* but with double vertical bars.
const KTXPMatrixEnv VmatrixStar = @"Vmatrix*";

#pragma mark - Array
typedef KTXPEnvironment KTXPArrayEnv;
/**
 Makes a table.
 Columns are separated by `&` and each row ends with a line separator.
 Has an argument syntax within braces:
	- Each column can have an alignment letter:
		- c (default, centered)
		- l (left)
		- r (right)
	- The column letters have to be <= the number of columns.
	- The column letters can be interspersed with `|` (solid lines) or `:` (dashed lines) which will give vertical lines to separate the columns.
 When you need a horizontal line, can use `\hline` or `\hdashline`.
 */
const KTXPArrayEnv array = @"array";
/**
 Used within other environments. Has an argument where you can align the whole thing with an alignment letter. Otherwise works like array.
 */
const KTXPArrayEnv subarray = @"subarray";
/// Not supported. Throw error.
const KTXPArrayEnv darray = @"darray";

#pragma mark - Cases
typedef KTXPEnvironment KTXPCasesEnv;
/**
 Renders a large brace to the left of multiple lines.
 */
const KTXPCasesEnv cases = @"cases";
/**
 Like cases but puts the first column into displaymode.
 */
const KTXPCasesEnv dcases = @"dcases";
/**
 Like cases but puts the brace on the right rather than the left.
 */
const KTXPCasesEnv rcases = @"rcases";
/**
 Does both dcases and rcases in one.
 */
const KTXPCasesEnv drcases = @"drcases";

#pragma mark - Align

typedef KTXPEnvironment KTXPAlignEnv;
/**
 Vertically aligns rows of tokens. Each line is separated by a line separator.
 By default alignment is at equals signs or I guess signs of comparison.
 You can force vertical alignment at specific points using a bunch of `&`. The columns will then be aligned that way.
 Gives each row automatic numbering.
 */
const KTXPAlignEnv align = @"align";
/**
 More detailed align.
 Has a required argument {n} where n is the number of columns. It requires manual alignment marks with `&`.
 Gives each row automatic numbering.
 */
const KTXPAlignEnv alignat = @"alignat";
/**
 Subenvironment from within `equation` or `displaymath`. Works like align, but doesn't do automatic numbering.
 */
const KTXPAlignEnv aligned = @"aligned";
/**
 Subenvironment from within `equation` or `displaymath`. Works like aligned, but doesnt do automatic numbering.
 */
const KTXPAlignEnv alignedat = @"alignedat";
/// Same as align but without row numbering.
const KTXPAlignEnv alignStar = @"align*";
/// Same as alignat but without row numbering.
const KTXPAlignEnv alignatStar = @"alignat*";

#pragma mark - Equations
typedef KTXPEnvironment KTXPEquationsEnv;
/**
 Puts equations in a center aligned list with numbers for each.
 */
const KTXPEquationsEnv gather = @"gather";
/**
 Puts equations in a center aligned list without numbers.
 */
const KTXPEquationsEnv gatherStar = @"gather*";
/**
 Horizontally centers equations.
 The entire group has 1 single equation number.
 Does not automatically break lines.
 */
const KTXPEquationsEnv gathered = @"gathered";
/**
 Puts equations in an aligned list with numbers for each.
 Does not allow line breaks.
 */
const KTXPEquationsEnv equation = @"equation";
/**
 Puts equations in an aligned list without numbers.
 Does not allow line breaks.
 */
const KTXPEquationsEnv equationStar = @"equation*";

#endif /* KTXPEnvironments_h */
