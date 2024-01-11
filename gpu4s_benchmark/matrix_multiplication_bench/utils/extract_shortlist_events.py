import sys
import os

EVENTS_PER_FILE=int(sys.argv[1])

if sys.argv[2]=='all':
    TOTAL_EVENTS='all'
else:
    TOTAL_EVENTS=int(sys.argv[2])

HPC_TYPE=sys.argv[3]
STARTING_POINT=int(sys.argv[4])
#with open("optimal_UDP_metrics",'r') as f:
with open("ncu_cuda_avail2",'r') as f:
#with open("optimal_L0_metrics",'r') as f:    
    my_num_events=0
    block=0
    fnew=open(f"cuda_events/block{block}",'w')
    event_num=0
    print(f"type of TOTAL_EVENTS: {type(TOTAL_EVENTS)}")
    while(True):
        line=f.readline()
        if TOTAL_EVENTS=='all': 
            #print("in TOTAL_EVENTS branch")
            if "End of file" in line:
                if((my_num_events%EVENTS_PER_FILE)==0):
                    os.system(f"rm cuda_events/block{block}")
                break
        else:
            if(("End of file" in line) or (my_num_events>=TOTAL_EVENTS)):
                if((my_num_events%EVENTS_PER_FILE)==0):
                    os.system(f"rm cuda_events/block{block}")
                break
        if ((HPC_TYPE in line) or (HPC_TYPE=='all')):
            if "Counter" in line:
                event_num+=1
                if event_num<STARTING_POINT:
                    continue
                my_num_events+=1
                HPC=line.split(' ')[0]
                line="cuda:::"+HPC+".sum:device=0 "
                fnew.write(line)
                print(line)
                if ((my_num_events%EVENTS_PER_FILE)==0):
                    block+=1
                    fnew.close()
                    fnew=open(f"cuda_events/block{block}",'w')
        
    fnew.close()
            
    print(my_num_events)

