#  NOTES
## Generic Data
Token types:
	- atoms 	-> these single tokens standalone and usually represent a character. Can either be TeX based like `\Updownarrow` or unicode based `⇕`.
	- unary 	-> these tokens only take 1 set of arguments.
	- binary 	-> these take 2 sets of arguments.
	- underover -> they take 1 argument but generally expect or support `_{}` or `^{}` or both or something else after them. They also tend to work just fine if you dont provide the `_^`.
	
Note that certain things that appear to be "backwards modifying" aren't. `a'` is not "a modified by a prime". It's just "a followed by a prime".

In TeX, macros can get away with a lot of stuff, though its generally considered bad form to do so. This is becuase they get to define their behavior. For example `\overbrace{a+b+c}^{\text{note}}` works. If you replace `^` with `_`, it instead renders as if you subscripted the `\text{note}`. Change the macro to `\underbrace` and it works as you'd expect. So a lot of the time, you just need special rules to deal with what a macro expects. This is a bit of a pain becuase you can't generalize the behavior without recreating TeX itself.

## Anatomy of TeX Macro
In TeX you define a new macro with \newcommand. In all commands:
	* You have the name usually preceeded by a backslash
	* If you need additional optional data fed as a parameter after an argument, you place it into []. If you don't then its ignored. Some of these arguments can be comma separated lists, space separated flags, and arbituary macros. The macro itself interprets the arguments based on how it expects. Each optional argument goes within a single pair of [], so if a macro takes multiple (like 2) then you will have multiple [].
	* The arguments within {}. If you have multiple arguments, you almost always have {} for each argument.
	* ***Some*** macros expect optional data to come after {} insead of before (though this is considered unusual). These are macro dependent. They always come after the main argument that they affect so one hack is to just lookahead to see if [ comes immediately after a }.

Example:
`\newcommand{\myfrac}[2]{\frac{#1}{#2}}`
In this example, we define a new command, provide the new name as an argument, then additional data is specified in the macro, which we feed with `[]`. That additional data in this context is the amount of arguments for the new macro. Then we provide what it equates to in the next argument, which is \frac. In TeX, arguments are index as #n, where n is >0. So #1 means first argument fed to \myfrac, #2 means second arg, and so on. We are feeding the arguments to the original \frac macro.

TeX really doesn't like when you don't have braces for parameters. So only a few macros even allow that. Also in my research, TeX only allows that when the argument only takes 1 token. So for instance, with \frac and numerator and denominator, there can only be 1 value inside both of those. This is why you can usually leave the braces out (though doing so is considered bad form).

This is why `\frac12` is not `\frac{12}{}`, its actually `\frac{1}{2}` becuase the token fed into args without {} is only 1 token wide.

## Environments
Environments provide context for macros. They pretty much are used to mofidy the interpretation of certain macros and tokens. For example, you can have an environment that centers all tokens within it.

All environments live within `\begin \end` macros. You specify the environment within braces and additional data within brackets like any other macro.
```
x = \begin{cases}
   a &\text{if } b \\
   c &\text{if } d
\end{cases}
```

## Groups
Each character or macro has a class it belongs to. This class primarily dictates spacing during the typsetting. As far as I can tell without reading the entire TeXBook, thats pretty much its only function. This isn't what I wanted when deciding token types.

The original tex \mathchar atom types are:
- ord or ordinary
- op for operator
- binary operation
- relation
- opening
- closing
- punctuation
- variable family

KaTeX has a couple more:
```
export const ATOMS = {
    "bin": 1,
    "close": 1,
    "inner": 1,
    "open": 1,
    "punct": 1,
    "rel": 1,
};
export const NON_ATOMS = {
    "accent-token": 1,
    "mathord": 1,
    "op-token": 1,
    "spacing": 1,
    "textord": 1,
};
```

I do think this data could be potentially useful, but for straight parsing, it's not what I wanted. This means I still have to go one by one and set a token type for how it should be treated. The token types I want should define behavior, not intention.

I guess the token types I want are:
- Atom 				 		 : macros that don't take arguments
- Function 			 		 : for macros that take arguments
- Special Function 		 : for macros that do weird things with their arguments (like not use {})
- Open/Close Group 		 : macros or characters that TeX uses to denote groups (like {})
- Open/Close Environment : for opening and closing an environment (like \begin{}\end{} and \left \right)
- Whitespace 		 		 : for condensing whitespace into a token if possible
- Comment					 : for comments

I'd guess to handle some functions that act strange like \int, you'd have to handle them manually even if their type is still function. Then you could handle all the bullshit like \brace, \int, \sum, \underbrace, \overbrace, and so on.

For instance \left \right do not use braces for arguments. And they require their partner to enclose the whole thing. If you don't you get an `invalid delimiter type ordgroup` error. In fact if you don't put an ordinary group character in (say you put a letter or number), you get an `invalid delimiter` error again. Technically you wouldn't really need to have a type specifically for ordinary groups I guess, you could just check the argument given and see if its within that limited set of allowed strings.

I think you could have some other extra property that has the amount of arguments something takes.

## Unicode
My understanding is that unicode characters are just straight up rendered, though I'm not exactly sure how. It *may* be translated into the equivalent atom in latex. That would make sense, since you can insert a unicode character and yet TeX acts as if you inserted the macro when it comes to the typesetting modifications.

If this happens, it only seems to happen on non-ASCII characters. And even then, some are considered special. The tilde for instance, is not available in TeX without special packages. Everything else, unless it is a control character or maps to a macro in some way, seems to just be rendered as a macro itself.

The other option is there's just a 2nd dictionary that contains the unicode characters TeX supports and just has them mapped to a macro. Then it could leave the character.

In the event of a unicode character being hit that we don't have a direct mapping to, we should either have a default it goes to *or* throw an error equivalent to "unrecognized macro".

We may not actually have to do any of this. All I've seen are examples of them being rendered as atom macros. So if we don't find them in the supported dictionary, then we don't need to do anything except make them atom macros as a fall back.

## Lexing
I think the best way to go would be creating the tokens, and then going through that array and "fixing" it by replacing unicode characters with the equivalent tokens. That way, when we use it for anything else and need to lookup the macro, the additional lookup is already done ahead of time.

## Parsing
Since this simply just makes a tree, all we have to do is fit the tokens into respective nodes to make the AST. While you could skip dictionary lookup by having node objects for each token instead, that just seems like a lot of pointless work for not much performance gain.
