digit [0-9]
letter [A-Za-z_]

%{
	int yyerror();
%}

%%


\"[^\"]*\"						{printf("T_stringLiteral "); }
"'"(.|\\n)"'"					{printf("T_character ");}
"//".*\n                        {;}
"/*"[^*/]*"*/"					{;}


alignas|alignof|and|and_eq|asm|atomic_cancel|atomic_commit|atomic_noexcept|bitand|bitor|break|case|catch|class|compl|concept|const|consteval|constexpr|constinit|const_cast|continue|co_await|co_return|co_yield|decltype|default|delete|do|dynamic_cast|enum|explicit|export|extern|false|friend|goto|inline|mutable|namespace|new|noexcept|not|not_eq|nullptr|operator|or|or_eq|private|protected|public|reflexpr|register|reinterpret_cast|requires|signed|sizeof|static|static_assert|static_cast|struct|switch|synchronized|template|this|thread_local|throw|true|try|typedef|typeid|typename|union|unsigned|using|virtual|void|volatile|wchar_t|xor|xor_e  {printf("T_keyword ");}

"if"																{printf("T_if " );}
"else"																{printf("T_else" );}
"int" 																{printf("T_int "); }
"main"																{printf("T_main "); }
"auto"|"bool"|"char"|"char8_t"|"char16_t"|"char32_t"|"double"|"float"|"long"|"short" 	{printf("T_type ");}
"return" 																{printf("T_return ");}

"for"							{printf("T_for ");}
"while"							{printf("T_while ");}


"<<"							{printf("T_InputStream ");}
">>"							{printf("T_OutputStream ");}


"("							  	{printf("T_openParenthesis ");}		  
")"								{printf("T_closedParanthesis ");}
"{"								{printf("T_openFlowerBracket ");}
"}"								{printf("T_closedFlowerBracket ");}

">"|"<"|">="|"<="|"=="|"!="   	{printf("T_RelationalOperator ");}
"&&"|"[|][|]"					{printf("T_LogicalOperator ");}
"++"|"--"						{printf("T_UnaryOperator  ");}
[+/%*-]							{printf("T_ArithmeticOperator ");}
"="								{printf("T_AssignmentOperator ");}
[&|^]							{printf("T_BitwiseOperator ");}

";"								{printf("T_Semicolon ");}

{letter}({letter}|{digit})* 	{printf("T_identifier ");}

{digit}+						{printf("T_numericConstants ");}


	
[ \t]                          {/*printf("T_whiteSpace ");*/}
[\n]							{;}
.								yyerror("Invalid character found, Abort!!!");


%%


int yywrap()
{
	return 1;
}

int yyerror()
{
	printf("Lex error\n");
}

int main()
{
	yylex();
}