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

//FILE *fp;
//fp = fopen("sil.asm", "a");

void yyerror(char *);
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
struct idReg *head = NULL;;

int checker=0,scopeG=GS, tempTypeG=2, regCount=0, tmpCount=0, idCount=0, labelCount=0;
char glob[3000] = {};

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

main_funct      : INTEGER MAIN '(' ')' '{' global_var K_BEGIN body RETURN INT ';' END '}'   { addTac($8);
                                                                                              printf("\n>>> %s <<\n", $8->code);
                                                                                            }
                ;

body	: statement ';' body    { $$ = makenode(BD, 0, "", $1, $3, NULL, 0);
                                  /*if(!strcmp($1->check, "void") && !strcmp($3->check, "void")) //|| ($3 == NULL)))
                                    $$->check = "void";
                                  else
                                    yyerror("body  ");*/

                                  //addTac($1);
                                  //printf("\n%s\n", $1->code);
                                  //printTree($1);
                                }
	    |                       { $$ = makenode(BD1, 0, "", NULL, NULL, NULL, 0);
                                  //$$->check = "void";
                                }
	    ;

statement	: assignment_stmnt  { $$ = $1; //printf("sadas");
                                  //$$->check = $1->check;
                                  //printTree($1);
                                }
		    | conditional_stmnt { $$ = $1;
                                  //$$->check = $1->check;
                                  //printTree($1);
                                }
		    | iterative_stmnt   { $$ = $1;
                                  //$$->check = $1->check;
                                  //printTree($1);
                                }
		    | in_out_stmnt      { $$ = $1;
                                  //$$->check = $1->check;
                                  //printTree($1);
                                }
		    ;


conditional_stmnt	: IF '(' condition ')' THEN body ELSE body ENDIF    { $$ = makenode(IF1, 0, "", $3, $6, $8, 0); 
                                                                          /*if(!strcmp($3->check, "bool") && !strcmp($6->check, "void") && !strcmp($8->check, "void"))
                                                                            $$->check = "void";
                                                                          else
                                                                            yyerror("if_one  \n ");*/
                                                                        }
			        | IF '(' condition ')' THEN body ENDIF              { $$ = makenode(IF2, 0, "", $3, $6, NULL, 0); 
                                                                          /*if(!strcmp($3->check, "bool") && !strcmp($6->check, "void"))
                                                                            $$->check = "void";
                                                                          else
                                                                            yyerror("if_two\n");*/
                                                                        }
			        ;

iterative_stmnt	: WHILE '(' condition ')' DO body ENDWHILE  { $$ = makenode(IS, 0, "", $3, $6, NULL, 0);
                                                              /*if(!strcmp($3->check, "bool") && !strcmp($6->check, "void"))
                                                                $$->check = "void";
                                                              else
                                                                yyerror("while  \n ");*/
                                                           }
		        ;

condition	: expr 'a' expr { $$ = makenode(GE1, 0, "", $1, $3, NULL, 0); 
                              /*if(typeCheck($1, $3) && !strcmp($1->check, "int"))
                                $$->check = "bool";
                              else
                                yyerror("condition1 \n");*/
                            }
		    | expr 'b' expr { $$ = makenode(LE1, 0, "", $1, $3, NULL, 0); 
                              /*if(typeCheck($1, $3) && !strcmp($1->check, "int"))
                                $$->check = "bool";
                              else
                                yyerror("condition2\n");*/
                            }
		    | expr 'c' expr { $$ = makenode(L1, 0, "", $1, $3, NULL, 0); 
                              /*if(typeCheck($1, $3) && !strcmp($1->check, "int"))
                                $$->check = "bool";
                              else
                                yyerror("condition3\n");*/
                            }
		    | expr 'd' expr { $$ = makenode(G1, 0, "", $1, $3, NULL, 0); 
                              /*if(typeCheck($1, $3) && !strcmp($1->check, "int"))
                                $$->check = "bool";
                              else
                                yyerror("condition4\n");*/
                            }
		    | expr 'e' expr { $$ = makenode(EE1, 0, "", $1, $3, NULL, 0); 
                              /*if(typeCheck($1, $3) && !strcmp($1->check, "int"))
                                $$->check = "bool";
                              else
                                yyerror("condition5\n");*/
                            }
            | expr 'f' expr { $$ = makenode(NE1, 0, "", $1, $3, NULL, 0); 
                              /*if(typeCheck($1, $3) && !strcmp($1->check, "int"))
                                $$->check = "bool";
                              else
                                yyerror("condition6\n");*/
                            }
            | expr          { $$ = $1;
                            }
		    ;


