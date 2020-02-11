
%{
    #include <stdio.h>
    #include <stdlib.h>
	int yydebug = 1;
	extern int st[100];
	extern int top;
	extern int count;
	extern void display();
%}

%token T_keyword T_int T_main T_type T_return T_for T_if T_else T_while T_InputStream T_OutputStream 
%token T_openParenthesis T_closedParanthesis T_openFlowerBracket T_closedFlowerBracket 
%token T_RelationalOperator T_LogicalOperator T_UnaryOperator 
%token T_AssignmentOperator  T_Semicolon T_identifier T_numericConstants T_stringLiteral
%token T_character T_plus T_minus T_mod T_divide T_multiply
%token T_whiteSpace T_shortHand

%left T_LogicalOperator 
%left T_RelationalOperator
%left T_plus T_minus
%left T_multiply T_divide
%left T_UnaryOperator

%%

/*Flower brackets are mandatory for main*/

Start : T_int T_main T_openParenthesis T_closedParanthesis T_openFlowerBracket block_end_flower  	{printf("Works!\n");}


/* This production assumes flower bracket has been opened*/
block_end_flower : stmt Multiple_stmts 
				| T_closedFlowerBracket

/*This takes care of statements like if(...);. Note that to include multiple statements, a block has to open with a flower bracket*/
block :  T_openFlowerBracket block_end_flower
	    | stmt
	    | T_Semicolon
		;

/* block would cover anything following statement. consider the for statement for example. All possiblities are:
for(expr;expr;expr);													(block -> ;)
for(...) stmt          , where stmt contains T_Semicolon				(block -> stmt)
for(...){}																(block -> {block_end_flower -> {})
for(...){stmt, stmt, stmt, ...}											(block -> {block_end_flower -> {smt Multiple_stmts})
for(...){stmt, if/while/for{stmt, stmt.}} , this is achieved implicity because stmt in previous can in turn be if or for while
*/


Multiple_stmts : stmt Multiple_stmts
		|T_closedFlowerBracket
		;

stmt : expr_with_semicolon					{/*Statement cannot be empty, block takes care of empty string*/}
		| if_stmt
		| while_stmt
		| for_stmt
		| Assignment_stmt T_Semicolon
		;


for_stmt : T_for T_openParenthesis expr_with_semicolon expr_with_semicolon expr_or_empty T_closedParanthesis block

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

stmt_without_if : expr_with_semicolon
					| Assignment_stmt T_Semicolon
					| while_stmt
					|for_stmt
					;

Assignment_stmt: T_identifier T_AssignmentOperator expr
				;

expr: T_numericConstants BinaryOperator T_numericConstants
		| T_identifier BinaryOperator T_numericConstants
		| T_identifier BinaryOperator T_identifier
		| T_UnaryOperator T_identifier
		| T_identifier T_UnaryOperator
		| T_numericConstants
		| T_stringLiteral
		| T_identifier

expr_or_empty: expr
				| 
				;

expr_with_semicolon:
		 T_numericConstants BinaryOperator T_numericConstants T_Semicolon
		| T_identifier BinaryOperator T_numericConstants T_Semicolon
		| T_identifier BinaryOperator T_identifier T_Semicolon
		| T_UnaryOperator T_identifier T_Semicolon 
	 	| T_identifier T_UnaryOperator T_Semicolon 
		| T_numericConstants T_Semicolon
		| T_stringLiteral T_Semicolon
		| T_identifier T_Semicolon
	  ;


ArithmeticOperator: T_plus | T_minus | T_multiply | T_divide | T_mod

BinaryOperator : ArithmeticOperator | T_LogicalOperator | T_RelationalOperator

%%

int yyerror() 
{ 
	printf("Syntax error\n");
	return 1;
} 


int main()
{
	yyparse();
	printf("\n*************************************************************************************************\n");
	display();
	printf("\n*************************************************************************************************\n");
	return 0;
}
