import re

f = open('corpus/adaboost_smt_svm.txt')

content = f.read()

matrices = re.findall(r"\[\[[\s0-9\s]+\]\n\s\[[\s0-9\s]+\]\]", content) 

print(matrices)

# RegEx work Complete

# Generate Matrices
# tn, fp, fn, tp


for matrix in matrices:
    matrix = matrix.replace('[', '')
    matrix = matrix.replace(']', '')
    matrix = matrix.replace('\n', '')
    mat = re.sub(r'\s+', ',', matrix.strip())

    mat = mat.split(',')
    print(mat)