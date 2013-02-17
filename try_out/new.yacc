%{
#include<stdio.h>
void yyerror(char *);
%}

%token INT, INTEGER,  COMMA, ID, BOOL, BOOLEAN, DECL, ENDDECL, AMP, SIM_BRAC_O, SIM_BRAC_C, SQR_BRAC_O, SQR_BRAC_C, CURL_BRAC_O, CURL_BRAC_C, K_BEGIN, END, RETURN, SEMICOLN, EQUAL, MAIN, PLUS, MINUS, MULTIPLY, DIVIDE, AND, OR, NOT, WHILE, DO, ENDWHILE, LESS_THAN_EQUAL, GREATER_THAN_EQUAL, EXACTLY_EQUAL, NOT_EQUAL, LESS_THAN, GREATER_THAN, IF, THEN, ELSE, ENDIF, READ, WRITE


%%

start	: global_var main_funct
	;

main_funct      : INTEGER MAIN SIM_BRAC_O SIM_BRAC_C CURL_BRAC_O global_var funct_body CURL_BRAC_C
		;

global_var      : DECL BOOLEAN var var_r ENDDECL  {printf("correct");}
                | DECL INTEGER var var_r ENDDECL  {printf("correct");}
                ;

var_r   : COMMA var var_r
	| COMMA var SEMICOLN
        | SEMICOLN INTEGER var var_r
	| SEMICOLN BOOLEAN var var_r
        | SEMICOLN INTEGER var SEMICOLN
        | SEMICOLN BOOLEAN var SEMICOLN
	|
        ;

var     : ID SQR_BRAC_O INT SQR_BRAC_C   {printf("array");}
        | ID   {printf("ID");}
        ;

funct_body	: K_BEGIN content_r RETURN INT SEMICOLN END       {printf("body");}
		| K_BEGIN RETURN INT SEMICOLN END
		;

content_r       : statement SEMICOLN content_r
                | statement SEMICOLN
                ;

statement	: assignment_stmnt  {printf("assignment");}
		| conditional_stmnt {printf("condition");}
		| iterative_stmnt   {printf("iteration");}
		| in_out_stmnt      {printf("input output");}
		;

in_out_stmnt	: READ SIM_BRAC_O var SIM_BRAC_C 
		| WRITE SIM_BRAC_O arithmetic_expr SIM_BRAC_C 
		;

assignment_stmnt	: var EQUAL arithmetic_expr  {printf("assignment1");}
			| var EQUAL logical_expr     {printf("assignment2");}
			|
			;

logical_expr    : SIM_BRAC_O exp OR logical_expr SIM_BRAC_C
		| SIM_BRAC_O exp AND logical_expr SIM_BRAC_C
                | SIM_BRAC_O NOT logical_expr SIM_BRAC_C
                ;


arithmetic_expr : expr PLUS arithmetic_expr
                | expr MINUS arithmetic_expr
                | expr
                ;

expr    : exp MULTIPLY expr
        | exp DIVIDE expr
        | exp
        ;

exp	: BOOL
	| INT
	| var
	;

conditional_stmnt	: IF SIM_BRAC_O arithmetic_expr relop arithmetic_expr SIM_BRAC_C THEN content_r ELSE content_r ENDIF 
			| IF SIM_BRAC_O arithmetic_expr relop arithmetic_expr SIM_BRAC_C THEN content_r ELSE ENDIF
			| IF SIM_BRAC_O arithmetic_expr relop arithmetic_expr SIM_BRAC_C THEN content_r ENDIF 
			| IF SIM_BRAC_O arithmetic_expr relop arithmetic_expr SIM_BRAC_C THEN ELSE content_r ENDIF
			;

iterative_stmnt	: WHILE SIM_BRAC_O arithmetic_expr relop arithmetic_expr SIM_BRAC_C DO content_r ENDWHILE
		| WHILE SIM_BRAC_O arithmetic_expr relop arithmetic_expr SIM_BRAC_C DO ENDWHILE 
		;

relop	: LESS_THAN_EQUAL
	| GREATER_THAN_EQUAL
	| EXACTLY_EQUAL
	| NOT_EQUAL
	| LESS_THAN
	| GREATER_THAN
	;


%%

void yyerror(char *s) {
    fprintf(stderr, "%s\n", s);
}

int main(void) {
    yyparse();
    return 0;
}
