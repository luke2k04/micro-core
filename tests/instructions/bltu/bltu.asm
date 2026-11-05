lw t0, 0
lw t1, 4
bltu t0, t1, after
addi a0, zero, 1
after:
addi a0, zero, 2
sw a0, 8
ecall
