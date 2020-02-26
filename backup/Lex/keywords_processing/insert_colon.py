s = "auto|bool|char|char8_t|char16_t|char32_t|double|float|long|short" 
s = s.split("|")
for i in s:
	print('"' + i + '"|', end = "")
print()