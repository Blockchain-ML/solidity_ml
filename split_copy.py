from os import listdir
from os.path import isfile, join
contracts = [f for f in listdir('./contracts') if isfile(join('./contracts', f))]

from shutil import copyfile

bdir = 1
count = 0
for contract in contracts:
    copyfile('./contracts/' + contract, './batch' + bdir + '/testData/examples/solidity/' + contract)
    count += 1
    if count % 4000:
        bdir += 1

print("ALL DONE!")
