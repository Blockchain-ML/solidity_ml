#!/usr/bin/env python
# coding: utf-8

# In[5]:


import pandas as pd
file1=pd.read_csv("Blockchain/Bigram_c.csv",dtype={'label': object})
file2=pd.read_csv("Blockchain/UniqueBigram.csv")


# In[46]:


file1.iloc[2,2]


# In[4]:


file2


# In[9]:


import numpy as np
arr1=np.zeros((62183,3541))


# In[11]:


print(arr1.shape)


# In[20]:


opcode3=[]
for i in range(3541):
    s="("+"'"+file2.loc[i,'opcode1']+"'"+", "+"'"+file2.loc[i,'opcode2']+"'"+")"
    opcode3.append(s)


# In[21]:


print(opcode3)


# In[47]:


cnt=0
for index1,i in enumerate(file1['opcode']):
    print(cnt)
    cnt+=1
    for index2,j in enumerate(opcode3):
        arr1[index1,index2]=(i.count(j))/(i.count('('))


# In[48]:

sol=pd.DataFrame(arr1)
sol.to_csv("featurevector.csv")



# In[ ]:




