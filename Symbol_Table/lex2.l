digit [0-9]
letter [A-Za-z_]
%option yylineno
%{
	#include "y.tab.h"
	int yyerror(char*);
	int st[100];
	int top;
	int count;
	void insertIntoSym(char *text,int nm,int scp);
	void display();

%}

%%


\"[^\"]*\"						{return T_stringLiteral;}
"'"(.|\\n)"'"					{return T_character;}
"//".*\n                        {;}
"/*"[^*/]*"*/"					{;}


alignas|alignof|and|and_eq|asm|atomic_cancel|atomic_commit|atomic_noexcept|bitand|bitor|break|case|catch|class|compl|concept|const|consteval|constexpr|constinit|const_cast|continue|co_await|co_return|co_yield|decltype|default|delete|do|dynamic_cast|enum|explicit|export|extern|false|friend|goto|inline|mutable|namespace|new|noexcept|not|not_eq|nullptr|operator|or|or_eq|private|protected|public|reflexpr|register|reinterpret_cast|requires|signed|sizeof|static|static_assert|static_cast|struct|switch|synchronized|template|this|thread_local|throw|true|try|typedef|typeid|typename|union|unsigned|using|virtual|void|volatile|wchar_t|xor|xor_e  {return T_keyword;}

"if"																{return T_if ;}
"else"																{return T_else ;}

"int" 																{return T_int ; }
"main"																{return T_main ; }
"auto"|"bool"|"char"|"char8_t"|"char16_t"|"char32_t"|"double"|"float"|"long"|"short" 	{return T_type;}
"return" 																{return T_return;}

"for"							{return T_for;}
"while"							{return T_while;}
present

"<<"							{return T_InputStream ;}
">>"							{return T_OutputStream ;}


"("							  	{return T_openParenthesis ;}		  
")"								{return T_closedParanthesis ;}
"{"								{count=count+1;top=top+1;st[top]=count;return T_openFlowerBracket ;}
"}"								{top=top-1;return T_closedFlowerBracket ;}

">"|"<"|">="|"<="|"=="|"!="   	{return T_RelationalOperator ;}
"&&"|"[|][|]"					{return T_LogicalOperator ;}
"++"|"--"						{return T_UnaryOperator ;}

"+="|"-="|"*="|"/="|"%="		{return T_shortHand;}

"+"								{return T_plus;}
"-"								{return T_minus;}
"/"								{return T_divide;}
"*"								{return T_multiply;}
"%"								{return T_mod;}
"="								{return T_AssignmentOperator ;}

";"								{return T_Semicolon ;}

{letter}({letter}|{digit})* 	{insertIntoSym(yytext,yylineno,st[top]);return T_identifier ;}

{digit}+						{return T_numericConstants ;}


	
[ \t]                          {/*printf("T_whiteSpace ");*/}
[\n]							{;}
.								yyerror("Invalid character found, Abort!!!");


%%

struct var
{
	char c[20];
	char l[100];
	int scope;
	int y;
};
struct scope
{
	struct var arr[20];
	int up;
};

struct scope symtab[100];


void insertIntoSym(char *text,int nm,int scp)
{
	int flag=0;
	for(int i=0;i<=symtab[scp].up;i++)
	{
		if(strcmp(symtab[scp].arr[i].c,text)==0)
		{
			char buffer[20];
			sprintf(buffer,"%d",nm);
			flag=1;
			strcat(symtab[scp].arr[i].l,",");
			strcat(symtab[scp].arr[i].l,buffer);	
			symtab[scp].arr[i].scope=scp;		
			break;
		}
	}
	if(flag==0)
	{
		char buffer[20];
		sprintf(buffer,"%d",nm);
		symtab[scp].up++;
		int p=symtab[scp].up;
		strcpy(symtab[scp].arr[p].c,text);
		strcpy(symtab[scp].arr[p].l,"");
		strcat(symtab[scp].arr[p].l,buffer);
		symtab[scp].arr[p].scope=scp;
	}
	
}

void display()
{
	for(int i=0;i<=count;i++)
	{
		int h=symtab[i].up;
		for (int j=1;j<=h;j++)
		{
			printf("Symbol:%s \t Scope:%d \t Line number: %s\n",symtab[i].arr[j].c,symtab[i].arr[j].scope,symtab[i].arr[j].l);
		}
	}	
}

int yywrap()
{
	return 1;
}
