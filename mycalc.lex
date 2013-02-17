%{

#include "y.tab.h"
#include <stdio.h>
#include <stdlib.h>
void yyerror(char *);
extern int yylval;

%}

INT		[0-9]+

%%

{INT}		{ yylval = atoi(yytext);
	  	  return INT;
		}

(\-|\+|\/|\*|\n)	{return *yytext;
		}

.		;
