#!/usr/bin/env python3

import re
import sys

if len(sys.argv) != 3:
    print(f"Usage: {sys.argv[0]} input.log output.log")
    sys.exit(1)

with open(sys.argv[1], "r") as fin, open(sys.argv[2], "w") as fout:
    skip_until_next_inst = False

    for line in fin:

        # Collapse any "(spike) ..." annotation block into a single ';'
        if line.startswith("(spike)"):
            if not skip_until_next_inst:
                fout.write(";\n")
                skip_until_next_inst = True
            continue

        # Skip the following "core ..." disassembly line after "(spike) >>>>"
        if skip_until_next_inst and line.startswith("core"):
            continue

        skip_until_next_inst = False

        # Replace ONLY lines that begin with clk=
        if line.startswith("clk="):
            line = re.sub(
                r"^clk=[0-9A-Fa-f]+",
                "clk=0000000000000000",
                line,
            )

        fout.write(line)