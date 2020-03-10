
%{
    #include <stdio.h>
    #include <stdlib.h>
	#include <string.h>
	int yylex();
	int yydebug = 0;
	extern int yylineno;
	extern int st[100];
	extern int top;
	extern int count;
	extern void display();
	extern void insert_in_st(char*, char*, int, char*);

	typedef struct ASTNode
	{
		struct ASTNode *left;
		struct ASTNode *right;
		char *token;
	} node;
	
	node *mknode(node *left, node *right, char *token)
	{
		node *newnode = (node *)malloc(sizeof(node));
		char *newstr = (char *)malloc(strlen(token)+1);
		strcpy(newstr, token);
		newnode->left = left;
		newnode->right = right;
		newnode->token = newstr;
		return(newnode); 
	}
	
	void printtree(node *tree)
	{
		if (tree->left || tree->right)
			printf("(");
		printf(" %s ", tree->token);
		if (tree->left)
			printtree(tree->left);
		if (tree->right)
			printtree(tree->right);
		if (tree->left || tree->right)
			printf(")"); 
	}
%}

%union {
    char *str;
	struct ASTNode *NODE;
}



%define parse.error verbose

%token <str> T_keyword T_int T_main T_type T_return T_for T_if T_else T_while T_InputStream T_OutputStream 
%token <str> T_openParenthesis T_closedParanthesis T_openFlowerBracket T_closedFlowerBracket 
%token <str> T_RelationalOperator T_LogicalOperator T_UnaryOperator 
%token <str> T_AssignmentOperator  T_Semicolon T_identifier T_numericConstants T_stringLiteral
%token <str> T_character T_plus T_minus T_mod T_divide T_multiply error
%token <str> T_whiteSpace T_shortHand

%left T_LogicalAnd T_LogicalOr
%left T_less T_less_equal T_greater T_greater_equal T_equal_equal T_not_equal
%left T_plus T_minus
%left T_multiply T_divide T_mod

%type <NODE> Start block_end_flower block Multiple_stmts stmt
%type <NODE> if_stmt Multiple_stmts_not_if elseif_else_empty stmt_without_if
%type <NODE> expr_without_constants expr expr_or_empty closeflower
%type <NODE> Assignment_stmt
%type <NODE> for_stmt while_stmt 
%type <NODE> idid nc sc

%%

/*Flower brackets are mandatory for main*/


Start : T_int T_main T_openParenthesis T_closedParanthesis openflower block_end_flower  	{$$ = $6;}


/* This production assumes flower bracket has been opened*/
block_end_flower : stmt Multiple_stmts 							{$$ = $1;}
				| closeflower {$$ = mknode(NULL, NULL, ";"); }

/*This takes care of statements like if(...);. Note that to include multiple statements, a block has to open with a flower bracket*/
block :  openflower block_end_flower						{$$ = $2;}
	    | stmt												{$$ = $1;}
	    | T_Semicolon										{$$ = mknode(NULL, NULL, ";"); }
		;

/* block would cover anything following statement. consider the for statement for example. All possiblities are:
for(expr;expr;expr);													(block -> ;)
for(...) stmt          , where stmt contains T_Semicolon				(block -> stmt)
for(...){}																(block -> {block_end_flower -> {})
for(...){stmt, stmt, stmt, ...}											(block -> {block_end_flower -> {smt Multiple_stmts})
for(...){stmt, if/while/for{stmt, stmt.}} , this is achieved implicity because stmt in previous can in turn be if or for while
*/


Multiple_stmts : stmt Multiple_stmts						{$$ = $1;}
		|closeflower {$$ = mknode(NULL, NULL, ";"); }
		;

stmt : expr T_Semicolon					{$$ = $1;}
		| if_stmt						{$$ = $1;}
		| while_stmt					{$$ = $1;}
		| for_stmt						{$$ = $1;}
		| Assignment_stmt T_Semicolon	{$$ = $1;}
		| error T_Semicolon {$$ = mknode(NULL, NULL, ";"); }
		;


//for_stmt : T_for T_openParenthesis expr_with_semicolon expr_with_semicolon expr_or_empty T_closedParanthesis block

for_stmt : T_for T_openParenthesis expr_or_empty T_Semicolon expr_or_empty T_Semicolon expr_or_empty T_closedParanthesis block	{{$$ = mknode(NULL, NULL, "For"); printtree($$); printf("\n");}}

while_stmt : T_while T_openParenthesis expr T_closedParanthesis block										{$$ = mknode($3, $5, "While"); printtree($$); printf("\n");}

if_stmt : T_if T_openParenthesis expr T_closedParanthesis block elseif_else_empty {$$ = mknode(NULL, NULL, ";"); }

