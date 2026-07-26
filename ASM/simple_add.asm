# simple_add.s
.text
.globl main

main:
    addi x5, x0, 10      # x5 = 10
    addi x6, x0, 20      # x6 = 20
    add  x7, x5, x6      # x7 = x5 + x6 = 30
    sw   x7, 0(x0)       # store result at address 0
    beq  x0, x0, main    # infinite loop (halt)