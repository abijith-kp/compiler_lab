%{
#include<stdio.h>

#define ID 1
#define AR 2
#define IN 3
#define BL 4
#define DI 5
#define DB 6

void yyerror(char *);


struct node {
	int type;
	int intVal;
	char charVal;
	int datatype;
    struct node *one;
	struct node *two;
	struct node *three;
	};

struct node *makenode(int type, int intVal, char charVal[20], struct node *one, struct node *two, struct node *three);

%}

%union
	{ int intVal;
	  char charVal[20];
	  struct node *n;
	}

%token INT INTEGER  ID BOOL BOOLEAN DECL ENDDECL K_BEGIN END RETURN MAIN AND OR NOT WHILE DO ENDWHILE IF THEN ELSE ENDIF READ WRITE

%type<n> var type datatype var_r decl

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

decl	: datatype var var_r ';' decl { $$ = makenode(DCL, 0, "", $1, $2, $3); }
	    | {}
	    ;

var_r   : ',' var var_r  { $$ = makenode(0, 0, "", $2, $3, NULL); }
	    | {}
        ;

datatype	: INTEGER  { $$ = makenode(DB , 0 , "" , NULL, NULL, NUll); }
		    | BOOLEAN  { $$ = makenode(DI , 0 , "" , NULL, NULL, NUll); }

		    ;

type	: var { $$ = $1; }

	    | INT { $$ = makenode(IN , $1 , "" , NULL, NULL, NUll); }

	    | BOOL { $$ = makenode(BL , 0 , $1 , NULL, NULL, NUll); }

	    ;

var     : ID '[' INT ']'  { $$ = makenode(AR , $3 , $1 , NULL, NULL, NUll); }
        | ID   { $$ = makenode(ID , 0, $1, NULLL, NULL, NULL); }
        ; 


%%

struct node *makenode(int type, int intVal, char charVal, struct node *one, struct node *two, struct node *three) {
    struct node *tmp = malloc(sizeof(struct node));

    tmp->type = type;
    strcpy(tmp->charVal,charVal);
    tmp->intVal = intVal;
    tmp->one = one;
    tmp->two = two;
    tmp->three = three;

    return tmp;
}

void yyerror(char *s) {
    fprintf(stderr, "%s\n", s);
}

int main(void) {
    yyparse();
    return 0;
}
