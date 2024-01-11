with open('ncu_cuda_avail2','r') as f:
    line_list=[]
    with open('cuda_hw_events2','w') as g:
        lines=f.readlines()
        for line in lines:
            if 'Counter' in line:
                line=line.split(' ')
                line=f'cuda:::{line[0]}.sum:device=0 \n'
                g.write(line)
                '''
                if line not in line_list:
                    line_list.append(line)
                    g.write(line)
                '''



