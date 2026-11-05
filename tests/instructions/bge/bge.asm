addi t0, zero, 1
addi t1, zero, 2
bge t1, t0, l1
sw t0, 0 # should not happen
l1:
sw t1, 4
bge t0, t1, l2
sw t0, 8 # should happen
l2:
sw t1, 12
ecall
