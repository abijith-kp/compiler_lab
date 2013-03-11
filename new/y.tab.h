/* A Bison parser, made by GNU Bison 2.5.  */

/* Bison interface for Yacc-like parsers in C
   
      Copyright (C) 1984, 1989-1990, 2000-2011 Free Software Foundation, Inc.
   
   This program is free software: you can redistribute it and/or modify
   it under the terms of the GNU General Public License as published by
   the Free Software Foundation, either version 3 of the License, or
   (at your option) any later version.
   
   This program is distributed in the hope that it will be useful,
   but WITHOUT ANY WARRANTY; without even the implied warranty of
   MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the
   GNU General Public License for more details.
   
   You should have received a copy of the GNU General Public License
   along with this program.  If not, see <http://www.gnu.org/licenses/>.  */

/* As a special exception, you may create a larger work that contains
   part or all of the Bison parser skeleton and distribute that work
   under terms of your choice, so long as that work isn't itself a
   parser generator using the skeleton or a modified version thereof
   as a parser skeleton.  Alternatively, if you modify or redistribute
   the parser skeleton itself, you may (at your option) remove this
   special exception, which will cause the skeleton and the resulting
   Bison output files to be licensed under the GNU General Public
   License without this special exception.
   
   This special exception was added by the Free Software Foundation in
   version 2.2 of Bison.  */


/* Tokens.  */
#ifndef YYTOKENTYPE
# define YYTOKENTYPE
   /* Put the tokens into the symbol table, so that GDB and other debuggers
      know about them.  */
   enum yytokentype {
     INT = 258,
     INTEGER = 259,
     ID = 260,
     BOOL = 261,
     BOOLEAN = 262,
     DECL = 263,
     ENDDECL = 264,
     K_BEGIN = 265,
     END = 266,
     RETURN = 267,
     MAIN = 268,
     AND = 269,
     OR = 270,
     NOT = 271,
     WHILE = 272,
     DO = 273,
     ENDWHILE = 274,
     IF = 275,
     THEN = 276,
     ELSE = 277,
     ENDIF = 278,
     READ = 279,
     WRITE = 280
   };
#endif
/* Tokens.  */
#define INT 258
#define INTEGER 259
#define ID 260
#define BOOL 261
#define BOOLEAN 262
#define DECL 263
#define ENDDECL 264
#define K_BEGIN 265
#define END 266
#define RETURN 267
#define MAIN 268
#define AND 269
#define OR 270
#define NOT 271
#define WHILE 272
#define DO 273
#define ENDWHILE 274
#define IF 275
#define THEN 276
#define ELSE 277
#define ENDIF 278
#define READ 279
#define WRITE 280




#if ! defined YYSTYPE && ! defined YYSTYPE_IS_DECLARED
typedef union YYSTYPE
{

/* Line 2068 of yacc.c  */
#line 8 "sil_yacc.yacc"
 int intVal;
	  char charVal;
	


/* Line 2068 of yacc.c  */
#line 106 "y.tab.h"
} YYSTYPE;
# define YYSTYPE_IS_TRIVIAL 1
# define yystype YYSTYPE /* obsolescent; will be withdrawn */
# define YYSTYPE_IS_DECLARED 1
#endif

extern YYSTYPE yylval;


