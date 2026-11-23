#!/bin/python

import subprocess

program_file_name = "test.asm"
code_file_name = "text.hex"
data_file_name = "data.hex"
memory_file_name = "memory.hex"

subprocess.run(["flatpak", "run", "io.github.TheThirdOne.rars", "a", "nc", "dump", ".text", "HexText", code_file_name, program_file_name])

text = []

with open(code_file_name, "r") as f:
    text = f.readlines()

data = []

with open(data_file_name, "r") as f:
    data = f.readlines()

memory = []

for i in range(0x40):
    try:
        memory.append(text[i])
    except:
        memory.append("00000000\n")

for i in range(0x40, 0x80):
    try:
        memory.append(data[i - 0x40])
    except:
        memory.append("00000000\n")

with open(memory_file_name, "w") as f:
    f.writelines(memory)


