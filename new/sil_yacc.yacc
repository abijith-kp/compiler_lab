%{
#include <stdio.h>
#include <string.h>
#include <stdlib.h>

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
#define BD1 27

void yyerror(char *);
int yylex(void);
void makeSymbol(int scope, int dataType, char *idVal, int size);

struct node {
	int type;
	int intVal;
    char *check;
	char *charVal;
	int datatype;
    char *code;
    int id;
    struct node *one;
	struct node *two;
	struct node *three;
	};

struct symbol {
    int scope;
    int dataType;
    char *idVal;
    int size;
    int binding;
    struct symbol *next;
    };

struct tac {
    char *op;
    char *dest;
    char *src1;
    char *src2;
    struct tac *next;
};

struct idReg {
    int id;
    int reg;
    struct idReg *next;
};

struct symbol *headG = NULL, *headL = NULL;
struct idReg *head = NULL;

int checker=0,scopeG=GS, tempTypeG=2, regCount=0, tmpCount=0, idCount=0, labelCount=0, bod=0, memoryAdd = 100;
char glob[3000] = {}, glob1[3000] = {}, *temp2, globReg=0;

struct node *makenode(int type, int intVal, char *charVal, struct node *one, struct node *two, struct node *three, int id);
void printTree(struct node *n);
void printTable(struct symbol *n);
int typeCheck(struct node *a, struct node *b);
char *lookup(char *a);
int addTac(struct node *);
int idLook(int a, int b);
void addReg(char *, int);
int checkT(char *);
void add(struct tac *t);
void printCode(struct node *t);
int check(char *t, int type, struct symbol *p);
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

start	: global_var function_def main_funct    { printf("main"); }
        | global_var main_funct { }
	    ;

main_funct      : INTEGER MAIN '(' ')' '{' global_var K_BEGIN body RETURN INT ';' END '}'   { addTac($8);
                                                                                              printf("\nSTART\n%s\nHALT\n", $8->code);
                                                                                            }
                ;

function_def    : INTEGER ID '(' ')' '{' global_var K_BEGIN RETURN INT ';' END '}'
                | BOOLEAN ID '(' ')' '{' global_var K_BEGIN RETURN BOOL ';' END '}'
                ;



body	: statement ';' body    { $$ = makenode(BD, 0, "", $1, $3, NULL, 0);
                                }
	    |                       { $$ = makenode(BD1, 0, "", NULL, NULL, NULL, 0);
                                }
	    ;

statement	: assignment_stmnt  { $$ = $1;
                                }
		    | conditional_stmnt { $$ = $1;
                                }
		    | iterative_stmnt   { $$ = $1;
                                }
		    | in_out_stmnt      { $$ = $1;
                                }
            | function_def      {
                                }
		    ;


conditional_stmnt	: IF '(' condition ')' THEN body ELSE body ENDIF    { $$ = makenode(IF1, 0, "", $3, $6, $8, 0); 
                                                                        }
			        | IF '(' condition ')' THEN body ENDIF              { $$ = makenode(IF2, 0, "", $3, $6, NULL, 0); 
                                                                        }
			        ;

iterative_stmnt	: WHILE '(' condition ')' DO body ENDWHILE  { $$ = makenode(IS, 0, "", $3, $6, NULL, 0); }
		        ;

condition	: expr 'a' expr { $$ = makenode(GE1, 0, "", $1, $3, NULL, 0); 
                            }
		    | expr 'b' expr { $$ = makenode(LE1, 0, "", $1, $3, NULL, 0); 
                            }
		    | expr 'c' expr { $$ = makenode(L1, 0, "", $1, $3, NULL, 0); 
                            }
		    | expr 'd' expr { $$ = makenode(G1, 0, "", $1, $3, NULL, 0); 
                            }
		    | expr 'e' expr { $$ = makenode(EE1, 0, "", $1, $3, NULL, 0); 
                            }
            | expr 'f' expr { $$ = makenode(NE1, 0, "", $1, $3, NULL, 0); 
                            }
            | expr          { $$ = $1;
                            }
		    ;


in_out_stmnt	: READ '(' var ')'      { $$ = makenode(RD, 0, "", $3, NULL, NULL, 0);
                                        }
                | WRITE '(' expr ')'    { $$ = makenode(WR, 0, "", $3, NULL, NULL, 0); 
                                        }
                ;

assignment_stmnt	: var '=' expr  { $$ = makenode(AS, 0, "", $1, $3, NULL, 0); 
                                    }
			        ;

expr 	: type '+' expr	{ $$ = makenode(PL, 0, "", $1, $3, NULL, 0); 
                        }
      	| type '-' expr { $$ = makenode(SU, 0, "", $1, $3, NULL, 0);
                        }
      	| type '*' expr { $$ = makenode(ML, 0, "", $1, $3, NULL, 0);
                        }
  	    | type '/' expr { $$ = makenode(DV, 0, "", $1, $3, NULL, 0); 
                        }
	    | type OR expr  { $$ = makenode(R, 0, "", $1, $3, NULL, 0);
                        }
        | type AND expr { $$ = makenode(ND, 0, "", $1, $3, NULL, 0);
                        }
        | NOT expr      { $$ = makenode(NT, 0, "", $2, NULL, NULL, 0);
                        }
	    | type	        { $$ = $1;
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


var     : ID '[' INT ']'    { $$ = makenode(AR , $3 , $1 , NULL, NULL, NULL, 0); 
                              if(checker<=1) 
                                makeSymbol(scopeG, tempTypeG, $1, $3);
                              char tmp[100] = {};
                              char *tp;
                              tp = lookup($1);     //lookup in the symbol table and returns error if not found or returns type if found
                              if(!strcmp(tp, "error")) {
                                  sprintf(tmp, "%s variable not found", $1); 
                              }
                            }
        | ID                { $$ = makenode(I , 0 , $1 , NULL, NULL, NULL, 0); 
                              if(checker<=1) 
                                makeSymbol(scopeG, tempTypeG, $1, 0);
                              char tmp[100] = {};
                              char *tp;
                              tp = lookup($1);
                              if(!strcmp(tp, "error")) {
                                sprintf(tmp, "%s variable not found", $1);
                                yyerror(tmp);
                              }
                            }
        ;

type	: var { $$ = $1; 
              }

	    | INT { $$ = makenode(IN , $1 , "" , NULL, NULL, NULL, 0); 
              }

	    | BOOL { $$ = makenode(BL , 0 , $1 , NULL, NULL, NULL, 0); 
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

    while(tmp != NULL) {
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
        if(check(idVal, dataType, headL)) {
            yyerror(idVal);
        }
        else {
	    tmp->next = headL;
        headL = tmp;
        tmp->binding = memoryAdd++;
        }
    }
    else if(scopeL == GS) {
        if(check(idVal, dataType, headG)) {
            yyerror(idVal);
        }
        else {
            tmp->next = headG;
            headG = tmp;
        }
    }
}

int check(char *name, int type, struct symbol *point) {
    if(point == NULL)
        { return 0; }
    if(!(strcmp(point->idVal, name)) && (point->dataType == type))
        { return 1; }
    else
        { check(name, type, point->next); }
    return 0;
}

void printTree(struct node *point) {
    if(point == NULL)
        return;

    char tmp[2000] = {};
    sprintf(tmp, "%s\n%s", point->code, glob);
    strcpy(glob, tmp);
}

void printTable(struct symbol *point) {
    if(point == NULL)
        return;
    printf("\n %d \t %d \t %d \t %s \t %d", point->scope, point->dataType, point->size, point->idVal, point->binding);
    printTable(point->next);
    printf("\n");
}

void printCode(struct node *t) {
    if(t == NULL)
        return;

    printCode(t->one);
    printCode(t->two);
    printCode(t->three);
}

int idLook(int a, int b) { //returns the corresponding registre number
    struct idReg *h = head;
    struct idReg *ir = malloc(sizeof(struct idReg));

    
    if(b == 0) {
        ir->id = b;
        ir->reg = a;
        regCount++;
        ir->next = head;
        head = ir;
        return (regCount-1);
    }
    while(h) {
        if(h->id == b)
            return h->reg;
        else
            h = h->next;
    }
    return b;
}

void look(char *name) {
    struct symbol *tmp = headL;
    int t;

    while(tmp) {
        if(!strcmp(tmp->idVal, name)) {
            globReg = tmp->binding;
            return;
        }
        tmp = tmp->next;
    }
    tmp = headG;
    while(tmp) {
        if(!strcmp(tmp->idVal, name)) {
            globReg = tmp->binding;
            return;
        }
        tmp = tmp->next;
    }
}

int addTac(struct node *t) {
    char temp1[10000] = {}, temp2[10000] = {}, temp3[10000] = {};
    int tp, tr;

    if(t == NULL) {
        return 0;
    }

    if(t->type == I) {
        tp = idLook(regCount, t->id);
        look(t->charVal);
        sprintf(temp1, "MOV R%d %d", tp, globReg);
        t->code = malloc(sizeof(temp1));
        strcpy(t->code, temp1);
        return tp;
    }
    else if(t->type == IN) {
        sprintf(temp1, "MOV R%d %d", regCount++, t->intVal);
        t->code = malloc(sizeof(temp1));
        strcpy(t->code, temp1);

        return (regCount-1);
    }
    else if(t->type == BL) {
        tp = 0;
        if(!strcmp(t->charVal, "true"))
            tp = 1;
        sprintf(temp1, "MOV R%d %d", regCount++, tp);
        t->code = malloc(sizeof(temp1));
        strcpy(t->code, temp1);

        return (regCount-1);
    }/*
    else if(t->type == AR) {
        //printf("\nAR\n");
        tp = idLook(regCount, t->id);
        sprintf(temp1, "MOV R%d %d", regCount++, t->intVal);
        sprintf(temp2, "MUL R%d 8", regCount-1);
        sprintf(temp3, "%s\n%s", temp1, temp2);
        sprintf(temp1, "MOV R%d %d", tp, t->binding);
        sprintf(temp2, "%s\n%s\nADD R%d R%d", temp1, temp3, regCount-2, regCount-1);
        t->code = malloc(sizeof(temp2));
        strcpy(t->code, temp2);
        return tp;
    }*/
    else if(t->type == PL) {
        //new->op = "+";
        int tp = addTac(t->one);
        int tq = addTac(t->two);
        sprintf(temp1, "%s\n%s\nADD R%d R%d", (t->one)->code, (t->two)->code, tp, tq);
        t->code = malloc(sizeof(temp1));
        strcpy(t->code, temp1);
        return tp;
    }
    else if(t->type == SU) {
        tp = addTac(t->one);
        tr = addTac(t->two);
        sprintf(temp1, "%s\n%s\nSUB R%d R%d", (t->one)->code, (t->two)->code, tp, tr);
        t->code = malloc(sizeof(temp1));
        strcpy(t->code, temp1);
        return tp;
    }
    else if(t->type == ML) {
        tp = addTac(t->one);
        tr = addTac(t->two);
        sprintf(temp1, "%s\n%s\nMUL R%d R%d", (t->one)->code, (t->two)->code, tp, tr);
        t->code = malloc(sizeof(temp1));
        strcpy(t->code, temp1);
        return tp;
    }
    else if(t->type == DV) {
        tp = addTac(t->one);
        tr = addTac(t->two);
        sprintf(temp1, "%s\n%s\nDIV R%d R%d", (t->one)->code, (t->two)->code, tp, tr);
        t->code = malloc(sizeof(temp1));
        strcpy(t->code, temp1);
        return tp;
    }
    else if(t->type == AS) {
        tp = addTac(t->one);
        tr = addTac(t->two);
        look(t->charVal);
        sprintf(temp1, "%s\n%s\nMOV R%d R%d\nMOV [%d] R%d", (t->one)->code, (t->two)->code, tp, tr, globReg, tp);
        t->code = malloc(sizeof(temp1));
        strcpy(t->code, temp1);
        regCount = 0;
        return tp;
    }
    else if(t->type == BD) {
        addTac(t->one);
        addTac(t->two);
        sprintf(temp1, "%s\n%s", (t->one)->code, (t->two)->code);
        t->code = malloc(sizeof(temp1));
        t->code = temp1;
        return 0;
    }
    else if(t->type == BD1) {
        strcpy(temp1, "");
        t->code = malloc(sizeof(temp1));
        strcpy(t->code, temp1);
        return 0;
    }
    else if(t->type == RD) {
        tp = addTac(t->one);
        sprintf(temp1,"%s\nIN R%d", (t->one)->code, tp);
        
        t->code = malloc(sizeof(temp1));
        strcpy(t->code, temp1);
        regCount = 0;
        return 0;
    }
    else if(t->type == WR) {
        tp = addTac(t->one);
        sprintf(temp1,"%s\nOUT R%d", (t->one)->code, tp);
        t->code = malloc(sizeof(temp1));
        strcpy(t->code, temp1);
        regCount = 0;
        return 0;
    }
    else if(t->type == IF1) {
        tp = addTac(t->one);
        tr = addTac(t->two);
        addTac(t->three);

        labelCount += 2;
        sprintf(temp1, "%s\nJZ R%d L%d\n%s\nJMP L%d\nL%d: %s\nL%d:", (t->one)->code, tp, labelCount-2, (t->two)->code, labelCount-1, labelCount-2, (t->three)->code, labelCount-1);
        t->code = malloc(sizeof(temp1));
        strcpy(t->code, temp1);
        regCount = 0;
        return 0;
    }
    else if(t->type == IF2) {
        tp = addTac(t->one);
        tr = addTac(t->two);
  
        labelCount += 1;
        sprintf(temp1, "%s\nJZ R%d L%d\n%s\nL%d:", (t->one)->code, tp, labelCount-1, (t->two)->code, labelCount-1);
        t->code = malloc(sizeof(temp1));
        strcpy(t->code, temp1);
        regCount = 0;
        return 0;
    }
   else if(t->type == IS) {
        tp = addTac(t->one);
        tr = addTac(t->two);
        labelCount += 2;
        sprintf(temp1, "L%d:%s\nJZ R%d L%d\n%s\nJMP L%d\nL%d:", labelCount-2, (t->one)->code, tp, labelCount-1, (t->two)->code, labelCount-2, labelCount-1);
        t->code = malloc(sizeof(temp1));
        strcpy(t->code, temp1);
        regCount = 0;
        return 0;
    }
    return 0;
}

struct node *makenode(int type, int intVal, char *charVal, struct node *one, struct node *two, struct node *three, int id) {
    struct node *tmp = malloc(sizeof(struct node));
    tmp->type = type;
    tmp->charVal = charVal;
    tmp->intVal = intVal;
    tmp->one = one;
    tmp->two = two;
    tmp->three = three;
    tmp->id = 0;
    
    return tmp;
}

void yyerror(char *s) {
    fprintf(stderr, "ERROR: %s\n", s);
    exit(0);
}

int main(void) {
    yyparse();

    //printf("\nGlobal syntax table:\n");
    //printTable(headG);
    //printf("\nLocal syntax table:\n");
    //printTable(headL);
    return 0;
}
