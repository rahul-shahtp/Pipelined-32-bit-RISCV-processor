# test_lui_auipc.s -- LUI / AUIPC
# Assumes this program is loaded starting at address 0x0 (adjust the
# expected AUIPC values below if your instr_mem base differs).
#
# Expected final register state:
#   x1 = 0x12345000            lui
#   x2 = 0xfffff000            lui
#   x3 = 0x00000008             auipc x3,0   at addr 0x08 -> 0x08+0
#   x4 = 0x00001010             auipc x4,1   at addr 0x10 -> 0x10+0x1000
.text
.globl _start
_start:
    lui   x1, 0x12345      # 0x00
    lui   x2, 0xFFFFF      # 0x04
    auipc x3, 0            # 0x08
    nop                    # 0x0c
    auipc x4, 0x1          # 0x10
    ebreak                 # 0x14