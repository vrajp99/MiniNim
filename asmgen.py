#!/usr/bin/env python3
import sys

# For changing color of output in print
class color:
    GREEN = '\033[1;32;48m'
    YELLOW = '\033[1;33;48m'
    RED = '\033[1;31;48m'
    END = '\033[0m'

class var:
    def __init__(self, name, typ, size):
        self.name = name # Name of the variable (This will be the alias)
        self.type = typ # int, float, bool, str, char = 0,1,2,3,4
        self.size = size # Number of bytes of storage required

const = -1 # A global counter, used for float literals, as they have to be stored in .data 

# Utility function to generate a constant name,for float literals
def gen_const():
    global const
    const+=1
    return "_const%d"%const

''' 
    Function to backpatch the bp_labels with corresponding labels, 
    store the symbol table info and extract the final Intermediate 
    Representation.
'''
def get_IR():
    IR = ""
    patches = {}
    vars = {}
    with open(".mininimIR", "r") as f:
        line = f.readline()
        while line.strip() != "IR_END":
            IR += line
            line = f.readline()
        while line.strip() != "PATCH_LABELS":
            line = f.readline()
        while line.strip() != "DATA":
            if line[:3]=="_bp":
                bplab, lab = line.strip().split()
                patches[bplab] = lab
            line = f.readline()
        while line != "":
            if line[:5]=="_temp":
                name, typ, size = line.strip().split()
                vars[name] = var(name, int(typ), size)
            line = f.readline()
    for bplab in patches:
        IR = IR.replace(bplab+"\n", patches[bplab]+"\n")
    
    return IR.split("\n"), vars

# Begin: Macros for different operations #
def asmd(a,b,c,op,oper,sym): # Add, Sub, Mul and Div
    if op == sym:
        if sym=="/":
            return "lw $t0, %s\n\tmtc1 $t0, $f2\n\tcvt.d.w $f2, $f2\n\tlw $t1, %s\n\tmtc1 $t1, $f4\n\tcvt.d.w $f4, $f4\n\t%s.d $f6, $f2, $f4\n\tsdc1 $f6, %s\n"%(b.name,c.name,oper, a.name)
        return "lw $t0, %s\n\tlw $t1, %s\n\t%s $t2, $t0, $t1\n\tsw $t2, %s\n"%(b.name,c.name,oper,a.name)
    if op[0] == "f":
        code = "ldc1 $f2, %s\n\t"%b.name
    else:
        code = "lw $t0, %s\n\tmtc1 $t0, $f2\n\tcvt.d.w $f2, $f2\n\t"%b.name
    if op[-1]== "f":
        code += "ldc1 $f4, %s\n\t"%c.name
    else:
        code += "lw $t1, %s\n\tmtc1 $t1, $f4\n\tcvt.d.w $f4, $f4\n\t"%c.name
    code += "%s.d $f6, $f2, $f4\n\tsdc1 $f6, %s\n"%(oper, a.name)
    return code

def uminus(a,b,op): # Unary -
    if op == "-":
        return "lw $t0, %s\n\tsub $t1, $zero, $t0\n\tsw $t1, %s\n"%(b.name,a.name)
    else:
        return "ldc1 $f0, _zero\n\tldc1 $f2, %s\n\tsub.d $f4, $f0, $f2\n\tsdc1 $f4, %s\n"%(b.name,a.name)

def if_(a,b,label,op,sym): # If rules with all supported relops
    code = ""
    if op==sym:
        return "lw $t0, %s\n\tlw $t1, %s\n\tb%s $t0, $t1, %s\n"%(a.name, b.name, sym, label)
    if op[0] == "f":
        code += "ldc1 $f2, %s\n\t"%a.name
    else:
        code += "lw $t0, %s\n\tmtc1 $t0, $f2\n\tcvt.d.w $f2, $f2\n\t"%a.name
    if op[-1]== "f":
        code += "ldc1 $f4, %s\n\t"%b.name
    else:
        code += "lw $t1, %s\n\tmtc1 $t1, $f4\n\tcvt.d.w $f4, $f4\n\t"%b.name
    code += "sub.d $f6, $f2, $f4\n\tldc1 $f0, _zero\n\tc.%s.d $f6, $f0\n\tbc1t %s\n"%(sym,label)
    return code

def printt(a,op): # Printing: int, float and string
    if op == "f":
        return "ldc1 $f12, %s\n\tli $v0, 3\n\tsyscall\n"%a
    elif op == "i":
        return "lw $a0, %s\n\tli $v0,1\n\tsyscall\n"%a
    else:
        return "la $a0, %s\n\tli $v0,4\n\tsyscall\n"%a

