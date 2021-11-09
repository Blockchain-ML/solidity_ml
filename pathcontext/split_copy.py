from os import listdir
from os.path import isfile, join
contracts = [f for f in listdir('./sols') if isfile(join('./sols', f))]

from shutil import copy

contracts.sort()

bdir = 1
count = 0
for contract in contracts:
    copy('./sols/' + str(contract), './batch' + str(bdir) + '/testData/examples/solidity/')
    print(contract, count)
    count += 1
    if count % 4000 == 0:
        bdir += 1

print("ALL DONE!")
