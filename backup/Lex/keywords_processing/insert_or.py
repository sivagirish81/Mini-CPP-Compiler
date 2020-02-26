f = open('keywords.txt', 'r')
for i in f:
	print(i[:-1], end = '|')
print()