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
data = pd.read_csv(r'CDS_vectorization_v1.csv',dtype={'Error_Label':object} )
print(data)
#data.head()

# split labels and return new dataframe
#Create independent and Dependent Features
#data=split_label(data)
def split_label_dict(df):
    # Change 'label' to whatever naming used in the original DataFrame.
    temp_df = df['Error_Label'].str.split("", n = -1, expand = True)
    for i in range(1, 19):
        df[f'l{2}'] = temp_df[2]
        df[f'l{2}'] = pd.to_numeric(df[f'l{2}'])
    return df

newdata=split_label_dict(data)
#print(newdata)
#Create independent and Dependent Features
columns = newdata.columns.tolist()
# Filter the columns to remove data we do not want 
columns = [c for c in columns if c not in ["l2"]]
# Store the variable we are predicting 
target = "l2"
# Define a random state 
state = np.random.RandomState(69)
X = newdata[columns]
Y = newdata[target]
# Print the shapes of X & Y
print(X.shape)
print(Y.shape)

from sklearn.svm import SVC
from sklearn.model_selection import train_test_split

X_train,X_test, y_train,y_test = train_test_split(X,Y,test_size=0.3,random_state=69)

# Feature Scaling

from sklearn.preprocessing import StandardScaler
sc_X = StandardScaler()
X_train = sc_X.fit_transform(X_train)
X_test = sc_X.transform(X_test)

from sklearn.svm import SVC
# Fitting the classifier into the Training set
classifier = SVC(kernel = 'linear', random_state = 69)
model=classifier.fit(X_train, y_train)
# Predicting the test set results
Y_Pred = classifier.predict(X_test)
print(accuracy_score(y_test,Y_Pred))
pd.crosstab(y_test,Y_Pred)

import pickle
# Save History as Pickle

filename = '/home/supriya/pathcontext/vectorization_work/models_results/original_model/l2SVM.pickle'
with open(filename, 'wb') as fh:
    pickle.dump(model, fh)

from sklearn.metrics import classification_report,confusion_matrix
from sklearn.model_selection import cross_val_score 
import pickle
results=classification_report(y_test,Y_Pred)
#accuracy_score=accuracy_score(y_test,Y_Pred)
cm = confusion_matrix(y_test, Y_Pred)
print(cm)
print(results) 
#print(accuracy_score)

# Save Results as Pickle
filename = '/home/supriya/pathcontext/vectorization_work/models_results/original_model/l2SVM_result.pickle'
with open(filename, 'wb') as fh:
    pickle.dump([results, cm], fh)

