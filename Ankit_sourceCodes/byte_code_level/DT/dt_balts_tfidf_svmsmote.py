from sklearn.metrics import confusion_matrix
from sklearn.ensemble import IsolationForest
from sklearn.metrics import f1_score
from sklearn.neighbors import LocalOutlierFactor
from sklearn.svm import OneClassSVM
from sklearn.metrics import roc_auc_score
from pylab import rcParams
from sklearn.tree import DecisionTreeClassifier
from sklearn.model_selection import train_test_split
from sklearn.metrics import classification_report
from imblearn.combine import SMOTETomek
from imblearn.over_sampling import SMOTE
from sklearn.datasets import make_classification
from imblearn.over_sampling import SVMSMOTE
from imblearn.combine import SMOTEENN
import pandas as pd
import pickle
from sklearn.metrics import accuracy_score
import xgboost
from imblearn.combine import SMOTETomek
from imblearn.over_sampling import SMOTE
file=pd.read_csv("big_tfidf.csv")
labels=pd.read_csv('labels.csv')

for i in labels:
    print(i)
    X=file
    y=labels[i]


    X_train,X_test, y_train,y_test = train_test_split(X,y,test_size=0.3,random_state=42,stratify=y)

    smk = SMOTETomek()
    #smk=SMOTEENN()
    X_res,y_res=smk.fit_resample(X_train.astype('float'),y_train)
    print(X_res.shape,y_res.shape)
    model = DecisionTreeClassifier(max_depth=25,min_samples_split=5,class_weight='balanced') 
    model.fit(X_res, y_res)
    smv = SVMSMOTE()
    X_smv,y_smv=smv.fit_resample(X_test,y_test)
    print(X_res.shape,y_res.shape)
    # Predicting the test set results
    y_pred = model.predict(X_smv)
    results=classification_report(y_smv,y_pred)
    cm = confusion_matrix(y_smv, y_pred)
    roc=roc_auc_score(y_smv,y_pred)
    f1_mac=f1_score(y_smv, y_pred, average='macro')
    f1_mic=f1_score(y_smv, y_pred, average='micro')
    f1_wei=f1_score(y_smv, y_pred, average='weighted')
    predictions = [round(value) for value in y_pred]
    accuracy = accuracy_score(y_smv, predictions)
    filename = 'Blockchain/model_results/SVMSMOTE/tfidf_dt_results_SVMSMOTE_ts.txt'
    with open(filename, 'a') as fh:
            fh.write("\n"+"---------------------------------------"+"\n"+i+ " TFIDF results for xgboost with SVMSMOTE on test set"+"\n"+str(results)+"\n" +"\n"+"Confusion_Matrix"+"\n"+str(cm)+"\n\n"+"Macro f1 "+str(f1_mac)+"\n\n"+"Micro f1 "+str(f1_mic)+"\n\n"+"Weigted f1 "+str(f1_wei)+"\n\n"+"ROC_acc "+str(roc))
            fh.close
    print("Accuracy: %.2f%%" % (accuracy * 100.0))
    print("F1_score: %.2f%%" % (f1_mac * 100.0))
