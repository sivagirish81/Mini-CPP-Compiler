
%{
    #include <stdio.h>
    #include <stdlib.h>
	#include <string.h>
  	#include <ctype.h>
	#include <stdarg.h>
	int yylex();
	int yydebug = 0;
	extern int yylineno;
	extern int st[100];
	extern int top;
	extern int count;
	extern void display();
	extern void insert_in_st(char*, char*, int, char*);
	// AST_Node* Construct_AST(char*,AST_Node*,AST_Node*);
	// void display_Tree(AST_Node*);
	#define YYSTYPE char*
	typedef struct Abstract_Syntax_Tree_Node AST_Node;
	struct Abstract_Syntax_Tree_Node
	{
		char *Name;
		struct Node* left;
		struct Node* right;
	};
	struct AST_Node* Construct_AST(char *op,AST_Node *left,AST_Node *right);
	void display_Tree(AST_Node*);

%}

%locations

%union {
    char *str;
	/*
	struct ast_Node
	{
		int float;
		int val;
		struct Node* node;
	}ast_Node;
	*/
	AST_Node* node;
}

%error-verbose

%token <str> T_keyword T_int T_main T_type T_return T_for T_if T_else T_while T_InputStream T_OutputStream 
%token <str> T_openParenthesis T_closedParanthesis T_openFlowerBracket T_closedFlowerBracket 
%token <str> T_RelationalOperator T_LogicalOperator T_UnaryOperator 
%token <str> T_AssignmentOperator T_numericConstants T_stringLiteral
%token <str> T_character T_plus T_minus T_mod T_divide T_multiply
%token <str> T_whiteSpace T_shortHand
%token <str> T_identifier
%token <str> T_Semicolon

%left T_LogicalAnd T_LogicalOr
%left T_less T_less_equal T_greater T_greater_equal T_equal_equal T_not_equal
%left T_plus T_minus
%left T_multiply T_divide T_mod


%type <node> Start block_end_flower block Multiple_stmts stmt
%type <node> if_stmt Multiple_stmts_not_if elseif_else_empty stmt_without_if
%type <node> expr_without_constants expr expr_or_empty expr_with_semicolon 
%type <node> Assignment_stmt
%type <node> for_stmt while_stmt 

%%

/*Flower brackets are mandatory for main*/


Start : T_int T_main T_openParenthesis T_closedParanthesis openflower block_end_flower  	{$$ = display_Tree($6);}


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

stmt : expr T_Semicolon					{/*Statement cannot be empty, block takes care of empty string*/ display_Tree($1);}
		| if_stmt						{display_Tree($$);}
		| while_stmt					{display_Tree($$);}
		| for_stmt						{}
		| Assignment_stmt T_Semicolon	{$$ = $1;}
		| error T_Semicolon				
		;


//for_stmt : T_for T_openParenthesis expr_with_semicolon expr_with_semicolon expr_or_empty T_closedParanthesis block

for_stmt : T_for T_openParenthesis expr_or_empty T_Semicolon expr_or_empty T_Semicolon expr_or_empty T_closedParanthesis block

while_stmt : T_while T_openParenthesis expr T_closedParanthesis block		{$$ = Construct_AST("WHILE",$3,$5);}

if_stmt : T_if T_openParenthesis expr T_closedParanthesis block elseif_else_empty	{$$ = Construct_AST("IF",$3,$5);}

elseif_else_empty : T_else T_if T_openParenthesis expr T_closedParanthesis block elseif_else_empty
					| T_else Multiple_stmts_not_if
					| T_else openflower block_end_flower
					|
					;

Multiple_stmts_not_if : stmt_without_if Multiple_stmts
					|T_Semicolon
					;

stmt_without_if : expr T_Semicolon						{display_Tree($1);}
					| Assignment_stmt T_Semicolon		{$$ = $1;}
					| while_stmt						{display_Tree($1);}
					|for_stmt
					;

