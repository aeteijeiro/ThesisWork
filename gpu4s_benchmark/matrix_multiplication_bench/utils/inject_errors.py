import sys

def add_regs(newfile,newRegsAdded,line):
    if ".reg " in line:
        print(f"in Reg")
        newfile.write(line)
        newline="    .reg .pred      mycondition;"
        newline+="\n    .reg .u32       mystoreSMID;"
        newline+="\n    .reg .u32       mystorelaneID;"
        newline+="\n    .reg .u32       mystoreCTAx;"
        newline+="\n    .reg .u32       mystoreCTAy;"
        newline+="\n    .reg .u32       mystorewarpID;\n"
        print(newline)
        newfile.write(newline)
        newRegsAdded=1
    return newRegsAdded

def inject_predicates(newfile, idsMoved,line,sm_count):
    if (('@' in line) and (idsMoved==0)):
        newline="        mov.u32         mystoreCTAx, %ctaid.x;"
        newline+="\n        mov.u32         mystoreCTAy, %ctaid.y;"
        newline+="\n       mov.u32         mystorewarpID, %warpid;"

        newline+="\n       setp.lt.u32     mycondition, mystoreCTAx,"+sm_count+";"
        if GOLDEN:
            newline+="\n@mycondition setp.eq.u32     mycondition, mystoreCTAy,0;"
            newline+="\n@mycondition setp.eq.u32     mycondition, mystorewarpID,100;"
        else:
            newline+="\n@mycondition setp.eq.u32     mycondition, mystoreCTAy,0;"
            newline+="\n@mycondition setp.eq.u32     mycondition, mystorewarpID,0;"
        predicate_name=line.split(" ")[0].strip().strip('@')
        newline+="\n@mycondition xor.pred" + "         " + predicate_name.strip('\t') + ", " + predicate_name.strip('\t') + ", 1;\n"
        print(newline)
        newfile.write(newline)
        idsMoved=1
    newfile.write(line)
    return idsMoved


def inject_L0(newfile, idsMoved,line,sm_count):
    if (('st.global.u32' in line) and (idsMoved==0)):
        print('in idsMoved')
        newline="        mov.u32         mystoreCTAx, %ctaid.x;"
        newline+="\n        mov.u32         mystoreCTAy, %ctaid.y;"
        newline+="\n       mov.u32         mystorewarpID, %warpid;"

        newline+="\n       setp.lt.u32     mycondition, mystoreCTAx,"+sm_count+";"
        newline+="\n@mycondition setp.lt.u32     mycondition, mystoreCTAy,"+sm_count+";"
        if GOLDEN:
            newline+="\n@mycondition setp.eq.u32     mycondition, mystorewarpID,1000;"
        else:
            newline+="\n@mycondition setp.eq.u32     mycondition, mystorewarpID,0;"

        target_variable=line.split('[')[1].split(']')[0]
        if idsMoved==0:
            newline+="\n@mycondition    xor.b64" + "         " + target_variable + ", " + target_variable + ", 1048576;\n"
        print(newline)
        newfile.write(newline)
        idsMoved=1
    newfile.write(line)
    return idsMoved

def inject_LSU(newfile, idsMoved,line,sm_count):
    if (('st.global.u32' in line) and (idsMoved==0)):
        print('in idsMoved')
        newline="        mov.u32         mystoreCTAx, %ctaid.x;"
        newline+="\n        mov.u32         mystoreCTAy, %ctaid.y;"
        newline+="\n       mov.u32         mystorewarpID, %warpid;"
        newline+="\n       mov.u32         mystorelaneID, %laneid;"
        
        newline+="\n       setp.lt.u32     mycondition, mystoreCTAx,"+sm_count+";"
        newline+="\n@mycondition setp.lt.u32     mycondition, mystoreCTAy,"+sm_count+";"
        newline+="\n@mycondition setp.eq.u32     mycondition, mystorewarpID,0;"
        if GOLDEN:
            newline+="\n@mycondition setp.lt.u32     mycondition, mystorelaneID,0;"
        else:
            newline+="\n@mycondition setp.lt.u32     mycondition, mystorelaneID,8;"

        target_variable=line.split('[')[1].split(']')[0]
        if idsMoved==0:
            newline+="\n@mycondition    xor.b64" + "         " + target_variable + ", " + target_variable + ", 1048576;\n" 
        print(newline)
        newfile.write(newline)
        idsMoved=1
    newfile.write(line)
    return idsMoved

