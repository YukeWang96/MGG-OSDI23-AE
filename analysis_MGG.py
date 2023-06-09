#!/usr/bin/env python3
import sys 

if len(sys.argv) < 3:
    raise ValueError("Usage: ./1_log2csv.py result.log num_gpus")

fp = open(sys.argv[1], "r")
num_GPUs = int(sys.argv[2])

dataset_li = []
time_li = []
for line in fp:
    if "Graph File:" in line:
        dataset = line.split("/")[-1].strip('.mtx').strip('\n')
        dataset_li.append(dataset)
    if "MPI time (ms)" in line:
        time = line.strip("MPI time (ms)").strip('\n')
        print(time)
        time_li.append(float(time))
fp.close()

fout = open(sys.argv[1].strip(".log")+".csv", 'w')
# fout = open("test.csv", 'w')

# fout.write("Dataset,Time (ms)\n")
# print(time_li)

cnt = 0
# print(dataset_li)
# print(time_li)
# print(len(dataset_li))
for data in dataset_li:
    if cnt % num_GPUs == 0:
        # print("---", int(cnt/num_GPUs))
        tmp_t = time_li[int(cnt/num_GPUs)]
        fout.write("{},{}\n".format(data.strip(".bin"), tmp_t))
    cnt += 1
fout.close()