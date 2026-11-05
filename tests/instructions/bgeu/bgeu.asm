lw t0, 0
lw t1, 4
bgeu t1, t0, after
addi a0, zero, 1
after:
addi a0, zero, 2
sw a0, 8
ecall
