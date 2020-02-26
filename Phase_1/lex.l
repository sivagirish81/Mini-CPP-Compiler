digit [0-9]
letter [A-Za-z_]

%{
	//#include "y.tab.h"
	int yyerror(char*);
	int st[100];
	int top;
	int count;
	void Gen_Symbol_Table(char *text,int nm,int scp);
	void display();
	// char Global_Type_Array[100];
%}

%option yylineno

%%


\"[^\"]*\"						{printf("T_stringLiteral ");}
"'"(.|\\n)"'"					{printf("T_character ");}
"//".*\n                        {;}
"/*"[^*/]*"*/"					{;}


alignas|alignof|and|and_eq|asm|atomic_cancel|atomic_commit|atomic_noexcept|bitand|bitor|break|case|catch|class|compl|concept|const|consteval|constexpr|constinit|const_cast|continue|co_await|co_return|co_yield|decltype|default|delete|do|dynamic_cast|enum|explicit|export|extern|false|friend|goto|inline|mutable|namespace|new|noexcept|not|not_eq|nullptr|operator|or|or_eq|private|protected|public|reflexpr|register|reinterpret_cast|requires|signed|sizeof|static|static_assert|static_cast|struct|switch|synchronized|template|this|thread_local|throw|true|try|typedef|typeid|typename|union|unsigned|using|virtual|void|volatile|wchar_t|xor|xor_e  {printf("T_keyword ");}

"if"																{printf("T_if  ");}
"else"																{printf("T_else  ");}

"int" 																{printf("T_int  "); }
"main"																{printf("T_main  "); }
"auto"|"bool"|"char"|"char8_t"|"char16_t"|"char32_t"|"double"|"float"|"long"|"short" 	{printf("T_type  ");}
"return" 																{printf("T_return ");}

"for"							{printf("T_for ");}
"while"							{printf("T_while ");}


"<<"							{printf("T_InputStream  ");}
">>"							{printf("T_OutputStream  ");}


"("							  	{printf("T_openParenthesis  ");}		  
")"								{printf("T_closedParanthesis  ");}
"{"								{count=count+1;top=top+1;st[top]=count;printf("T_openFlowerBracket  ");}
"}"								{top=top-1;printf("T_closedFlowerBracket  ");}

">"								{printf("T_greater ");}
">="							{printf("T_greater_equal ");}
"<"								{printf("T_less ");}
"<="							{printf("T_less_equal ");}
"=="							{printf("T_equal_equal ");}
"!="							{printf("T_not_equal ");}

"&&"							{printf("T_LogicalAnd ");}
"[|][|]"						{printf("T_LogicalOr ");}



"+="|"-="|"*="|"/="|"%="		{printf("T_shortHand ");}

"+"								{printf("T_plus ");}
"-"								{printf("T_minus ");}
"/"								{printf("T_divide ");}
"*"								{printf("T_multiply ");}
"%"								{printf("T_mod ");}
"="								{printf("T_AssignmentOperator  ");}

";"								{printf("T_Semicolon  ");}

{letter}({letter}|{digit})* 	{Gen_Symbol_Table(yytext,yylineno,st[top]);printf("T_identifier ");  }

{digit}+						{printf("T_numericConstants ");}


	
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
	// char type[100];
	int scope;
};
struct scope
{
	struct var arr[20];
	int up;
};

struct scope Symbol_Table[100];


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
			Symbol_Table[scp].arr[i].scope=scp;		
			break;
		}
	}
	if(flag==0)
	{
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
	printf("\n************************************************************************\n");
	for(int i=0;i<=count;i++)
	{
		int h=Symbol_Table[i].up;
		for (int j=1;j<=h;j++)
		{
			printf("Symbol:%s \t Scope:%d \t Line number: %s\n",Symbol_Table[i].arr[j].var_name,Symbol_Table[i].arr[j].scope,Symbol_Table[i].arr[j].Line_t);
		}
	}	
	printf("\n************************************************************************\n");

}

int yywrap()
{
	return 1;
}

int main()
{
	yylex();
	
	display();
}