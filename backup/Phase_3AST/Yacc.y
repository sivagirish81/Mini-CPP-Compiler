
%{
    #include <stdio.h>
    #include <stdlib.h>
	int yylex();
	int yydebug = 0;
	extern int yylineno;
	extern int st[100];
	extern int top;
	extern int count;
	extern void display();
	extern void insert_in_st(char*, char*, int, char*);	
	struct node{
		char* var;
		char* val;
		struct node * left;
		struct node* right;
	};
	struct node* createLeafNode(char* val,char* var);
	struct node* createNode(char* val,struct node* left,struct node* right);
%}

%union {
    char *str;
	struct ast_Node
	{
		int val;
		float flt;
		struct node* nd;
	}ast_Node;
}


%error-verbose

%token <str> T_keyword T_int T_main T_type T_return T_for T_if T_else T_while T_InputStream T_OutputStream 
%token <str> T_openParenthesis T_closedParanthesis T_openFlowerBracket T_closedFlowerBracket 
%token <str> T_RelationalOperator T_LogicalOperator T_UnaryOperator 
%token <str> T_AssignmentOperator  T_Semicolon T_identifier T_numericConstants T_stringLiteral
%token <str> T_character T_plus T_minus T_mod T_divide T_multiply
%token <str> T_whiteSpace T_shortHand

%left T_LogicalAnd T_LogicalOr
%left T_less T_less_equal T_greater T_greater_equal T_equal_equal T_not_equal
%left T_plus T_minus
%left T_multiply T_divide T_mod

%type <ast_Node> Start block_end_flower block Multiple_stmts stmt
%type <ast_Node> if_stmt Multiple_stmts_not_if elseif_else_empty stmt_without_if
%type <ast_Node> expr_without_constants expr expr_or_empty expr_with_semicolon 
%type <ast_Node> Assignment_stmt
%type <ast_Node> for_stmt while_stmt 


%%

/*Flower brackets are mandatory for main*/


Start : T_int T_main T_openParenthesis T_closedParanthesis openflower block_end_flower  	{}


/* This production assumes flower bracket has been opened*/
block_end_flower : stmt Multiple_stmts 
				| closeflower

/*This takes care of statements like if(...);. Note that to include multiple statements, a block has to open with a flower bracket*/
block :  openflower block_end_flower
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
		|closeflower
		;

stmt : expr T_Semicolon					{/*Statement cannot be empty, block takes care of empty string*/}
		| if_stmt
		| while_stmt
		| for_stmt
		| Assignment_stmt T_Semicolon
		| error T_Semicolon
		;


//for_stmt : T_for T_openParenthesis expr_with_semicolon expr_with_semicolon expr_or_empty T_closedParanthesis block

for_stmt : T_for T_openParenthesis expr_or_empty T_Semicolon expr_or_empty T_Semicolon expr_or_empty T_closedParanthesis block

while_stmt : T_while T_openParenthesis expr T_closedParanthesis block

if_stmt : T_if T_openParenthesis expr T_closedParanthesis block elseif_else_empty

elseif_else_empty : T_else T_if T_openParenthesis expr T_closedParanthesis block elseif_else_empty
					| T_else Multiple_stmts_not_if
					| T_else openflower block_end_flower
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
					| T_type T_identifier T_AssignmentOperator expr_without_constants   {insert_in_st($1, $2, st[top], "j");}	
					| T_type T_identifier T_AssignmentOperator T_stringLiteral   {insert_in_st($1, $2, st[top], $4);}
					| T_type T_identifier T_AssignmentOperator T_numericConstants   {insert_in_st($1, $2, st[top], $4);}
					| T_int T_identifier T_AssignmentOperator expr_without_constants    {insert_in_st($1, $2, st[top], "j");}
					| T_int T_identifier T_AssignmentOperator T_numericConstants    {insert_in_st($1, $2, st[top], $4);}
				;



expr_without_constants:  T_identifier
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

openflower: T_openFlowerBracket {};
closeflower: T_closedFlowerBracket {};


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
