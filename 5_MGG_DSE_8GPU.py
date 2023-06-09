#!/usr/bin/env python3
import os
os.system("mv *.csv csvs/")
os.system("mv *.log logs/")

num_gpus = 8
for dist in [1,2,4,8,16]:
    for ps in [1,2,4,8,16,32]:
        os.system("./bench_MGG_DSE_dist_ps.py {0} {1} {2}| tee MGG_dist_{0}_ps_{1}.log".format(dist, ps, num_gpus))
        os.system("./analysis_MGG.py MGG_dist_{0}_ps_{1}.log {2}".format(dist, ps, num_gpus))
        os.system("mv MGG_dist_{0}_ps_{1}.log logs/".format(dist, ps))
os.system("./extract_search_dist_ps.py 6 > Reddit_8xA100_dist_ps.csv")

for dist in [1,2,4,8,16]:
    for wpb in [1,2,4,8,16]:
        os.system("./bench_MGG_DSE_dist_wpb.py {0} {1} {2}| tee MGG_dist_{0}_wpb_{1}.log".format(dist, wpb, num_gpus))
        os.system("./analysis_MGG.py MGG_dist_{0}_wpb_{1}.log {2}".format(dist, wpb, num_gpus))
        os.system("mv MGG_dist_{0}_wpb_{1}.log logs/".format(dist, wpb))
os.system("./extract_search_dist_wpb.py 5 > Reddit_8xA100_dist_wpb.csv")

os.system("mv MGG_dist_*.csv csvs/")