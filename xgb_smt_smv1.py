import numpy as np
import pandas as pd
import sklearn
from sklearn.metrics import classification_report, accuracy_score, f1_score, recall_score, precision_score, confusion_matrix
from sklearn import tree
from sklearn import preprocessing
import sys
import pickle

DATASET = 'Hyb'

# SET Batch (1, 2, 3, 4, 5)
BATCH = int(sys.argv[1])

# SET BATCH LIST
BLIST = [[7], [11], [13], [15], [ 17,18]]
BATCH = BLIST[BATCH-1]

for ERROR_LABEL in BATCH:

    X_res = pickle.load(open(f'/home/supriya/sampling_pickle/l{ERROR_LABEL}_X_smt.pickle','rb'))
    y_res = pickle.load(open(f'/home/supriya/sampling_pickle/l{ERROR_LABEL}_Y_smt.pickle','rb'))
    X_smv = pickle.load(open(f'/home/supriya/sampling_pickle/l{ERROR_LABEL}_X_svm.pickle','rb'))
    y_smv = pickle.load(open(f'/home/supriya/sampling_pickle/l{ERROR_LABEL}_Y_svm.pickle','rb'))
    print(X_res.shape, y_res.shape)
    print(X_smv.shape, y_smv.shape)

    from sklearn.neighbors import KNeighborsClassifier
    from sklearn.model_selection import train_test_split
    # Feature Scaling
    from sklearn.preprocessing import StandardScaler
    from imblearn.combine import SMOTETomek
    from imblearn.over_sampling import SMOTE
    from sklearn.datasets import make_classification
    from imblearn.over_sampling import SVMSMOTE
    # Hyperparameter optimization using RandomizedSearchCV
    import xgboost

    # Fitting the classifier into the Training set
    CLIST=[6,9,10,12,14,15,18,20,21,24,25]
    for c in CLIST:

      classifier = xgboost.XGBClassifier(base_score=0.5, booster='gbtree', colsample_bylevel=1,
                                        colsample_bytree=0.5, gamma=0.4, learning_rate=0.1,
                                        max_delta_step=0, max_depth=c, min_child_weight=7, missing=1,
                                        n_estimators=100, n_jobs=1, nthread=None,
                                        objective='binary:logistic', random_state=69, reg_alpha=0,
                                        reg_lambda=1, scale_pos_weight=1, seed=None,
                                        subsample=1)
      classifier.fit(X_res, y_res)

      # Predicting the test set results
      y_predict = classifier.predict(X_smv)
      pd.crosstab(y_smv, y_predict)

      # Predicting the train set results
      y_predict_train = classifier.predict(X_res)

  
      import pickle
      # Save History as Pickle
      filename = f'/home/supriya/pickle_xgb/l{ERROR_LABEL}_model_{c}.pickle'
      with open(filename, 'wb') as fh:
          pickle.dump(classifier,fh)


      from sklearn.model_selection import cross_val_score
      from sklearn.metrics import roc_auc_score
      import pickle
      results = classification_report(y_smv, y_predict)

      cm = confusion_matrix(y_smv, y_predict)
      roc = roc_auc_score(y_smv, y_predict)

      print(cm)
      print(results)

      from sklearn.model_selection import cross_val_score
      from sklearn.metrics import roc_auc_score
      import pickle
      results = classification_report(y_smv, y_predict)

      cm = confusion_matrix(y_smv, y_predict)
      roc = roc_auc_score(y_smv, y_predict)
      f1_mac=f1_score(y_smv, y_predict, average='macro')
      f1_mic=f1_score(y_smv, y_predict, average='micro')
      f1_wei=f1_score(y_smv, y_predict, average='weighted')


      print(cm)
      print(results)

      
      # Save Results as txt
      filename = f'/home/supriya/xgb_results/{DATASET}_l{ERROR_LABEL}_XGB_SMT_SVM.txt'
      with open(filename, 'a') as fh:
          fh.write(str(results)+"\n" + f"Max_depth ={c}" +"\n" "ROC_ACCuracy:  "+str(roc) +"\n"+"Confusion_Matrix"+"\n"+str(cm)+"\n\n"+"Macro f1 "+str(f1_mac)+"\n\n"+"Micro f1 "+str(f1_mic)+"\n\n"+"Weigted f1 "+str(f1_wei)+"\n\n")
