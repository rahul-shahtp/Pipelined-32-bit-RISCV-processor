# test_jal_jalr.s -- JAL (with and without link), JALR return, and
# flush verification
#
# Expected final x10 = 0x00000457 (1111)
.text
.globl _start
_start:
    addi x10, x0, 0

    jal  x0, SKIP        # unconditional jump, link discarded
    addi x10, x10, 999     # dead code -- must be flushed, never executed
SKIP:
    addi x10, x10, 1        # x10 = 1

    jal  x1, FUNC             # "call": jump to FUNC, save return addr in x1
    addi x10, x10, 10           # executes only after JALR returns here
    j    END
FUNC:
    addi x10, x10, 100            # x10 += 100 (inside "function")
    jalr x0, x1, 0                  # return to caller via saved link address

END:
    addi x10, x10, 1000                # final marker
    ebreak
    