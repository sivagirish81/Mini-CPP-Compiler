
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
	extern int count;
	extern void display();
	extern void insert_in_st(char*, char*, int, char*);

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

	typedef struct quadruples
  	{
    	char *op;
    	char *arg1;
    	char *arg2;
    	char *res;
  	}quad;
  	int quadlen = 0;
  	quad q[100];
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
				| closeflower {$$ = Construct_AST(NULL, NULL, ";"); }

/*This takes care of statements like if(...);. Note that to include multiple statements, a block has to open with a flower bracket*/
block :  openflower block_end_flower						{$$ = $2;}
	    | stmt												{$$ = $1;}
	    | T_Semicolon										{$$ = Construct_AST(NULL, NULL, ";"); }
		;

/* block would cover anything following statement. consider the for statement for example. All possiblities are:
for(expr;expr;expr);													(block -> ;)
for(...) stmt          , where stmt contains T_Semicolon				(block -> stmt)
for(...){}																(block -> {block_end_flower -> {})
for(...){stmt, stmt, stmt, ...}											(block -> {block_end_flower -> {smt Multiple_stmts})
for(...){stmt, if/while/for{stmt, stmt.}} , this is achieved implicity because stmt in previous can in turn be if or for while
*/


Multiple_stmts : stmt Multiple_stmts						{$$ = $1;}
		|closeflower {$$ = Construct_AST(NULL, NULL, ";"); }
		;

stmt : expr T_Semicolon					{$$ = $1;}
		| if_stmt						{$$ = $1;}
		| while_stmt					{$$ = $1;}
		| for_stmt						{$$ = $1;}
		| Assignment_stmt T_Semicolon	{$$ = $1;}
		| error T_Semicolon {$$ = Construct_AST(NULL, NULL, ";"); }
		;


//for_stmt : T_for T_openParenthesis expr_with_semicolon expr_with_semicolon expr_or_empty T_closedParanthesis block

for_stmt : T_for T_openParenthesis expr_or_empty_with_semicolon_and_assignment  expr_or_empty_with_semicolon_and_assignment  expr_or_empty_with_assignment_and_closed_parent  block	{{ 	node* left;
																																	node* right;
																																	left = Construct_AST($4, $6, "Cond_Loopstmts");
																																	right = Construct_AST($3,$5,"Init_&_Increment");
																																	$$ = Construct_AST(left,right,"FOR");
																																	Display_tree($$); printf("\n");}}



// Condition : 		{}

while_stmt : T_while T_openParenthesis expr T_closedParanthesis block										{$$ = Construct_AST($3, $5, "While"); Display_tree($$); printf("\n");}

if_stmt : T_if T_openParenthesis expr T_closedParanthesis block elseif_else_empty {$$ = Construct_AST($3, $5, "IF");Display_tree($$); printf("\n"); }

elseif_else_empty : T_else T_if T_openParenthesis expr T_closedParanthesis block elseif_else_empty {$$ = Construct_AST($4, $6, "ELSEIF"); }
					| T_else Multiple_stmts_not_if {$$ = $2;}
					| T_else openflower block_end_flower {$$ = $3; }
					| {$$ = Construct_AST(NULL, NULL, ";"); }
					;

Multiple_stmts_not_if : stmt_without_if Multiple_stmts {$$ = $1;}
					|T_Semicolon {$$ = Construct_AST(NULL, NULL, ";"); }
					;

stmt_without_if : expr T_Semicolon										{$$ = $1;}
					| Assignment_stmt T_Semicolon						{$$ = $1;Display_tree($$);}
					| while_stmt										{$$ = $1;}
					|for_stmt											{$$ = $1;}
					;