Assignment_stmt: 	T_identifier T_AssignmentOperator expr								{$$ = Construct_AST("=",$1,$3);}
					| T_identifier T_shortHand expr
					| T_type T_identifier T_AssignmentOperator expr_without_constants   {insert_in_st($1, $2, st[top], "j");$$ = Construct_AST("=",$2,$4);}	
					| T_type T_identifier T_AssignmentOperator T_stringLiteral   		{insert_in_st($1, $2, st[top], $4);$$ = Construct_AST("=",$2,$4);}
					| T_type T_identifier T_AssignmentOperator T_numericConstants   	{insert_in_st($1, $2, st[top], $4);$$ = Construct_AST("=",$2,$4);}
					| T_int T_identifier T_AssignmentOperator expr_without_constants    {insert_in_st($1, $2, st[top], "j");$$ = Construct_AST("=",$2,$4);}
					| T_int T_identifier T_AssignmentOperator T_numericConstants    	{insert_in_st($1, $2, st[top], $4);$$ = Construct_AST("=",$2,$4);}
				;



expr_without_constants:  T_identifier	{$$.node = Construct_AST((char*)yylval,NULL,NULL);}
		| expr T_plus expr				{$$.node = Construct_AST("+",$1,$3);}
		| expr T_minus expr				{$$.node = Construct_AST("-",$1,$3);}
		| expr T_divide expr			{$$.node = Construct_AST("/",$1,$3);}
		| expr T_multiply expr			{$$.node = Construct_AST("*",$1,$3);}
		| expr T_mod expr				{$$.node = Construct_AST("%",$1,$3);}
		| expr T_LogicalAnd expr		{$$.node = Construct_AST("&",$1,$3);}
		| expr T_LogicalOr expr			{$$.node = Construct_AST("|",$1,$3);}
		| expr T_less expr				{$$.node = Construct_AST("<",$1,$3);}
		| expr T_less_equal expr		{$$.node = Construct_AST("<=",$1,$3);}
		| expr T_greater expr			{$$.node = Construct_AST(">",$1,$3);}
		| expr T_greater_equal expr		{$$.node = Construct_AST(">=",$1,$3);}
		| expr T_equal_equal expr		{$$.node = Construct_AST("==",$1,$3);}
		| expr T_not_equal expr			{$$.node = Construct_AST("!=",$1,$3);}
		;


expr: 	T_numericConstants  			{$$ = Construct_AST((char*)yylval,NULL,NULL);}
		| T_stringLiteral   			{$$ = Construct_AST((char*)yylval,NULL,NULL);}
		| T_identifier  				{$$ = Construct_AST((char*)yylval,NULL,NULL);}
		| expr T_plus expr  			{$$ = Construct_AST("+",$1,$3);}
		| expr T_minus expr 			{$$ = Construct_AST("-",$1,$3);}
		| expr T_divide expr			{$$ = Construct_AST("/",$1,$3);}
		| expr T_multiply expr			{$$ = Construct_AST("*",$1,$3);}
		| expr T_mod expr				{$$ = Construct_AST("%",$1,$3);}
		| expr T_LogicalAnd expr		{$$ = Construct_AST("&",$1,$3);}
		| expr T_LogicalOr expr			{$$ = Construct_AST("|",$1,$3);}
		| expr T_less expr				{$$ = Construct_AST("<",$1,$3);}
		| expr T_less_equal expr		{$$ = Construct_AST("<=",$1,$3);}
		| expr T_greater expr			{$$ = Construct_AST(">",$1,$3);}
		| expr T_greater_equal expr		{$$ = Construct_AST(">=",$1,$3);}
		| expr T_equal_equal expr		{$$ = Construct_AST("==",$1,$3);}
		| expr T_not_equal expr			{$$ = Construct_AST("!=",$1,$3);}
		;

expr_or_empty: expr						//{$$ = $1;}
				|
				;

openflower: T_openFlowerBracket {};
closeflower: T_closedFlowerBracket {};


%%

AST_Node* Construct_AST(char *op,AST_Node *left,AST_Node *right)
{
	AST_Node *root = (AST_Node*)malloc(sizeof(AST_Node));
	char* Operator = (char*)malloc(strlen(op) + 1);
	Operator = strcpy(Operator,op);
	root->left = left;
	root->right = right;
	root->Name = Operator;
	return root;
}


void display_Tree(AST_Node *AST)
{
	if(AST->left || AST->right)
		printf("[");
	printf(" %s ",AST->Name);
	if(AST->left)
		display_Tree(AST->left);
	if(AST->right)
		display_Tree(AST->right);
	if(AST->left || AST->right)
		printf("]");
}

/*
AST_Node* Make_Leaf(char* rt)
{
	AST_Node* root = (AST_Node*)malloc(sizeof(AST_Node*));
	strcpy(root->data,rt);
	root->left = root->right = NULL;
	return root;
}
*/

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
