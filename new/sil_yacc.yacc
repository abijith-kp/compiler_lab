%{
#include <stdio.h>
#include <string.h>

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
#define TMP 27

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

struct tac {
    char *dest;
    char *src1;
    char *src2;
    char *op;
    struct tac *next;
    };

struct reg {
    char *registr;
    char *tmp;
    struct reg *next;
};

struct symbol *headG = NULL, *headL = NULL;
struct tac *top=NULL;
struct reg *head=NULL;

int checker=0,scopeG=GS, tempTypeG=2, tmpCount=0, bufCount=0, regCount=0;
char *buffer[100];


struct node *makenode(int type, int intVal, char *charVal, struct node *one, struct node *two, struct node *three);
void printTree(struct node *n);
void printTable(struct symbol *n);
int typeCheck(struct node *a, struct node *b);
char *lookup(char *a);
void addTac(char *op, char *dest, char *src1, char *src2);
char *create_code(struct node *n);
void printCode(struct tac *t);
void assm(char *op, char *dest, char *src1, char *src2);
char *getReg(char *t);
void addReg(char *a, int b);


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

main_funct      : INTEGER MAIN '(' ')' '{' global_var K_BEGIN body RETURN INT ';' END '}'       { //create_code($8); //printf("{{{{{{}}}}}}}}}}"); printCode(); 
                          }
                ;

body	: statement ';' body    { $$ = makenode(BD, 0, "", $1, $3, NULL);
                                  if(!strcmp($1->check, "void") && !strcmp($3->check, "void"))// || ($3 == NULL)))
                                    $$->check = "void";
                                  else
                                    yyerror("body  ");
                                  create_code($1);
                                  printCode(top);
                                }
	    |                       { $$ = makenode(BD, 0, "", NULL, NULL, NULL);
                                  $$->check = "void"; 
                                }
	    ;

statement	: assignment_stmnt  { $$ = $1; //printf("sadas");
                                  $$->check = $1->check;
                                  //printTree($1);
                                  //create_code($1);
                                  //printCode();
                                }
		    | conditional_stmnt { $$ = $1;
                                  $$->check = $1->check;
                                  //printTree($1);
                                }
		    | iterative_stmnt   { $$ = $1;
                                  $$->check = $1->check;
                                  //printTree($1);
                                }
		    | in_out_stmnt      { $$ = $1;
                                  $$->check = $1->check;
                                  //printTree($1);
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
                              char *tmp;
                              tmp = lookup($1);     //lookup in the symbol table and returns error if not found or returns type if found
                              if(tmp != "error") {
                                $$->check = tmp;
                              }
                              else
                                yyerror("type checking error");
                            }
        | ID                { $$ = makenode(I , 0 , $1 , NULL, NULL, NULL); 
                              if(checker<=1) 
                                makeSymbol(scopeG, tempTypeG, $1, 0);
                              char *tmp;
                              tmp = lookup($1);
                              if(tmp != "error") {
                                $$->check = tmp;
                              }
                              else
                                yyerror("type checking error");

                            }
        ;

type	: var { $$ = $1; 
                $$->check = $1->check; 
              }

	    | INT { $$ = makenode(IN , $1 , "" , NULL, NULL, NULL); 
                $$->check = "int"; 
                //create_code($$);
              }

	    | BOOL { $$ = makenode(BL , 0 , $1 , NULL, NULL, NULL); 
                 $$->check = "bool";
                 //cireate_code($$);
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
        if(dataType == TMP) {
            tmp->next = headL;
            headL = tmp;
            return;
        }

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

char *create_code(struct node *nod) {
    //struct tac *tmp = malloc(sizeof(struct tac));
    char *tmp = "", *q = "";
    char t[100] = {};
    char t1[100] = {};

    if(nod->type == AS) {
        tmp = create_code(nod->one); 
        addTac("=", tmp, create_code(nod->two), "");
        return tmp;
    } 
    else if(nod->type == PL) {
        //tmpCount++;
        //sprintf(t, "_tmp%d", tmpCount);
        //makeSymbol(LS, TMP, t, 0);
        //tmp = t;
        addTac("+", (q=create_code(nod->one)), create_code(nod->two), "");
        return  q;
    }
    else if(nod->type == SU) {
        //tmpCount++;
        //sprintf(t, "_tmp%d", tmpCount);
        //tmp = t;
        //makeSymbol(LS, TMP, tmp, 0);
        addTac("-", (q = create_code(nod->one)), create_code(nod->two), "");
        return q;
    } 
    else if(nod->type == ML) {
        //tmpCount++;
        //sprintf(t, "_tmp%d", tmpCount);
        //makeSymbol(LS, TMP, t, 0);
        //tmp = t;
        addTac("*", (q = create_code(nod->one)), create_code(nod->two), "");
        return q;
    }
    else if(nod->type == DV) {
        //tmpCount++;
        //sprintf(t, "_tmp%d", tmpCount);
        //makeSymbol(LS, TMP, t, 0);
        //tmp = t;
        addTac("/", (q = create_code(nod->one)), create_code(nod->two), "");
        return q;
    }      

    if(nod->type == IN) {
        tmpCount++;
        sprintf(t, "_tmp%d", tmpCount);
        sprintf(t1, "%d", nod->intVal);
        makeSymbol(LS, TMP, t, 0);
        tmp = t;
        addTac("in", tmp, t1, "");
        return tmp;
    }
    else if(nod->type == BL) {
        tmpCount++;
        sprintf(t, "_tmp%d", tmpCount);
        makeSymbol(LS, TMP, t, 0);
        tmp = t;
        addTac("bl", tmp, nod->charVal, "");
        return tmp;
    }
    else if(nod->type == I) {
        tmp = nod->charVal;
        addTac("id", tmp, "", "");
        return tmp;
    }
    else if(nod->type == RD) {
        tmp = create_code(nod->one);
        addTac("rd", tmp, "", "");
    }
    else if(nod->type == WR) {
        tmp = create_code(nod->one);
        addTac("wr", tmp, "", "");
    }
    else if(nod->type == AR) 
         { sprintf(t, "%d", nod->intVal);
           addTac("ar", nod->charVal, t, "");
           return nod->charVal;
         }
    return "999oooo9999";
}

void printCode(struct tac *t) {
    //struct tac *q = malloc(sizeof(struct tac));
    //q = t;
    //int i=0;
    

    //while (q != NULL) {
        //printf("\n(%s) \t (%s) \t (%s) \t (%s)", q->op, q->dest, q->src1, q->src2);
     //   q = q->next;
    //}
    
    printf("\n***********************************************\n");

    struct reg *s = malloc(sizeof(struct reg));
    s = head;
    while(s) {
        printf("\n%s    %s", s->tmp, s->registr);
        s = s->next;
    } 
    printf("................................................");
}

void addTac(char *op, char *dest, char *src1, char *src2) {
    struct tac *t = (struct tac *) malloc(sizeof(struct tac));
    t->op = op;
    t->dest = dest;
    t->src1 = src1;
    t->src2 = src2;
    t->next = top;
    top = t;
    //printf("\n%s \t %s \t %s \t %s", top->op, top->dest, top->src1, top->src2);
    assm(op, dest, src1, src2);

    }

void assm(char *op, char *dest, char *src1, char *src2) {
    char t[100] = {};

    //printf(">>>> %s  %s\n", dest, op);
    if(!strcmp(op, "id")) {
        addReg(dest, regCount);
        sprintf(t , "MOV R%d [%s]", regCount++, dest);
        printf("\n%s", t);
    }
    else if(!strcmp(op, "in")) {
        addReg(dest, regCount);
        sprintf(t, "MOV R%d %s", regCount++, src1);
        printf("\n%s", t);
    }
    else if(!strcmp(op, "=")) {
        sprintf(t, "MOV %s [%s]", getReg(dest), getReg(src1));
        printf("\n%s\n", t);
    }
    else if(!strcmp(op, "*")) {

        sprintf(t, "MUL %s %s", getReg(src1), getReg(src2));
        printf("\n%s\n", t);
        //sprintf(t, "MOV %s %s", getReg(dest), getReg(src1));
        //printf("\n%s\n", t);
    }
    else if(!strcmp(op, "/")) {

        sprintf(t, "DIV %s %s", getReg(src1), getReg(src2));
        printf("\n%s\n", t);
        //sprintf(t, "MOV %s %s", getReg(dest), getReg(src1));
        //printf("\n%s\n", t);
    }
else if(!strcmp(op, "-")) {

        sprintf(t, "SUB %s %s", getReg(src1), getReg(src2));
        printf("\n%s\n", t);
        //sprintf(t, "MOV %s %s", getReg(dest), getReg(src1));
        //printf("\n%s\n", t);
    }
else if(!strcmp(op, "+")) {

        sprintf(t, "ADD %s %s", getReg(src1), getReg(src2));
        printf("\n%s\n", t);
        //sprintf(t, "MOV %s %s", getReg(dest), getReg(src1));
        //printf("\n%s\n", t);
    }

}

char *getReg(char *a) {
    struct reg *t;
    t = head;

    while(t) {
        if(!strcmp(t->tmp, a))
            return t->registr;
        t = t->next;
    }
}

void addReg(char *a, int b) {
    struct reg *tn = (struct reg *) malloc(sizeof(struct reg));
    struct reg *tq = (struct reg *)malloc(sizeof(struct reg));
    tq = head;
    int t=0;
    char tw[100] = {};
    
    sprintf(tw, "R%d", b);
    tn->tmp = a;
    tn->registr = tw;
    
   // if (tq == NULL) {
        tn->next = head;
        head = tn;
   //     return;
    //}
/*
    while(tq->next != NULL) {
        if(!strcmp(tq->tmp, a)) {
            regCount--;
            return;
        }
        tq = tq->next;
    }
    
    if (!strcmp(tq->tmp, a)) {
        regCount--;
        return;
    }
    
    tq->next = tn;
    tn->next = NULL;
    return; */
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
