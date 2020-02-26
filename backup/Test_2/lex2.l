digit [0-9]
letter [A-Za-z_]

%{
	#include "y.tab.h"
	int yyerror(char*);
%}

%option yylineno

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
"auto"|"bool"|"char"|"char8_t"|"char16_t"|"char32_t"|"double"|"float"|"long"|"short" 	{return T_type ;}
"return" 																{return T_return;}

"for"							{return T_for;}
"while"							{return T_while;}


"<<"							{return T_InputStream ;}
">>"							{return T_OutputStream ;}


"("							  	{return T_openParenthesis ;}		  
")"								{return T_closedParanthesis ;}
"{"								{return T_openFlowerBracket ;}
"}"								{return T_closedFlowerBracket ;}

">"								{return T_greater;}
">="							{return T_greater_equal;}
"<"								{return T_less;}
"<="							{return T_less_equal;}
"=="							{return T_equal_equal;}
"!="							{return T_not_equal;}

"&&"							{return T_LogicalAnd;}
"[|][|]"						{return T_LogicalOr;}



"+="|"-="|"*="|"/="|"%="		{return T_shortHand;}

"+"								{return T_plus;}
"-"								{return T_minus;}
"/"								{return T_divide;}
"*"								{return T_multiply;}
"%"								{return T_mod;}
"="								{return T_AssignmentOperator ;}

";"								{return T_Semicolon ;}

{letter}({letter}|{digit})* 	{return T_identifier ;}

{digit}+						{return T_numericConstants ;}


	
[ \t]                          {/*printf("T_whiteSpace ");*/}
[\n]							{;}
.								yyerror("Invalid character found, Abort!!!");


%%


int yywrap()
{
	return 1;
}
