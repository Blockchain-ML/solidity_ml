import pandas as pd
import pickle
from sklearn.metrics import accuracy_score
import xgboost
from sklearn.metrics import classification_report, confusion_matrix
from sklearn.metrics import f1_score
from imblearn.combine import SMOTETomek
from imblearn.over_sampling import SMOTE
from sklearn.model_selection import train_test_split
from random import sample
from sklearn.linear_model import LogisticRegression
file=pd.read_csv("big_tfidf.csv")
labels=pd.read_csv('labels.csv')


    
for i in labels:
    print(i)
    X=file
    y=labels[i]
    X_train,X_test, y_train,y_test = train_test_split(X, y, test_size=0.3,stratify=y)
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
        X_test=X_test.iloc[:,1:901]
    else:
        y_test=X_test[i]
        X_test=X_test.iloc[:,1:901]

    
    filename = 'Blockchain/model_results/tfidf_knn__smote_Random Sampling.txt'

    smk = SMOTE()
    X_res,y_res=smk.fit_sample(X_train.astype('float'),y_train)
    print(X_res.shape,y_res.shape)
    print(X_res)
    print(y_res)
    
    
    y_res.astype(bool).sum(axis=0)
    from sklearn.neighbors import KNeighborsClassifier
    classifier = KNeighborsClassifier(n_neighbors=1)
    classifier.fit(X_res, y_res)

# make predictions for test data
    y_pred = classifier.predict(X_test)
    predictions = [round(value) for value in y_pred]
# evaluate predictions


    cm=confusion_matrix(y_test, y_pred)
    results=classification_report(y_test, y_pred)
    f1_mac=f1_score(y_test, y_pred, average='macro')
    f1_mic=f1_score(y_test, y_pred, average='micro')
    f1_wei=f1_score(y_test, y_pred, average='weighted')
    accuracy = accuracy_score(y_test, predictions)
    with open(filename, 'a') as fh:
        fh.write("\n"+"---------------------------------------"+"\n"+i+ " results for knn with smote on Random Sampling"+"\n"+str(results)+"\n" +"\n"+"Confusion_Matrix"+"\n"+str(cm)+"\n\n"+"Macro f1 "+str(f1_mac)+"\n\n"+"Micro f1 "+str(f1_mic)+"\n\n"+"Weigted f1 "+str(f1_wei))
        fh.close
    print("Accuracy: %.2f%%" % (accuracy * 100.0))
    
    
    #Smote
    
    
    