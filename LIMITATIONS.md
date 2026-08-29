# Known Limitations

This document lists known limitations of the RV32IM pipelined processor.

## Timing

- Clock target is 10 ns (100 MHz) but WNS is -2.29 ns at TT, 25C, 1.8V
- Critical path is in the ID stage (branch resolution + register file read + next PC mux)
- Not optimized for physical tapeout — designed for RTL simulation and ASIC flow exploration

## Physical Implementation

- LVS does not currently pass due to DEF-to-GDS conversion requiring proper LEF layer mapping
- DRC clean (0 violations) but LVS netlists do not match
- No GDS output from OpenROAD flow (only DEF and SPICE extracted netlist)

## Pipeline

- Branch resolution happens in ID stage, creating a long combinational path
- Only 1-cycle branch penalty — mispredicted instructions in IF and ID are flushed
- No branch prediction (always predicts not-taken)

## Multiply/Divide

- M-extension uses iterative shift-and-add algorithm (32 cycles latency)
- Not pipelined — stalls entire pipeline while computing
- No early-out optimization for small operands

## Memory

- No instruction cache — direct ROM access
- No data cache — direct SRAM access
- Data memory is 4 KB (4 x 1 KB SRAM macros)
- Instruction memory is 4 KB (1024 x 32-bit words)

## ISA Coverage

- Implements RV32I base integer instruction set
- Implements M-extension (MUL, MULH, MULHSU, MULHU, DIV, DIVU, REM, REMU)
- Does not implement: F/D extensions (floating point), C extension (compressed instructions), A extension (atomics), privilege modes, interrupts, CSR instructions

## Verification

- Testbench uses Icarus Verilog with SystemVerilog assertions
- 16 regression tests covering R-type, I-type, load/store, branch, jump, multiply, divide
- No formal verification
- No coverage metrics collected

## Other

- No debug interface (JTAG)
- No interrupt controller
- No power management (clock gating)
- No scan chain for testability
- Single-clock domain only
