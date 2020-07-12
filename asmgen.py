const = -1
# int, float, bool, str, char = 0,1,2,3,4
def gen_const():
    const+=1
    return "_const%d"%const

class var:
    def __init__(self, name, typ, size):
        self.name = name
        self.type = typ
        self.size = size

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

# Begin Macros
def asmd(a,b,c,op,oper,sym):
    code = ""
    if op == sym:
        if sym=="/":
            return "lw $t0, %s\n\tmtc1 $t0, $f2\n\tcvt.d.w $f2, $f2\n\tlw $t1, %s\n\tmtc1 $t1, $f4\n\tcvt.d.w $f4, $f4\n\t%s.d $f6, $f2, $f4\n\tsdc1 $f6, %s\n"%(b.name,c.name,oper, a.name)
        return "lw $t0, %s\n\tlw $t1, %s\n\t%s $t2, $t0, $t1\n\tsw $t2, %s\n"%(b.name,c.name,oper,a.name)
    if op[0] == "f":
        code += "ldc1 $f2, %s\n\t"%b.name
    else:
        code += "lw $t0, %s\n\tmtc1 $t0, $f2\n\tcvt.d.w $f2, $f2\n\t"%b.name
    if op[-1]== "f":
        code += "ldc1 $f4, %s\n\t"%c.name
    else:
        code += "lw $t1, %s\n\tmtc1 $t1, $f4\n\tcvt.d.w $f4, $f4\n\t"%c.name
    code += "%s.d $f6, $f2, $f4\n\tsdc1 $f6, %s\n"%(oper, a.name)
    return code

def if_(a,b,label,op,sym):
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

def printt(a,op):
    if op=="f":
        return "ldc1 $f12, %s\n\tli $v0, 3\n\tsyscall\n"%a
    else:
        return "lw $a0, %s\n\tli $v0,1\n\tsyscall\n"%a

def inputt(a,op):
    if op=="f":
        return "li $v0, 7\n\tsyscall\n\tsdc1 $f0, %s\n"%a
    else:
        return "li $v0,5\n\tsyscall\n\tsw $v0, %s\n"%a


idiv = lambda a,b,c: "lw $t0, %s\n\tlw $t1, %s\n\tdiv $t2, $t0, $t1\n\tsw $t2, %s\n"%(b.name,c.name,a.name)
mod = lambda a,b,c: "lw $t0, %s\n\tlw $t1, %s\n\tdiv $t0, $t1\n\tmfhi $t2\n\tsw $t2, %s\n"%(a.name,b.name,c.name)
assignfi = lambda a,b: "lw $t0, %s\n\tmtc1 $t0, $f2\n\tcvt.d.w $f2, $f2\n\tsdc1 $f2, %s\n"%(b.name,a.name)
assignii = lambda a,b: "lw $t0, %s\n\tsw $t0, %s\n"%(b.name, a.name)
assignff = lambda a,b: loadf(a,b.name)
loadif = lambda a,b: "li $t0, %s\n\tmtc1 $t0, $f2\n\tcvt.d.w $f2, $f2\n\tsdc1 $f2, %s\n"%(b,a.name)
loadf = lambda a,b: "ldc1 $f2, %s\n\tsdc1 $f2, %s\n"%(b,a.name)
loadi = lambda a,b: "li $t0, %s\n\tsw $t0, %s\n"%(b,a.name)
println= lambda: "li $v0, 4\n\tla $a0, _newline\n\tsyscall\n"

#End Macros

def gen_asm(IR, vars):
    data = '.data\n\t_zero: .double 0.0\n\t_incr: .word 1\n\t_newline: .asciiz "\\n"\n\t.align 3\n'
    text = ".text\n"
    done = {"_incr"}
    for line in IR:
        atr = line.split()
        if len(atr)==1:
            text += "\n  "+atr[0]+"\n"
        elif len(atr)==2 and atr[0]=="goto":
            text += "\t"+"b "+atr[1]+"\n"
        elif len(atr)==2 and atr[0][1:]=="print":
            text += "\t" + printt(atr[1],atr[0][0])+ "\t"+println()
        elif len(atr)==2 and atr[0][1:]=="read":
            text += "\t" + inputt(atr[1],atr[0][0])+ "\t"
        elif len(atr)==3 and ("=" in atr[1]):
            if atr[2][0]!="_":
                v1 = vars[atr[0]]
                if atr[1][-1]=="f":
                    text += "\t" + loadif(v1,atr[2])
                    data += "\t" + atr[0] + ": .space 8\n"
                elif atr[1][0]=="f":
                    cons = gen_const()
                    data += "\t" + cons + ": .double " + atr[2] + "\n"
                    text += "\t" + loadf(v1, cons)
                else:
                    text += "\t" + loadi(v1, atr[2])
                    data += "\t" + atr[0] + ": .space 4\n"
                done.add(atr[0])
            else:
                if atr[1][-1]=="f":
                    text += "\t" + assignfi(vars[atr[0]], vars[atr[2]])
                elif atr[1][0]=="f":
                    text += "\t" + assignff(vars[atr[0]], vars[atr[2]])
                else:
                    text += "\t" + assignii(vars[atr[0]], vars[atr[2]])
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
        elif len(atr)==6 and atr[0]=="if":
            op = atr[2].replace("f","")
            text += "\t" + if_(vars[atr[1]], vars[atr[3]], atr[5], atr[2], op)
    for ident in vars:
        if ident not in done:
            data += "\t" + ident +": .space "+ vars[ident].size +"\n"
    return data + "\n" + text

def dump_file(code, name):
    with open(name+".asm","w") as f:
        f.write(code)

def main():
    IR, vars = get_IR()
    vars["_incr"] = var("_incr", 0,"4")
    code = gen_asm(IR, vars)
    dump_file(code, "mininim")

if __name__=="__main__":
    main()