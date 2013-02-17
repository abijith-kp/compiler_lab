%{
#include<stdio.h>
void yyerror(char *);
%}

%token INT, INTEGER,  COMMA, ID, BOOL, BOOLEAN, DECL, ENDDECL, AMP, SIM_BRAC_O, SIM_BRAC_C, SQR_BRAC_O, SQR_BRAC_C, CURL_BRAC_O, CURL_BRAC_C, K_BEGIN, END, RETURN, SEMICOLN, EQUAL, MAIN, PLUS, MINUS, MULTIPLY, DIVIDE, AND, OR, NOT, WHILE, DO, ENDWHILE, LESS_THAN_EQUAL, GREATER_THAN_EQUAL, EXACTLY_EQUAL, NOT_EQUAL, LESS_THAN, GREATER_THAN, IF, THEN, ELSE, ENDIF, READ, WRITE

%%

arithmetic_expr : expr PLUS arithmetic_expr  {printf("sadsad");}
                | expr MINUS arithmetic_expr
                | expr
                ;

expr    : exp MULTIPLY expr
        | exp DIVIDE expr
        | exp
        ;

exp	: INT
	| var
	;

var     : ID SQR_BRAC_O INT SQR_BRAC_C  
        | ID
        ;

%%

void yyerror(char *s) {
    fprintf(stderr, "%s\n", s);
}

int main(void) {
    yyparse();
    return 0;
}
