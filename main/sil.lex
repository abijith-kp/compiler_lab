%{

#include "y.tab.h"
#include <stdio.h>
#include <stdlib.h>
void yyerror(char *);
extern int yylval;

%}

INT	[0-9]+

%%

{INT}		return INT;

[-+/*\n]	return *yytext;

.	;
