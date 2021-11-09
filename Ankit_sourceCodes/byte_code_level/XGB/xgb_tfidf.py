import pandas as pd
import pickle
from sklearn.metrics import accuracy_score
import xgboost
from imblearn.combine import SMOTETomek
from imblearn.over_sampling import SMOTE
from sklearn.model_selection import train_test_split
from sklearn.metrics import classification_report, confusion_matrix
from sklearn.metrics import f1_score
from sklearn.metrics import roc_auc_score
file=pd.read_csv("big_tfidf.csv")
labels=pd.read_csv('labels.csv')

for i in labels:
    print(i)
    X=file
    y=labels[i]
    X_train,X_test, y_train,y_test = train_test_split(X, y, test_size=0.2,stratify=y)
    filename = 'Blockchain/model_results/tfidfres/xgb_results_unbalanced.txt'
    model = xgboost.XGBClassifier(eta=0.5,max_depth=20,max_delta_step=10,reg_alpha=2,grow_policy='lossguide',subsample=0.8,tree_method='approx',max_leaves=1)
    model.fit(X_train, y_train)
# make predictions for test data
    y_pred = model.predict(X_test)
    predictions = [round(value) for value in y_pred]
# evaluate predictions
    cm=confusion_matrix(y_test, y_pred)
    results=classification_report(y_test, y_pred)
    f1_mac=f1_score(y_test, y_pred, average='macro')
    f1_mic=f1_score(y_test, y_pred, average='micro')
    f1_wei=f1_score(y_test, y_pred, average='weighted')
    accuracy = accuracy_score(y_test, predictions)
    roc=roc_auc_score(y_test,y_pred)
    with open(filename, 'a') as fh:
        fh.write("\n"+"---------------------------------------"+"\n"+i+ " Results for xgboost for "+i+"\n"+str(results)+"\n" +"\n"+"Confusion_Matrix"+"\n"+str(cm)+"\n\n"+"Macro f1 "+str(f1_mac)+"\n\n"+"Micro f1 "+str(f1_mic)+"\n\n"+"Weigted f1 "+str(f1_wei)+"\n\n"+"ROC_acc "+str(roc))
        fh.close
    print("Accuracy: %.2f%%" % (accuracy * 100.0))
    file_name1 = "Blockchain/saved_models/xgb_reg"+i+".pkl"
    pickle.dump(model, open(file_name1, "wb"))

