import seaborn as sns
import polars as pl
import pandas as pd
import sys
from sklearn import svm
from sklearn.model_selection import cross_val_score
from sklearn.utils import shuffle
from sklearn.neighbors import LocalOutlierFactor
from sklearn.ensemble import IsolationForest
import matplotlib.pyplot as plt
import numpy as np

def print_separator(message):
    print(f"####################\n {message}\n####################")

def remove_outliers(DataFrame):
    df_local=DataFrame
    df_np=df_local.drop('target').to_numpy()
    #noise_clf=LocalOutlierFactor(n_neighbors=2,algorithm='brute')
    noise_clf=IsolationForest(n_estimators=200)
    inline=noise_clf.fit_predict(df_np)
    inliers=[idx for idx,res in enumerate(inline) if res==1]
    df_local=df_local.with_row_count("row_number")
    df_local=df_local.filter(pl.col('row_number').is_in(pl.Series("inliers",inliers)))
    #print(df_local); input()
    return df_local.drop("row_number") 

if len(sys.argv)!=8:
    raise Exception("must supply VERBOSITY, GRAPHICS, ML, HPC_TYPE, TARGET_INSTRUCTION, SM_COUNT, NUM_RUNS arguments")

VERBOSITY=sys.argv[1]; GRAPHICS=sys.argv[2]; ML=sys.argv[3]; HPC_TYPE=sys.argv[4]; TARGET_INSTRUCTION=sys.argv[5];SM_COUNT=sys.argv[6];NUM_RUNS=sys.argv[7]

if VERBOSITY=='verbose':
    VERBOSE=True
else:
    VERBOSE=False

if GRAPHICS=='distribution':
    DISTPLOT=True
    SCATTERPLOT=False
elif GRAPHICS=='scatter':
    SCATTERPLOT=True
    DISTPLOT=False
elif GRAPHICS=='both':
    DISTPLOT=True
    SCATTERPLOT=True
else:
    DISTPLOT=False
    SCATTERPLOT=False

if ML=='svm':
    SVM=True
    LOF=False
elif ML=='LOF':
    SVM=False
    LOF=True
else:
    SVM=False
    LOF=False

#initial processing of original dataset
#print_separator('Original Dataset')
df = pl.read_parquet(f"results/final_dataset_{HPC_TYPE}_{TARGET_INSTRUCTION}_{SM_COUNT}_{NUM_RUNS}.parquet")
df_golden=df.filter(pl.col('target')=='golden')
df_injected=df.filter(pl.col('target')=='injected')
#print(df)


#remove all columns with 0 standard deviation, since they probably aren't telling me anything anyways.
#print_separator('Reduced Dataset')
for col in df.columns:
    #print(df[col]);print(df[col].std());input("waiting")
    if df[col].std()==0:
        df=df.drop(col)

#print(df)

df_pd=df.to_pandas()
if DISTPLOT:
    for col in df.columns:
        if col != 'target':
            sns.kdeplot(data=df_pd,x=col,hue='target')
            plt.show()

if VERBOSE:
    for col in df_mean.columns:
        print_separator()
        print("column name: "+col)
        print(df_mean[col])
        print_separator()
        input()

if SCATTERPLOT:
    for col in df.columns:
        if col != 'target':
            noise_column=pd.DataFrame(data=np.random.rand(df_pd.shape[0],1),columns=["noise_value"])
            df_pd_with_noise = pd.concat([df_pd,noise_column],axis=1)
            print(df_pd_with_noise)
            sns.scatterplot(data=df_pd_with_noise,x=col,y='noise_value',hue='target')
            plt.show()


if SVM:
    for col in df.columns:
        if col != 'target':
            X=df.select(col).to_pandas()
            y=df.select('target')
            y=np.ravel(y)
            X_shuffled,y_shuffled=shuffle(X,y)#,random_state=42)
            clf=svm.SVC()
            scores=cross_val_score(clf,X_shuffled,y_shuffled,cv=3)
            print(f"{HPC_TYPE} {TARGET_INSTRUCTION} 3-CV accuracy: {scores}")
            #print(f"{col}, {HPC_TYPE}, {TARGET_INSTRUCTION} scores: {scores}")

if LOF:
    df_pl_with_noise = (df_golden.select(df_golden.columns[0])+pl.from_numpy(np.random.uniform(-5,5,(df_golden.shape[0],1)))).with_columns(df_golden['target'])#.rename({'column_0':'target'})
    X_shuffled,y_shuffled = shuffle(df_pl_with_noise.drop('target'),df_pl_with_noise.select('target'))
    noise_clf=LocalOutlierFactor(novelty=True,n_neighbors=60)
    noise_clf.fit(X_shuffled)
    
    apply=pl.DataFrame(noise_clf.predict(X_shuffled.to_pandas()))
    result=X_shuffled.with_columns(apply)
    result=result.with_columns(y_shuffled['target'])

    zeros = pl.from_numpy(np.zeros((df.shape[0],1)))
    apply=pl.DataFrame(noise_clf.predict(df.select(df.columns[0]).drop('target')))
    classified_df=df.with_columns(apply)

    correct=0
    for row in classified_df.rows():
        if 'golden' in row:
            if row[row.index('golden')+1]==1:
                correct+=1
        elif 'injected' in row:
            if row[row.index('injected')+1]==-1:
                correct+=1
    print(f"{HPC_TYPE} {TARGET_INSTRUCTION} LOF accuracy: {(correct/df.shape[0])*100}%")
    
    
