digit [0-9]
letter [A-Za-z_]
%option yylineno

%{
	#include "y.tab.h"
	void Gen_Symbol_Table(char* Text,int line_number,int scope_number);
	int TOP;
	int Count;
	int SymTab[100];
	int yyerror(char*);
%}

%%

alignas|alignof|and|and_eq|asm|atomic_cancel|atomic_commit|atomic_noexcept|bitand|bitor|break|case|catch|class|compl|concept|const|consteval|constexpr|constinit|const_cast|continue|co_await|co_return|co_yield|decltype|default|delete|do|dynamic_cast|else|enum|explicit|export|extern|false|friend|goto|if|inline|mutable|namespace|new|noexcept|not|not_eq|nullptr|operator|or|or_eq|private|protected|public|reflexpr|register|reinterpret_cast|requires|signed|sizeof|static|static_assert|static_cast|struct|switch|synchronized|template|this|thread_local|throw|true|try|typedef|typeid|typename|union|unsigned|using|virtual|void|volatile|wchar_t|xor|xor_e  {return T_keyword;}

"int" 																{return T_int ; }
"main"																{return T_main ; }
"auto"|"bool"|"char"|"char8_t"|"char16_t"|"char32_t"|"double"|"float"|"long"|"short" 	{return T_type ;}
"return" 																{return T_return;}

"for"							{return T_for;}
"while"							{return T_while;}


"<<"							{return T_InputStream ;}
">>"							{return T_OutputStream ;}


"("							  	{return T_openParenthesis ;}		  
")"								{return T_closedParanthesis ;}
"{"								{	Count++;
									TOP++;
									SymTab[TOP] = Count;
									return T_openFlowerBracket ;
								}
"}"								{
									TOP--;
									return T_closedFlowerBracket ;
								}

">"|"<"|">="|"<="|"=="|"!="   	{return T_RelationalOperator ;}
"&&"|"[|][|]"					{return T_LogicalOperator ;}
"++"|"--"						{return T_UnaryOperator ;}
[+/%*-]							{return T_ArithmeticOperator ;}
"="								{return T_AssignmentOperator ;}
[&|^]							{return T_BitwiseOperator ;}

";"								{return T_Semicolon ;}

{letter}({letter}|{digit})* 	{Gen_Symbol_Table(yytext,yylineno,SymTab[TOP]);return T_identifier ;}

{digit}+						{return T_numericConstants ;}
\"([^\\\"]|\\.)*\"				{return T_stringLiteral; }	

[ \n\t]                          {;}
.								yyerror("Invalid character found, Abort!!!");

%%

struct Var 
{
	char C[20];
	char l[100];
	int scope_num;
	int y;
}

struct Scope
{
	struct Var Arr[50];
	int up;
};

struct Scope Symbol_Table[100];

void Gen_Symbol_Table(char* Text,int line_number,int scope_number)
{
	int flag=0;
	for(int i=0;i<=Symbol_Table[scope_number].up;i++)
	{
		if(strcmp(Symbol_Table[scope_number].Arr[i].c,text)==0)
		{
			char buffer[20];
			sprintf(buffer,"%d",nm);
			flag=1;
			strcat(Symbol_Table[scope_number].Arr[i].l,",");
			strcat(Symbol_Table[scope_number].Arr[i].l,buffer);	
			Symbol_Table[scope_number].Arr[i].scope=scope_number;		
			break;
		}
	}
	if(flag==0)
	{
		char buffer[20];
		sprintf(buffer,"%d",nm);
		Symbol_Table[scope_number].up++;
		int p=Symbol_Table[scope_number].up;
		strcpy(Symbol_Table[scope_number].Arr[p].c,text);
		strcpy(Symbol_Table[scope_number].Arr[p].l,"");
		strcat(Symbol_Table[scope_number].Arr[p].l,buffer);
		Symbol_Table[scope_number].Arr[p].scope=scope_number;
	}
}

void display()
{
	for(int i=0;i<=count;i++)
	{
		int h=Symbol_Table[i].up;
		for (int j=1;j<=h;j++)
		{
			printf("Symbol:%s \t Scope:%d \t Line number: %s\n",Symbol_Table[i].Arr[j].c,Symbol_Table[i].Arr[j].scope,Symbol_Table[i].Arr[j].l);
		}
	}	
}

int yywrap()
{
	return 1;
}

