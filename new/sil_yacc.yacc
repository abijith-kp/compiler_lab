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
#define LS  25
#define GS  26

void yyerror(char *);
void makeSymbol(int scope, int dataType, char *idVal, int size);

struct node {
	int type;
	int intVal;
    char *check;
	char *charVal;
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

struct symbol *headG = NULL, *headL = NULL;

int checker=0,scopeG=GS, tempTypeG=2;


struct node *makenode(int type, int intVal, char *charVal, struct node *one, struct node *two, struct node *three);
void printTree(struct node *n);
void printTable(struct symbol *n);
int typeCheck(struct node *a, struct node *b);
char *lookup(char *a);

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

start	: global_var main_funct    {  }
	    ;

main_funct      : INTEGER MAIN '(' ')' '{' global_var K_BEGIN body RETURN INT ';' END '}'
                ;

body	: statement ';' body    { $$ = makenode(BD, 0, "", $1, $3, NULL);
                                  if(!strcmp($1->check, "void") && !strcmp($3->check, "void"))// || ($3 == NULL)))
                                    $$->check = "void";
                                  else
                                    yyerror("body  ");
                                }
	    |                       { $$ = makenode(BD, 0, "", NULL, NULL, NULL);
                                  $$->check = "void"; 
                                }
	    ;

statement	: assignment_stmnt  { $$ = $1; //printf("sadas");
                                  $$->check = $1->check;
                                  printTree($1);
                                }
		    | conditional_stmnt { $$ = $1;
                                  $$->check = $1->check;
                                  printTree($1);
                                }
		    | iterative_stmnt   { $$ = $1;
                                  $$->check = $1->check;
                                  printTree($1);
                                }
		    | in_out_stmnt      { $$ = $1;
                                  $$->check = $1->check;
                                  printTree($1);
                                }
		    ;


conditional_stmnt	: IF '(' condition ')' THEN body ELSE body ENDIF    { $$ = makenode(IF1, 0, "", $3, $6, $8); 
                                                                          if(!strcmp($3->check, "bool") && !strcmp($6->check, "void") && !strcmp($8->check, "void"))
                                                                            $$->check = "void";
                                                                          else
                                                                            yyerror("if_one  \n ");
                                                                        }
			        | IF '(' condition ')' THEN body ENDIF              { $$ = makenode(IF2, 0, "", $3, $6, NULL); 
                                                                          if(!strcmp($3->check, "bool") && !strcmp($6->check, "void"))
                                                                            $$->check = "void";
                                                                          else
                                                                            yyerror("if_two\n");
                                                                        }
			        ;

iterative_stmnt	: WHILE '(' condition ')' DO body ENDWHILE  { $$ = makenode(IS, 0, "", $3, $6, NULL);
                                                              if(!strcmp($3->check, "bool") && !strcmp($6->check, "void"))
                                                                $$->check = "void";
                                                              else
                                                                yyerror("while  \n ");
                                                           }
		        ;

condition	: expr 'a' expr { $$ = makenode(GE1, 0, "", $1, $3, NULL); 
                              if(typeCheck($1, $3) && !strcmp($1->check, "int"))
                                $$->check = "bool";
                              else
                                yyerror("condition1 \n");
                            }
		    | expr 'b' expr { $$ = makenode(LE1, 0, "", $1, $3, NULL); 
                              if(typeCheck($1, $3) && !strcmp($1->check, "int"))
                                $$->check = "bool";
                              else
                                yyerror("condition2\n");
                            }
		    | expr 'c' expr { $$ = makenode(L1, 0, "", $1, $3, NULL); 
                              if(typeCheck($1, $3) && !strcmp($1->check, "int"))
                                $$->check = "bool";
                              else
                                yyerror("condition3\n");
                            }
		    | expr 'd' expr { $$ = makenode(G1, 0, "", $1, $3, NULL); 
                              if(typeCheck($1, $3) && !strcmp($1->check, "int"))
                                $$->check = "bool";
                              else
                                yyerror("condition4\n");
                            }
		    | expr 'e' expr { $$ = makenode(EE1, 0, "", $1, $3, NULL); 
                              if(typeCheck($1, $3) && !strcmp($1->check, "int"))
                                $$->check = "bool";
                              else
                                yyerror("condition5\n");
                            }
            | expr 'f' expr { $$ = makenode(NE1, 0, "", $1, $3, NULL); 
                              if(typeCheck($1, $3) && !strcmp($1->check, "int"))
                                $$->check = "bool";
                              else
                                yyerror("condition6\n");
                            }
		    ;


in_out_stmnt	: READ '(' var ')'      { $$ = makenode(RD, 0, "", $3, NULL, NULL);
                                          $$->check = "void";
                                        }
                | WRITE '(' expr ')'    { $$ = makenode(WR, 0, "", $3, NULL, NULL); 
                                          $$->check = "void"; 
                                        }
                ;

assignment_stmnt	: var '=' expr  { $$ = makenode(AS, 0, "", $1, $3, NULL); 
                                      if(typeCheck($1, $3))
                                        { $$->check = "void"; /*printTree($$);*/ }
                                      else {
                                        yyerror("assignment_stmnt\n");
                                        }
                                    }
			        ;

expr 	: type '+' expr	{ $$ = makenode(PL, 0, "", $1, $3, NULL); 
                          if(typeCheck($1, $3))
                            $$->check = "int";
                          else
                            yyerror("type checking error");
                        }
      	| type '-' expr { $$ = makenode(SU, 0, "", $1, $3, NULL);
                          if(typeCheck($1, $3))
                            $$->check = "int";
                          else
                            yyerror("type checking error");
                        }
      	| type '*' expr { $$ = makenode(ML, 0, "", $1, $3, NULL);
                          if(typeCheck($1, $3))
                            $$->check = "int";
                          else
                            yyerror("type checking error");
                        }
  	    | type '/' expr { $$ = makenode(DV, 0, "", $1, $3, NULL); 
                          if(typeCheck($1, $3))
                            $$->check = "int";
                          else
                            yyerror("type checking error");
                        }
	    | type OR expr  { $$ = makenode(R, 0, "", $1, $3, NULL);
                          if(typeCheck($1, $3))
                            $$->check = "bool";
                          else
                            yyerror("type checking error");
                        }
        | type AND expr { $$ = makenode(ND, 0, "", $1, $3, NULL);
                          if(typeCheck($1, $3))
                            $$->check = "bool";
                          else
                            yyerror("type checking error");
                        }
        | NOT expr      { $$ = makenode(NT, 0, "", $2, NULL, NULL);
                          if($2->check == "bool")
                            $$->check = "bool";
                          else
                            yyerror("type checking error");
                        }
	    | type	        { $$ = $1;
                          //$$->check = $1->check;
                          //printf(" %s %s %d ",$$->check, $1->check, $1->type);
                        }
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


var     : ID '[' INT ']'    { $$ = makenode(AR , $3 , $1 , NULL, NULL, NULL); 
                              if(checker<=1) 
                                makeSymbol(scopeG, tempTypeG, $1, $3);
                              char tmp[100] = {};
                              char *tp;
                              tp = lookup($1);     //lookup in the symbol table and returns error if not found or returns type if found
                              if(tp != "error") {
                                $$->check = tp;
                              }
                              else
                                { sprintf(tmp, "%s variable not found", $1); yyerror(tmp); return; }
                            }
        | ID                { $$ = makenode(I , 0 , $1 , NULL, NULL, NULL); 
                              if(checker<=1) 
                                makeSymbol(scopeG, tempTypeG, $1, 0);
                              char tmp[100] = {};
                              char *tp;
                              tp = lookup($1);
                              if(tp != "error") {
                                $$->check = tp;
                              }
                              else
                                { sprintf(tmp, "%s variable not found", $1); yyerror(tmp); return; }

                            }
        ;

type	: var { $$ = $1; 
                $$->check = $1->check; 
              }

