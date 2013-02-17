%{
#include<stdio.h>
void yyerror(char *);
%}

%token INT

%%

start	: exp_r
	;

exp_r	: exp '\n' exp_r
	|
	;

exp	: expr '+' exp 	{ printf("accepted\n"); }
	| expr '-' exp 	{ printf("accepted\n"); }
	| expr '*' exp 	{ printf("accepted\n"); }
	| expr '/' exp 	{ $$ = $1 + $3 }
	| expr		{ $$ = $1; }
	;

expr	: INT
	;

%%

void yyerror(char *s) {
    fprintf(stderr, "%s\n", s);
}

int main(void) {
    yyparse();
    return 0;
}
