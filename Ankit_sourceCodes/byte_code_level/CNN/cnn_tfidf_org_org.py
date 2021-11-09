import tensorflow as tf
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



data = pd.read_csv("../Blockchain/new_tfidf.csv")
print(data.shape)
X=data


labels=pd.read_csv('../labels.csv')


for i in labels:
    Y=labels[i]
# Print the shapes of X & Y
    print(X.shape, Y.shape)


    X_train, X_test, y_train, y_test = train_test_split(X, Y, test_size=0.2, random_state=69, stratify=Y)

    X_train, X_val, y_train, y_val = train_test_split(X_train, y_train, test_size=0.2, random_state=23, stratify=y_train)

    # Feature Scaling
    sc_X = StandardScaler()
    X_train = sc_X.fit_transform(X_train)
    X_test = sc_X.transform(X_test)

    # Sampling Training set
    # X_res, y_res = X_train, y_train
    #smk = SVMSMOTE()
    X_res=X_train
    y_res=y_train
    print(X_res.shape, y_res.shape)

    # Sampling Testing set
    # X_smv, y_smv = X_test, y_test
    #smv = SVMSMOTE()
    #X_smv, y_smv = smv.fit_resample(X_test, y_test)
    print(X_test.shape,y_test.shape)

    X_smv=X_val
    y_smv=y_val
    
    
    train_sequences = np.array(X_res)
    train_labels = np.array(y_res)

    val_sequences = np.array(X_smv)
    val_labels = np.array(y_smv)
    
    test_sequences = np.array(X_test)
    test_labels = np.array(y_test)

    print("Train-Sequences", train_sequences.shape, type(train_sequences[0]))
    print("Train-Labels", train_labels.shape, type(train_labels[0]))
    
    print("Validation-Sequences", val_sequences.shape, type(val_sequences[0]))
    print("Validation-Labels", val_labels.shape, type(val_sequences[0]))

    print("Test-Sequences", test_sequences.shape, type(test_sequences[0]))
    print("Test-Labels", test_labels.shape, type(test_labels[0]))
    

    OPCODE_SEQ_LEN = 250
    EMBEDDING_DIM = 100
    NUM_EPOCS = 10
    BATCH_SIZE = 128
    
   
    model = tf.keras.models.Sequential()
    model.add(tf.keras.layers.Embedding(250, EMBEDDING_DIM, input_length=OPCODE_SEQ_LEN))
    model.add(tf.keras.layers.Conv1D(filters=32, kernel_size=8, activation='relu'))
    model.add(tf.keras.layers.MaxPooling1D(pool_size=2))
    model.add(tf.keras.layers.Flatten())
    model.add(tf.keras.layers.Dense(10, activation='relu'))
    model.add(tf.keras.layers.Dense(1, name='out_layer', activation='sigmoid'))

    model.summary()
    
    model.compile(loss='binary_crossentropy',optimizer='adam', metrics=['accuracy'])

    history = model.fit(train_sequences, train_labels, epochs=NUM_EPOCS, validation_data=(val_sequences, val_labels),batch_size=BATCH_SIZE, verbose=1)

    results = model.evaluate(test_sequences, test_labels, batch_size=BATCH_SIZE)
    print("Test Loss, Test Accuracy:", results)
    

    filename1='../Blockchain/models/cnn/cnn_tfidf_org_org_'+i+'.h5'

    model.save(filename1)
    
    
    y_pred1=model.predict_classes(X_train)
    y_pred2=model.predict_classes(X_val)
    y_pred3=model.predict_classes(X_test)
    

    filename= '../Blockchain/CNN/lstm_tfidf_org_org.txt'

    cm=confusion_matrix(y_train, y_pred1)
    roc=roc_auc_score(y_train, y_pred1)
    results=classification_report(y_train, y_pred1)
    f1_mac=f1_score(y_train, y_pred1, average='macro')
    f1_mic=f1_score(y_train, y_pred1, average='micro')
    f1_wei=f1_score(y_train, y_pred1, average='weighted')
    accuracy = accuracy_score(y_train, y_pred1)
    


    with open(filename, 'a') as fh:
        fh.write("\n"+"---------------------------------------"+"\n"+i+ " Training results for cnn/tfidf with original train and original test set"+"\n"+str(results)+"\n" +"\n"+"Confusion_Matrix"+"\n"+str(cm)+"\n\n"+"Macro f1 "+str(f1_mac)+"\n\n"+"Micro f1 "+str(f1_mic)+"\n\n"+"Weigted f1 "+str(f1_wei)+"\n\n"+"ROC_acc "+str(roc))
        fh.close
        
        
        
        
        
    
    cm=confusion_matrix(y_val, y_pred2)
    roc=roc_auc_score(y_val, y_pred2)
    results=classification_report(y_val, y_pred2)
    f1_mac=f1_score(y_val, y_pred2, average='macro')
    f1_mic=f1_score(y_val, y_pred2, average='micro')
    f1_wei=f1_score(y_val, y_pred2, average='weighted')
    accuracy = accuracy_score(y_val, y_pred2)
    
    with open(filename, 'a') as fh:
        fh.write("\n"+"---------------------------------------"+"\n"+i+ " Validation results for cnn/tfidf with original train and original test set"+"\n"+str(results)+"\n" +"\n"+"Confusion_Matrix"+"\n"+str(cm)+"\n\n"+"Macro f1 "+str(f1_mac)+"\n\n"+"Micro f1 "+str(f1_mic)+"\n\n"+"Weigted f1 "+str(f1_wei)+"\n\n"+"ROC_acc "+str(roc))
        fh.close
    
    cm=confusion_matrix(y_test, y_pred3)
    roc=roc_auc_score(y_test, y_pred3)
    results=classification_report(y_test, y_pred3)
    f1_mac=f1_score(y_test, y_pred3, average='macro')
    f1_mic=f1_score(y_test, y_pred3, average='micro')
    f1_wei=f1_score(y_test, y_pred3, average='weighted')
    accuracy = accuracy_score(y_test, y_pred3)
    
    with open(filename, 'a') as fh:
        fh.write("\n"+"---------------------------------------"+"\n"+i+ " Test results for cnn/tfidf with original train and original test set"+"\n"+str(results)+"\n" +"\n"+"Confusion_Matrix"+"\n"+str(cm)+"\n\n"+"Macro f1 "+str(f1_mac)+"\n\n"+"Micro f1 "+str(f1_mic)+"\n\n"+"Weigted f1 "+str(f1_wei)+"\n\n"+"ROC_acc "+str(roc))
        fh.close
        
    