def inject_ALU(newfile, idsMoved,line,sm_count):
    if (('st.global.u32' in line) and (idsMoved==0)):
        print('in idsMoved')
        newline="        mov.u32         mystoreCTAx, %ctaid.x;"
        newline+="\n        mov.u32         mystoreCTAy, %ctaid.y;"
        newline+="\n       mov.u32         mystorewarpID, %warpid;"
        newline+="\n       mov.u32         mystorelaneID, %laneid;"

        newline+="\n       setp.lt.u32     mycondition, mystoreCTAx,"+sm_count+";"
        newline+="\n@mycondition setp.lt.u32     mycondition, mystoreCTAy,"+sm_count+";"
        newline+="\n@mycondition setp.eq.u32     mycondition, mystorewarpID,0;"
        if GOLDEN:
            newline+="\n@mycondition setp.eq.u32     mycondition, mystorelaneID,1000;"
        else:
            newline+="\n@mycondition setp.eq.u32     mycondition, mystorelaneID,0;"

        target_variable=line.split('[')[1].split(']')[0]
        if idsMoved==0:
            newline+="\n@mycondition    xor.b64" + "         " + target_variable + ", " + target_variable + ", 1048576;\n" 
        print(newline)
        newfile.write(newline)
        idsMoved=1
    newfile.write(line)
    return idsMoved

def inject_fma(newfile, idsMoved,line,sm_count):
    if 'mad.lo.s32' in line:
        newfile.write(line)
        if(idsMoved==0):
            print('in idsMoved')
            newline="        mov.u32         mystoreCTAx, %ctaid.x;"
            newline+="\n        mov.u32         mystoreCTAy, %ctaid.y;"
            newline+="\n       mov.u32         mystorewarpID, %warpid;"
            newline+="\n       setp.lt.u32     mycondition, mystoreCTAx,"+sm_count+";"
            if GOLDEN:
                newline+="\n@mycondition setp.eq.u32     mycondition, mystoreCTAy,0;"
                newline+="\n@mycondition setp.eq.u32     mycondition, mystorewarpID,100;"
            else:
                newline+="\n@mycondition setp.eq.u32     mycondition, mystoreCTAy,0;"
                newline+="\n@mycondition setp.eq.u32     mycondition, mystorewarpID,0;"

            target_variable=line.split(',')[0].split(' ')[-1].strip()
            newline+="\n@mycondition     add.s32" + "         " + target_variable + ", " + target_variable + ", 100000;\n"
            print(newline)
            newfile.write(newline);
            idsMoved=1
    else:
        newfile.write(line)
    return idsMoved

with open("lib_cuda.ptx",'w') as newfile:
    with open("../build/lib_cuda.ptx",'r') as originalfile:
        f=originalfile.readlines()
        newRegsAdded=0
        idsMoved=0;
        target=sys.argv[1]+'.'
        SM_COUNT=sys.argv[2]
        RUN_TYPE=sys.argv[3]
        if RUN_TYPE=='golden':
            GOLDEN=1
        elif RUN_TYPE=='injected':
            GOLDEN=0
        else:
            raise Exception("RUN_TYPE not set properly")

        if len(target)==0:
            print("ERROR: no target passed"); input()
        for line in f:
            if ((".reg " in line) and (newRegsAdded==0)):
                newRegsAdded=add_regs(newfile, newRegsAdded, line)
            elif target=='predicates.':
                idsMoved=inject_predicates(newfile, idsMoved,line,SM_COUNT)
            
            elif target=='LSU.':
                idsMoved=inject_LSU(newfile, idsMoved,line,SM_COUNT)
            
            elif target=='L0.':
                idsMoved=inject_L0(newfile, idsMoved,line,SM_COUNT)

            elif target=='ALU.':
                idsMoved=inject_ALU(newfile, idsMoved,line,SM_COUNT)

            elif target=='fma.':
                idsMoved=inject_fma(newfile, idsMoved,line,SM_COUNT)
            else:
                idsMoved=inject_other(newfile, idsMoved,line,target)
                
                    


