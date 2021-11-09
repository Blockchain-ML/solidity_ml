from imblearn.over_sampling import SVMSMOTE
from sklearn.datasets import make_classification
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

# SET Batch (1, 2, 3, 4, 5)
BATCH = int(sys.argv[1])

# SET BATCH LIST
BLIST = [[1,2], [3,5], [7,11], [13,15], [ 17,18]]
BATCH = BLIST[BATCH-1]


for ERROR_LABEL in BATCH:

    data = pd.read_csv(r'/dataset/origin/CDS_hy1_v2x.csv'', dtype={'label': object})
    print(data.shape)


    # split labels and return new dataframe
    # Create independent and Dependent Features
    def split_label_dict(df, ERL):
        # Change 'label' to whatever naming used in the original DataFrame.
        df[f'label'] = df['label'].astype(str).str[ERL-1]
        df[f'label'] = pd.to_numeric(df[f'label'])
        # print(df)
        return df


    df = split_label_dict(data, ERROR_LABEL)
    print(ERROR_LABEL, len(df[df['label'] == 1]), '\n', df)

    # Create independent and Dependent Features
    X = df.drop(['label', 'ID'], axis=1)
    # Store the variable we are predicting
    Y = df[f"label"]

    # Print the shapes of X & Y
    print('FSPLIT', X.shape, Y.shape)

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

    filename = f'/home/supriya/lstm_pickle/l{ERROR_LABEL}_X_smt.pickle'
    with open(filename, 'wb') as fh:
        pickle.dump(X_res,fh)
        
    filename = f'/home/supriya/lstm_pickle/l{ERROR_LABEL}_Y_smt.pickle'
    with open(filename, 'wb') as fh:
        pickle.dump(y_res,fh)


    filename = f'/home/supriya/lstm_pickle/l{ERROR_LABEL}_X_svm.pickle'
    with open(filename, 'wb') as fh:
        pickle.dump(X_smv,fh)
        
    filename = f'/home/supriya/lstm_pickle/l{ERROR_LABEL}_Y_svm.pickle'
    with open(filename, 'wb') as fh:
        pickle.dump(y_smv,fh)

