import pandas as pd
file1=pd.read_csv("bigram_v2.csv",dtype={'label': object})
fileo=pd.read_csv("UniqueBigrams_v2.csv")
import numpy as np
arr1=np.zeros((67677,3726))
opcode3=[]
for i in range(3726):
    s="("+"'"+fileo.loc[i,'opcode1']+"'"+", "+"'"+fileo.loc[i,'opcode2']+"'"+")"
    opcode3.append(s)
cnt=0
for index1,i in enumerate(file1['opcode']):
    print(cnt)
    cnt+=1
    for index2,j in enumerate(opcode3):
        arr1[index1,index2]=(i.count(j))/(i.count('('))

sol=pd.DataFrame(arr1)
sol.to_csv("featurevector_v2.csv")