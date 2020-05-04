def add_linep(variable,line_no):
	if variable!="NULL":
		if variable not in linesp:
			linesp[variable]=[]
		linesp[variable].append(line_no)
		if variable not in linesr:
			linesr[variable]=[]
		linesr[variable].append(line_no)


def add_liner(variable,line_no):
	if variable!="NULL":
		if variable not in linesr:
			linesr[variable]=[]
		linesr[variable].append(line_no)


def checkp(arg2,line_no):
	linesp[arg2].remove(line_no)
	linesr[arg2].remove(line_no)
	if(len(linesr[arg2])==0 and not(arg2.isnumeric())):
		temp=vtr[arg2][0]
		if(arg2[0]!="T" ):
			if(len(linesr[arg2])>len(linesp[arg2])):
				print("\tSTR %s %s"%(arg2,temp))
		tempreg=vtr.pop(arg2)
		del rtv[tempreg[0]]
		reg.insert(0,int(tempreg[0][1:]))
		reg.sort()
	

def checkr(arg2,line_no):
	linesr[arg2].remove(line_no)
	if(len(linesr[arg2])==0 and not(arg2.isnumeric())):
		temp=vtr[arg2][0]
		if(arg2[0]!="T"):
			print("\tSTR %s %s"%(arg2,temp))
		tempreg=vtr.pop(arg2)
		del rtv[tempreg[0]]
		reg.insert(0,int(tempreg[0][1:]))
		reg.sort()

def free_all():
	global vtr
	global rtv
	global reg
	y=[]
	for i in vtr:
		if(not(i.isnumeric())):
			y.append(i)
	
	for i in y:
		temp=vtr[i][0]
		if(linesp[i][0]==-1):
			print("\tSTR %s %s"%(i,temp))
		tempreg=vtr.pop(i)
		del rtv[tempreg[0]]
					
	vtr={}
	rtv={}
	reg=[]
	for i in range(1,total_reg+1):
		reg.append(i)

def getreg(val,f,i):			# i is 1 -> send immediate or register. f is whether load 
	global reg
	if i:
		if(val.isnumeric()):
			return("#"+val)
		else:
			if val not in vtr:
				a_reg=reg[0]
				assgn_reg="R"+str(a_reg)
				reg=reg[1:]
				vtr[val]=[assgn_reg]
				rtv[assgn_reg]=[val]
				if(f):
					print("\tLDR %s %s"%(assgn_reg,val))
				return(assgn_reg)
			else:
				return(vtr[val][0])

	else:
		if(val.isnumeric()):
			if val not in vtr:
				a_reg=reg[0]
				assgn_reg="R"+str(a_reg)
				reg=reg[1:]
				vtr[val]=[assgn_reg]
				rtv[assgn_reg]=[val]
				print("\tMOV %s #%s"%(assgn_reg,val))
				return(assgn_reg)
			else:
				return(vtr[val][0])
		else:
			if val not in vtr:
				a_reg=reg[0]
				assgn_reg="R"+str(a_reg)
				reg=reg[1:]
				vtr[val]=[assgn_reg]
				rtv[assgn_reg]=[val]
				if(f):
					print("\tLDR %s %s"%(assgn_reg,val))
				return(assgn_reg)
			else:
				return(vtr[val][0])


h=int(input())
p=h
q=[]
while(h):
	o=input()
	#print(o)
	s=o.split()
	q.append(s)
	h=h-1
reg=[]
total_reg=16
for i in range(1,total_reg+1):
	reg.append(i)
rtv={}
vtr={}
linesp={}
linesr={}


for i in range(p):
	if q[i][1]=="not":
		q[i-1][0]=q[i+1][0]
	

#print(linesp)
#print(linesr)



removed=[]
for i in range(p):
	if q[i][1]=="not":
		removed.append(i)
	elif q[i][1]=="if":
		removed.append(i)

p=p-len(removed)


w=0
for i in range(len(removed)):
	removed[i]=removed[i]-w
	w=w+1



for i in removed:
	del q[i]

'''
T1 		 < 		 a 		 b 		
T2 		 not 		 T1 		 NULL 		
L0 		 if 		 T2 		 NULL 	
Like what is 
became

L0 < a b. As this is all the information we need in assembly code
'''


block=0
for i in range(p):
	if(q[i][0][0]=="L" and q[i][1]=="Label"):
		block+=1
		q[i].append(block)
	elif q[i][0][0]=="L":
		q[i].append(block)
		block+=1
	else:
		q[i].append(block)

print(q)




for i in range(p):
	if q[i][1]=="not":
		c=1
	elif q[i][1]=="if":
		c=1
	elif q[i][1]=="Label":
		c=1
	elif q[i][1]=="goto":
		c=1
	elif q[i][1]=="<":
		add_linep(q[i][2],i)
		add_linep(q[i][3],i)
	elif q[i][1]=="<=":
		add_linep(q[i][2],i)
		add_linep(q[i][3],i)
	elif q[i][1]==">":
		add_linep(q[i][2],i)
		add_linep(q[i][3],i)
	elif q[i][1]==">=":
		add_linep(q[i][2],i)
		add_linep(q[i][3],i)
	elif q[i][1]=="==":
		add_linep(q[i][2],i)
		add_linep(q[i][3],i)
	elif q[i][1]=="!=":
		add_linep(q[i][2],i)
		add_linep(q[i][3],i)
	elif q[i][1]=="=":
		add_linep(q[i][2],i)
		add_liner(q[i][0],i)	
	else:
		add_liner(q[i][0],i)
		add_linep(q[i][2],i)
		add_linep(q[i][3],i)


