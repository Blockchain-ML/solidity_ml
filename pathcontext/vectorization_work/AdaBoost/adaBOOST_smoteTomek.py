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
data = pd.read_csv(r'/home/supriya/CDS_vectorization_v2x.csv',dtype={'Error_Label':object} )
#data = pd.read_csv(r'/home/supriya/Hybrid_v2_v2x.csv',dtype={'Error_Label':object} )
print(data.shape)
#data.head()





# split labels and return new dataframe
#Create independent and Dependent Features
ERROR_LABEL=10
def split_label_dict(df):
    # Change 'label' to whatever naming used in the original DataFrame.
    temp_df = df['Error_Label'].str.split("", n = -1, expand = True)
    for i in range(1, 19):
        df[f'l{i}'] = temp_df[i]
        df[f'l{i}'] = pd.to_numeric(df[f'l{i}'])
    return df

newdata=split_label_dict(data)
#print(newdata)
#Create independent and Dependent Features
df = pd.DataFrame(data)
new_df = df.drop(['Error_Label','l18','l17','l16','l15','l14','l13','l12','l11','l10','l9','l8','l7','l6','l5','l3','l4','l2','l1', 'ID'],axis=1)
#new_df = data.drop(['Error_Label','ID'],axis=1)
X = new_df
# Store the variable we are predicting 
Y = newdata[f"l{ERROR_LABEL}"]

# Print the shapes of X & Y
print(X.shape,Y.shape)


from sklearn.neighbors import KNeighborsClassifier
from sklearn.model_selection import train_test_split

X_train,X_test, y_train,y_test = train_test_split(X,Y,test_size=0.3,random_state=42,stratify=Y)





# Feature Scaling

from sklearn.preprocessing import StandardScaler
sc_X = StandardScaler()
X_train = sc_X.fit_transform(X_train)
X_test = sc_X.transform(X_test)


# In[ ]:


from imblearn.combine import SMOTETomek
from imblearn.over_sampling import SMOTE
from sklearn.datasets import make_classification
from imblearn.over_sampling import SVMSMOTE
smk = SVMSMOTE()
#smk = SMOTE()
#smk = SMOTETomek()
X_res,y_res=smk.fit_sample(X_train.astype('float'),y_train)
print(X_res.shape,y_res.shape)
#print(X_res)
#print(y_res)


# In[6]:


## Hyperparameter optimization using RandomizedSearchCV
from sklearn.model_selection import RandomizedSearchCV, GridSearchCV
#import xgboost

from sklearn.ensemble import AdaBoostClassifier

# Fitting the classifier into the Training set

classifier = AdaBoostClassifier(
    DecisionTreeClassifier(max_depth=1),
    n_estimators=200,learning_rate=1
)
classifier.fit(X_res, y_res)
# Predicting the test set results
y_predict = classifier.predict(X_test)
print(accuracy_score(y_test,y_predict))
pd.crosstab(y_test,y_predict)



from sklearn.metrics import classification_report,confusion_matrix
from sklearn.model_selection import cross_val_score
print(classification_report(y_test,y_predict))
print(accuracy_score(y_test,y_predict))

from sklearn.metrics import classification_report,confusion_matrix
from sklearn.model_selection import cross_val_score 
from sklearn.metrics import roc_auc_score
import pickle
results=classification_report(y_test,y_predict)
accuracy_score=accuracy_score(y_test,y_predict)
cm = confusion_matrix(y_test, y_predict)
roc=roc_auc_score(y_test,y_predict)

print(cm)
print(results) 
#print(accuracy_score)

# Save Results as txt
filename = f'/home/supriya/pathcontext/vectorization_work/AdaBoost/svmSMOTE_v2x/l{ERROR_LABEL}comb_SMOTETomek_results.txt'
with open(filename, 'a') as fh:
    fh.write(str(results)+"\n" +"ROC_ACCuracy:  "+str(roc) +"\n"+"Confusion_Matrix"+"\n"+str(cm)+"\n"+"accuracy_score: "+str(accuracy_score))




