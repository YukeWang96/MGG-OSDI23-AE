#!/usr/bin/env python3
import os
# os.system("mv *.csv csvs/")
os.system("mv *.err logs/")
os.system("mv *.log logs/")
num_gpus = [8]

for gpu in num_gpus:
    os.system("./bench_UVM.py {0}| tee UVM_GCN_{0}GPU.log 2>UVM_GCN_{0}GPU.err".format(gpu))
    os.system("./analysis_UVM.py UVM_GCN_{0}GPU.log {0}".format(gpu))
    os.system("mv UVM_GCN_{0}GPU.log logs/".format(gpu))