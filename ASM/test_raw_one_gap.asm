# test_raw_one_gap.s -- RAW hazard with one independent instruction between
# producer and consumer (exercises the MEM/WB -> EX forward path rather
# than the immediate EX/MEM -> EX path).
#
# Expected final register state:
#   x2  = 0x0000000a (10)   producer: 5+5
#   x3  = 0x00000014 (20)   consumer, 1-instr gap: 10+10
#   x5  = 0xfffffffe (-2)   producer: 3-5
#   x6  = 0xfffffffc (-4)   consumer, 1-instr gap: -2+-2
#   x8  = 0x00000005 (5)    producer: 7&5
#   x10 = 0x00000005 (5)    consumer, 1-instr gap: 5|5
.text
.globl _start
_start:
    addi x1, x0, 5
    add  x2, x1, x1      # producer
    addi x9, x0, 1        # filler (independent)
    add  x3, x2, x2         # consumer, one instruction gap from producer

    addi x4, x0, 3
    sub  x5, x4, x1       # producer
    addi x9, x9, 1         # filler
    add  x6, x5, x5          # consumer, one instruction gap

    addi x7, x0, 7
    and  x8, x7, x1       # producer
    addi x9, x9, 1         # filler
    or   x10, x8, x1         # consumer, one instruction gap

    ebreak