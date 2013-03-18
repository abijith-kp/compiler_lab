%{

#include "y.tab.h"
#include <stdio.h>
#include <stdlib.h>

#define GE 'a'
#define LE 'b'
#define L 'c'
#define G 'd'
#define EE 'e'
#define NE 'f'

void yyerror(char *);

extern YYSTYPE yylval;


%}

ID      [a-z][a-zA-Z0-9]*
INT             [0-9]+
INTEGER		(integer)
DECL		(decl)
ENDDECL		(enddecl)
BOOL		(True|false)
BOOLEAN		(boolean)
K_BEGIN		(begin)
END		(end)
RETURN		(return)
MAIN		(main)
AND		(and)
OR		(or)
NOT		(not)
WHILE		(while)
DO		(do)
ENDWHILE	(endwhile)
IF		(if)
THEN		(then)
ELSE		(else)
ENDIF		(endif)
READ		(read)
WRITE		(write)

%%

"/*"[^"*/"]*"*/"    printf("cccccccc");;
"//".*              ;

{DECL}          return DECL;
{ENDDECL}       return ENDDECL;
{BOOLEAN}       return BOOLEAN;
{INTEGER}       return INTEGER;
{K_BEGIN}	return K_BEGIN;
{END}		return END;
{RETURN}	return RETURN;
{MAIN}		return MAIN;
{BOOL}          return BOOL;
{AND}           return AND;
{OR}            return OR;
{NOT}           return NOT;
{WHILE}         return WHILE;
{DO}            return DO;
{ENDWHILE}      return ENDWHILE;
{IF}            return IF;
{THEN}          return THEN;
{ELSE}          return ELSE;
{ENDIF}		return ENDIF;
{READ}		return READ;
{WRITE}		return WRITE;

{ID}            { char *tmp = malloc(sizeof(yyleng));
                  return ID;
{INT}           { yylval.intVal = atoi(yytext);
                  return INT;
                }

"<="       return LE;
">="    return GE;
"=="         return EE;
"!="            return NE;
"<"             return L;
">"          return G;

"&"           return *yytext;
";"	      return *yytext;
","         return *yytext;
"="         return *yytext;
"+"       	   return *yytext;
"-"        	 return *yytext;
"/"     	   return *yytext;
"*"	      return *yytext;

"("   return *yytext;
")"    return *yytext;
"["    return *yytext;
"]"    return *yytext;
"{"   return *yytext;
"}"   return *yytext;

.		;
