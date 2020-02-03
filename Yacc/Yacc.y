
%{
    #include <stdio.h>
    #include <stdlib.h>
%}

%token T_keyword T_int T_main T_type T_return T_for T_while T_InputStream T_OutputStream 
%token T_OpenParenthesis T_ClosedParanthesis T_OpenFlowerBracket T_ClosedFlowerBracket 
%token T_RelationalOperator T_LogicalOperator T_UnaryOperator T_ArithmeticOperator 
%token T_AssignmentOperator T_BitwiseOperator T_Semicolon T_identifier T_NumericConstants T_StringLiteral
%left '~' '^' '&' '|'
%left '+' '-'
%left '*' '/'
%left AND OR NOT EQ NOTEQ GTE LTE GT LT INC DEC

%%

Start : int main'('')' stmt

stmt :     if '(' expr ')' stmt [else if '(' expr ')' stmt ][ else stmt ]
        |  while '(' expr ')' stmt
        |  for '(' [ assg ] ';' [ expr ] ';' [ assg ] ')' stmt
	    |  return [ expr ] ';'
	    |  Assignment
	    |  Name'(' [expr { ',' expr } ] ')' ';'
	    |  '{' { stmt } '}'
	    |  ';'  
        |   expr ';'
        |   NULL
        |   cout {{'<<' expr} [<< endl]}';

expr : '~' expr
	    |     '!' expr
        |   unary expr
        |   expr unary
        |   expr Logic_op expr
	    |   expr binop expr
	    |   expr relop expr
	    |   expr bitwise_op expr
	    |   '(' expr ')'
        |   Name
        |   Numeric_Constants
        |   String_Constants

binop :   +
	    | –
	    | *
	    | /
        | %

unary :     --
        |   ++

relop :   	 ==
	    |    !=
	    |    <=
	    |    <
	    |    >=
	    |    >

Logic_op :  &&
          | ||

bitwise_op :   &
            |  |
            |  ^

Assignment : dt [{Name','}]Name ';'
            |  dt Name '=' expr ';'
            |  Name '=' expr ';'

dt : int | short | byte | long | double | float | string | bool | char

%%

int yyerror() 
{ 
	printf("Syntax error\n");
	return 1;
} 


int main()
{
	yyparse();
	return 0;
}
