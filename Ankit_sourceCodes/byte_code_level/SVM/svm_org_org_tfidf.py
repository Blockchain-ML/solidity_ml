import pandas as pd
import pickle
from sklearn.naive_bayes import GaussianNB
from sklearn.metrics import accuracy_score
import xgboost
from sklearn.metrics import classification_report, confusion_matrix
from sklearn.metrics import f1_score
from imblearn.combine import SMOTETomek
from imblearn.over_sampling import SMOTE
from sklearn.model_selection import train_test_split
from random import sample
from sklearn.metrics import roc_auc_score
from sklearn.neural_network import MLPClassifier
from sklearn.svm import SVC
from sklearn.linear_model import LogisticRegression
file=pd.read_csv("big_tfidf.csv")
labels=pd.read_csv('labels.csv')


    
for i in labels:
    print(i)
    X=file
    from sklearn.decomposition import PCA
    pca = PCA(n_components=250)
    X = pca.fit_transform(X)
    y=labels[i]
    X_train,X_test, y_train,y_test = train_test_split(X, y, test_size=0.2,stratify=y)
        
    filename = 'Blockchain/model_results/org-org/svm__org_org_tfidf.txt'

    from sklearn.neighbors import KNeighborsClassifier
    classifier = SVC( C=0.5, kernel='linear', degree=3, gamma='scale', coef0=0.0, shrinking=True, probability=False, tol=0.001, cache_size=200, class_weight=None, verbose=False, max_iter=1000, decision_function_shape='ovr', break_ties=False)    
  
    classifier.fit(X_train, y_train)

# make predictions for test data
    y_pred = classifier.predict(X_test)
    predictions = [round(value) for value in y_pred]
# evaluate predictions


    cm=confusion_matrix(y_test, y_pred)
    roc=roc_auc_score(y_test,y_pred)
    results=classification_report(y_test, y_pred)
    f1_mac=f1_score(y_test, y_pred, average='macro')
    f1_mic=f1_score(y_test, y_pred, average='micro')
    f1_wei=f1_score(y_test, y_pred, average='weighted')
    accuracy = accuracy_score(y_test, predictions)
    #file_name1 = "Blockchain/saved_models/smotetomek-org/mlpc_smote_org_cw"+i+".pkl"
    #pickle.dump(classifier, open(file_name1, "wb"))
    with open(filename, 'a') as fh:
        fh.write("\n"+"---------------------------------------"+"\n"+i+ " results for svm with original Training set and original test set on tfidf dataset"+"\n"+str(results)+"\n" +"\n"+"Confusion_Matrix"+"\n"+str(cm)+"\n\n"+"Macro f1 "+str(f1_mac)+"\n\n"+"Micro f1 "+str(f1_mic)+"\n\n"+"Weigted f1 "+str(f1_wei)+"\n\n"+"ROC_acc "+str(roc))
        fh.close
    print("Accuracy: %.2f%%" % (accuracy * 100.0))
    print("F1 Score: %.2f%%" % (f1_mac * 100.0))

    
    
    #Smote
    
    
    