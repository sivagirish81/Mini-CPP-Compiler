digit [0-9]
letter [A-Za-z_]



%{
	#include <stdio.h>
	int yyerror(char*);
	int count;
%}

%%



alignas|alignof|and|and_eq|asm|atomic_cancel|atomic_commit|atomic_noexcept|bitand|bitor|break|case|catch|class|compl|concept|const|consteval|constexpr|constinit|const_cast|continue|co_await|co_return|co_yield|decltype|default|delete|do|dynamic_cast|else|enum|explicit|export|extern|false|friend|goto|if|inline|mutable|namespace|new|noexcept|not|not_eq|nullptr|operator|or|or_eq|private|protected|public|reflexpr|register|reinterpret_cast|requires|signed|sizeof|static|static_assert|static_cast|struct|switch|synchronized|template|this|thread_local|throw|true|try|typedef|typeid|typename|union|unsigned|using|virtual|void|volatile|wchar_t|xor|xor_e  {printf("keyword ");}

"int" 																{printf("int "); }
"main"																{printf("main "); }
"auto"|"bool"|"char"|"char8_t"|"char16_t"|"char32_t"|"double"|"float"|"long"|"short" 	{printf("type ");}
"return" 																{printf("return ");}

"for"							{printf("for ");}
"while"							{printf("while ");}


"<<"							{printf("InputStream ");}
">>"							{printf("OutputStream ");}


"("							  	{printf("OpenParenthesis ");}		  
")"								{printf("ClosedParanthesis ");}
"{"								{printf("OpenFlowerBracket ");}
"}"								{printf("ClosedFlowerBracket ");}

">"|"<"|">="|"<="|"=="|"!="   	{printf("RelationalOperator ");}
"&&"|"[|][|]"					{printf("LogicalOperator ");}
"++"|"--"						{printf("UnaryOperator ");}
[+/%*-]							{printf("ArithmeticOperator ");}
"="								{printf("AssignmentOperator ");}
[&|^]							{printf("BitwiseOperator ");}

";"								{printf("Semicolon ");}

{letter}({letter}|{digit})* 	{printf("identifier ");}

{digit}+						{printf("NumericConstants ");}
\"([^\\\"]|\\.)*\"				{printf("String Literal" ); }	

[ \n\t]                          {;}
.								yyerror("Invalid character found, Abort!!!");


%%

int yyerror(char* message)
{
	printf("\n\n\n%s\n\n\n", message);
	exit(1);
}

int yywrap()
{
	return 1;
}

int main()
{

	FILE* fin = fopen("input.cpp", "r");
	yyin = fin;
	FILE* fout = fopen("output.txt", "w");
	yyout = fout;

	yylex();
	printf("\n");

	fclose(fin);
	fclose(fout);

	return 0;
}


/*
	Choose tokens such that parser does not need to know its value. eg: Parser only needs to know that a relational operator is present 
	between variables for a condition in if or a variable is present
*/