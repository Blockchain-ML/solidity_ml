import pandas as pd
dataset=pd.read_csv("bigram_v2.csv",dtype={'label':object})

import ast

test = dataset['opcode']

opcode_list=test.tolist()
tt = pd.DataFrame(test)
cnt=0
uniquebigrams = []
for i,row in tt.iterrows():
    print(cnt)
    cnt+=1
    uniquebigrams.extend(ast.literal_eval(tt.iloc[i,0]))
    
    
    
uniqueWords = pd.DataFrame(uniquebigrams,columns=['opcode1','opcode2']).drop_duplicates()

uniqueWords.to_csv("UniqueBigrams_v2.csv",index=None)