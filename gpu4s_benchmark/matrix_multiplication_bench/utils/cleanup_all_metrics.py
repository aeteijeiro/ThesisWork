with open('final_dataset_LSU_all_1_20.txt','r') as f:
    line_list=[]
    with open('optimal_LSU_metrics','w') as g:
        lines=f.readlines()
        for line in lines:
            satisfactory=True
            scores=line.split('[')[1].split(']')[0].strip().split(' ')
            #print(scores)
            for score in scores:
                if score == '':
                    continue
                if float(score) <=.95:
                    satisfactory=False
                    break
            if satisfactory:
                metric=line.split(':::')[1].split('.sum')[0]
                g.write(metric+"    Counter \n")
        g.write("End of file")
