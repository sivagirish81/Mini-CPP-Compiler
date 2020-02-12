
%{
    #include <stdio.h>
    #include <stdlib.h>
	int yydebug = 0;
	extern int yylineno;
	extern int st[100];
	extern int top;
	extern int count;
	extern void display();
%}

%error-verbose

%token T_keyword T_int T_main T_type T_return T_for T_if T_else T_while T_InputStream T_OutputStream 
%token T_openParenthesis T_closedParanthesis T_openFlowerBracket T_closedFlowerBracket 
%token T_RelationalOperator T_LogicalOperator T_UnaryOperator 
%token T_AssignmentOperator  T_Semicolon T_identifier T_numericConstants T_stringLiteral
%token T_character T_plus T_minus T_mod T_divide T_multiply
%token T_whiteSpace T_shortHand

%left T_LogicalAnd T_LogicalOr
%left T_less T_less_equal T_greater T_greater_equal T_equal_equal T_not_equal
%left T_plus T_minus
%left T_multiply T_divide T_mod



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

stmt : expr T_Semicolon					{/*Statement cannot be empty, block takes care of empty string*/}
		| if_stmt
		| while_stmt
		| for_stmt
		| Assignment_stmt T_Semicolon
		;


//for_stmt : T_for T_openParenthesis expr_with_semicolon expr_with_semicolon expr_or_empty T_closedParanthesis block

for_stmt : T_for T_openParenthesis expr_or_empty T_Semicolon expr_or_empty T_Semicolon expr_or_empty T_closedParanthesis block

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

stmt_without_if : expr T_Semicolon
					| Assignment_stmt T_Semicolon
					| while_stmt
					|for_stmt
					;

Assignment_stmt: 	T_identifier T_AssignmentOperator expr
					| T_identifier T_shortHand expr
					| T_type T_identifier T_AssignmentOperator expr
					| T_int T_identifier T_AssignmentOperator expr
				;

expr: 	T_numericConstants
		| T_stringLiteral
		| T_identifier
		| expr T_plus expr
		| expr T_minus expr
		| expr T_divide expr
		| expr T_multiply expr
		| expr T_mod expr
		| expr T_LogicalAnd expr
		| expr T_LogicalOr expr
		| expr T_less expr
		| expr T_less_equal expr
		| expr T_greater expr
		| expr T_greater_equal expr
		| expr T_equal_equal expr
		| expr T_not_equal expr
		;

expr_or_empty: expr
				| 
				;

// expr_with_semicolon:
// 		T_numericConstants T_Semicolon
// 		| T_stringLiteral T_Semicolon
// 		| T_identifier T_Semicolon
// 		|expr BinaryOperator expr T_Semicolon
// 		;


// ArithmeticOperator: T_plus | T_minus | T_multiply | T_divide | T_mod

// BinaryOperator : ArithmeticOperator | T_LogicalOperator | T_RelationalOperator

%%

int yyerror(const char *str) 
{ 
	printf("Error | Line: %d\n%s\n",yylineno,str);
} 


int main()
{
	yyparse();
	printf("\n*************************************************************************************************\n");
	display();
	printf("\n*************************************************************************************************\n");
	return 0;
}
