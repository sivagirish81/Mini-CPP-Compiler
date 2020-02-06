lex lex.l
yacc yacc.y
gcc y.tab.c -ll -ly -w
./a.out
