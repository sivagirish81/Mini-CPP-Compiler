
%{
	#include <stdio.h>
%}

%token T_keyword T_int T_main T_type T_return T_for T_while T_InputStream T_OutputStream T_OpenParenthesis T_ClosedParanthesis T_OpenFlowerBracket T_ClosedFlowerBracket T_RelationalOperator T_LogicalOperator T_UnaryOperator T_ArithmeticOperator T_AssignmentOperator T_BitwiseOperator T_Semicolon T_identifier T_NumericConstants T_StringLiteral


%%


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