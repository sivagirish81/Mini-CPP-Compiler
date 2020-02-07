yacc -d bare_yac.y
lex while_if_for.l
gcc y.tab.c lex.yy.c
 
