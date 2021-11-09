import numpy as np
import pandas as pd
import sklearn
from sklearn.metrics import classification_report, accuracy_score, f1_score, recall_score, precision_score, confusion_matrix
from sklearn import tree
from sklearn import preprocessing

import sys


# SET Dataset
DATASET = 'Hybrid v1'

# SET Batch (1, 2, 3, 4, 5)
BATCH = int(sys.argv[1])

# SET BATCH LIST
BLIST = [[1, 2], [5,  7], [ 11, 3], [13,  15], [ 17, 18]]
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
    from sklearn.decomposition import PCA
    pca = PCA(n_components=400)
    X = pca.fit_transform(X)

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
    from sklearn.neural_network import MLPClassifier
    from sklearn.datasets import make_classification

    # Fitting the classifier into the Training set
    CLIST=[20,50,100,150,200,250,300,450,500,550,600,700,800,900,1000]
    for c in CLIST:

      classifier = MLPClassifier(random_state=69, hidden_layer_sizes=c)
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

      filename = f'/home/supriya/MLP//{DATASET}_l{ERROR_LABEL}_mlp_pca.pickle'
      with open(filename, 'wb') as fh:
          pickle.dump(classifier, fh)


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

      message = ''
      message += f'=========================\nMLP -->ERROR LABEL {ERROR_LABEL}\nTR -> SMT | TE -> SVM\n=========================\n'
      message += f'Train Metrics\n-------------------------' + '\n'
      # accuracy: (tp + tn) / (p + n)
      accuracy = accuracy_score(y_res, y_predict_train)
      message += 'Accuracy: %f' % accuracy + '\n'
      # precision tp / (tp + fp)
      precision = precision_score(y_res, y_predict_train)
      message += 'Precision: %f' % precision + '\n'
      # recall: tp / (tp + fn)
      recall = recall_score(y_res, y_predict_train)
      message += 'Recall: %f' % recall + '\n'
      # f1: 2 tp / (2 tp + fp + fn)
      f1 = f1_score(y_res, y_predict_train)
      message += 'F1 score: %f' % f1 + '\n'
      f1M = f1_score(y_res, y_predict_train, average='macro')
      message += 'F1-M score: %f' % f1M + '\n'

      # confusion matrix
      matrix = confusion_matrix(y_res, y_predict_train)
      message += str(matrix) + '\n'
      message += f'-------------------------\nTest Metrics\n-------------------------' + '\n'
      # accuracy: (tp + tn) / (p + n)
      accuracy = accuracy_score(y_smv, y_predict)
      message += 'Accuracy: %f' % accuracy + '\n'
      # precision tp / (tp + fp)
      precision = precision_score(y_smv, y_predict)
      message += 'Precision: %f' % precision + '\n'
      # recall: tp / (tp + fn)
      recall = recall_score(y_smv, y_predict)
      message += 'Recall: %f' % recall + '\n'
      # f1: 2 tp / (2 tp + fp + fn)
      f1 = f1_score(y_smv, y_predict)
      message += 'F1 score: %f' % f1 + '\n'
      f1M = f1_score(y_smv, y_predict, average='macro')
      message += 'F1-M score: %f' % f1M + '\n'
      # confusion matrix
      matrix = confusion_matrix(y_smv, y_predict)
      message += str(matrix) + '\n'
      message += '-------------------------' + '\n'

      # Save Results as txt
      filename = f'/home/supriya/MLP/{DATASET}_l{ERROR_LABEL}_MLP_SMT_SVM_results.txt'
      with open(filename, 'a') as fh:
          fh.write(str(results)+"\n" + f"hidden_layer_sizes={c}" +"\n" "ROC_ACCuracy:  "+str(roc) +"\n"+"Confusion_Matrix"+"\n"+str(cm)+"\n\n"+"Macro f1 "+str(f1_mac)+"\n\n"+"Micro f1 "+str(f1_mic)+"\n\n"+"Weigted f1 "+str(f1_wei)+"\n\n")


