
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

Start : T_int T_main T_openParenthesis T_closedParanthesis T_openFlowerBracket block  	{printf("Works!\n");}

block :  T_openFlowerBracket block
	    | stmt Multiple_stmts T_closedFlowerBracket
	    | T_closedFlowerBracket
		|
		;

/*Block is {}, Multiple statements, {block}, {Multiple statements}, Empty*/

Multiple_stmts : stmt Multiple_stmts
		|
		;

stmt : T_character	T_Semicolon					{/*Statement cannot be nothing, block takes care of empty string*/}
		| if_stmt
		;

if_stmt : T_if T_openParenthesis expr T_closedParanthesis block


expr: T_character;						/*If cannot be empty*/

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
