%{
#include<stdio.h>
void yyerror(char *);

struct node {
	int type;
	int intVal;
	char charVal;
	struct node *one;
	struct node *two;
	struct node *three;
	};

%}

%union
	{ int intVal;
	  char charVal[20];
	  struct node *n;
	}

%token INT INTEGER  ID BOOL BOOLEAN DECL ENDDECL K_BEGIN END RETURN MAIN AND OR NOT WHILE DO ENDWHILE IF THEN ELSE ENDIF READ WRITE



%start start

%%

start	: global_var main_funct    { printf("main"); }
	;

main_funct      : INTEGER MAIN '(' ')' '{' global_var K_BEGIN body RETURN INT ';' END '}'  

body	: statement ';' body
	|
	;

statement	: assignment_stmnt  {printf("assignment");}
		| conditional_stmnt {printf("condition");}
		| iterative_stmnt   {printf("iteration");}
		| in_out_stmnt      {printf("input output");}
		;


conditional_stmnt	: IF '(' condition ')' THEN body ELSE body ENDIF 
			| IF '(' condition ')' THEN body ENDIF
			;

iterative_stmnt	: WHILE '(' condition ')' DO body ENDWHILE
		;

condition	: expr 'a' expr
		| expr 'b' expr
		| expr 'c' expr
		| expr 'd' expr
		| expr 'e' expr
                | expr 'f'  expr
		;


in_out_stmnt	: READ '(' var ')'
		| WRITE '(' expr ')' 
		;

assignment_stmnt	: var '=' expr  { printf("assignment1"); }
			;

expr 	: type '+' expr	{ printf("21333333333"); }
      	| type '-' expr
      	| type '*' expr
  	| type '/' expr
	| type OR expr
        | type AND expr
        | NOT expr
	| type	{ printf("21333333333"); }
      	;




global_var      : DECL decl ENDDECL     { printf("global"); }
                ;

decl	: datatype var var_r ';' decl
	|
	;

var_r   : ',' var var_r
	| 
        ;

datatype	: INTEGER  { printf("type"); }
		| BOOLEAN
		;

type	: var
	| INT
	| BOOL
	;

var     : ID '[' INT ']'  { printf("var"); }
        | ID   { printf("var"); }
        ;


%%

void yyerror(char *s) {
    fprintf(stderr, "%s\n", s);
}

int main(void) {
    yyparse();
    return 0;
}