Assignment_stmt: 	idid T_AssignmentOperator expr																		{$$ = Construct_AST($1,$3,"=");Display_tree($$);}
					| idid T_shortHand expr																				{$$ = Construct_AST($1,$3,"SE");Display_tree($$);}
					| T_type idid T_AssignmentOperator expr_without_constants   {insert_in_st($1, $2->token, st[top], "j");$$ = Construct_AST($2,$4,"=");Display_tree($$);printf("\n");}	
					| T_type idid T_AssignmentOperator sc   {insert_in_st($1, $2->token, st[top], $4->token);$$ = Construct_AST($2,$4,"=");Display_tree($$);printf("\n");}
					| T_type idid T_AssignmentOperator nc   {insert_in_st($1, $2->token, st[top], $4->token);$$ = Construct_AST($2,$4,"=");Display_tree($$);printf("\n");}
					| T_int idid T_AssignmentOperator expr_without_constants    {insert_in_st($1, $2->token, st[top], "j");$$ = Construct_AST($2,$4,"=");Display_tree($$);printf("\n");}
					| T_int idid T_AssignmentOperator nc    {insert_in_st($1, $2->token, st[top], $4->token);$$ = Construct_AST($2,$4,"=");Display_tree($$);printf("\n");}
				;



expr_without_constants:  idid							{$$ = $1;}
		| expr T_plus expr								{$$ = Construct_AST($1, $3, "+");}
		| expr T_minus expr								{$$ = Construct_AST($1, $3, "-");}
		| expr T_divide expr							{$$ = Construct_AST($1, $3, "/");}
		| expr T_multiply expr							{$$ = Construct_AST($1, $3, "*");}
		| expr T_mod expr								{$$ = Construct_AST($1, $3, "%");}
		| expr T_LogicalAnd expr						{$$ = Construct_AST($1, $3, "&");}
		| expr T_LogicalOr expr							{$$ = Construct_AST($1, $3, "|");}
		| expr T_less expr								{$$ = Construct_AST($1, $3, "<");}				
		| expr T_less_equal expr						{$$ = Construct_AST($1, $3, "<=");}
		| expr T_greater expr							{$$ = Construct_AST($1, $3, ">");}
		| expr T_greater_equal expr						{$$ = Construct_AST($1, $3, ">=");}
		| expr T_equal_equal expr						{$$ = Construct_AST($1, $3, "==");}
		| expr T_not_equal expr							{$$ = Construct_AST($1, $3, "!=");}
		;


expr: 	nc												{$$ = $1;}
		| sc											{$$ = $1;}								
		| idid											{$$ = $1;}
		| expr T_plus expr								{$$ = Construct_AST($1, $3, "+");}
		| expr T_minus expr								{$$ = Construct_AST($1, $3, "-");}
		| expr T_divide expr							{$$ = Construct_AST($1, $3, "/");}
		| expr T_multiply expr							{$$ = Construct_AST($1, $3, "*");}
		| expr T_mod expr								{$$ = Construct_AST($1, $3, "%");}
		| expr T_LogicalAnd expr						{$$ = Construct_AST($1, $3, "&");}
		| expr T_LogicalOr expr							{$$ = Construct_AST($1, $3, "|");}
		| expr T_less expr								{$$ = Construct_AST($1, $3, "<");}				
		| expr T_less_equal expr						{$$ = Construct_AST($1, $3, "<=");}
		| expr T_greater expr							{$$ = Construct_AST($1, $3, ">");}
		| expr T_greater_equal expr						{$$ = Construct_AST($1, $3, ">=");}
		| expr T_equal_equal expr						{$$ = Construct_AST($1, $3, "==");}
		| expr T_not_equal expr							{$$ = Construct_AST($1, $3, "!=");}
		;

expr_or_empty_with_semicolon_and_assignment: expr_or_empty T_Semicolon			{$$ = $1;}
	| Assignment_stmt T_Semicolon												{$$ = $1;}

expr_or_empty_with_assignment_and_closed_parent: expr_or_empty T_closedParanthesis							{$$ = $1;}
	| Assignment_stmt T_closedParanthesis																	{$$ = $1;}

idid : T_identifier										{$$ = Construct_AST(NULL, NULL, (char*)yylval.str); }
		;
