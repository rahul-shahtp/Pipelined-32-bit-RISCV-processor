# Pipelined 32-bit RISC-V (RV32IM) Processor

[![Verilog](https://img.shields.io/badge/Verilog-HDL-blue.svg)](https://www.ieee.org/standards/ieee-1364.html)
[![Sky130](https://img.shields.io/badge/PDK-Sky130A-green.svg)](https://github.com/google/skywater-pdk)
[![Yosys](https://img.shields.io/badge/Synthesis-Yosys-orange.svg)](https://github.com/YosysHQ/yosys)
[![OpenROAD](https://img.shields.io/badge/P%26R-OpenROAD-red.svg)](https://github.com/The-OpenROAD-Project/OpenROAD)
[![License](https://img.shields.io/badge/License-MIT-yellow.svg)](LICENSE)

A complete RTL-to-GDS implementation of a **5-stage pipelined RV32IM core** (RV32I base ISA + M-extension for integer multiplication/division) in Verilog, verified with SystemVerilog testbenches and taken through full physical implementation using the open-source Sky130 PDK.

---

## 📐 Architecture

### Pipeline Stages
| Stage | Function | Key Modules |
|-------|----------|-------------|
| **IF** | Instruction Fetch | `pc_reg`, `pc_adder`, `instr_mem`, `if_to_id_reg` |
| **ID** | Decode / Register Read / Hazard Detection | `control_unit`, `register_file`, `imm_gen`, `branch_unit`, `hazard_detection_unit`, `id_to_ex_reg` |
| **EX** | Execute / ALU / Forwarding | `alu`, `alu_control`, `forwarding_unit`, `mul_div_unit`, `ex_to_mem_reg` |
| **MEM** | Memory Access | `data_memory` (4× SRAM macros), `mem_to_wb_reg` |
| **WB** | Writeback | `wb_mux` |

### Key Microarchitectural Features
- **5-stage pipeline** with full bypass/forwarding (ALU operand A & B)
- **Hazard Detection Unit** — load-use stalls (1-cycle bubble)
- **Branch Unit** — early branch resolution in ID; control flush on mispredict
- **M-Extension** — iterative multiplier/divider (`mul_div_unit`) with `mul`, `mulh`, `mulhu`, `div`, `divu`, `rem`, `remu`
- **Byte/Halfword/Word Load-Store** — `LB/LH/LBU/LHU/SB/SH/SW` with sign/zero extension
- **JAL/JALR** — link register support with PC+4 writeback
- **SRAM Integration** — 4× `sky130_sram_1kbyte_1rw1r_8x1024_8` macros (4 KB total, 1 per byte lane)

---

## 🛠 Tools Used

| Category | Tools |
|----------|-------|
| **Simulation** | Icarus Verilog, GTKWave |
| **Synthesis** | Yosys (Sky130 standard cells) |
| **Physical Implementation** | OpenROAD (floorplan → placement → CTS → routing) |
| **PDK** | Sky130A (sky130_fd_sc_hd + sky130_sram_macros) |
| **Sign-off / View** | Magic, KLayout |

---

## ✅ Verification

SystemVerilog testbench (`tb/rv32im_top_tb.sv`) with **16/16 regression tests passing**:

| Test | Coverage |
|------|----------|
| `test_rtype` | ADD, SUB, AND, OR, XOR, SLT, SLTU, SLL, SRL, SRA |
| `test_itype` | ADDI, ANDI, ORI, XORI, SLTI, SLTIU, SLLI, SRLI, SRAI |
| `test_loadstore` | LB, LH, LBU, LHU, SB, SH, SW |
| `test_branch_taken_nottaken` | BEQ, BNE, BLT, BGE, BLTU, BGEU |
| `test_branch_after_alu` | Branch immediately after ALU op (forwarding) |
| `test_load_use` | Load-use stall (1-cycle bubble) |
| `test_raw_back2back` | Back-to-back RAW hazards |
| `test_raw_one_gap` | RAW with one instruction gap |
| `test_jal_jalr` | JAL, JALR with link register |
| `test_lui_auipc` | LUI, AUIPC |
| `test_mul` | MUL, MULH, MULHU |
| `test_div` | DIV, DIVU, REM, REMU (edge cases: div by 0, overflow) |
| `test_x0_writeignore` | x0 hardwired to zero |
| `test_factorial` | Recursive factorial (stress) |
| `test_fibonacci` | Iterative Fibonacci (stress) |
| `test_stress_mixed` | Mixed instruction stream |

Run locally:
```bash
iverilog -g2012 -o sim.out tb/rv32im_top_tb.sv rtl/**/*.v
vvp sim.out
gtkwave dump.vcd
```

---

## 🏗 Physical Implementation

**Flow**: `flow.tcl` (OpenROAD) — synthesis → floorplan → placement → CTS → routing

```bash
# Synthesis (Yosys)
yosys synth_out/sky130_synth.ys

# PnR (OpenROAD)
openroad -no_init -exit flow.tcl
```

### Results

| Metric | Value |
|--------|-------|
| **Die Area** | 1.5 mm² (1250 × 1200 µm) |
| **Core Utilization** | 62% |
| **Total Instances** | 18,759 (incl. 4 SRAM macros, 8,160 tapcells, 866 endcaps, 290 CTS buffers) |
| **Total Wirelength** | 457k µm |
| **Metal Usage** | met1: 172k, met2: 199k, met3: 50k, met4: 35k, met5: 0.9k µm |
| **Clock Period** | 10 ns (100 MHz target) |
| **WNS (TT, 25°C, 1.8V)** | −2.29 ns |
| **TNS** | −12.6 ns |
| **DRC Violations** | 0 |
| **LVS** | Not yet run |

> ⚠️ **Timing**: Negative WNS indicates setup violations at 100 MHz. Further optimization (retiming, larger clock period, or cell upsizing) needed for closure.

---

## 📁 Repository Structure

```
├── ASM/                    # Assembly test programs (.asm)
├── hex/                    # Pre-compiled hex files for simulation
├── rtl/
│   ├── if_stage/           # IF pipeline stage
│   ├── id_stage/           # ID pipeline stage
│   ├── ex_stage/           # EX pipeline stage (ALU, MUL/DIV, forwarding)
│   ├── mem_stage/          # MEM pipeline stage (SRAM, data memory)
│   ├── wb_stage/           # WB pipeline stage
│   └── top/                # Top-level integration (rv32im_top.v, rv32im_asic.v)
├── tb/
│   └── rv32im_top_tb.sv    # SystemVerilog testbench (16 tests)
├── synth/
│   └── sky130_synth.ys     # Yosys synthesis script
├── flow.tcl                # OpenROAD PnR flow script
├── docs/
    ├── design/             # Design documentation
    ├── Klayout_view/       # Layout screenshots
    └── waveforms/          # Simulation waveforms
```

---

## 🚀 How to Run

### Prerequisites
- Icarus Verilog (`iverilog`)
- GTKWave (`gtkwave`)
- Yosys + Sky130 PDK
- OpenROAD + Sky130 PDK
- Magic / KLayout (layout viewing)

### Simulation
```bash
# Compile & run all tests
iverilog -g2012 -o sim.out tb/rv32im_top_tb.sv rtl/**/*.v
vvp sim.out

# View waveforms
gtkwave dump.vcd
```

### Synthesis (Yosys)
```bash
cd synth
yosys sky130_synth.ys
# Outputs: synth_out/rv32im_asic_sky130.v, rv32im_asic.sdc
```

### Physical Implementation (OpenROAD)
```bash
export PDK_ROOT=/path/to/pdk
openroad -no_init -exit flow.tcl
# Outputs in results/: .def, _route.v, .sdc, .db, timing/area/power reports
```

---

## 🔮 Future Work
- **AI Accelerator Extension** — integrate a systolic-array MAC coprocessor for matrix multiply, connected via memory-mapped I/O to the RV32IM core

---

## 📄 License

MIT License — see [LICENSE](LICENSE) for details.