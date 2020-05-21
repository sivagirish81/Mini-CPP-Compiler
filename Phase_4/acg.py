def initialize_register_list():
	return list(range(1, number_of_registers+1))



def read_quadruples(file):
	f = open(file, "r")
	instructions = list()
	for i in f.readlines():
		instructions.append(i.split())
	return instructions


def remove_ifs_and_nots(instructions):
	to_be_removed = list()
	for i in range(len(instructions)):
		if instructions[i][0] == "not":
			instructions[i-1][3] = instructions[i+1][3]
			to_be_removed.append(i)
		elif instructions[i][0] == "if":
			to_be_removed.append(i)

	to_be_removed.sort(reverse = True)	
	for index in to_be_removed:		#deleting from behind so that index doesnt change
		del instructions[index]

def getRegister(value, to_be_loaded):	# remember to load when returned. Also rtv code and 0 index
	global available_registers
	global variable_register_mapping
<<<<<<< HEAD
	# print(variable_register_mapping.keys())
	if (len(available_registers) == 0):
		print("Freeing Registers")
		release_registers()
		if (len(available_registers) == 0):
			global swap_space
			# swap_space.append(variable_register_mapping[0])
			print("Stack limit Reached")
=======

	if(len(available_registers) == 0):
		reg = available_registers.pop(0)
		


>>>>>>> f0ba2a02efeccb94db351381e21d8ca1dd8b470a
	if(value.isnumeric()):
		return "#" + value
	else:
		if value in variable_register_mapping:
			used_registers.remove(variable_register_mapping[value])
			used_registers.append(variable_register_mapping[value])
			return "R" + str(variable_register_mapping[value])
		else:
			variable_register_mapping[value] = available_registers[0]
			if(to_be_loaded):
				print("LD", "R" + str(available_registers[0]), value)
			to_return = "R" + str(available_registers[0])
			available_registers.pop(0)
			used_registers.append(to_return)
			return to_return

def add_variable_to_line_mapping(variable, line, mapping):
	if(variable != "(null"):
		if variable not in mapping:
			mapping[variable] = []
		mapping[variable].append(line)

def map_variable_lines(instructions):


	global source_variable_lines_mapping
	global common_variable_lines_mapping

	for i in range(len(instructions)):
		if instructions[i][0] in ["Label", "goto"]:			# label and goto have no use of registers
			pass
		elif instructions[i][0] in ["<", "<=", ">", ">=", "==", "!="]: 
			add_variable_to_line_mapping(instructions[i][1], i, source_variable_lines_mapping)
			add_variable_to_line_mapping(instructions[i][2], i, source_variable_lines_mapping)
			add_variable_to_line_mapping(instructions[i][1], i, common_variable_lines_mapping)
			add_variable_to_line_mapping(instructions[i][2], i, common_variable_lines_mapping)

		elif instructions[i][0] == "=":
			# print(i)
			# print(source_variable_lines_mapping)
			# print(common_variable_lines_mapping)
			add_variable_to_line_mapping(instructions[i][1], i, source_variable_lines_mapping)
			add_variable_to_line_mapping(instructions[i][1], i, common_variable_lines_mapping)
			add_variable_to_line_mapping(instructions[i][3], i, common_variable_lines_mapping)
			# print(source_variable_lines_mapping)
			# print(common_variable_lines_mapping)
		
		else:
			add_variable_to_line_mapping(instructions[i][1], i, source_variable_lines_mapping)
			add_variable_to_line_mapping(instructions[i][2], i, source_variable_lines_mapping)
			add_variable_to_line_mapping(instructions[i][1], i, common_variable_lines_mapping)
			add_variable_to_line_mapping(instructions[i][2], i, common_variable_lines_mapping)
			add_variable_to_line_mapping(instructions[i][3], i, common_variable_lines_mapping)

	

def release_registers():

	global variable_register_mapping
	global available_registers

	# print(variable_register_mapping)

	variables_used = [i for i in variable_register_mapping if not i.isnumeric()]
	for i in variables_used:
		register = variable_register_mapping[i]
		if(len(common_variable_lines_mapping[i]) >= len(source_variable_lines_mapping[i])):
			print("ST ", i, "R" + str(register))

	variable_register_mapping = {}
	available_registers = initialize_register_list()

