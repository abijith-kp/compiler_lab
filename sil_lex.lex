%{

#include "y.tab.h"
#include <stdio.h>
#include <stdlib.h>
void yyerror(char *);
extern int yylval;

%}

ID      [a-z][a-zA-Z0-9]*
INT             [0-9]+
INTEGER		(integer)
DECL		(decl)
ENDDECL		(enddecl)
SEMICOLN	(;)
COMMA		(,)
EQUAL		(=)
BOOL		(True|false)
BOOLEAN		(boolean)
AMP		(&)
SIM_BRAC_O	(\()
SIM_BRAC_C	(\))
SQR_BRAC_O	(\[)
SQR_BRAC_C	(\])
CURL_BRAC_O	(\{)
CURL_BRAC_C	(\})
K_BEGIN		(begin)
END		(end)
RETURN		(return)
MAIN		(main)
PLUS		(\+)
MINUS		(-)
DIVIDE		(\/)
MULTIPLY	(\*)
AND		(and)
OR		(or)
NOT		(not)
WHILE		(while)
DO		(do)
ENDWHILE	(endwhile)
LESS_THAN	(<)
GREATER_THAN	(>)
LESS_THAN_EQUAL	(<=)
GREATER_THAN_EQUAL	(>=)
EXACTLY_EQUAL	(==)
NOT_EQUAL	(!=)
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

{ID}            return ID;
{INT}           return INT;

{LESS_THAN_EQUAL}       return LESS_THAN_EQUAL;
{GREATER_THAN_EQUAL}    return GREATER_THAN_EQUAL;
{EXACTLY_EQUAL}         return EXACTLY_EQUAL;
{NOT_EQUAL}             return NOT_EQUAL;
{LESS_THAN}             return LESS_THAN;
{GREATER_THAN}          return GREATER_THAN;

{AMP}           return AMP;
{SEMICOLN}      return SEMICOLN;
{COMMA}         return COMMA;
{EQUAL}         return EQUAL;
{PLUS}          return PLUS;
{MINUS}         return MINUS;
{DIVIDE}        return DIVIDE;
{MULTIPLY}      return MULTIPLY;

{SIM_BRAC_O}    return SIM_BRAC_O;
{SIM_BRAC_C}    return SIM_BRAC_C;
{SQR_BRAC_O}    return SQR_BRAC_O;
{SQR_BRAC_C}    return SQR_BRAC_C;
{CURL_BRAC_O}   return CURL_BRAC_O;
{CURL_BRAC_C}   return CURL_BRAC_C;
.		;