sc 	 : T_stringLiteral									{$$ = Construct_AST(NULL, NULL, (char*)yylval.str); }
		;
nc	 : T_numericConstants								{$$ = Construct_AST(NULL, NULL, (char*)yylval.str); }
		;

expr_or_empty: expr										{$$ = $1;}
				| {$$ = Construct_AST(NULL, NULL, ";"); }
				;

openflower: T_openFlowerBracket {};
closeflower: T_closedFlowerBracket {};


%%

#include<ctype.h>
char ststack[100][100];

char i_[2]="0";
int temp_i=0;
char tmp_i[3];
char temp[2]="t";
int label[20];
int lnum=0;
int ltop=0;
int abcd=0;
int l_while=0;
int l_for=0;
int flag_set = 1;

void yyerror(const char *str) 
{ 
	printf("Error | Line: %d\n%s\n",yylineno,str);
} 

void printICG()
{
	if(!yyparse())  //yyparse-> 0 if success
  	{
    	printf("Parsing Complete\n");
    	printf("---------------------Quadruples-------------------------\n\n");
    	printf("Operator \t Arg1 \t\t Arg2 \t\t Result \n");
    	int i;
    	for(i=0;i<quadlen;i++)
    	{
    	    printf("%-8s \t %-8s \t %-8s \t %-6s \n",q[i].op,q[i].arg1,q[i].arg2,q[i].res);
    	}
  	}
  	else
  	{
    	printf("Parsing failed\n");
  	}
}

int main()
{
	yyparse();
	printf("\n*************************************************************************************************\n");
	display();
	printf("\n*************************************************************************************************\n");
	printf("Intermediate Code Generation(ICG)\n");
	printf("\n_________________________________________________________________________________________________\n");
	printICG();
	printf("\n_________________________________________________________________________________________________\n");
	return 0;
}


void push()
{
	strcpy(ststack[++top],yylval);
}

void pusha()
{
	strcpy(ststack[++top],"  ");
}

void pushx()
{
	strcpy(ststack[++top],"x ");
}

void pushab()
{
	strcpy(ststack[++top],"  ");
	strcpy(ststack[++top],"  ");
	strcpy(ststack[++top],"  ");
}

void codegen()
{
    strcpy(temp,"T");
    sprintf(tmp_i, "%d", temp_i);
    strcat(temp,tmp_i);
    printf("%s = %s %s %s\n",temp,ststack[top-2],ststack[top-1],ststack[top]);
    q[quadlen].op = (char*)malloc(sizeof(char)*strlen(ststack[top-1]));
    q[quadlen].arg1 = (char*)malloc(sizeof(char)*strlen(ststack[top-2]));
    q[quadlen].arg2 = (char*)malloc(sizeof(char)*strlen(ststack[top]));
    q[quadlen].res = (char*)malloc(sizeof(char)*strlen(temp));
    strcpy(q[quadlen].op,ststack[top-1]);
    strcpy(q[quadlen].arg1,ststack[top-2]);
    strcpy(q[quadlen].arg2,ststack[top]);
    strcpy(q[quadlen].res,temp);
    quadlen++;
    top-=2;
    strcpy(ststack[top],temp);

	temp_i++;
}
void codegen_assigna()
{
	strcpy(temp,"T");
	sprintf(tmp_i, "%d", temp_i);
	strcat(temp,tmp_i);
	printf("%s = %s %s %s %s\n",temp,ststack[top-3],ststack[top-2],ststack[top-1],ststack[top]);
	//printf("%d\n",strlen(st[top]));
	if(strlen(ststack[top])==1)
	{
		//printf("hello");

	    char t[20];
		//printf("hello");
		strcpy(t,ststack[top-2]);
		strcat(t,ststack[top-1]);
		q[quadlen].op = (char*)malloc(sizeof(char)*strlen(t));
	    q[quadlen].arg1 = (char*)malloc(sizeof(char)*strlen(ststack[top-3]));
	    q[quadlen].arg2 = (char*)malloc(sizeof(char)*strlen(ststack[top]));
	    q[quadlen].res = (char*)malloc(sizeof(char)*strlen(temp));
	    strcpy(q[quadlen].op,t);
	    strcpy(q[quadlen].arg1,ststack[top-3]);
	    strcpy(q[quadlen].arg2,ststack[top]);
	    strcpy(q[quadlen].res,temp);
	    quadlen++;
	
	}
	else
	{
		q[quadlen].op = (char*)malloc(sizeof(char)*strlen(ststack[top-2]));
	    q[quadlen].arg1 = (char*)malloc(sizeof(char)*strlen(ststack[top-3]));
	    q[quadlen].arg2 = (char*)malloc(sizeof(char)*strlen(ststack[top-1]));
	    q[quadlen].res = (char*)malloc(sizeof(char)*strlen(temp));
	    strcpy(q[quadlen].op,ststack[top-2]);
	    strcpy(q[quadlen].arg1,ststack[top-3]);
	    strcpy(q[quadlen].arg2,ststack[top-1]);
	    strcpy(q[quadlen].res,temp);
	    quadlen++;
	}
	top-=4;

	temp_i++;
	strcpy(ststack[++top],temp);
}

