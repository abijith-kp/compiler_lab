%{
#include<stdio.h>
void yyerror(char *);

struct tnode {  char type;
		struct tnode *c1, *c2, *c3;
	     };

#define YYSTYPE struct tnode *makenode(int type, struct tnode *c1, struct tnode *c2, struct tnode *c3);

%}

%token INT, INTEGER,  COMMA, ID, BOOL, BOOLEAN, DECL, ENDDECL, AMP, SIM_BRAC_O, SIM_BRAC_C, SQR_BRAC_O, SQR_BRAC_C, CURL_BRAC_O, CURL_BRAC_C, K_BEGIN, END, RETURN, SEMICOLN, EQUAL, MAIN, PLUS, MINUS, MULTIPLY, DIVIDE, AND, OR, NOT, WHILE, DO, ENDWHILE, LESS_THAN_EQUAL, GREATER_THAN_EQUAL, EXACTLY_EQUAL, NOT_EQUAL, LESS_THAN, GREATER_THAN, IF, THEN, ELSE, ENDIF, READ, WRITE


%%

start	: global_var main_funct
	;

main_funct      : INTEGER MAIN SIM_BRAC_O SIM_BRAC_C CURL_BRAC_O global_var funct_body CURL_BRAC_C
		;

global_var      : DECL datatype var var_r ENDDECL  {printf("correct");}
                ;

var_r   : COMMA var var_r			{ $$ = makenode(COMMA, $1, $2, NULL); }
	| COMMA var SEMICOLN			{ $$ = makenode(COMMA, $1, NULL, NULL); }
        | SEMICOLN datatype var var_r		{ $$ = makenode(SEMICOLN, $2, $3, $4); }
        | SEMICOLN datatype var SEMICOLN	{ $$ = makenode(SEMICOLN, $2, $3); }
	|
        ;

datatype	: INTEGER	{ $$ = makenode(INTEGER, $1, NULL, NULL); }
		| BOOLEAN	{ $$ = makenode(BOOLEAN, $1, NULL, NULL); }
		;

var     : ID SQR_BRAC_O INT SQR_BRAC_C  { $$ = makenode(ARRAY, $1, $3); }
        | ID   {printf("ID");}		{ $$ = makenode(ID, $1, NULL, NULL); }
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

assignment_stmnt	: var EQUAL arithmetic_expr  {printf("assignment1");}	{ $$ = makenode(EQUAL, $1, $3, NULL); }
			| var EQUAL logical_expr     {printf("assignment2");}	{ $$ = makenode(EQUAL, $1, $3, NULL); }
			|
			;

logical_expr    : SIM_BRAC_O exp OR logical_expr SIM_BRAC_C	{ $$ = makenode(OR, $2, $4, NULL); }
		| SIM_BRAC_O exp AND logical_expr SIM_BRAC_C	{ $$ = makenode(AND, $2, $4, NULL); }
                | SIM_BRAC_O NOT logical_expr SIM_BRAC_C	{ $$ = makenode(NOT, $3, NULL, NULL); }
                ;


arithmetic_expr : expr PLUS arithmetic_expr	{ $$ = makenode(PLUS, $1, $3, NULL); }
                | expr MINUS arithmetic_expr	{ $$ = makenode(MINUS, $1, $3, NULL); }
                | expr				{ $$ = $1; }
                ;

expr    : exp MULTIPLY expr	{ $$ = makenode(MULTIPLY, $1, $3, NULL); }
        | exp DIVIDE expr	{ $$ = makenode(DIVIDE, $1, $3, NULL); }
        | exp			{ $$ = $1; }
        ;

exp	: BOOL	{ $$ = $1; }
	| INT   { $$ = $1; }
	| var	{ $$ = $1; }
	;

conditional_stmnt	: IF SIM_BRAC_O condition SIM_BRAC_C THEN content_r ELSE content_r ENDIF 
			| IF SIM_BRAC_O condition SIM_BRAC_C THEN content_r ELSE ENDIF
			| IF SIM_BRAC_O condition SIM_BRAC_C THEN content_r ENDIF 
			| IF SIM_BRAC_O condition SIM_BRAC_C THEN ELSE content_r ENDIF
			;

iterative_stmnt	: WHILE SIM_BRAC_O condition SIM_BRAC_C DO content_r ENDWHILE
		| WHILE SIM_BRAC_O condition SIM_BRAC_C DO ENDWHILE 		

relop	: LESS_THAN_EQUAL	{ $$ = $1; }
	| GREATER_THAN_EQUAL	{ $$ = $1; }
	| EXACTLY_EQUAL		{ $$ = $1; }
	| NOT_EQUAL		{ $$ = $1; }
	| LESS_THAN		{ $$ = $1; }
	| GREATER_THAN		{ $$ = $1; }
	;

condition	: arithmetic_expr relop arithmetic_expr	{ $$ = makenode('c');}
		;

%%

struct tnode *makenode(int type, struct tnode *c1, struct tnode *c2, struct tnode *c3){
    struct tnode *temp = malloc(sizeof(tnode));
    temp->type = type;
    temp->c1 = c1;
    temp->c2 = c2;
    temp->c3 = c3;
    return temp;
}

void yyerror(char *s) {
    fprintf(stderr, "%s\n", s);
}

int main(void) {
    yyparse();
    return 0;
}
