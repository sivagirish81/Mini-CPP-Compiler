yacc -d --warning=none Yacc.y
lex lex.l
gcc y.tab.c lex.yy.c
./a.out < input.cpp