elseif_else_empty : T_else T_if T_openParenthesis expr T_closedParanthesis block elseif_else_empty {$$ = mknode(NULL, NULL, ";"); }
					| T_else Multiple_stmts_not_if {$$ = mknode(NULL, NULL, ";"); }
					| T_else openflower block_end_flower {$$ = mknode(NULL, NULL, ";"); }
					| {$$ = mknode(NULL, NULL, ";"); }
					;

Multiple_stmts_not_if : stmt_without_if Multiple_stmts {$$ = mknode(NULL, NULL, ";"); }
					|T_Semicolon {$$ = mknode(NULL, NULL, ";"); }
					;

stmt_without_if : expr T_Semicolon										{$$ = $1;}
					| Assignment_stmt T_Semicolon						{$$ = $1;printtree($$);}
					| while_stmt										{$$ = $1;}
					|for_stmt											{$$ = $1;}
					;

Assignment_stmt: 	idid T_AssignmentOperator expr																		{$$ = mknode($1,$3,"=");printtree($$);}
					| idid T_shortHand expr																				{$$ = mknode($1,$3,"SE");printtree($$);}
					| T_type idid T_AssignmentOperator expr_without_constants   {insert_in_st($1, $2->token, st[top], "j");$$ = mknode($2,$4,"=");printtree($$);printf("/n");}	
					| T_type idid T_AssignmentOperator sc   {insert_in_st($1, $2->token, st[top], $4->token);$$ = mknode($2,$4,"=");printtree($$);printf("/n");}
					| T_type idid T_AssignmentOperator nc   {insert_in_st($1, $2->token, st[top], $4->token);$$ = mknode($2,$4,"=");printtree($$);printf("/n");}
					| T_int idid T_AssignmentOperator expr_without_constants    {insert_in_st($1, $2->token, st[top], "j");$$ = mknode($2,$4,"=");printtree($$);printf("/n");}
					| T_int idid T_AssignmentOperator nc    {insert_in_st($1, $2->token, st[top], $4->token);$$ = mknode($2,$4,"=");printtree($$);printf("/n");}
				;




expr_without_constants:  idid							{$$ = $1;}
		| expr T_plus expr								{$$ = mknode($1, $3, "+");}
		| expr T_minus expr								{$$ = mknode($1, $3, "-");}
		| expr T_divide expr							{$$ = mknode($1, $3, "/");}
		| expr T_multiply expr							{$$ = mknode($1, $3, "*");}
		| expr T_mod expr								{$$ = mknode($1, $3, "%");}
		| expr T_LogicalAnd expr						{$$ = mknode($1, $3, "&");}
		| expr T_LogicalOr expr							{$$ = mknode($1, $3, "|");}
		| expr T_less expr								{$$ = mknode($1, $3, "<");}				
		| expr T_less_equal expr						{$$ = mknode($1, $3, "<=");}
		| expr T_greater expr							{$$ = mknode($1, $3, ">");}
		| expr T_greater_equal expr						{$$ = mknode($1, $3, ">=");}
		| expr T_equal_equal expr						{$$ = mknode($1, $3, "==");}
		| expr T_not_equal expr							{$$ = mknode($1, $3, "!=");}
		;


expr: 	nc												{$$ = $1;}
		| sc											{$$ = $1;}								
		| idid											{$$ = $1;}
		| expr T_plus expr								{$$ = mknode($1, $3, "+");}
		| expr T_minus expr								{$$ = mknode($1, $3, "-");}
		| expr T_divide expr							{$$ = mknode($1, $3, "/");}
		| expr T_multiply expr							{$$ = mknode($1, $3, "*");}
		| expr T_mod expr								{$$ = mknode($1, $3, "%");}
		| expr T_LogicalAnd expr						{$$ = mknode($1, $3, "&");}
		| expr T_LogicalOr expr							{$$ = mknode($1, $3, "|");}
		| expr T_less expr								{$$ = mknode($1, $3, "<");}				
		| expr T_less_equal expr						{$$ = mknode($1, $3, "<=");}
		| expr T_greater expr							{$$ = mknode($1, $3, ">");}
		| expr T_greater_equal expr						{$$ = mknode($1, $3, ">=");}
		| expr T_equal_equal expr						{$$ = mknode($1, $3, "==");}
		| expr T_not_equal expr							{$$ = mknode($1, $3, "!=");}
		;


idid : T_identifier										{$$ = mknode(NULL, NULL, (char*)yylval.str); }
		;
sc 	 : T_stringLiteral									{$$ = mknode(NULL, NULL, (char*)yylval.str); }
		;
nc	 : T_numericConstants								{$$ = mknode(NULL, NULL, (char*)yylval.str); }
		;

expr_or_empty: expr										{$$ = $1;}
				| {$$ = mknode(NULL, NULL, ";"); }
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
