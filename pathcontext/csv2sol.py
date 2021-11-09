import pandas as pd

df = pd.read_csv('23k_vx.csv', dtype={'label': object})

for index, row in df.iterrows():
    with open(f'./sols/{row["_id"]}.sol', 'a') as f:
        f.write(row['code'])
    print(f'Done {row["_id"]}')