def inputt(a,op): # Input: int and float
    if op=="f":
        if "[" in a:
            return "lw $t0, %s\n\tli $v0, 7\n\tsyscall\n\tsdc1 $f0, %s($t0)\n"%(a[a.find("[")+1:a.find("]")], a[:a.find("[")])
        else:
            return "li $v0, 7\n\tsyscall\n\tsdc1 $f0, %s\n"%a
    else:
        if "[" in a:
            return "lw $t0, %s\n\tli $v0,5\n\tsyscall\n\tsw $v0, %s($t0)\n"%(a[a.find("[")+1:a.find("]")], a[:a.find("[")])
        else:
            return "li $v0,5\n\tsyscall\n\tsw $v0, %s\n"%a

printnl = lambda: "li $v0, 4\n\tla $a0, _newline\n\tsyscall\n" # Printing newline
idiv = lambda a,b,c: "lw $t0, %s\n\tlw $t1, %s\n\tdiv $t2, $t0, $t1\n\tsw $t2, %s\n"%(b.name,c.name,a.name) # Integer Division
mod = lambda a,b,c: "lw $t0, %s\n\tlw $t1, %s\n\tdiv $t0, $t1\n\tmfhi $t2\n\tsw $t2, %s\n"%(b.name,c.name,a.name) # Modulo
ixor = lambda a,b,c: "lw $t0, %s\n\tlw $t1, %s\n\txor $t2, $t0, $t1\n\tsw $t2, %s\n"%(b.name,c.name,a.name) # Bitwise XOR
ior = lambda a,b,c: "lw $t0, %s\n\tlw $t1, %s\n\tor $t2, $t0, $t1\n\tsw $t2, %s\n"%(b.name,c.name,a.name) # Bitwise OR
iand = lambda a,b,c: "lw $t0, %s\n\tlw $t1, %s\n\tand $t2, $t0, $t1\n\tsw $t2, %s\n"%(b.name,c.name,a.name) # Bitwise AND
assignfi = lambda a,b: "lw $t0, %s\n\tmtc1 $t0, $f2\n\tcvt.d.w $f2, $f2\n\tsdc1 $f2, %s\n"%(b.name,a.name) # Assign: float = int
assignii = lambda a,b: "lw $t0, %s\n\tsw $t0, %s\n"%(b.name, a.name) # Assign: int = int
assignff = lambda a,b: loadf(a,b.name) #Assign: float = float
# Similar assignments to and from arrays
arrassignfi = lambda a,ind,b: "lw $t0, %s\n\tlw $t1, %s\n\tmtc1 $t1, $f2\n\tcvt.d.w $f2, $f2\n\tsdc1 $f2, %s($t0)\n"%(ind,b.name,a.name)
arrassignii = lambda a,ind,b: "lw $t0, %s\n\tlw $t1, %s\n\tsw $t1, %s($t0)\n"%(ind, b.name, a.name)
arrassignff = lambda a,ind,b: "lw $t0, %s\n\tldc1 $f2, %s\n\tsdc1 $f2, %s($t0)\n"%(b,a.name)
assignfiarr = lambda a,ind,b: "lw $t0, %s\n\tlw $t1, %s($t0)\n\tmtc1 $t1, $f2\n\tcvt.d.w $f2, $f2\n\tsdc1 $f2, %s\n"%(ind, b.name,a.name)
assigniiarr = lambda a,ind,b: "lw $t0, %s\n\tlw $t1, %s($t0)\n\tsw $t1, %s\n"%(ind, b.name, a.name)
assignffarr = lambda a,ind,b: "lw $t0, %s\n\tldc1 $f2, %s($t0)\n\tsdc1 $f2, %s\n"%(ind, b.name, a.name)
# Load Immediate:
loadif = lambda a,b: "li $t0, %s\n\tmtc1 $t0, $f2\n\tcvt.d.w $f2, $f2\n\tsdc1 $f2, %s\n"%(b,a.name) # float = int
loadf = lambda a,b: "ldc1 $f2, %s\n\tsdc1 $f2, %s\n"%(b,a.name) # float
loadi = lambda a,b: "li $t0, %s\n\tsw $t0, %s\n"%(b,a.name) # int

#End Macros

'''
    Main function:
    Generates MIPS code from Intermediate Representation
'''
def gen_asm(IR, vars):
    data = '.data\n\t_zero: .double 0.0\n\t_incr: .word 1\n\t_newline: .asciiz "\\n"\n\t.align 6\n'
    text = ".text\n.globl main\n  main:"
    done = {"_incr"}

    for line in IR:
        atr = line.split()
        if len(atr)>=3 and  ("\"" in atr[2]) and ("s=s" in atr[1]):
            strr = line[line.find('"'):]
            data += "\t" + atr[0] + ": .asciiz " + strr + "\n\t.align "+ str(8 - int(vars[atr[0]].size)%8)+"\n"
            done.add(atr[0])
        elif len(atr)==1 and atr[0][0]=="l":
            text += "\n  "+atr[0]+"\n"
        elif len(atr)==1 and atr[0][0]=="p":
            text += "\t"+printnl()
        elif len(atr)==2 and atr[0]=="goto":
            text += "\t"+"b "+atr[1]+"\n"
        elif len(atr)==2 and atr[0][1:]=="print":
            text += "\t" + printt(atr[1],atr[0][0])+ "\t"
        elif len(atr)==2 and atr[0][1:]=="read":
            text += "\t" + inputt(atr[1],atr[0][0])+ "\t"
        elif len(atr)==3 and ("=" in atr[1]):
            if atr[2][0]!="_":
                v1 = vars[atr[0]]
                if atr[1][0]=="f":
                    cons = gen_const()
                    data += "\t" + cons + ": .double " + atr[2] + "\n"
                    text += "\t" + loadf(v1, cons)
                    if atr[0] not in done:
                        data += "\t" + atr[0] + ": .space 8\n"
                else:
                    text += "\t" + loadi(v1, atr[2])
                    if atr[0] not in done:
                        data += "\t" + atr[0] + ": .space 4\n\t.align 4\n"
                done.add(atr[0])
            else:
                if "[" in atr[0]:
                    ind = atr[0][atr[0].find("[")+1:atr[0].find("]")]
                    arr = atr[0][:atr[0].find("[")]  
                    if atr[1][-1]=="f":
                        text += "\t" + arrassignfi(vars[arr], ind, vars[atr[2]])
                    elif atr[1][0]=="f":
                        text += "\t" + arrassignff(vars[arr], ind, vars[atr[2]])
                    else:
                        text += "\t" + arrassignii(vars[arr], ind, vars[atr[2]])
                elif "[" in atr[2]:
                    ind = atr[2][atr[2].find("[")+1:atr[2].find("]")]
                    arr = atr[2][:atr[2].find("[")]
                    if atr[1][-1]=="f":
                        text += "\t" + assignfiarr(vars[atr[0]], ind, vars[arr])
                    elif atr[1][0]=="f":
                        text += "\t" + assignffarr(vars[atr[0]], ind, vars[arr])
                    else:
                        text += "\t" + assigniiarr(vars[atr[0]], ind, vars[arr])
                else:
                    if atr[1][-1]=="f":
                        text += "\t" + assignfi(vars[atr[0]], vars[atr[2]])
                    elif atr[1][0]=="f":
                        text += "\t" + assignff(vars[atr[0]], vars[atr[2]])
                    else:
                        text += "\t" + assignii(vars[atr[0]], vars[atr[2]])
        elif len(atr)==4 and ("=" in atr[1]):
            text += "\t" + uminus(vars[atr[0]], vars[atr[3]],atr[2])
        elif len(atr)==5 and ("=" in atr[1]):
            if "+" in atr[3]:
                text += "\t"+ asmd(vars[atr[0]], vars[atr[2]], vars[atr[4]], atr[3],"add","+")
            elif "-" in atr[3]:
                text += "\t"+ asmd(vars[atr[0]], vars[atr[2]], vars[atr[4]], atr[3],"sub","-")
            elif "*" in atr[3]:
                text += "\t"+ asmd(vars[atr[0]], vars[atr[2]], vars[atr[4]], atr[3],"mul","*")
            elif "/" in atr[3]:
                text += "\t"+ asmd(vars[atr[0]], vars[atr[2]], vars[atr[4]], atr[3],"div","/")
            elif atr[3]=="div":
                text += "\t"+ idiv(vars[atr[0]], vars[atr[2]], vars[atr[4]])
            elif atr[3]=="mod":
                text += "\t" + mod(vars[atr[0]], vars[atr[2]], vars[atr[4]])
            elif atr[3]=="ixor":
                text += "\t" + ixor(vars[atr[0]], vars[atr[2]], vars[atr[4]])
            elif atr[3]=="ior":
                text += "\t" + ior(vars[atr[0]], vars[atr[2]], vars[atr[4]])
            elif atr[3]=="iand":
                text += "\t" + iand(vars[atr[0]], vars[atr[2]], vars[atr[4]])
        elif len(atr)==6 and atr[0]=="if":
            op = atr[2].replace("f","")
            text += "\t" + if_(vars[atr[1]], vars[atr[3]], atr[5], atr[2], op)
    
    for ident in vars:
        if ident not in done:
            data += "\t" + ident +": .space "+ vars[ident].size +"\n"
            if int(vars[ident].size)%8:
                data += "\t.align " + str(8 - int(vars[ident].size)%8) + "\n"
    
    text += "\tli $v0, 10\n\tsyscall\n"
    return data + "\n" + text

# Utility function to write MIPS code to a file 
def dump_file(code, name):
    with open(name+".asm","w") as f:
        f.write(code)

def main():
    IR, vars = get_IR()
    vars["_incr"] = var("_incr", 0,"4")
    code = gen_asm(IR, vars)
    filename = sys.argv[1]
    dump_file(code, filename[:-4])
    print(color.GREEN + "Build Complete: Generated", filename[:-4]+".asm" + color.END)

if __name__=="__main__":
    main()