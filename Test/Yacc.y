
%{
    #include <stdio.h>
    #include <stdlib.h>
%}

%token T_keyword T_int T_main T_type T_return T_for T_if T_else T_while T_InputStream T_OutputStream 
%token T_openParenthesis T_closedParanthesis T_openFlowerBracket T_closedFlowerBracket 
%token T_RelationalOperator T_LogicalOperator T_UnaryOperator T_ArithmeticOperator 
%token T_AssignmentOperator T_BitwiseOperator T_Semicolon T_identifier T_numeric_Constants T_string_Constants
%left '~' '^' '&' '|'
%left '+' '-'
%left '*' '/'
%left AND OR NOT EQ NOTEQ GTE LTE GT LT INC DEC

%%

Start : T_int T_main T_openParenthesis T_closedParanthesis block 

block :  T_openFlowerBracket block T_closedFlowerBracket
	    | stmt block
	    | stmt

If_Stmt : 	If_Stmt T_else block
		|	If_Stmt	T_else If_Stmt
		|	T_if  T_openParenthesis expr T_closedParanthesis block

For_Stmt : T_for T_openParenthesis Assignment expr ';' expr T_closedParanthesis block
		 | T_for T_openParenthesis ';' ';' T_closedParanthesis block
			
stmt  : 	If_Stmt
     	|   For_Stmt
	    |   T_return expr ';'
		|	T_return ';'
	    |   Assignment
	    |  ';'  
        |   T_keyword Multi_Print ';'

Multi_Print : Multi_Print '<''<' Printing_Types 
			| '<''<' Printing_Types

Printing_Types : expr | T_string_Constants

expr : 		'~' expr
	    |   '!' expr
        |   unary expr
        |   expr unary
        |   expr Logic_op expr
	    |   expr binop expr
	    |   expr relop expr
	    |   expr bitwise_op expr
	    |   T_openParenthesis expr T_closedParanthesis
        |   T_identifier
        |   T_numeric_Constants

binop :   T_ArithmeticOperator

unary :    T_UnaryOperator

relop :   	T_RelationalOperator

Logic_op :  T_LogicalOperator

bitwise_op :   T_BitwiseOperator

Declaration : dt T_identifier ';'

Assignment :   dt Multi_Assign ';'	
            |  dt T_identifier '=' expr ';'
            |  T_identifier '=' expr ';'

Multi_Assign : Multi_Assign ',' Assignment 
			  | Assignment


dt : T_type | T_int

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
