yacc -d Yacc.y
lex lex.l
gcc y.tab.c lex.yy.c