yacc -d Yacc.y
lex while_if_for.l
gcc y.tab.c lex.yy.c
 
