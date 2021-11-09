import os
import sys
import subprocess
import argparse
import numpy as np
import pandas as pd
import csv
import ast
import torch
import torch.nn as nn
import torch.optim as optim
from torch.autograd import Variable
from torch.nn import functional as F
from torch import nn
from torch.utils.data import DataLoader
import re
from data_processing.PathMinerLoader import PathMinerLoader
from data_processing.PathMinerDataset import PathMinerDataset
from model.CodeVectorizer import CodeVectorizer
from model.ProjectClassifier import ProjectClassifier
x = pd.read_csv("/dataset/origin/CDS_v2x.csv", dtype={'label': object})
label = x[['_id', 'label']].copy()
# ids=x['_id']
os.environ['KMP_DUPLICATE_LIB_OK'] = 'True'
# Example shows how to pass data generated by PathMiner to PyTorch Dataset for further convenient usage and build a
# classifier to solve a toy problem of distinguishing files between 2 projects.
# If projects aren't loaded or processed yet then do it.


def load_projects():
    necessary_files = ['node_types.csv', 'paths.csv',
                       'tokens.csv', 'path_contexts.csv']
    # print(necessary_files)
    if not any(fname in os.listdir('processed_data/') for fname in necessary_files):
        print("Some of the files are missing. Downloading projects and processing them")
        subprocess.call('./prepare_data.sh')


# Add labels with project info to path contexts.
def label_contexts(path_contexts):
    y = re.findall(r'\d+',)
    print(y)
    path_contexts['project'] = path_contexts['id'].map(
        lambda filename: (0, 0) if 'project1' in filename else (1, 1))

   # print(path_contexts['project'])

# Create training and validation dataset from path contexts.


def split2datasets(loader, test_size=0.1, keep_contexts=200):
    index = np.array(loader.path_contexts.index)
    # print(index)
    # print(len(loader.path_contexts))
    n_test = int(test_size * len(loader.path_contexts))
    n_val = int(n_test/2)
    test_indices = index[:n_test-n_val]
    val_indices = index[n_test-n_val:n_test]

    train_indices = index[n_test:]
    # print(test_indices)
    return PathMinerDataset(loader, train_indices, keep_contexts), PathMinerDataset(loader, test_indices, keep_contexts), PathMinerDataset(loader, val_indices, keep_contexts)


# Train a model, print training summary and results on test dataset after every epoch.
class _classifier(nn.Module):
    def __init__(self, nlabel):
        super(_classifier, self).__init__()
        self.main = nn.Sequential(
            nn.Linear(2, 64),
            nn.ReLU(),
            nn.Linear(64, nlabel),
        )

    def forward(self, input):
        return self.main(input)


nlabel = 25  # => 3
classifier = _classifier(nlabel)
optimizer = optim.Adam(classifier.parameters())
criterion = nn.MultiLabelSoftMarginLoss()