void codegen_umin()
{
    strcpy(temp,"T");
    sprintf(tmp_i, "%d", temp_i);
    strcat(temp,tmp_i);
    printf("%s = -%s\n",temp,ststack[top]);
    q[quadlen].op = (char*)malloc(sizeof(char));
    q[quadlen].arg1 = (char*)malloc(sizeof(char)*strlen(ststack[top]));
    q[quadlen].arg2 = NULL;
    q[quadlen].res = (char*)malloc(sizeof(char)*strlen(temp));
    strcpy(q[quadlen].op,"-");
    strcpy(q[quadlen].arg1,ststack[top-2]);
    strcpy(q[quadlen].res,temp);
    quadlen++;
    top--;
    strcpy(ststack[top],temp);
    temp_i++;
}

void codegen_assign()
{
    printf("%s = %s\n",ststack[top-3],ststack[top]);
    q[quadlen].op = (char*)malloc(sizeof(char));
    q[quadlen].arg1 = (char*)malloc(sizeof(char)*strlen(ststack[top]));
    q[quadlen].arg2 = NULL;
    q[quadlen].res = (char*)malloc(sizeof(char)*strlen(ststack[top-3]));
    strcpy(q[quadlen].op,"=");
    strcpy(q[quadlen].arg1,ststack[top]);
    strcpy(q[quadlen].res,ststack[top-3]);
    quadlen++;
    top-=2;
}

void if1()
{
	lnum++;
	strcpy(temp,"T");
	sprintf(tmp_i, "%d", temp_i);
	strcat(temp,tmp_i);
	printf("%s = not %s\n",temp,ststack[top]);
	q[quadlen].op = (char*)malloc(sizeof(char)*4);
	q[quadlen].arg1 = (char*)malloc(sizeof(char)*strlen(ststack[top]));
	q[quadlen].arg2 = NULL;
	q[quadlen].res = (char*)malloc(sizeof(char)*strlen(temp));
	strcpy(q[quadlen].op,"not");
	strcpy(q[quadlen].arg1,ststack[top]);
	strcpy(q[quadlen].res,temp);
	quadlen++;
	printf("if %s goto L%d\n",temp,lnum);
	q[quadlen].op = (char*)malloc(sizeof(char)*3);
	q[quadlen].arg1 = (char*)malloc(sizeof(char)*strlen(temp));
	q[quadlen].arg2 = NULL;
	q[quadlen].res = (char*)malloc(sizeof(char)*(lnum+2));
	strcpy(q[quadlen].op,"if");
	strcpy(q[quadlen].arg1,ststack[top-2]);
	char x[10];
	sprintf(x,"%d",lnum);
	char l[]="L";
	strcpy(q[quadlen].res,strcat(l,x));
	quadlen++;	
	temp_i++;
	label[++ltop]=lnum;
}

