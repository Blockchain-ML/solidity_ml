from os import listdir
from os.path import isfile, join
contracts = [f for f in listdir('./batch15') if isfile(join('./batch15', f))]

from shutil import copy

contracts.sort()

bdir = 1
count = 0
for contract in contracts:
    copy('./batch15/'+ str(contract) , './batch3' + '/testData/examples/b'+ str(bdir))
    print(contract, count)
    count += 1
    if count % 1000 == 0:
        bdir += 1

print("ALL DONE!")
