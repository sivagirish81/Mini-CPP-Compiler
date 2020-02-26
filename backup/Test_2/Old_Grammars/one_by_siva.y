
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

Printing_Types : expr | T_stringLiteral

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
        |   T_numericConstants

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