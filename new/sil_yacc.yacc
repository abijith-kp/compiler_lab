%{
#include<stdio.h>

#define I  1
#define AR 2
#define IN 3
#define BL 4
#define PL 5
#define SU 6
#define ML 7
#define DV 8
#define AS 9
#define NT 10
#define ND 11
#define R  12
#define RD 13
#define WR 14
#define GE1 15
#define LE1 16
#define L1  17
#define G1  18
#define EE1 19
#define NE1 20
#define BD  21
#define IS  22
#define IF1 23
#define IF2 24

void yyerror(char *);


struct node {
	int type;
	int intVal;
	char *charVal;
    struct node *one;
	struct node *two;
	struct node *three;
	};

struct node *makenode(int type, int intVal, char *charVal, struct node *one, struct node *two, struct node *three);

void printTree(struct node *n);

%}

%union
	{ int intVal;
	  char *charVal;
	  struct node *n;
	}

%token INT INTEGER  ID BOOL BOOLEAN DECL ENDDECL K_BEGIN END RETURN MAIN AND OR NOT WHILE DO ENDWHILE IF THEN ELSE ENDIF READ WRITE

%type<n> var type expr assignment_stmnt in_out_stmnt statement iterative_stmnt body condition conditional_stmnt
%type<intVal> INT
%type<charVal> ID BOOL

%start start

%%

start	: global_var main_funct    { //printf("main"); 
                                   }
	;

main_funct      : INTEGER MAIN '(' ')' '{' global_var K_BEGIN body RETURN INT ';' END '}'
                ;

body	: statement ';' body    { $$ = makenode(BD, 0, "", $1, $3, NULL); printTree($$); 
                                }
	    |                       { }
	    ;

statement	: assignment_stmnt  { $$ = $1; //printf("sadas");
                                 //printTree($1);
                                }
		    | conditional_stmnt { $$ = $1;
                                  //printTree($1);
                                }
		    | iterative_stmnt   { $$ = $1;
                                  //printTree($1);
                                }
		    | in_out_stmnt      { $$ = $1;
                                  //printTree($1);
                                }
		    ;


conditional_stmnt	: IF '(' condition ')' THEN body ELSE body ENDIF    { $$ = makenode(IF1, 0, "", $3, $6, $8); }
			        | IF '(' condition ')' THEN body ENDIF              { $$ = makenode(IF2, 0, "", $3, $6, NULL); }
			        ;

iterative_stmnt	: WHILE '(' condition ')' DO body ENDWHILE  { $$ = makenode(IS, 0, "", $3, $6, NULL); }
		        ;

condition	: expr 'a' expr { $$ = makenode(GE1, 0, "", $1, $3, NULL); }
		    | expr 'b' expr { $$ = makenode(LE1, 0, "", $1, $3, NULL); }
		    | expr 'c' expr { $$ = makenode(L1, 0, "", $1, $3, NULL); }
		    | expr 'd' expr { $$ = makenode(G1, 0, "", $1, $3, NULL); }
		    | expr 'e' expr { $$ = makenode(EE1, 0, "", $1, $3, NULL); }
            | expr 'f' expr { $$ = makenode(NE1, 0, "", $1, $3, NULL); }
		    ;


in_out_stmnt	: READ '(' var ')'      { $$ = makenode(RD, 0, "", $3, NULL, NULL); }
                | WRITE '(' expr ')'    { $$ = makenode(WR, 0, "", $3, NULL, NULL); }
                ;

assignment_stmnt	: var '=' expr  { $$ = makenode(AS, 0, "", $1, $3, NULL); 
                                     //printTree($$); 
                                    }
			        ;

expr 	: type '+' expr	{ $$ = makenode(PL, 0, "", $1, $3, NULL); }
      	| type '-' expr { $$ = makenode(SU, 0, "", $1, $3, NULL); } 
      	| type '*' expr { $$ = makenode(ML, 0, "", $1, $3, NULL); } 
  	    | type '/' expr { $$ = makenode(DV, 0, "", $1, $3, NULL); }
	    | type OR expr  { $$ = makenode(R, 0, "", $1, $3, NULL); }
        | type AND expr { $$ = makenode(ND, 0, "", $1, $3, NULL); }
        | NOT expr      { $$ = makenode(NT, 0, "", $2, NULL, NULL); }
	    | type	        { $$ = $1; }
      	;



