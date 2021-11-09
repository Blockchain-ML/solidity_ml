import pandas as pd
import pickle
from sklearn.tree import DecisionTreeClassifier
from sklearn.metrics import accuracy_score
from sklearn.ensemble import AdaBoostClassifier
import xgboost
import numpy as np
from sklearn.naive_bayes import GaussianNB
from sklearn.metrics import classification_report, confusion_matrix
from sklearn.metrics import f1_score
from imblearn.combine import SMOTETomek
from imblearn.over_sampling import SMOTE
from sklearn.model_selection import train_test_split
from random import sample
from sklearn.metrics import roc_auc_score
from sklearn.linear_model import LogisticRegression
from sklearn.svm import SVC
from sklearn.model_selection import GridSearchCV
#parameters={'kernel':['linear', 'poly', 'rbf', 'sigmoid', 'precomputed'],'shrinking':['True','False'],'C':[.1,.5,1,5,10],'class_weight':['balanced'],'max_iter':[-1,5,10,20,50,100],'probability':['True','False'],'gamma':[.0001,.01,.2,.5,1]}
file=pd.read_csv("big_tfidf.csv")
labels=pd.read_csv('labels.csv')


    
for i in labels:
    print(i)
    X=file
    y=labels[i]
    X_train,X_test, y_train,y_test = train_test_split(X, y, test_size=0.2,stratify=y)
    X_test=pd.concat([X_test,y_test],axis=1)
    zeros=[]
    ones=[]
    for x in X_test.index:
            if X_test.loc[x,i]==0:
                zeros.append(x)
            else:
                ones.append(x)
    if len(ones)/len(zeros)<0.2:
        zeros=sample(zeros,5*len(ones))
        test_indexes=zeros+ones
        test_set=X_test.loc[test_indexes,:]
        X_test=test_set
        y_test=test_set[i]
        X_test=X_test.iloc[:,:900]
    else:
        y_test=X_test[i]
        X_test=X_test.iloc[:,:900]

    
    filename = 'Blockchain/model_results/smotetomek-rs/nb__smotetomek_Random_Sampling_TFIDF.txt'

    smk = SMOTETomek()
    X_res,y_res=smk.fit_sample(X_train.astype('float'),y_train)
    print(X_res.shape,y_res.shape)
    print(X_res)
    print(y_res)
    
    
    y_res.astype(bool).sum(axis=0)

    clf = GaussianNB()
    clf.fit(X_train, y_train)
# make predictions for test data
    y_pred = clf.predict(X_test)
    predictions = [round(value) for value in y_pred]
# evaluate predictions


    cm=confusion_matrix(y_test, y_pred)
    roc=roc_auc_score(y_test,y_pred)
    results=classification_report(y_test, y_pred)
    f1_mac=f1_score(y_test, y_pred, average='macro')
    f1_mic=f1_score(y_test, y_pred, average='micro')
    f1_wei=f1_score(y_test, y_pred, average='weighted')
    accuracy = accuracy_score(y_test, predictions)
    file_name1 = "Blockchain/saved_models/nb_smotetomek_tfidf"+i+".pkl"
    pickle.dump(clf, open(file_name1, "wb"))
    with open(filename, 'a') as fh:
        fh.write("\n"+"---------------------------------------"+"\n"+i+ " results for Naive Bayes with smotetomek on Random Sampling on TFIDF"+"\n"+str(results)+"\n" +"\n"+"Confusion_Matrix"+"\n"+str(cm)+"\n\n"+"Macro f1 "+str(f1_mac)+"\n\n"+"Micro f1 "+str(f1_mic)+"\n\n"+"Weigted f1 "+str(f1_wei)+"\n\n"+"ROC_acc "+str(roc))
        fh.close
    print("Accuracy: %.2f%%" % (accuracy * 100.0))
    print("F1 Score: %.2f%%" % (f1_mac * 100.0))

    
    
    #Smote
    
    
    