in_out_stmnt	: READ '(' var ')'      { $$ = makenode(RD, 0, "", $3, NULL, NULL, 0);
                                          //$$->check = "void";
                                        }
                | WRITE '(' expr ')'    { $$ = makenode(WR, 0, "", $3, NULL, NULL, 0); 
                                          //$$->check = "void"; 
                                        }
                ;

assignment_stmnt	: var '=' expr  { $$ = makenode(AS, 0, "", $1, $3, NULL, 0); 
                                      /*if(typeCheck($1, $3))
                                        { $$->check = "void"; printTree($$); }
                                      else {
                                        yyerror("assignment_stmnt\n");
                                        }*/
                                    }
			        ;

expr 	: type '+' expr	{ $$ = makenode(PL, 0, "", $1, $3, NULL, 0); 
                          /*if(typeCheck($1, $3))
                            $$->check = "int";
                          else
                            yyerror("type checking error");*/
                        }
      	| type '-' expr { $$ = makenode(SU, 0, "", $1, $3, NULL, 0);
                          /*if(typeCheck($1, $3))
                            $$->check = "int";
                          else
                            yyerror("type checking error");*/
                        }
      	| type '*' expr { $$ = makenode(ML, 0, "", $1, $3, NULL, 0);
                          /*if(typeCheck($1, $3))
                            $$->check = "int";
                          else
                            yyerror("type checking error");*/
                        }
  	    | type '/' expr { $$ = makenode(DV, 0, "", $1, $3, NULL, 0); 
                          /*if(typeCheck($1, $3))
                            $$->check = "int";
                          else
                            yyerror("type checking error"); */
                        }
	    | type OR expr  { $$ = makenode(R, 0, "", $1, $3, NULL, 0);
                          /*if(typeCheck($1, $3))
                            $$->check = "bool";
                          else
                            yyerror("type checking error");*/
                        }
        | type AND expr { $$ = makenode(ND, 0, "", $1, $3, NULL, 0);
                          /*if(typeCheck($1, $3))
                            $$->check = "bool";
                          else
                            yyerror("type checking error");*/
                        }
        | NOT expr      { $$ = makenode(NT, 0, "", $2, NULL, NULL, 0);
                          /*if($2->check == "bool")
                            $$->check = "bool";
                          else
                            yyerror("type checking error");*/
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


var     : ID '[' INT ']'    { $$ = makenode(AR , $3 , $1 , NULL, NULL, NULL, 0); 
                              if(checker<=1) 
                                makeSymbol(scopeG, tempTypeG, $1, $3);
                              char tmp[100] = {};
                              char *tp;
                              tp = lookup($1);     //lookup in the symbol table and returns error if not found or returns type if found
                              if(tp == "error") {
                                  sprintf(tmp, "%s variable not found", $1); 
                                  //yyerror(tmp); 
                                  return;
                              }
                            }
        | ID                { $$ = makenode(I , 0 , $1 , NULL, NULL, NULL, 0); 
                              //$$->id = 0;
                              if(checker<=1) 
                                makeSymbol(scopeG, tempTypeG, $1, 0);
                              char tmp[100] = {};
                              char *tp;
                              tp = lookup($1);
                              if(tp == "error") {
                                sprintf(tmp, "%s variable not found", $1); 
                                //yyerror(tmp); 
                                return;
                              }
                            }
        ;

type	: var { $$ = $1; 
                //$$->check = $1->check; 
              }

	    | INT { $$ = makenode(IN , $1 , "" , NULL, NULL, NULL, 0); 
                //$$->check = "int"; 
              }

	    | BOOL { $$ = makenode(BL , 0 , $1 , NULL, NULL, NULL, 0); 
                 //$$->check = "bool";
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
    //tmp->id = idCount++;

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

    char tmp[2000] = {};
    sprintf(tmp, "%s\n%s", point->code, glob);
    strcpy(glob, tmp);
    printf("----------------------------\n%s\n---------------------\n", glob);
/*
    //printf("\n>>%d\n", point->type);
    if(point->one) {
        printf("\n%s", (point->one)->code);
        printTree(point->one);
    }
    if(point->two) {
        printf("\n%s", (point->two)->code);
        printTree(point->two);
    }
    if(point->three) {
        printf("\n%s", (point->three)->code);
        printTree(point->three);
    }
    if(!((point->type == IN) || (point->type == I) || (point->type == BL)))
        printf("\n%s", point->code);
*/
    /*
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
        }   */
}

void printTable(struct symbol *point) {
    if(point == NULL)
        return;
    printf("\n %d \t %d \t %d \t %s ", point->scope, point->dataType, point->size, point->idVal);
    printTable(point->next);
    printf("\n");
}

void printCode(struct node *t) {
    if(t == NULL)
        return;

    printCode(t->one);
    printCode(t->two);
    printCode(t->three);
    //printf("\n>>>>> %s", t->code);
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
}

int addTac(struct node *t) {
    char temp1[100] = {};
    char temp2[100] = {};
    char *tmp, *q;
    int tp, tr, te;

    struct tac *new = (struct tac *)malloc(sizeof(struct tac *));
    //printf("\n%s <<\n", t->charVal);

    if(t == NULL) {
        //printf("\ndsfdsf\n");
        return 0;
    }

    if(t->type == I) {
        /*new->dest = t->charVal;
        new->op = "id";
        add(new);*/

        tp = idLook(regCount, t->id);
        sprintf(temp1, "MOV R%d [%s]", tp, t->charVal);
        t->code = malloc(sizeof(temp1));
        strcpy(t->code, temp1);
        //printf("\n%s", temp1);
        return tp;
    }
    else if(t->type == IN) {
        sprintf(temp1, "MOV R%d %d", regCount++, t->intVal);
        /*new->dest = temp1;
        sprintf(temp2, "%d", t->intVal);
        new->src1 = temp2;
        new->op = "in";
        add(new);*/
        t->code = malloc(sizeof(temp1));
        strcpy(t->code, temp1);
        //printf("\n%s", temp1);
        return (regCount-1);
    }
/*
    else if(t->type == AR) {
        sprintf(temp1, "_temp%d", tmpCount++);
        new->op = "ofst";
        new->dest = temp1;
        t->intVal *= 8;
        sprintf(temp2, "%d", t->intVal);
        new->src1 = t->charVal;
        new->src2 = temp2;
        add(new);
        new->op = "ar";
        sprintf(temp2, "_temp%d", tmpCount++);
        new->dest = temp2;
        new->src1 = temp1;
        printf("\n two\n");
        add(new);
        return new->dest;
    } */
    else if(t->type == PL) {
        //new->op = "+";
        int tp = addTac(t->one);
        int tq = addTac(t->two);
        sprintf(temp1, "%s\n%s\nADD R%d R%d", (t->one)->code, (t->two)->code, tp, tq);
        
        /*new->dest = temp1;
        new->src1 = addTac(t->one);
        new->src2 = addTac(t->two);
        add(new);*/

        t->code = malloc(sizeof(temp1));
        strcpy(t->code, temp1);
        //printf("\n%s", temp1);
        return tp;
    }
    else if(t->type == SU) {
        //new->op = "-";
        int tp = addTac(t->one);
        sprintf(temp1, "%s\n%s\nSUB R%d R%d", (t->one)->code, (t->two)->code, tp, addTac(t->two));
        /*new->dest = temp1;
        new->src1 = addTac(t->one);
        new->src2 = addTac(t->two);
        add(new);*/
        //printf("\n%s", temp1);
        t->code = malloc(sizeof(temp1));
        strcpy(t->code, temp1);
        return tp;
    }
    else if(t->type == ML) {
        //new->op = "*";
        int tp = addTac(t->one);
        sprintf(temp1, "%s\n%s\nMUL R%d R%d", (t->one)->code, (t->two)->code, tp, addTac(t->two));
        /*new->dest = temp1;
        new->src1 = addTac(t->one);
        new->src2 = addTac(t->two);
        add(new);*/
        //printf("\n%s", temp1);
        t->code = malloc(sizeof(temp1));
        strcpy(t->code, temp1);
        return tp;
    }
    else if(t->type == DV) {
        //new->op = "/";
        int tp = addTac(t->one);
        sprintf(temp1, "%s\n%s\nDIV R%d R%d", (t->one)->code, (t->two)->code, tp, addTac(t->two));
        /*new->dest = temp1;
        new->src1 = addTac(t->one);
        new->src2 = addTac(t->two);
        add(new);*/
        //printf("\n%s", temp1);
        t->code = malloc(sizeof(temp1));
        strcpy(t->code, temp1);
        return tp;
    }
    else if(t->type == AS) {
        //new->op = "=";
        tp = addTac(t->one);
        //new->src1 = addTac(t->two);addTac(t->two);
        sprintf(temp1, "%s\n%s\nMOV R%d R%d", (t->one)->code, (t->two)->code, tp, addTac(t->two));
        //printf("\n%s", temp1);
        t->code = malloc(sizeof(temp1));
        strcpy(t->code, temp1);
        return tp;
    }
    else if(t->type == BD) {
        addTac(t->one);
        addTac(t->two);
        sprintf(temp1,"%s\n%s", (t->one)->code, (t->two)->code);
        t->code = malloc(sizeof(temp1));
        strcpy(t->code, temp1);
        return 0;
    }
    else if(t->type == BD1) {
        addTac(t->one);
        strcpy(temp1, "");
        t->code = malloc(sizeof(temp1));
        strcpy(t->code, temp1);
        return 0;
    }
    else if(t->type == RD) {
        tp = addTac(t->one);
        sprintf(temp1,"%s\nRD R%d", (t->one)->code, tp);
        t->code = malloc(sizeof(temp1));
        strcpy(t->code, temp1);
        return 0;
    }
    else if(t->type == WR) {
        tp = addTac(t->one);
        sprintf(temp1,"%s\nWR R%d", (t->one)->code, tp);
        t->code = malloc(sizeof(temp1));
        strcpy(t->code, temp1);
        return 0;
    }
    else if(t->type == IF1) {
        tp = addTac(t->one);
        tr = addTac(t->two);
        te = addTac(t->three);

        //printf("\n>>%s <<\n", (t->three)->code);
        labelCount += 2;
        sprintf(temp1, "%s\nJZ R%d L%d\n%s\nJMP L%d\nL%d: %s\nL%d:", (t->one)->code, tp, labelCount-2, (t->two)->code, labelCount-1, (labelCount-2), (t->three)->code, (labelCount-1));
        t->code = malloc(sizeof(temp1));
        strcpy(t->code, temp1);
        return 0;
    }
    else if(t->type == IF2) {
        tp = addTac(t->one);
        tr = addTac(t->two);

        //printf("\n>>%s <<\n", (t->three)->code);
        labelCount += 1;
        sprintf(temp1, "%s\nJZ R%d L%d\n%s\nL%d:", (t->one)->code, tp, labelCount, (t->two)->code, labelCount);
        t->code = malloc(sizeof(temp1));
        strcpy(t->code, temp1);
        return 0;
    }
   else if(t->type == IS) {
        tp = addTac(t->one);
        tr = addTac(t->two);
        labelCount += 2;
        sprintf(temp1, "L%d:%s\nJZ R%d L%d\n%s\nJMP L%d\nL%d:", labelCount-2, (t->one)->code, tp, labelCount-1, (t->two)->code, labelCount-2, labelCount-1);
        t->code = malloc(sizeof(temp1));
        strcpy(t->code, temp1);
        return 0;
    }
    return 0;
}

/*
void add(struct tac *t) {
    printf("\n %s    %s    %s    %s", t->op, t->dest, t->src1, t->src2);
    t->next = head;
    head = t;
}
*/

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
    fprintf(stderr, "%s sdjfksbdj\n", s);
}

int main(void) {
    yyparse();

    //printf("\nGlobal syntax table:\n");
    //printTable(headG);
    printf("\nLocal syntax table:\n");
    printTable(headL);
    return 0;
}
