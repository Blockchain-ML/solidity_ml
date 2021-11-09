import pandas as pd
import os

print('READING CSV . . . .')

DATASETPATH = '/dataset/origin/CDS_v2x.csv'

DATASET = pd.read_csv(DATASETPATH, dtype={'label': object})

print('STARTING . . . .', len(DATASET.index))

BATCH = 1
for INDEX in DATASET.index:
    if not os.path.exists(f'./batch{BATCH}/'):
        os.mkdir(f'./batch{BATCH}/')
    with open(f'./batch{BATCH}/{DATASET["_id"][INDEX]}.sol', 'w') as contract:
        contract.write(DATASET['code'][INDEX])
    if (INDEX % 3999) == 0 and INDEX != 0:
        print(f'BATCH {BATCH} COMPLETE ! ! ! !')
        BATCH += 1

print('PROCESS COMPLETE . . . .')
