digit [0-9]
letter [A-Za-z_]

%{
	#include "y.tab.h"
	#include<stdio.h>
	#include<stdlib.h>
	//#define YYSTYPE char *
	//#define YY_USER_ACTION yylloc.first_line = yylloc.last_line = yylineno;
	int yyerror(char*);
	int st[100];
	int top;
	int count;
	void Gen_Symbol_Table(char *text,int nm,int scp);
	void display();
	// char Global_Type_Array[100];
	extern yylval;
	void lookup(char*,char*,int);
%}

%option yylineno

%%


\"[^\"]*\"						{/*yylval = strdup(yytext);*/return T_stringLiteral;}
"'"(.|\\n)"'"					{/*yylval = strdup(yytext);*/return T_character;}
"//".*\n                        {;}
"/*"[^*/]*"*/"					{;}


alignas|alignof|and|and_eq|asm|atomic_cancel|atomic_commit|atomic_noexcept|bitand|bitor|break|case|catch|class|compl|concept|const|consteval|constexpr|constinit|const_cast|continue|co_await|co_return|co_yield|decltype|default|delete|do|dynamic_cast|enum|explicit|export|extern|false|friend|goto|inline|mutable|namespace|new|noexcept|not|not_eq|nullptr|operator|or|or_eq|private|protected|public|reflexpr|register|reinterpret_cast|requires|signed|sizeof|static|static_assert|static_cast|struct|switch|synchronized|template|this|thread_local|throw|true|try|typedef|typeid|typename|union|unsigned|using|virtual|void|volatile|wchar_t|xor|xor_e  {return T_keyword;}

"if"																{/*yylval = strdup(yytext);*/return T_if ;}
"else"																{/*yylval = strdup(yytext);*/return T_else ;}

"int" 																{/*yylval = strdup(yytext);*/return T_int ; }
"main"																{/*yylval = strdup(yytext);*/return T_main ; }
"auto"|"bool"|"char"|"char8_t"|"char16_t"|"char32_t"|"double"|"float"|"long"|"short" 	{/*yylval = strdup(yytext);*/return T_type ;}
"return" 																{/*yylval = strdup(yytext);*/return T_return;}

"for"							{/*yylval = strdup(yytext);*/return T_for;}
"while"							{/*yylval = strdup(yytext);*/return T_while;}


"<<"							{/*yylval = strdup(yytext);*/return T_InputStream ;}
">>"							{/*yylval = strdup(yytext);*/return T_OutputStream ;}


"("							  	{/*yylval = strdup(yytext);*/return T_openParenthesis ;}		  
")"								{/*yylval = strdup(yytext);*/return T_closedParanthesis ;}
"{"								{/*yylval = strdup(yytext);*/count=count+1;top=top+1;st[top]=count;return T_openFlowerBracket ;}
"}"								{/*yylval = strdup(yytext);*/top=top-1;return T_closedFlowerBracket ;}

">"								{/*yylval = strdup(yytext);*/return T_greater;}
">="							{/*yylval = strdup(yytext);*/return T_greater_equal;}
"<"								{/*yylval = strdup(yytext);*/return T_less;}
"<="							{/*yylval = strdup(yytext);*/return T_less_equal;}
"=="							{/*yylval = strdup(yytext);*/return T_equal_equal;}
"!="							{/*yylval = strdup(yytext);*/return T_not_equal;}

"&&"							{/*yylval = strdup(yytext);*/return T_LogicalAnd;}
"[|][|]"						{/*yylval = strdup(yytext);*/return T_LogicalOr;}



"+="|"-="|"*="|"/="|"%="		{/*yylval = strdup(yytext);*/return T_shortHand;}

"+"								{/*yylval = strdup(yytext);*/return T_plus;}
"-"								{/*yylval = strdup(yytext);*/return T_minus;}
"/"								{/*yylval = strdup(yytext);*/return T_divide;}
"*"								{/*yylval = strdup(yytext);*/return T_multiply;}
"%"								{/*yylval = strdup(yytext);*/return T_mod;}
"="								{/*yylval = strdup(yytext);*/return T_AssignmentOperator ;}

";"								{/*yylval = strdup(yytext);*/return T_Semicolon ;}

{letter}({letter}|{digit})* 	{/*yylval = strdup(yytext);*/Gen_Symbol_Table(yytext,yylineno,st[top]);return T_identifier ;}

{digit}+						{return T_numericConstants ;}


	
[ \t]                          {/*printf("T_whiteSpace ");*/}
[\n]							{;}
.								{printf("Invalid character found, Abort!!!");}


%%
// Variable structure that consists of - :
// + Variable name
// + Line number to assosciate particual variable with - Line_T
// + scope - Each opened block is assosciated with a scope number
struct var
{
	char var_name[20];
	char Line_t[100];
	char type[100];
	int scope;
};
struct scope
{
	struct var arr[20];
	int up;
};

struct scope Symbol_Table[100];


void lookup(char* tpe,char* text,int scp)
{
	for(int i=0;i<=Symbol_Table[scp].up;i++)
	{
		if(strcmp(Symbol_Table[scp].arr[i].var_name,text)==0)
		{
			strcat(Symbol_Table[scp].arr[i].type,tpe);
		}
	}
}

void Gen_Symbol_Table(char *text,int nm,int scp)
{
	int flag=0;
	for(int i=0;i<=Symbol_Table[scp].up;i++)
	{
		if(strcmp(Symbol_Table[scp].arr[i].var_name,text)==0)
		{
			char buffer[20];
			sprintf(buffer,"%d",nm);
			flag=1;
			strcat(Symbol_Table[scp].arr[i].Line_t,",");
			strcat(Symbol_Table[scp].arr[i].Line_t,buffer);
			//strcat(Symbol_Table[scp].arr[i].type,"int");
			Symbol_Table[scp].arr[i].scope=scp;		
			break;
		}
	}
	if(flag==0)
	{
		//if (!isalpha(text[0]) || text[0]!='_')
		//	return;
		char buffer[20];
		sprintf(buffer,"%d",nm);
		Symbol_Table[scp].up++;
		int p=Symbol_Table[scp].up;
		strcpy(Symbol_Table[scp].arr[p].var_name,text);
		strcpy(Symbol_Table[scp].arr[p].Line_t,"");
		strcat(Symbol_Table[scp].arr[p].Line_t,buffer);
		Symbol_Table[scp].arr[p].scope=scp;
	}
	
}

void display()
{
	for(int i=0;i<=count;i++)
	{
		int h=Symbol_Table[i].up;
		for (int j=1;j<=h;j++)
		{
			printf("Symbol:%s \t Data-Type : %s \t Scope:%d \t Line number: %s\n",Symbol_Table[i].arr[j].var_name,Symbol_Table[i].arr[j].type,Symbol_Table[i].arr[j].scope,Symbol_Table[i].arr[j].Line_t);
		}
	}	
}

int yywrap()
{
	return 1;
}
