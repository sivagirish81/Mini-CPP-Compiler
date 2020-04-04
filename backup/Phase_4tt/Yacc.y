
%{
    #include <stdio.h>
    #include <stdlib.h>
	#include <string.h>
	int yylex();
	int yydebug = 0;
	void yyerror(const char*);
	extern int yylineno;
	extern int st[100];
	extern int top;
	int stop;
	extern int count;
	extern void display();
	extern void insert_in_st(char*, char*, int, char*);
	int label[20];
	char temp[2]="t";
	char null[2]=" ";
	char temp_count[2]="0";
	int label_num=0;
	int ltop=0;
	char st1[100][10];
	typedef struct quadruples
  	{
    	char *op;
    	char *arg1;
    	char *arg2;
    	char *res;
  	}quad;
  	int quadlen = 0;
  	quad q[100];

	typedef struct ASTNode
	{
		struct ASTNode *left;
		struct ASTNode *right;
		char *token;
	} node;
	
	node *Construct_AST(node *left, node *right, char *token)
	{
		node *newnode = (node *)malloc(sizeof(node));
		char *newstr = (char *)malloc(strlen(token)+1);
		strcpy(newstr, token);
		newnode->left = left;
		newnode->right = right;
		newnode->token = newstr;
		return(newnode); 
	}
	
	void Display_tree(node *tree)
	{
		if (tree->left || tree->right)
			printf("(");
		printf(" %s ", tree->token);
		if (tree->left)
			Display_tree(tree->left);
		if (tree->right)
			Display_tree(tree->right);
		if (tree->left || tree->right)
			printf(")"); 
	}

	void push(char *a)
	{
		strcpy(st1[++top],a);
	}

	// If handler
	void if1()
	{
		label_num++;
		strcpy(temp,"t");
		strcat(temp,temp_count);
		printf("\n%s = not %s\n",temp,st1[top]);
	 	printf("if %s goto L%d\n",temp,label_num);
		temp_count[0]++;
		label[++ltop]=label_num;
	}

	void if2()
	{
		label_num++;
		printf("\ngoto L%d\n",label_num);
		printf("L%d: \n",label[ltop--]);
		label[++ltop]=label_num;
	}

	void if3()
	{
		printf("\nL%d:\n",label[ltop--]);
	}

	void while1()
	{
		label_num++;
		label[++ltop]=label_num;
		printf("\nL%d:\n",label_num);
	}

	void while2()
	{
		label_num++;
		strcpy(temp,"t");
		strcat(temp,temp_count);
		printf("\n%s = not %s\n",temp,st1[stop--]);
	 	printf("if %s goto L%d\n",temp,label_num);
		temp_count[0]++;
		label[++ltop]=label_num;
	}

	void while3()
	{
		int y=label[ltop--];
		printf("\ngoto L%d\n",label[ltop--]);
		printf("L%d:\n",y);
	}

	void for1()
	{
		label_num++;
		label[++ltop]=label_num;
		printf("\nL%d:\n",label_num);
	}

	void for2()
	{
		label_num++;
		strcpy(temp,"t");
		strcat(temp,temp_count);
		printf("\n%s = not %s\n",temp,st1[stop--]);
	 	printf("if %s goto L%d\n",temp,label_num);
		temp_count[0]++;
		label[++ltop]=label_num;
		label_num++;
		printf("goto L%d\n",label_num);
		label[++ltop]=label_num;
		label_num++;
		printf("L%d:\n",label_num);
		label[++ltop]=label_num;
	}

	void for3()
	{
		printf("\ngoto L%d\n",label[ltop-3]);
		printf("L%d:\n",label[ltop-1]);
	}

	void for4()
	{
		printf("\ngoto L%d\n",label[ltop]);
		printf("L%d:\n",label[ltop-2]);
		ltop-=4;
	}

	void codegen()
	{
		strcpy(temp,"t");
		strcat(temp,temp_count);
		printf("\n%s = %s %s %s\n",temp,st1[stop-2],st1[stop-1],st1[stop]);
		stop-=2;
		strcpy(st1[stop],temp);
		temp_count[0]++;
	}
	void codegen_umin()
	{
		strcpy(temp,"t");
		strcat(temp,temp_count);
		printf("\n%s = -%s\n",temp,st1[stop]);
		stop--;
		strcpy(st1[stop],temp);
		temp_count[0]++;
	}

	void codegen_assign()
	{
		printf("\n%s = %s\n",st1[stop-2],st1[stop]);
		stop-=2;
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
%type <NODE> expr_or_empty_with_semicolon_and_assignment  expr_or_empty_with_assignment_and_closed_parent

%%

/*Flower brackets are mandatory for main*/


Start : T_int T_main T_openParenthesis T_closedParanthesis openflower block_end_flower  	{$$ = $6;}


/* This production assumes flower bracket has been opened*/
block_end_flower : stmt Multiple_stmts 							{$$ = $1;}
				| closeflower 

/*This takes care of statements like if(...);. Note that to include multiple statements, a block has to open with a flower bracket*/
block :  openflower block_end_flower						{$$ = $2;}
	    | stmt												{$$ = $1;}
	    | T_Semicolon										
		;

/* block would cover anything following statement. consider the for statement for example. All possiblities are:
for(expr;expr;expr);													(block -> ;)
for(...) stmt          , where stmt contains T_Semicolon				(block -> stmt)
for(...){}																(block -> {block_end_flower -> {})
for(...){stmt, stmt, stmt, ...}											(block -> {block_end_flower -> {smt Multiple_stmts})
for(...){stmt, if/while/for{stmt, stmt.}} , this is achieved implicity because stmt in previous can in turn be if or for while
*/


Multiple_stmts : stmt Multiple_stmts						{$$ = $1;}
		|closeflower 
		;

stmt : expr T_Semicolon					{$$ = $1;}
		| if_stmt						{$$ = $1;}
		| while_stmt					{$$ = $1;}
		| for_stmt						{$$ = $1;}
		| Assignment_stmt T_Semicolon	{$$ = $1;}
		| error T_Semicolon 
		;


//for_stmt : T_for T_openParenthesis expr_with_semicolon expr_with_semicolon expr_or_empty T_closedParanthesis block

for_stmt : T_for T_openParenthesis expr_or_empty_with_semicolon_and_assignment {for1();} expr_or_empty_with_semicolon_and_assignment {for2();} expr_or_empty_with_assignment_and_closed_parent {for3();} block {for4();}
																																	



// Condition : 		{}

while_stmt : T_while {while1();} T_openParenthesis expr T_closedParanthesis {while2();} block										{while3();}

if_stmt : T_if T_openParenthesis expr T_closedParanthesis block elseif_else_empty 

elseif_else_empty : T_else T_if T_openParenthesis expr T_closedParanthesis {if1();} block {if2();} elseif_else_empty 
					| T_else Multiple_stmts_not_if 
					| T_else openflower block_end_flower 
					| 
					;

Multiple_stmts_not_if : stmt_without_if Multiple_stmts {$$ = $1;}
					|T_Semicolon {$$ = Construct_AST(NULL, NULL, ";"); }
					;

stmt_without_if : expr T_Semicolon										
					| Assignment_stmt T_Semicolon						
					| while_stmt										
					|for_stmt											
					;

Assignment_stmt: 	idid T_AssignmentOperator{strcpy(st1[++stop],"=");} expr																							
					| idid T_shortHand{strcpy(st1[++stop],"SE");} expr																				
					| T_type idid T_AssignmentOperator {strcpy(st1[++stop],"=");} expr_without_constants   {codegen_assign();insert_in_st($1, $2->token, st[top], "j");printf("\n");}	
					| T_type idid T_AssignmentOperator {strcpy(st1[++stop],"=");} sc   {codegen_assign();insert_in_st($1, $2->token, st[top], $4->token);}
					| T_type idid T_AssignmentOperator {strcpy(st1[++stop],"=");} nc   {codegen_assign();insert_in_st($1, $2->token, st[top], $4->token);}
					| T_int idid T_AssignmentOperator {strcpy(st1[++stop],"=");} expr_without_constants    {codegen_assign();insert_in_st($1, $2->token, st[top], "j");}
					| T_int idid T_AssignmentOperator {strcpy(st1[++stop],"=");} nc    {codegen_assign();insert_in_st($1, $2->token, st[top], $4->token);}
				;



expr_without_constants:  idid							{$$ = $1;}
		| expr T_plus{strcpy(st1[++stop],"+");} expr								{codegen();}
		| expr T_minus{strcpy(st1[++stop],"-");} expr								{codegen();}
		| expr T_divide{strcpy(st1[++stop],"/");} expr							{codegen();}
		| expr T_multiply{strcpy(st1[++stop],"*");} expr							{codegen();}
		| expr T_mod{strcpy(st1[++stop],"%");} expr								{codegen();}
		| expr T_LogicalAnd{strcpy(st1[++stop],"&");} expr						{codegen();}
		| expr T_LogicalOr{strcpy(st1[++stop],"|");} expr							{codegen();}
		| expr T_less{strcpy(st1[++stop],"<");} expr								{codegen();}				
		| expr T_less_equal{strcpy(st1[++stop],"<=");} expr							{codegen();}
		| expr T_greater{strcpy(st1[++stop],">");} expr								{codegen();}
		| expr T_greater_equal{strcpy(st1[++stop],">=");} expr						{codegen();}
		| expr T_equal_equal{strcpy(st1[++stop],"==");} expr						{codegen();}
		| expr T_not_equal{strcpy(st1[++stop],"!=");} expr							{codegen();}
		;


expr: 	nc												{$$ = $1;}
		| sc											{$$ = $1;}								
		| idid											{$$ = $1;}
		| expr T_plus{strcpy(st1[++stop],"+");} expr								{codegen();}
		| expr T_minus{strcpy(st1[++stop],"-");} expr								{codegen();}
		| expr T_divide{strcpy(st1[++stop],"/");} expr							{codegen();}
		| expr T_multiply{strcpy(st1[++stop],"*");} expr							{codegen();}
		| expr T_mod{strcpy(st1[++stop],"%");} expr								{codegen();}
		| expr T_LogicalAnd{strcpy(st1[++stop],"&");} expr						{codegen();}
		| expr T_LogicalOr{strcpy(st1[++stop],"|");} expr							{codegen();}
		| expr T_less{strcpy(st1[++stop],"<");} expr								{codegen();}				
		| expr T_less_equal{strcpy(st1[++stop],"<=");} expr						{codegen();}
		| expr T_greater{strcpy(st1[++stop],">");} expr							{codegen();}
		| expr T_greater_equal{strcpy(st1[++stop],">=");} expr						{codegen();}
		| expr T_equal_equal{strcpy(st1[++stop],"==");} expr						{codegen();}
		| expr T_not_equal{strcpy(st1[++stop],"!=");} expr							{codegen();}
		;

expr_or_empty_with_semicolon_and_assignment: expr_or_empty T_Semicolon			{$$ = $1;}
	| Assignment_stmt T_Semicolon												{$$ = $1;}

expr_or_empty_with_assignment_and_closed_parent: expr_or_empty T_closedParanthesis							{$$ = $1;}
	| Assignment_stmt T_closedParanthesis																	{$$ = $1;}

idid : T_identifier										{push((char*)yylval.str); }
		;
sc 	 : T_stringLiteral									{push((char*)yylval.str); }
		;
nc	 : T_numericConstants								{push((char*)yylval.str);}
		;

expr_or_empty: expr										{$$ = $1;}
				| 
				;

openflower: T_openFlowerBracket {};
closeflower: T_closedFlowerBracket {};


%%

void yyerror(const char *str) 
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