def main(args):
    print("Checking if projects are loaded and processed")
    load_projects()
    print("Loading generated data")
    loader = PathMinerLoader.from_folder(args.source_folder)
    print("Labeling contexts and print")
    # label_contexts(loader.path_contexts)
    print("Creating datasets")
    train_dataset, test_dataset, val_dataset = split2datasets(
        loader, keep_contexts=200)
    print(type(train_dataset))
    print(train_dataset)
    model = CodeVectorizer(len(loader.tokens) + 1, len(loader.paths) + 1, 8)
    trainX, testX, valX = [], [], []
    trainY, testY, valY = [], [], []
    flag = False
    for data in enumerate(train_dataset):
        # print("train_dataset")
        # print(data)
        # print("********")
        # print("********")
        # print(len(data))
        y = re.findall(r'\d+', data[1]['ids'])
        x = y[0]
        vector = model(data[1]['contexts'])
       # torch.from_numpy(int(label.loc[label['_id'] == int(x), 'label'].iloc[0])) convert into tensor
        # print(type(vector))
        # print(vector)
        # print(vector.detach().numpy().shape)
        #print(np.unique(label.loc[label['_id'] == int(x), 'label'].iloc[0]).shape)
        trainX.append(vector)
        trainY.append(label.loc[label['_id'] == int(x), 'label'].iloc[0])
        print("train_dataset",
              label.loc[label['_id'] == int(x), 'label'].iloc[0])
        with open('TrainB8.csv', 'a') as file:
            fieldnames = ['ID', 'Vector_form', 'label']
            writer = csv.DictWriter(file, fieldnames=fieldnames)
            if not flag:
                writer.writeheader()
                flag = True
            writer.writerow({'ID': str(x), 'Vector_form': vector,
                             'label': label.loc[label['_id'] == int(x), 'label'].iloc[0]})

        # with open('Vector.txt', 'a') as file1:
            # file1.write(str(x)+","+str(vector))
        # with open('Label.txt', 'a') as file2:
            #file2.write(str(x)+","+str(label.loc[label['_id'] == int(x), 'label'].iloc[0]))

    flag1 = False
    for data in enumerate(test_dataset):
        y = re.findall(r'\d+', data[1]['ids'])
        x = y[0]
        #print(label.loc[label['_id'] == int(x), 'label'].iloc[0])
        vector = model(data[1]['contexts'])
        # print(type(vector))
        # testX.append(vector)
        testX.append(vector)
        testY.append(label.loc[label['_id'] == int(x), 'label'].iloc[0])
        print("test_dataset",
              label.loc[label['_id'] == int(x), 'label'].iloc[0])
        #testY.append(np.array(label.loc[label['_id'] == int(x), 'label'].iloc[0]))
        with open('TestB8.csv', 'a') as file:
            fieldnames = ['ID', 'Vector_form', 'label']
            writer = csv.DictWriter(file, fieldnames=fieldnames)
            if not flag1:
                writer.writeheader()
                flag1 = True
            writer.writerow({'ID': str(x), 'Vector_form': vector,
                             'label': label.loc[label['_id'] == int(x), 'label'].iloc[0]})

    flag2 = False
    for data in enumerate(val_dataset):
        # print("test_dataset")
        y = re.findall(r'\d+', data[1]['ids'])
        x = y[0]
        vector = model(data[1]['contexts'])
        valX.append(vector)
        valY.append(label.loc[label['_id'] == int(x), 'label'].iloc[0])
        print("val_dataset",
              label.loc[label['_id'] == int(x), 'label'].iloc[0])
        with open('ValB8.csv', 'a') as file:
            fieldnames = ['ID', 'Vector_form', 'label']
            writer = csv.DictWriter(file, fieldnames=fieldnames)
            if not flag2:
                writer.writeheader()
                flag2 = True
            writer.writerow({'ID': str(x), 'Vector_form': vector,
                             'label': label.loc[label['_id'] == int(x), 'label'].iloc[0]})

    # print(type(trainX))
    # print(type(trainY))

    # with open('data.csv', 'w') as file:
            #fieldnames = ['ID','Vector_form', 'label']
            #writer = csv.DictWriter(file, fieldnames=fieldnames)
            # writer.writeheader()
            #writer.writerow({'ID': str(x),'Vector_form': trainX, 'label': trainY})
    # with open('Vector.txt', 'w') as file1:
        # file1.write(str(x)+","+str(trainX))
    # with open('Label.txt', 'w') as file2:
        # file2.write(str(x)+","+str(trainY))
    # print(type(trainX))
    # print(type(trainY))

    # print(trainX)

   # writer.writerow({'player_name': 'Magnus Carlsen', 'fide_rating': 2870})


   # epochs = 5
"""    losses = []
    for epoch in range(epochs):
        
        inputv = Variable(torch.FloatTensor(trainX))
        labelsv = Variable(torch.FloatTensor(trainY))
        
        output = classifier(inputv)
        loss = criterion(output, labelsv)

        optimizer.zero_grad()
        loss.backward()
        optimizer.step()
        losses.append(loss.data.mean())
    print("data")    
    print(inputv)
    print(labelsv)
    print(output)
    print('[%d/%d] Loss: %.3f' % (epoch+1, epochs, np.mean(losses)))"""


if __name__ == '__main__':
    # np.random.seed(42)

    parser = argparse.ArgumentParser()
    parser.add_argument('--source_folder', type=str, default='processed_data/',
                        help='Folder containing output of PathMiner')
    parser.add_argument('--batch_size', type=int, default=10,
                        help='Batch size for training')

    args = parser.parse_args()
    main(args)