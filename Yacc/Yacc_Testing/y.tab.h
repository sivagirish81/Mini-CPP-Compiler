/* A Bison parser, made by GNU Bison 3.0.4.  */

/* Bison interface for Yacc-like parsers in C

   Copyright (C) 1984, 1989-1990, 2000-2015 Free Software Foundation, Inc.

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

#ifndef YY_YY_Y_TAB_H_INCLUDED
# define YY_YY_Y_TAB_H_INCLUDED
/* Debug traces.  */
#ifndef YYDEBUG
# define YYDEBUG 0
#endif
#if YYDEBUG
extern int yydebug;
#endif

/* Token type.  */
#ifndef YYTOKENTYPE
# define YYTOKENTYPE
  enum yytokentype
  {
    T_keyword = 258,
    T_int = 259,
    T_main = 260,
    T_type = 261,
    T_return = 262,
    T_for = 263,
    T_while = 264,
    T_InputStream = 265,
    T_OutputStream = 266,
    T_openParenthesis = 267,
    T_closedParanthesis = 268,
    T_openFlowerBracket = 269,
    T_closedFlowerBracket = 270,
    T_RelationalOperator = 271,
    T_LogicalOperator = 272,
    T_UnaryOperator = 273,
    T_ArithmeticOperator = 274,
    T_AssignmentOperator = 275,
    T_BitwiseOperator = 276,
    T_Semicolon = 277,
    T_identifier = 278,
    T_numericConstants = 279,
    T_stringLiteral = 280,
    T_character = 281,
    T_whiteSpace = 282,
    AND = 283,
    OR = 284,
    NOT = 285,
    EQ = 286,
    NOTEQ = 287,
    GTE = 288,
    LTE = 289,
    GT = 290,
    LT = 291,
    INC = 292,
    DEC = 293
  };
#endif
/* Tokens.  */
#define T_keyword 258
#define T_int 259
#define T_main 260
#define T_type 261
#define T_return 262
#define T_for 263
#define T_while 264
#define T_InputStream 265
#define T_OutputStream 266
#define T_openParenthesis 267
#define T_closedParanthesis 268
#define T_openFlowerBracket 269
#define T_closedFlowerBracket 270
#define T_RelationalOperator 271
#define T_LogicalOperator 272
#define T_UnaryOperator 273
#define T_ArithmeticOperator 274
#define T_AssignmentOperator 275
#define T_BitwiseOperator 276
#define T_Semicolon 277
#define T_identifier 278
#define T_numericConstants 279
#define T_stringLiteral 280
#define T_character 281
#define T_whiteSpace 282
#define AND 283
#define OR 284
#define NOT 285
#define EQ 286
#define NOTEQ 287
#define GTE 288
#define LTE 289
#define GT 290
#define LT 291
#define INC 292
#define DEC 293

/* Value type.  */
#if ! defined YYSTYPE && ! defined YYSTYPE_IS_DECLARED
typedef int YYSTYPE;
# define YYSTYPE_IS_TRIVIAL 1
# define YYSTYPE_IS_DECLARED 1
#endif


extern YYSTYPE yylval;

int yyparse (void);

#endif /* !YY_YY_Y_TAB_H_INCLUDED  */
