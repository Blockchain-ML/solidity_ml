

import numpy as np
import matplotlib.pyplot as plt

#from google.colab import drive
#drive.mount('/content/gdrive')



import pandas as pd
dataset=pd.read_csv('new_opc.csv',dtype={'label':object})




#dataset.iloc[1,2]

#type(dataset.iloc[0,2])

res=dataset.iloc[0,2].split()




list1=['PUSH5','PUSH6','PUSH7','PUSH8','PUSH9','PUSH10','PUSH11','PUSH12','PUSH13','PUSH14','PUSH15','PUSH16','PUSH17','PUSH18','PUSH19','PUSH20','PUSH21','PUSH22','PUSH23','PUSH24','PUSH25','PUSH26','PUSH27','PUSH28','PUSH29','PUSH30','PUSH31','PUSH32']
list2=['LOG1','LOG2','LOG3','LOG4']
list3=['SWAP1','SWAP2','SWAP3','SWAP4','SWAP5','SWAP6','SWAP7','SWAP8','SWAP9','SWAP10','SWAP11','SWAP12','SWAP13','SWAP14','SWAP15','SWAP16']
list4=['DUP1','DUP2','DUP3','DUP4','DUP5','DUP6','DUP7','DUP8','DUP9','DUP10','DUP11','DUP12','DUP13','DUP14','DUP15','DUP16']
list5=['AND','OR','XOR','NOT']
list6=['LT','GT','SLT','SGT']
list7=['ADDRESS','ORIGIN','CALLER']
list8=['BLOCKHASH','TIMESTAMP','NUMBER','DIFFICULTY','GASLIMIT','COINBASE']
list9=['ADD','MUL','SUB','DIV','SDIV','SMOD','MOD','ADDMOD','MULMOD','EXP']



def f1(arg1):
  listk=arg1.split()
  list0=[]

  for index,i in enumerate(listk):
    if i[0]!='0':
      list0.append(i)
  

  for index,i in enumerate(list0):
    for j in list1:
      if j==i:
        list0[index]='PUSH'
        
  for index,i in enumerate(list0):
    for j in list2:
      if j==i:
        list0[index]='LOG'
  for index,i in enumerate(list0):
    for j in list3:
      if j==i:
        list0[index]='SWAP'
  for index,i in enumerate(list0):
    for j in list4:
      if j==i:
        list0[index]='DUP'
  for index,i in enumerate(list0):
    for j in list5:
      if j==i:
        list0[index]='LOGIC_OP'
  for index,i in enumerate(list0):
    for j in list6:
      if j==i:
        list0[index]='COMPARISON'
  for index,i in enumerate(list0):
    for j in list7:
      if j==i:
        list0[index]='CONSTANT2'
  for index,i in enumerate(list0):
    for j in list8:
      if j==i:
        list0[index]='CONSTANT1'
  for index,i in enumerate(list0):
    for j in list9:
      if j==i:
        list0[index]='ARITHMETIC_OP'
  return list0



dataset1=[]

for i in range(len(dataset)):
  dataset1.append((" ").join(f1(dataset.iloc[i,2])))
  print(i," ")

dataset1[0]

len(dataset1[32].split(" "))

var=[]
cnt=0

# using list comprehension + enumerate() + split() 
# for Bigram formation 
for k in dataset1[24000:32000]:
  res = [(x, k.split()[j + 1])   
        for j, x in enumerate(k.split()) if j < len(k.split()) - 1] 
  var.append(res)
  cnt+=1
  print(cnt," ")

var1=pd.Series(var)
dataset['opcode']=var1
dataset.to_csv("bigram3.csv",index=None)