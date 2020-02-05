
%{
    #include <stdio.h>
    #include <stdlib.h>
%}

%token T_keyword T_int T_main T_type T_return T_for T_while T_InputStream T_OutputStream 
%token T_openParenthesis T_closedParanthesis T_openFlowerBracket T_closedFlowerBracket 
%token T_RelationalOperator T_LogicalOperator T_UnaryOperator T_ArithmeticOperator 
%token T_AssignmentOperator T_BitwiseOperator T_Semicolon T_identifier T_numericConstants T_stringLiteral T_character T_whiteSpace
%left '~' '^' '&' '|'
%left '+' '-'
%left '*' '/'
%left AND OR NOT EQ NOTEQ GTE LTE GT LT INC DEC

%%

Start : expr T_stringLiteral  {printf("Works!\n"); return 0;}
		

expr : 	T_numericConstants
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
