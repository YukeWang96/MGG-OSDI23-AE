#!/usr/bin/env python3
import os

os.system("mv *.log logs/")
os.system("mv *.err logs/")
# os.system("mv *.csv csvs/")
num_gpus = [4]

for gpu in num_gpus:
    os.system("./bench_MGG_GIN.py {0}| tee MGG_{0}GPU_GIN.log 2>MGG_{0}GPU_GIN.err".format(gpu))
    os.system("./analysis_MGG.py MGG_{0}GPU_GIN.log {0}".format(gpu))
    os.system("mv MGG_{0}GPU_GIN.log logs/".format(gpu))