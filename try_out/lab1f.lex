KEYWORD		(float|record|main|do|new|free|boolean|integer|decl|enddecl|begin|if|then|else|endif|return|end|while|endwhile|read|write)
IDENTIFIER	[a-z][a-zA-Z0-9]*
INT		[0-9]+
MATHOP		[-/+*%]
RELOP		("<"|">"|"<="|">="|"=="|"!=")
EQUAL		[=]
BRACKETS	[\[\]\(\){}]
OTHER		[\.|;|/|\^]
REF		"&"
LOGOP		(AND|OR|NOT)
FLOAT		\-?{INT}\.{INT}(E\-?{INT})?
RECORD		{IDENTIFIER}"{"[^"}"]*"}"{IDENTIFIER}";"

%%

"/*"[^"*/"]*"*/"    printf("COMMENT(%s) " , yytext);
"//".*          printf("COMMENT(%s)" , yytext);
{KEYWORD}	 printf("KEYWORD(%s) " , yytext); 
{LOGOP}		printf("LOGOP(%s) " , yytext);
{RECORD}	{ printf("RECORD "); REJECT;}
{IDENTIFIER}	printf("IDENTIFIER(%s) " , yytext);
{REF}		printf("REF(%s) " , yytext);
{INT}		printf("INT(%s) " , yytext);
{MATHOP}           printf("MATHOP(%s) " , yytext);
{RELOP}           printf("RELOP(%s) " , yytext);
{EQUAL}		printf("EQUAL(%s) " , yytext);
{BRACKETS}           printf("BRACKETS(%s) " , yytext);
{OTHER}           printf("OTHER(%s) " , yytext);
{FLOAT}		printf("FLOAT ");
.		;
