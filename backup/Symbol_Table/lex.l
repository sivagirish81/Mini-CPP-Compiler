digit [0-9]
letter [A-Za-z_]
%option yylineno
%{
	#include "y.tab.h"
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
"{"								{return T_openFlowerBracket ;}
"}"								{return T_closedFlowerBracket ;}

">"|"<"|">="|"<="|"=="|"!="   	{return T_RelationalOperator ;}
"&&"|"[|][|]"					{return T_LogicalOperator ;}
"++"|"--"						{return T_UnaryOperator ;}
[+/%*-]							{return T_ArithmeticOperator ;}
"="								{return T_AssignmentOperator ;}
[&|^]							{return T_BitwiseOperator ;}

";"								{return T_Semicolon ;}

{letter}({letter}|{digit})* 	{return T_identifier ;}

{digit}+						{return T_numericConstants ;}
\"([^\\\"]|\\.)*\"				{return T_stringLiteral; }	

 \n                          {yylineno++;}
 \t  						 {;}
.								yyerror("Invalid character found, Abort!!!");


%%


int yywrap()
{
	return 1;
}

