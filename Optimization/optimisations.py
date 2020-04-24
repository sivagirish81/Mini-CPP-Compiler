input_file = open('example.txt','r')
output_file = open('output.txt','w')

constant_folded_list = []
tempDict = dict()

file_lines = input_file.readlines()

for i in file_lines:
	
	i = i.strip("\n")

	ops,arg1,arg2,res = i.split()
	operator = ["+","-","*","/"]


	if(ops in operator):
		
		if(arg1.isdigit() and arg2.isdigit()):

			resu = eval(arg1+ops+arg2)
			tempDict[res] = resu
			constant_folded_list.append(["=",resu,"NULL",res])

		elif (arg1.isdigit()):

			if(arg2 in tempDict):

				resu = eval(arg1+op+tempDict[arg2])
				tempDict[res] = resu
				constant_folded_list.append(["=",resu,"NULL",res])

			else:
				constant_folded_list.append([op,arg1,arg2,res])

		elif (arg2.isdigit()):

			if(arg1 in tempDict):

				resu = eval(tempDict[arg1]+ops+arg2)
				tempDict[res] = resu
				constant_folded_list.append(["=",resu,"NULL",res])

			else:
				constant_folded_list.append([ops,arg1,arg2,res])	

		else:

			arg1_in_dict = 0
			arg2_in_dict = 0

			arg1_res = arg1

			if(arg1 in tempDict):

				arg1_res = str(tempDict[arg1])
				arg1_in_dict = 1

			arg2_res = arg2

			if(arg2 in tempDict):

				arg2_res = str(tempDict[arg2])
				arg2_in_dict = 1

			if(arg2_in_dict and arg1_in_dict):

				result = eval(arg1_res+ops+arg2_res)
				tempDict[res] = result
				constant_folded_list.append(["=",result,"NULL",res])
			
			else:
				constant_folded_list.append([ops,arg1_res,arg2_res,res])


	elif (ops == '='):

		if(arg1.isdigit()):

			tempDict[res] = arg1
			constant_folded_list.append(["=",arg1,"NULL",res])
		else : 

			if(arg1 in tempDict):

				constant_folded_list.append(["=",tempDict[arg1],"NULL",res])
			
			else:

				constant_folded_list.append(["=",arg1,"NULL",res])

	else:

		constant_folded_list.append([ops,arg1,arg2,res])


print("After code optimisation")
print("----------------------------------------------")

for i in constant_folded_list:

	if(i[0] == "="):
		pass

	elif(i[0] in ["+","-","*","/","==","<=","<",">",">="]):
		print(i[3],"=",i[1],i[0],i[2])

	elif(i[0] in ["not","goto","label","if"]):

		if(i[0]=="if"):
			print(i[0],i[1],"goto",i[3])

		if(i[0]=="not"):
			print(i[3],"=",i[0],i[1])

		if(i[0]=="goto"):
			print(i[0],i[3])
        
        if(i[0]=="label"):
            print(i[3],":")
        




