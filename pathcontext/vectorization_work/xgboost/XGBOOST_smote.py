#!/usr/bin/env python
# coding: utf-8

# In[1]:


import numpy as np
import pandas as pd
import sklearn
import scipy
from sklearn.metrics import classification_report,accuracy_score
from sklearn.ensemble import IsolationForest
from sklearn.neighbors import LocalOutlierFactor
from sklearn.svm import OneClassSVM
from pylab import rcParams
#from sklearn.cross_validation import train_test_split
from sklearn.tree import DecisionTreeClassifier
from sklearn.metrics import accuracy_score
from sklearn import tree
from sklearn import preprocessing
data = pd.read_csv(r'/home/supriya/pathcontext/vectorization_work/CDS_vectorization_v1.csv',dtype={'Error_Label':object} )
print(data)
#data.head()


# In[2]:


# split labels and return new dataframe
#Create independent and Dependent Features
#data=split_label(data)
def split_label_dict(df):
    # Change 'label' to whatever naming used in the original DataFrame.
    temp_df = df['Error_Label'].str.split("", n = -1, expand = True)
    for i in range(1, 19):
        df[f'l{18}'] = temp_df[18]
        df[f'l{18}'] = pd.to_numeric(df[f'l{18}'])
    return df

newdata=split_label_dict(data)
#print(newdata)
#Create independent and Dependent Features
columns = newdata.columns.tolist()
# Filter the columns to remove data we do not want 
columns = [c for c in columns if c not in ["l18"]]
# Store the variable we are predicting 
target = "l18"
# Define a random state 
state = np.random.RandomState(69)
X = newdata[columns]
Y = newdata[target]
# Print the shapes of X & Y
print(X.shape)
print(Y)


# In[3]:


from sklearn.neighbors import KNeighborsClassifier
from sklearn.model_selection import train_test_split

X_train,X_test, y_train,y_test = train_test_split(X,Y,test_size=0.3,random_state=69,stratify=Y)


# In[4]:


# Feature Scaling

from sklearn.preprocessing import StandardScaler
sc_X = StandardScaler()
X_train = sc_X.fit_transform(X_train)
X_test = sc_X.transform(X_test)


# In[ ]:


from imblearn.combine import SMOTETomek
from imblearn.over_sampling import SMOTE
smk = SMOTE()
X_res,y_res=smk.fit_sample(X_train.astype('float'),y_train)
print(X_res.shape,y_res.shape)
#print(X_res)
#print(y_res)


# In[6]:


## Hyperparameter optimization using RandomizedSearchCV
from sklearn.model_selection import RandomizedSearchCV, GridSearchCV
import xgboost

classifier=xgboost.XGBClassifier(base_score=0.5, booster='gbtree', colsample_bylevel=1,
       colsample_bytree=0.5, gamma=0.4, learning_rate=0.1,
       max_delta_step=0, max_depth=6, min_child_weight=7, missing=None,
       n_estimators=100, n_jobs=1, nthread=None,
       objective='binary:logistic', random_state=69, reg_alpha=0,
       reg_lambda=1, scale_pos_weight=1, seed=None,
       subsample=1)
model=classifier.fit(X_res, y_res)
# Predicting the test set results
y_predict = classifier.predict(X_test)
print(accuracy_score(y_test,y_predict))
pd.crosstab(y_test,y_predict)


# In[ ]:


import pickle
# Save History as Pickle

filename = '/home/supriya/pathcontext/vectorization_work/xgboost/xgboost_smote/l18xgboost_smote.pickle'
with open(filename, 'wb') as fh:
    pickle.dump(model, fh)


# In[ ]:


from sklearn.metrics import classification_report,confusion_matrix
from sklearn.model_selection import cross_val_score 
from sklearn.metrics import roc_auc_score
import pickle
results=classification_report(y_test,y_predict)
accuracy_score=accuracy_score(y_test,y_predict)
cm = confusion_matrix(y_test, y_predict)
roc=roc_auc_score(y_test,y_predict)
print("ROC_ACCuracy:",roc)
print(cm)
print(results) 
#print(accuracy_score)

# Save Results as Pickle
filename = '/home/supriya/pathcontext/vectorization_work/xgboost/xgboost_smote/l18xgboost_smote.txt'
with open(filename, 'a') as fh:
    fh.write(str(results)+"\n" +"ROC_ACCuracy:  "+str(roc) +"\n"+"Confusion_Mtraix"+"\n"+str(cm)+"\n"+"accuracy_score: "+str(accuracy_score))


# In[ ]:




