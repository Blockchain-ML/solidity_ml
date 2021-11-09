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
BLIST = [[1 ], [13,2], [15,3], [17,5], [ 7,18]]
BATCH = BLIST[BATCH-1]

for ERROR_LABEL in BATCH:

    data = pd.read_csv(r'/dataset/origin/CDS_hy1_v2x.csv', dtype={'label': object})
    print(data.shape)

    # split labels and return new dataframe
    # Create independent and Dependent Features

    def split_label_dict(df):
        # Change 'label' to whatever naming used in the original DataFrame.
        temp_df = df['label'].str.split("", n=-1, expand=True)
        for i in range(1, 19):
            df[f'l{i}'] = temp_df[i]
            df[f'l{i}'] = pd.to_numeric(df[f'l{i}'])
        return df

    newdata = split_label_dict(data)
    # Create independent and Dependent Features
    df = pd.DataFrame(data)
    new_df = df.drop(['label', 'l18', 'l17', 'l16', 'l15', 'l14', 'l13', 'l12', 'l11',
                      'l10', 'l9', 'l8', 'l7', 'l6', 'l5', 'l3', 'l4', 'l2', 'l1', 'ID'], axis=1)
    X = new_df
    # Store the variable we are predicting
    Y = newdata[f"l{ERROR_LABEL}"]

    # Print the shapes of X & Y
    print(X.shape, Y.shape)

    from sklearn.neighbors import KNeighborsClassifier
    from sklearn.model_selection import train_test_split

    X_train, X_test, y_train, y_test = train_test_split(
        X, Y, test_size=0.3, random_state=69, stratify=Y)

    # Feature Scaling
    from sklearn.preprocessing import StandardScaler
    sc_X = StandardScaler()
    X_train = sc_X.fit_transform(X_train)
    X_test = sc_X.transform(X_test)

    from imblearn.combine import SMOTETomek
    from imblearn.over_sampling import SMOTE
    from sklearn.datasets import make_classification
    from imblearn.over_sampling import SVMSMOTE

    smk = SMOTETomek()
    X_res, y_res = smk.fit_resample(X_train.astype('float'), y_train)
    print(X_res.shape, y_res.shape)

    # Hyperparameter optimization using RandomizedSearchCV
    import xgboost

    # Fitting the classifier into the Training set
    # CLIST=[6,9,10,12,14,15,18,20,21,24,25]
    CLIST=[14]
    for c in CLIST:

      classifier = xgboost.XGBClassifier(base_score=0.5, booster='gbtree', colsample_bylevel=1,
                                        colsample_bytree=0.5, gamma=0.4, learning_rate=0.1,
                                        max_delta_step=0, max_depth=c, min_child_weight=7,
                                        n_estimators=100, n_jobs=1,
                                        objective='binary:logistic', random_state=69, reg_alpha=0,
                                        reg_lambda=1, scale_pos_weight=1, seed=None,
                                        subsample=1)
      classifier.fit(X_res, y_res)

      # Sampling Testing set
      smv = SVMSMOTE()

      X_smv, y_smv = smv.fit_resample(X_test, y_test)
      print(X_res.shape, y_res.shape)

      # Predicting the test set results
      y_predict = classifier.predict(X_smv)
      pd.crosstab(y_smv, y_predict)

      # Predicting the train set results
      y_predict_train = classifier.predict(X_res)

  
      import pickle
      # Save History as Pickle
      filename = f'/home/supriya/xgb_pickle/l{ERROR_LABEL}_model_{c}.pickle'
      with open(filename, 'wb') as fh:
          pickle.dump(classifier,fh)
      filename = f'/home/supriya/xgb_pickle/l{ERROR_LABEL}_X_{c}.pickle'
      with open(filename, 'wb') as fh:
          pickle.dump(X_smv,fh)
          
      filename = f'/home/supriya/xgb_pickle/l{ERROR_LABEL}_Y_{c}.pickle'
      with open(filename, 'wb') as fh:
          pickle.dump(y_smv,fh)



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
      filename = f'/home/supriya/results/{DATASET}_l{ERROR_LABEL}_XGB_SMT_SVM.txt'
      with open(filename, 'a') as fh:
          fh.write(str(results)+"\n" + f"Max_depth ={c}" +"\n" "ROC_ACCuracy:  "+str(roc) +"\n"+"Confusion_Matrix"+"\n"+str(cm)+"\n\n"+"Macro f1 "+str(f1_mac)+"\n\n"+"Micro f1 "+str(f1_mic)+"\n\n"+"Weigted f1 "+str(f1_wei)+"\n\n")
