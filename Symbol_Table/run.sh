yacc -d --debug --verbose Yacc.y
lex lex2.l
gcc y.tab.c lex.yy.c