# test_raw_back2back.s -- RAW hazard, every instruction depends on the
# result of the one immediately before it (tightest forwarding case,
# EX/MEM -> EX forward). No stalls should be needed if forwarding works.
#
# Expected final register state:
#   x2 = 0x0000000a (10)   5+5
#   x3 = 0x00000014 (20)   10+10
#   x4 = 0x0000000a (10)   20-10
#   x5 = 0x0000001e (30)   10+20
#   x6 = 0x00000014 (20)   30^10
.text
.globl _start
_start:
    addi x1, x0, 5
    add  x2, x1, x1     # depends on x1 (prev instr)
    add  x3, x2, x2     # depends on x2 (prev instr)
    sub  x4, x3, x2     # depends on x3 (prev instr)
    add  x5, x4, x3     # depends on x4 (prev instr)
    xor  x6, x5, x4     # depends on x5 (prev instr)
    ebreak