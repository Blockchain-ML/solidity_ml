from imblearn.over_sampling import SVMSMOTE
from sklearn.datasets import make_classification
from imblearn import under_sampling, over_sampling
from imblearn.over_sampling import SMOTE
from imblearn.over_sampling import SMOTE
from imblearn.combine import SMOTETomek
from sklearn.preprocessing import StandardScaler
from sklearn.model_selection import train_test_split
from sklearn.neighbors import KNeighborsClassifier
import numpy as np
import pandas as pd
import sklearn
from sklearn.metrics import classification_report, accuracy_score, f1_score, recall_score, precision_score, confusion_matrix, roc_auc_score
from sklearn import tree
from sklearn import preprocessing
import sys
import pickle


DATASET = 'cw'
data = pd.read_csv(r'/home/supriya/new_tfidf.csv')
print(data.shape)
X=data
labels=pd.read_csv('/home/supriya/Ankit_sourceCodes/byte_code_level/labels.csv')


for i in labels:
    if i in ['l4','l6','l8','l10','l12','l9','l14','l16']:
        continue

    Y=labels[i]
    print(f"ERROR_LABEL :{i}")
    # Print the shapes of X & Y
    print(X.shape, Y.shape)

    X_train, X_test, y_train, y_test = train_test_split(
        X, Y, test_size=0.3, random_state=69, stratify=Y)

    # Feature Scaling
    sc_X = StandardScaler()
    X_train = sc_X.fit_transform(X_train)
    X_test = sc_X.transform(X_test)

    # Sampling Training set
    # X_res, y_res = X_train, y_train
    smk = SMOTETomek()
    X_res, y_res = smk.fit_resample(X_train.astype('float'), y_train)
    print(X_res.shape, y_res.shape)

    # Sampling Testing set
    # X_smv, y_smv = X_test, y_test
    smv = SVMSMOTE()
    X_smv, y_smv = smv.fit_resample(X_test, y_test)
    print(X_smv.shape, y_smv.shape)

    filename = f'/home/supriya/tfidf_pickle/{i}_X_smt.pickle'
    with open(filename, 'wb') as fh:
        pickle.dump(X_res,fh)
        
    filename = f'/home/supriya/tfidf_pickle/{i}_Y_smt.pickle'
    with open(filename, 'wb') as fh:
        pickle.dump(y_res,fh)


    filename = f'/home/supriya/tfidf_pickle/{i}_X_svm.pickle'
    with open(filename, 'wb') as fh:
        pickle.dump(X_smv,fh)
        
    filename = f'/home/supriya/tfidf_pickle/{i}_Y_svm.pickle'
    with open(filename, 'wb') as fh:
        pickle.dump(y_smv,fh)

