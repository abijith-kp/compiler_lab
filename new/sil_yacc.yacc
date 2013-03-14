%{
#include<stdio.h>

#define LS 0
#define GS 1
#define IN 2
#define BL 3

void yyerror(char *);
void makeSymbol(int scope, int dataType, char *idVal, int size);

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
    char *idVal;
    int size;
    struct symbol *next;
    };

void printTree(struct symbol *s);

struct symbol *headG = NULL, *headL = NULL;

int checker=0,scopeG=GS, tempTypeG=2;

%}

%union
	{ int intVal;
	  char *charVal;
      struct node *n;
	}

%token INT INTEGER  ID BOOL BOOLEAN DECL ENDDECL K_BEGIN END RETURN MAIN AND OR NOT WHILE DO ENDWHILE IF THEN ELSE ENDIF READ WRITE

%start start

%type<intVal> INT
%type<charVal> ID

%%

start	: global_var main_funct    {  }
	    ;

main_funct      : INTEGER MAIN '(' ')' '{' global_var K_BEGIN body RETURN INT ';' END '}'   { }

body	: statement ';' body
	    |
	    ;

statement	: assignment_stmnt  { }
		    | conditional_stmnt { }
		    | iterative_stmnt   { }
		    | in_out_stmnt      { }
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

assignment_stmnt	: var '=' expr  { }
			    ;

expr 	: type '+' expr	{ }
      	| type '-' expr
      	| type '*' expr
  	    | type '/' expr
	    | type OR expr
        | type AND expr
        | NOT expr
	    | type	{  }
      	;




global_var      : DECL decl ENDDECL     { if(checker == 0)
						{ scopeG = LS; checker++; }
					  else
						checker++;
					}
                ;

decl	: datatype var var_r { }
	    |   {}
	    ;

var_r   : ',' var var_r { }
	| ';' decl  {}
        ;

datatype	: INTEGER   { tempTypeG = IN; }
		    | BOOLEAN   { tempTypeG = BL; }
		    ;

type	: var
	    | INT
	    | BOOL
	    ;

var     : ID '[' INT ']'    { if(checker<=1) makeSymbol(scopeG, tempTypeG, $1, $3); }
        | ID                { if(checker<=1) makeSymbol(scopeG, tempTypeG, $1, 0); }
        ;


%%

void makeSymbol(int scopeL, int dataType, char *idVal, int size) {
    struct symbol *tmp = malloc(sizeof(struct symbol));
    tmp->scope = scopeL;
    tmp->dataType = dataType;
    tmp->idVal = idVal;
    tmp->size = size;


    if(scopeL == LS) {
        if(check(idVal, headL)) {
            yyerror(idVal);
        }
        else {
	    tmp->next = headL;
            headL = tmp;
        }
    }
    else if(scopeL == GS) {
        if(check(idVal, headG)) {
            yyerror(idVal);
        }
        else {
            tmp->next = headG;
            headG = tmp;
        }
    }
}

int check(char name[20], struct symbol *point) {
    if(point == NULL)
        { return 0; }
    if(!(strcmp(point->idVal, name)))
        { return 1; }
    else
        { check(name, point->next); }
}

void printTree(struct symbol *s) {
    if(s == NULL)
        { return; }

    else {
        printf("%d \t %s \t %d\n", s->dataType, s->idVal, s->size);
        printTree(s->next);
        }
}

void yyerror(char *s) {
    fprintf(stderr, "%s\n", s);
}

int main(void) {
    yyparse();
    printf("Global syntax table:\n");
    printTree(headG);
    printf("Local syntax table:\n");
    printTree(headL);
    return 0;
}
