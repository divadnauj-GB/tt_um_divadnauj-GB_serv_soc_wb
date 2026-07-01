#!/usr/bin/env python3

import re
import sys

if len(sys.argv) > 5:
    print(f"Usage: {sys.argv[0]} input.log output.log")
    sys.exit(1)

with open(sys.argv[1], "r") as fin, open(sys.argv[2], "w") as fout:
    inputfile=fin.readlines()
    init=sys.argv[3]
    end=sys.argv[4]
    if len(sys.argv) >5:
        num=int(sys.argv[5])
    flag1=False
    flag2=True
    cont=0
    for line in inputfile:
        if init in line:
            flag1=True
        if end in line:
            flag2=False
        if flag1 and flag2:
            fout.write(line)
    