for i in linesp:
	if (len(linesr[i])>len(linesp[i])):
		linesp[i].insert(0,-1)
	else:
		linesp[i].insert(0,-2)

# linesp is variables occuring only in operands
# llines r is both operands and destinations

print(linesp)
print(linesr)



print("\n\nstart:")
for i in range(p):
	
	if q[i][1]=="Label":
		free_all()
		print("%s:"%q[i][0])
	elif q[i][1]=="goto":
		free_all()
		print("\tB %s"%q[i][0])
	elif q[i][1]=="<":
		p1=getreg(q[i][2],1,0)
		p2=getreg(q[i][3],1,1)
		free_all()
		print("\tCMN %s %s"%(p1,p2))
		print("\tBLT %s"%q[i][0])
		linesp[q[i][2]].remove(i)
		linesp[q[i][3]].remove(i)
		linesr[q[i][2]].remove(i)
		linesr[q[i][3]].remove(i)
	elif q[i][1]=="<=":
		p1=getreg(q[i][2],1,0)
		p2=getreg(q[i][3],1,1)
		free_all()
		print("\tCMN %s %s"%(p1,p2))
		print("\tBLE %s"%q[i][0])
		linesp[q[i][2]].remove(i)
		linesp[q[i][3]].remove(i)
		linesr[q[i][2]].remove(i)
		linesr[q[i][3]].remove(i)
	elif q[i][1]==">":
		p1=getreg(q[i][2],1,0)
		p2=getreg(q[i][3],1,1)
		free_all()
		print("\tCMN %s %s"%(p1,p2))
		print("\tBGT %s"%q[i][0])
		linesp[q[i][2]].remove(i)
		linesp[q[i][3]].remove(i)
		linesr[q[i][2]].remove(i)
		linesr[q[i][3]].remove(i)
	elif q[i][1]==">=":
		p1=getreg(q[i][2],1,0)
		p2=getreg(q[i][3],1,1)
		free_all()
		print("\tCMN %s %s"%(p1,p2))
		print("\tBGE %s"%q[i][0])
		linesp[q[i][2]].remove(i)
		linesp[q[i][3]].remove(i)
		linesr[q[i][2]].remove(i)
		linesr[q[i][3]].remove(i)
	elif q[i][1]=="==":
		p1=getreg(q[i][2],1,0)
		p2=getreg(q[i][3],1,1)
		free_all()
		print("\tCMN %s %s"%(p1,p2))
		print("\tBEQ %s"%q[i][0])
		linesp[q[i][2]].remove(i)
		linesp[q[i][3]].remove(i)
		linesr[q[i][2]].remove(i)
		linesr[q[i][3]].remove(i)
	elif q[i][1]=="!=":
		p1=getreg(q[i][2],1,0)
		p2=getreg(q[i][3],1,1)
		free_all()
		print("\tCMN %s %s"%(p1,p2))
		print("\tBNE %s"%q[i][0])
		linesp[q[i][2]].remove(i)
		linesp[q[i][3]].remove(i)
		linesr[q[i][2]].remove(i)
		linesr[q[i][3]].remove(i)
	elif q[i][1]=="+":
		p1=getreg(q[i][2],1,0)
		p2=getreg(q[i][3],1,1)
		checkp(q[i][2],i)
		checkp(q[i][3],i)
		res=getreg(q[i][0],0,0)
		print("\tADD %s %s %s"%(res,p1,p2))
		checkr(q[i][0],i)

	elif q[i][1]=="-":
		p1=getreg(q[i][2],1,0)
		p2=getreg(q[i][3],1,1)
		checkp(q[i][2],i)
		checkp(q[i][3],i)
		res=getreg(q[i][0],0,0)
		print("\tSUB %s %s %s"%(res,p1,p2))
		checkr(q[i][0],i)
	elif q[i][1]=="*":
		p1=getreg(q[i][2],1,0)#no immediate allowed
		p2=getreg(q[i][3],1,0)
		checkp(q[i][2],i)
		checkp(q[i][3],i)
		res=getreg(q[i][0],0,0)
		print("\tMUL %s %s %s"%(res,p1,p2))
		checkr(q[i][0],i)
	elif q[i][1]=="/":
		p1=getreg(q[i][2],1,0)
		p2=getreg(q[i][3],1,0)
		checkp(q[i][2],i)
		checkp(q[i][3],i)
		res=getreg(q[i][0],0,0)
		print("\tUDIV %s %s %s"%(res,p1,p2))
		checkr(q[i][0],i)
	elif q[i][1]=="&&":
		p1=getreg(q[i][2],1,0)
		p2=getreg(q[i][3],1,1)
		checkp(q[i][2],i)
		checkp(q[i][3],i)
		res=getreg(q[i][0],0,0)
		print("\tAND %s %s %s"%(res,p1,p2))
		checkr(q[i][0],i)
	elif q[i][1]=="||":
		p1=getreg(q[i][2],1,0)
		p2=getreg(q[i][3],1,1)
		checkp(q[i][2],i)
		checkp(q[i][3],i)
		res=getreg(q[i][0],0,0)
		print("\tORR %s %s %s"%(res,p1,p2))
		checkr(q[i][0],i)
	elif q[i][1]=="=":
		p1=getreg(q[i][2],1,1)
		checkp(q[i][2],i)
		res=getreg(q[i][0],0,0)
		if(res!=p1):
			print("\tMOV %s %s"%(res,p1))
		checkr(q[i][0],i)

print("\n\n")