void if3()
{
    int y;
    y=label[ltop--];
    printf("L%d: \n",y);
    q[quadlen].op = (char*)malloc(sizeof(char)*6);
    q[quadlen].arg1 = NULL;
    q[quadlen].arg2 = NULL;
    q[quadlen].res = (char*)malloc(sizeof(char)*(y+2));
    strcpy(q[quadlen].op,"Label");
    char x[10];
    sprintf(x,"%d",y);
    char l[]="L";
    strcpy(q[quadlen].res,strcat(l,x));
    quadlen++;
}

void ifelse1()
{
    lnum++;
    strcpy(temp,"T");
    sprintf(tmp_i, "%d", temp_i);
    strcat(temp,tmp_i);
    printf("%s = not %s\n",temp,ststack[top]);
    q[quadlen].op = (char*)malloc(sizeof(char)*4);
    q[quadlen].arg1 = (char*)malloc(sizeof(char)*strlen(ststack[top]));
    q[quadlen].arg2 = NULL;
    q[quadlen].res = (char*)malloc(sizeof(char)*strlen(temp));
    strcpy(q[quadlen].op,"not");
    strcpy(q[quadlen].arg1,ststack[top]);
    strcpy(q[quadlen].res,temp);
    quadlen++;
    printf("if %s goto L%d\n",temp,lnum);
    q[quadlen].op = (char*)malloc(sizeof(char)*3);
    q[quadlen].arg1 = (char*)malloc(sizeof(char)*strlen(temp));
    q[quadlen].arg2 = NULL;
    q[quadlen].res = (char*)malloc(sizeof(char)*(lnum+2));
    strcpy(q[quadlen].op,"if");
    strcpy(q[quadlen].arg1,temp);
    char x[10];
    sprintf(x,"%d",lnum);
    char l[]="L";
    strcpy(q[quadlen].res,strcat(l,x));
    quadlen++;
    temp_i++;
    label[++ltop]=lnum;
}

void ifelse2()
{
    int x;
    lnum++;
    x=label[ltop--];
    printf("goto L%d\n",lnum);
    q[quadlen].op = (char*)malloc(sizeof(char)*5);
    q[quadlen].arg1 = NULL;
    q[quadlen].arg2 = NULL;
    q[quadlen].res = (char*)malloc(sizeof(char)*(lnum+2));
    strcpy(q[quadlen].op,"goto");
    char jug[10];
    sprintf(jug,"%d",lnum);
    char l[]="L";
    strcpy(q[quadlen].res,strcat(l,jug));
    quadlen++;
    printf("L%d: \n",x);
    q[quadlen].op = (char*)malloc(sizeof(char)*6);
    q[quadlen].arg1 = NULL;
    q[quadlen].arg2 = NULL;
    q[quadlen].res = (char*)malloc(sizeof(char)*(x+2));
    strcpy(q[quadlen].op,"Label");

    char jug1[10];
    sprintf(jug1,"%d",x);
    char l1[]="L";
    strcpy(q[quadlen].res,strcat(l1,jug1));
    quadlen++;
    label[++ltop]=lnum;
}

void ifelse3()
{
	int y;
	y=label[ltop--];
	printf("L%d: \n",y);
	q[quadlen].op = (char*)malloc(sizeof(char)*6);
    q[quadlen].arg1 = NULL;
    q[quadlen].arg2 = NULL;
    q[quadlen].res = (char*)malloc(sizeof(char)*(y+2));
    strcpy(q[quadlen].op,"Label");
    char x[10];
    sprintf(x,"%d",y);
    char l[]="L";
    strcpy(q[quadlen].res,strcat(l,x));
    quadlen++;
	lnum++;
}

