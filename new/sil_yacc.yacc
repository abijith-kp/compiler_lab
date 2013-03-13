%{
#include<stdio.h>

#define LS 0
#define GS 1
#define IN 2
#define BL 3

void yyerror(char *);
void makeSymbol(int scope, int dataType, char idVal[20], int size);
void printTree(struct symbol *symbl);

struct node {
	int type;
	int intVal;
	char charVal;
	int datatype;
    struct node *one;
	struct node *two;
	struct node *three;
	};

struct symbol {
    int scope;
    int dataType;
    char idVal[20];
    int size;
    struct symbol *next;
    };

struct symbol *headG = NULL, *headL = NULL;

int scope=-1;

%}

%union
	{ int intVal;
	  char charVal[20];
      struct node *n;
	}

%token INT INTEGER  ID BOOL BOOLEAN DECL ENDDECL K_BEGIN END RETURN MAIN AND OR NOT WHILE DO ENDWHILE IF THEN ELSE ENDIF READ WRITE

%start start

%%

start	: global_var main_funct    { scope = GS; }
	    ;

main_funct      : INTEGER MAIN '(' ')' '{' global_var K_BEGIN body RETURN INT ';' END '}'   { scope = LS; }

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




global_var      : DECL decl ENDDECL     { print("main"); }
                ;

decl	: datatype var var_r ';' decl   { int tempType = $1.dataType; addVar($2, scope, tempType); }
	    |   {}
	    ;

var_r   : ',' var var_r { addVar($2); }
	    |   {}
        ;

datatype	: INTEGER   { makeSymbol(scope, IN, "integer", 0); }
		    | BOOLEAN   { makesymbol(scope, BL, "boolean", 0); }
		    ;

type	: var
	    | INT
	    | BOOL
	    ;

var     : ID '[' INT ']'    { makeSymbol(scope, tempType, $1, $3); }
        | ID                { makeSymbol(scope, tempType, $1, 0); }
        ;


%%

void makeSymbol(int scope, int dataType, char idVal[20], int size) {
    struct symbol *tmp = malloc(sizeof(struct symbol));
    tmp->scope = scope;
    tmp->dataType = dataType;
    strcpy(tmp->idVal, idVal);
    tmp->size = size;

    if((scope == LS) && !(strcmp(idVal, "integer") || (strcmp(idVal
    , "boolean"))) {
        if(check(idVal, headL)) {
            yyerror();
        }
        else {
            tmp->next = headL;
            headL = *tmp;
        }
    }
    else if((scope == GS) && !(strcmp(idVal, "integer") || (strcmp(idVal , "boolean"))) {
        if(check(idVal, headG)) {
            yyerror();
        }
        else {
            tmp->next = headG;
            headG = *tmp;
        }
    }
}

int check(char name[20], struct symbol *point) {
    if(point == NULL)
        return 0;
    if(!(strcmp(point->idVal, name)))
        return 1;
    else
        check(name, point->next);
}

void printTree(struct symbol *symbol) {
}

void yyerror(char *s) {
    fprintf(stderr, "%s\n", s);
}

int main(void) {
    yyparse();
    return 0;
}
