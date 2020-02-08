
%{
    #include <stdio.h>
    #include <stdlib.h>
	int yydebug = 1;
%}

%token T_keyword T_int T_main T_type T_return T_for T_if T_else T_while T_InputStream T_OutputStream 
%token T_openParenthesis T_closedParanthesis T_openFlowerBracket T_closedFlowerBracket 
%token T_RelationalOperator T_LogicalOperator T_UnaryOperator T_ArithmeticOperator 
%token T_AssignmentOperator T_BitwiseOperator T_Semicolon T_identifier T_numericConstants T_stringLiteral
%token T_character
%token T_whiteSpace
%left '~' '^' '&' '|'
%left '+' '-'
%left '*' '/'
%left AND OR NOT EQ NOTEQ GTE LTE GT LT INC DEC

%%

Start : T_int T_main T_openParenthesis T_closedParanthesis T_openFlowerBracket block_end_flower  	{printf("Works!\n");}

block_end_flower : T_openFlowerBracket block_end_flower
				| stmt Multiple_stmts T_closedFlowerBracket
				| T_closedFlowerBracket

block :  T_openFlowerBracket block_end_flower
	    | stmt Multiple_stmts
	    | T_Semicolon
		;

/*Block is {}, Multiple statements, {block}, {Multiple statements}, ;*/

Multiple_stmts : stmt Multiple_stmts
		|
		;

/*Multiple states can be empty, while writing make sure you write stmt multiple_stmts*/

stmt : T_character	T_Semicolon					{/*Statement cannot be empty, block takes care of empty string*/}
		| if_stmt
		| while_stmt
		| for_stmt
		;


for_stmt : T_for T_openParenthesis expr T_Semicolon expr T_Semicolon expr T_closedParanthesis block

while_stmt : T_while T_openParenthesis expr T_closedParanthesis block

if_stmt : T_if T_openParenthesis expr T_closedParanthesis block elseif_else_empty

elseif_else_empty : T_else T_if T_openParenthesis expr T_closedParanthesis block elseif_else_empty
					| T_else Multiple_stmts_not_if
					| T_else T_openFlowerBracket block_end_flower
					|
					;

Multiple_stmts_not_if : stmt_without_if Multiple_stmts
					|T_Semicolon
					;

stmt_without_if : T_character T_Semicolon
					| while_stmt
					|for_stmt
					;

expr: 	T_character
		|
		;						

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