void while1()
{

    l_while = lnum;
    printf("L%d: \n",lnum++);
    q[quadlen].op = (char*)malloc(sizeof(char)*6);
    q[quadlen].arg1 = NULL;
    q[quadlen].arg2 = NULL;
    q[quadlen].res = (char*)malloc(sizeof(char)*(lnum+2));
    strcpy(q[quadlen].op,"Label");
    char x[10];
    sprintf(x,"%d",lnum-1);
    char l[]="L";
    strcpy(q[quadlen].res,strcat(l,x));
    quadlen++;
}

void while2()
{
 	strcpy(temp,"T");
 	sprintf(tmp_i, "%d", temp_i);
 	strcat(temp,tmp_i);
 	printf("%s = not %s\n",temp,st[top]);
    q[quadlen].op = (char*)malloc(sizeof(char)*4);
    q[quadlen].arg1 = (char*)malloc(sizeof(char)*strlen(ststack[top]));
    q[quadlen].arg2 = NULL;
    q[quadlen].res = (char*)malloc(sizeof(char)*strlen(temp));
    strcpy(q[quadlen].op,"not");
    strcpy(q[quadlen].arg1,ststack[top]);
    strcpy(q[quadlen].res,temp);
    quadlen++;
    printf("if %s goto L%d\n",temp,lnum);
    q[quadlen].op = (char*)malloc(sizeof(char)*3);
    q[quadlen].arg1 = (char*)malloc(sizeof(char)*strlen(temp));
    q[quadlen].arg2 = NULL;
    q[quadlen].res = (char*)malloc(sizeof(char)*(lnum+2));
    strcpy(q[quadlen].op,"if");
    strcpy(q[quadlen].arg1,temp);
    char x[10];
    sprintf(x,"%d",lnum);char l[]="L";
    strcpy(q[quadlen].res,strcat(l,x));
    quadlen++;
	temp_i++;
 }

void while3()
{
	printf("goto L%d \n",l_while);
	q[quadlen].op = (char*)malloc(sizeof(char)*5);
    q[quadlen].arg1 = NULL;
    q[quadlen].arg2 = NULL;
    q[quadlen].res = (char*)malloc(sizeof(char)*(l_while+2));
    strcpy(q[quadlen].op,"goto");
    char x[10];
    sprintf(x,"%d",l_while);
    char l[]="L";
    strcpy(q[quadlen].res,strcat(l,x));
    quadlen++;
    printf("L%d: \n",lnum++);
    q[quadlen].op = (char*)malloc(sizeof(char)*6);
    q[quadlen].arg1 = NULL;
    q[quadlen].arg2 = NULL;
    q[quadlen].res = (char*)malloc(sizeof(char)*(lnum+2));
    strcpy(q[quadlen].op,"Label");
    char x1[10];
    sprintf(x1,"%d",lnum-1);
    char l1[]="L";
    strcpy(q[quadlen].res,strcat(l1,x1));
    quadlen++;
}

void for1()
{
    l_for = lnum;
    printf("L%d: \n",lnum++);
    q[quadlen].op = (char*)malloc(sizeof(char)*6);
    q[quadlen].arg1 = NULL;
    q[quadlen].arg2 = NULL;
    q[quadlen].res = (char*)malloc(sizeof(char)*(lnum+2));
    strcpy(q[quadlen].op,"Label");
    char x[10];
    sprintf(x,"%d",lnum-1);
    char l[]="L";
    strcpy(q[quadlen].res,strcat(l,x));
    quadlen++;
}

