KEYWORD		(do|new|free|boolean|integer|decl|enddecl|begin|if|then|else|endif|return|end|while|endwhile|read|write)
IDENTIFIER	[a-z][a-zA-Z0-9]*
INT		[0-9]+
COMMENTS        "//".*
MATHOP		[-/+*]
RELOP		("<"|">"|"<="|">="|"=="|"!=")
EQUAL		[=]
BRACKETS	[\[\]\(\){}]
OTHER		[\.|;|/|\^]

%%

{KEYWORD}	 printf("KEYWORD(%s) " , yytext); 
{IDENTIFIER}	printf("IDENTIFIER(%s) " , yytext);
{INT}		printf("INT(%s) " , yytext);
{MATHOP}           printf("MATHOP(%s) " , yytext);
{RELOP}           printf("RELOP(%s) " , yytext);
{EQUAL}		printf("EQUAL(%s) " , yytext);
{BRACKETS}           printf("BRACKETS(%s) " , yytext);
{OTHER}           printf("OTHER(%s) " , yytext);
{COMMENTS}           printf("COMMENTS(%s) " , yytext);
