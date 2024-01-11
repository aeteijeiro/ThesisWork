import os
import polars as pl
import sys

HPC_TYPE=sys.argv[1]
TARGET_INSTRUCTION=sys.argv[2]
SM_COUNT=sys.argv[3]
NUM_RUNS=sys.argv[4]
directory = '../bin/golden_runs/profiler'
df = pl.DataFrame()
for filename in os.listdir(directory):
    if filename.endswith('.out'):
        with open(os.path.join(directory, filename)) as f:
            print(filename)
            lines=f.readlines()
            counts = {}
            for line in lines:
                if 'stop' in line:
                    count=int(line.split(":")[1].split('=')[0])
                    label="cuda:::"+line.split(":::")[1].split(':')[0]
                    counts[label]=count #**4
            
            '''
            dontadd=0
            for item in counts.values():
                if (item < 0):# or (item > 50000)):
                    dontadd=1
                    print('dontadd')
            if dontadd==0:
                df=pl.concat([df,pl.DataFrame(counts)])
            '''
            df=pl.concat([df,pl.DataFrame(counts)])
            #print(df.head())
            #input()
#df=df.with_columns(new_column = pl.Series("Status",["pre-injection"] ))
df_golden=df.with_columns(pl.lit("golden").alias("target"))
#print(df_golden)
#df_golden.write_parquet('../bin/golden_counts/counts.parquet')
#print(df.mean())
#df.write_csv('../bin/golden_counts/counts.csv')


directory = '../bin/injector_runs/profiler'
df = pl.DataFrame()
for filename in os.listdir(directory):
    if filename.endswith('.out'):
        with open(os.path.join(directory, filename)) as f:
            print(filename)
            lines=f.readlines()
            counts = {}
            for line in lines:
                if 'stop' in line:
                    count=int(line.split(":")[1].split('=')[0])
                    label="cuda:::"+line.split(":::")[1].split(':')[0]
                    counts[label]=count #**4
            
            '''
            dontadd=0
            for item in counts.values():
                if (item < 0):# or (item > 50000)):
                    dontadd=1
            if dontadd==0:
                df=pl.concat([df,pl.DataFrame(counts)])
            '''
            df=pl.concat([df,pl.DataFrame(counts)])
            #print(df.head())
            #input()
            
df_injected=df.with_columns(pl.lit("injected").alias("target"))
#print(df_injected)
#df_injected.write_parquet('../bin/injector_counts/counts.parquet')

df_final=pl.concat([df_golden,df_injected])
df_final.write_parquet(f"results/final_dataset_{HPC_TYPE}_{TARGET_INSTRUCTION}_{SM_COUNT}_{NUM_RUNS}.parquet")
#df.write_csv('../bin/injector_counts/counts.csv')

#print(df.mean())