void for2()
{
    strcpy(temp,"T");
    sprintf(tmp_i, "%d", temp_i);
    strcat(temp,tmp_i);
    printf("%s = not %s\n",temp,st[top]);
    q[quadlen].op = (char*)malloc(sizeof(char)*4);
    q[quadlen].arg1 = (char*)malloc(sizeof(char)*strlen(ststack[top]));
    q[quadlen].arg2 = NULL;
    q[quadlen].res = (char*)malloc(sizeof(char)*strlen(temp));
    strcpy(q[quadlen].op,"not");
    strcpy(q[quadlen].arg1,ststack[top]);
    strcpy(q[quadlen].res,temp);
    quadlen++;
    printf("if %s goto L%d\n",temp,lnum);
    q[quadlen].op = (char*)malloc(sizeof(char)*3);
    q[quadlen].arg1 = (char*)malloc(sizeof(char)*strlen(temp));
    q[quadlen].arg2 = NULL;
    q[quadlen].res = (char*)malloc(sizeof(char)*(lnum+2));
    strcpy(q[quadlen].op,"if");
    strcpy(q[quadlen].arg1,temp);
    char x[10];
    sprintf(x,"%d",lnum);
    char l[]="L";
    strcpy(q[quadlen].res,strcat(l,x));
    quadlen++;

    temp_i++;
    label[++ltop]=lnum;
    lnum++;
    printf("goto L%d\n",lnum);
    q[quadlen].op = (char*)malloc(sizeof(char)*5);
    q[quadlen].arg1 = NULL;
    q[quadlen].arg2 = NULL;
    q[quadlen].res = (char*)malloc(sizeof(char)*(lnum+2));
    strcpy(q[quadlen].op,"goto");
    char x1[10];
    sprintf(x1,"%d",lnum);
    char l1[]="L";
    strcpy(q[quadlen].res,strcat(l1,x1));
    quadlen++;
    label[++ltop]=lnum;
    printf("L%d: \n",++lnum);
    q[quadlen].op = (char*)malloc(sizeof(char)*6);
    q[quadlen].arg1 = NULL;
    q[quadlen].arg2 = NULL;
    q[quadlen].res = (char*)malloc(sizeof(char)*(lnum+2));
    strcpy(q[quadlen].op,"Label");
    char x2[10];
    sprintf(x2,"%d",lnum);
    char l2[]="L";
    strcpy(q[quadlen].res,strcat(l2,x2));
    quadlen++;
}

void for3()
{
    int x;
    x=label[ltop--];
    printf("goto L%d \n",l_for);

    q[quadlen].op = (char*)malloc(sizeof(char)*5);
    q[quadlen].arg1 = NULL;
    q[quadlen].arg2 = NULL;
    q[quadlen].res = (char*)malloc(sizeof(char)*strlen(temp));
    strcpy(q[quadlen].op,"goto");
    char jug[10];
    sprintf(jug,"%d",l_for);
    char l[]="L";
    strcpy(q[quadlen].res,strcat(l,jug));
    quadlen++;


    printf("L%d: \n",x);

    q[quadlen].op = (char*)malloc(sizeof(char)*6);
    q[quadlen].arg1 = NULL;
    q[quadlen].arg2 = NULL;
    q[quadlen].res = (char*)malloc(sizeof(char)*(x+2));
    strcpy(q[quadlen].op,"Label");
    char jug1[10];
    sprintf(jug1,"%d",x);
    char l1[]="L";
    strcpy(q[quadlen].res,strcat(l1,jug1));
    quadlen++;

}

void for4()
{
    int x;
    x=label[ltop--];
    printf("goto L%d \n",lnum);

    q[quadlen].op = (char*)malloc(sizeof(char)*5);
    q[quadlen].arg1 = NULL;
    q[quadlen].arg2 = NULL;
    q[quadlen].res = (char*)malloc(sizeof(char)*strlen(temp));
    strcpy(q[quadlen].op,"goto");
    char jug[10];
    sprintf(jug,"%d",lnum);
    char l[]="L";
    strcpy(q[quadlen].res,strcat(l,jug));
    quadlen++;

    printf("L%d: \n",x);

    q[quadlen].op = (char*)malloc(sizeof(char)*6);
    q[quadlen].arg1 = NULL;
    q[quadlen].arg2 = NULL;
    q[quadlen].res = (char*)malloc(sizeof(char)*(x+2));
    strcpy(q[quadlen].op,"Label");
    char jug1[10];
    sprintf(jug1,"%d",x);
    char l1[]="L";
    strcpy(q[quadlen].res,strcat(l1,jug1));
    quadlen++;
}