global_var      : DECL decl ENDDECL 
                ;

decl	: datatype var var_r ';' decl
	    | 
	    ;

var_r   : ',' var var_r  
        | 
        ;

datatype	: INTEGER  
		    | BOOLEAN  

		    ;

type	: var { $$ = $1; }

	    | INT { $$ = makenode(IN , $1 , "" , NULL, NULL, NULL); }

	    | BOOL { $$ = makenode(BL , 0 , $1 , NULL, NULL, NULL); }

	    ;

var     : ID '[' INT ']'  { $$ = makenode(AR , $3 , $1 , NULL, NULL, NULL); }
        | ID              { $$ = makenode(I , 0, $1, NULL, NULL, NULL); }
        ; 

%%

void printTree(struct node *point) {
    if(point == NULL)
        return;

    if(point->type == AS) {
        printTree(point->one);
        printf(" = ");
        printTree(point->two);
        //printf("\n");
    }
    else if(point->type == PL) {
        printTree(point->one);
        printf(" + ");
        printTree(point->two);
    }
    else if(point->type == SU) {
        printTree(point->one);
        printf(" - ");
        printTree(point->two);
    }
    else if(point->type == ML) {
        printTree(point->one);
        printf(" * ");
        printTree(point->two);
    }
    else if(point->type == DV) {
        printTree(point->one);
        printf(" / ");
        printTree(point->two);
    }
    else if(point->type == ND) {
        printTree(point->one);
        printf(" and ");
        printTree(point->two);
    }
    else if(point->type == NT) {
        printTree(point->one);
        printf(" not ");
        printTree(point->two);
    } 
    else if(point->type == R) {
        printTree(point->one);
        printf(" or ");
        printTree(point->two);
    }
    else if(point->type == IN) {
        printf(" %d ", point->intVal);
    }
    else if(point->type == BL) {
        printf(" %s ", point->charVal);
    }
    else if(point->type == AR) {
        printf(" %s[%d] ", point->charVal, point->intVal);
    } 
    else if(point->type == I) {
        printf(" %s ", point->charVal);
    }
    else if(point->type == RD) {
        printf(" read ");
        printTree(point->one);
    }
    else if(point->type == WR) {
        printf(" write ");
        printTree(point->one);
    }
    else if(point->type == IS) {
        printf(" while ");
        printTree(point->one);
        printf("\n");
        printTree(point->two);
    }
    else if(point->type == BD) {
        printTree(point->one);
        printf("\n");
        printTree(point->two);
        printf("\n");
    }
    else if(point->type == GE1) {
        printTree(point->one);
        printf(" >= ");
        printTree(point->two);
        }
    else if(point->type == LE1) {
        printTree(point->one);
        printf(" <= ");
        printTree(point->two);
        }
else if(point->type == L1) {
        printTree(point->one);
        printf(" < ");
        printTree(point->two);
        }
else if(point->type == G1) {
        printTree(point->one);
        printf(" > ");
        printTree(point->two);
        }
else if(point->type == EE1) {
        printTree(point->one);
        printf(" == ");
        printTree(point->two);
        }
else if(point->type == NE1) {
        printTree(point->one);
        printf(" != ");
        printTree(point->two);
        }
else if(point->type == IF1) {
        printf(" if ");
        printTree(point->one);
        printf("\n");
        printTree(point->two);
        printf("\nelse\n");
        printTree(point->three);
        }
else if(point->type == IF2) {
        printf(" if ");
        printTree(point->one);
        printf("\n");
        printTree(point->two);
        }

}

struct node *makenode(int type, int intVal, char *charVal, struct node *one, struct node *two, struct node *three) {
    struct node *tmp = malloc(sizeof(struct node));

    tmp->type = type;
    tmp->charVal = charVal;
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