	    | INT { $$ = makenode(IN , $1 , "" , NULL, NULL, NULL); 
                $$->check = "int"; 
              }

	    | BOOL { $$ = makenode(BL , 0 , $1 , NULL, NULL, NULL); 
                 $$->check = "bool";
               }
	    ;

%%

char *lookup(char *a) {

    struct symbol *tmp;
    char *t,*t1,*t2;
    t = "error";
    t1 = "int";
    t2 = "bool";
    tmp = headL;

    int i=0;
    //printf("\n");
    
    while(tmp != NULL) {
        //printf("%d  %s  %s\n", i++, a, tmp->idVal);
        if(!strcmp(tmp->idVal, a)) {
            if(tmp->dataType == IN)
                { return t1; }
            else
                { return t2; }
        }
    tmp = tmp->next;
    }
    
    tmp = headG;

    while(tmp != NULL) {
        if(!strcmp(tmp->idVal, a)) {
            if(tmp->dataType == IN)
                return t1;
            else
                return t2;
        }
    tmp = tmp->next;
    }
    return t;
}

int typeCheck(struct node *a, struct node *b) {
    if(a->check == b->check)
        return 1;
    else {
        return 0;
    }
}

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

void printTable(struct symbol *point) {
    if(point == NULL)
        return;
    printf("\n %d \t %d \t %d \t %s ", point->scope, point->dataType, point->size, point->idVal);
    printTable(point->next);
    printf("\n");
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

    //printf("\nGlobal syntax table:\n");
    //printTable(headG);
    //printf("\nLocal syntax table:\n");
    //printTable(headL);
    return 0;
}