def check_source(value, line):
	
	source_variable_lines_mapping[value].remove(line)
	common_variable_lines_mapping[value].remove(line)
	if(len(common_variable_lines_mapping[value]) == 0 and not value.isnumeric()):
		reg = variable_register_mapping[value]
		if(value[0] != 'T'):
			if(len(common_variable_lines_mapping[value]) >= len(source_variable_lines_mapping[value])):
				print("ST", value, "R" + str(reg))
		variable_register_mapping.pop(value)
		available_registers.insert(0, reg)
		available_registers.sort()


def check_destination(value, line):

	common_variable_lines_mapping[value].remove(line)
	if(len(common_variable_lines_mapping[value]) == 0 and not value.isnumeric()):
		reg = variable_register_mapping[value]
		if(value[0] != 'T'):
				print("ST", value, "R" + str(reg))
		variable_register_mapping.pop(value)
		available_registers.insert(0, reg)
		available_registers.sort()


def assembly_gen(instructions):

	global source_variable_lines_mapping
	global common_variable_lines_mapping

	remove_ifs_and_nots(instructions)

	map_variable_lines(instructions)


	print("Start:")

	for i in range(len(instructions)):
		
		if(instructions[i][0] == "Label"):
			release_registers()		
			print(instructions[i][3] + ":")
		elif(instructions[i][0] == "goto"):
			release_registers()
			print("BR " + instructions[i][3])
		elif instructions[i][0] in ["<", "<=", ">", ">=", "==", "!="]: 
			reg1 = getRegister(instructions[i][1], 1)
			reg2 = getRegister(instructions[i][2], 1)
			print("CMP", reg1, reg2)
			if instructions[i][0] == "<":
				print("BLT", instructions[i][3])
			elif instructions[i][0] == "<=":
				print("BLE", instructions[i][3])
			elif instructions[i][0] == ">":
				print("BGT", instructions[i][3])
			elif instructions[i][0] == ">=":
				print("BGE", instructions[i][3])
			elif instructions[i][0] == "==":
				print("BEQ", instructions[i][3])
			elif instructions[i][0] == "!=":
				print("BNE", instructions[i][3])

			source_variable_lines_mapping[instructions[i][1]].remove(i)
			source_variable_lines_mapping[instructions[i][2]].remove(i)
			common_variable_lines_mapping[instructions[i][1]].remove(i)
			common_variable_lines_mapping[instructions[i][2]].remove(i)

		elif instructions[i][0] in ["+", "-", "*", "/", "&&", "||"]: 
			reg1 = getRegister(instructions[i][1], 1)
			reg2 = getRegister(instructions[i][2], 1)		
			reg3 = getRegister(instructions[i][3], 0)
			

			if instructions[i][0] == "+":
				print("ADD", reg3, reg1, reg2)
			elif instructions[i][0] == "-":
				print("SUB", reg3, reg1, reg2)
			elif instructions[i][0] == "*":
				print("MUL", reg3, reg1, reg2)
			elif instructions[i][0] == "/":
				print("DIV", reg3, reg1, reg2)
			elif instructions[i][0] == "&&":
				print("AND", reg3, reg1, reg2)
			elif instructions[i][0] == "||":
				print("OR", reg3, reg1, reg2)

			check_source(instructions[i][1], i)
			check_source(instructions[i][2], i)
			check_destination(instructions[i][3], i)
		

		else:
			reg1 = getRegister(instructions[i][3], 0)		
			reg2 = getRegister(instructions[i][1], 1)
			print("MOV", reg1, reg2)

			check_source(instructions[i][1], i)
			check_destination(instructions[i][3], i)		

instructions = read_quadruples("Quadruples.txt")

number_of_registers = 16
available_registers = initialize_register_list()
variable_register_mapping = {}	
# Which register is variable stored in. Useful to avoid redundant registers

<<<<<<< HEAD
swap_space = {}

=======
source_variable_lines_mapping = {}	# source variables and corresponding line number
common_variable_lines_mapping = {}	# source and destination variables and corresponding line numbers
used_registers = []
>>>>>>> f0ba2a02efeccb94db351381e21d8ca1dd8b470a
assembly_gen(instructions)
