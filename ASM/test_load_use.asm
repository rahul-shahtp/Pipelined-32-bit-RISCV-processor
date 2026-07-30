# test_load_use.s -- Load-use hazard: a load immediately followed by an
# instruction that consumes the loaded value
#
# Expected final register state:
#   x3 = 0x00001234           lw result
#   x4 = 0x00002468           add x3,x3 -- consumes load result immediately
#   x5 = 0x00001235           addi x3,1 -- second consumer, right after stall
.text
.globl _start
_start:
    addi x1, x0, 0x100      # scratch base address
    li   x2, 0x1234
    sw   x2, 0(x1)

    lw   x3, 0(x1)          # load
    add  x4, x3, x3         # immediate use -> load-use hazard, must stall
    addi x5, x3, 1          # second consumer, after the stall resolves

    ebreak