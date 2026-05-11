# RV32I 5-Stage Pipelined Processor

A fully functional **RISC-V RV32I** 5-stage pipelined processor implemented in Verilog, with complete hazard handling and a Python-based golden model verification framework.

## Architecture

```
┌──────┐   ┌──────┐   ┌──────┐   ┌──────┐   ┌──────┐
│  IF  │──▶│  ID  │──▶│  EX  │──▶│ MEM  │──▶│  WB  │
│Fetch │   │Decode│   │Execute│  │Memory│   │Write │
└──────┘   └──────┘   └──────┘   └──────┘   └──────┘
     ◀──── Forwarding Unit (EX-EX, MEM-EX) ────▶
     ◀──── Hazard Unit (Load-Use Stall) ────────▶
     ◀──── Branch Flush (IF/ID + ID/EX) ────────▶
```

### Supported Instructions

| Type | Instructions |
|------|-------------|
| **R-type** | ADD, SUB, SLL, SLT, SLTU, XOR, SRL, SRA, OR, AND |
| **I-type** | ADDI, SLTI, SLTIU, XORI, ORI, ANDI, SLLI, SRLI, SRAI |
| **Load**   | LW |
| **Store**  | SW |
| **Branch** | BEQ, BNE, BLT, BGE, BLTU, BGEU |

### Hazard Handling

- **Data Hazards (RAW):** Resolved via EX-EX and MEM-EX forwarding
- **Load-Use Hazards:** 1-cycle pipeline stall (PC hold + IF/ID hold + ID/EX bubble)
- **Control Hazards:** Pipeline flush of IF/ID and ID/EX registers on taken branches

## Project Structure

```
pp/
├── pp.srcs/sources_1/new/       # RTL source files
│   ├── top_module.v             # Top-level pipeline
│   ├── pc_.v                    # Program counter (with stall)
│   ├── instruction.v            # Instruction memory
│   ├── controlpath.v            # Control signal decoder
│   ├── reg_file_.v              # Register file (32x32)
│   ├── ALU.v                    # Arithmetic Logic Unit
│   ├── alu_pc.v                 # Branch target adder
│   ├── alu_four.v               # PC+4 adder
│   ├── data_mem.v               # Data memory
│   ├── hazard_unit.v            # Forwarding + stall logic
│   ├── bj_det.v                 # Branch/jump detector
│   ├── extender_offsethandler.v # Immediate sign extension
│   ├── mux_32.v                 # 2:1 mux
│   ├── mux_32_3in.v             # 3:1 mux (forwarding)
│   ├── pp_stage_2.v             # IF/ID pipeline register
│   ├── pp_stage_3.v             # ID/EX pipeline register
│   ├── pp_stage_4.v             # EX/MEM pipeline register
│   └── pp_stage_5.v             # MEM/WB pipeline register
│
├── pp.srcs/sim_1/new/
│   └── testbench.v              # Self-checking Vivado testbench
│
└── cocotb_test/                 # Golden model verification
    ├── Makefile                 # Just type 'make'
    ├── run.bat                  # Windows: run.bat [seed] [xsim|iverilog]
    ├── golden_model.py          # Python RV32I ISA simulator
    ├── gen_test.py              # Random instruction generator
    ├── tb_golden.v              # Minimal dump testbench
    └── compare.py               # RTL vs golden model comparison
```

## Verification

### Quick Start (WSL + Icarus Verilog)

```bash
cd cocotb_test
make                  # default seed=42
make SEED=123         # different random seed
make clean            # remove build artifacts
```

### Quick Start (Windows + Vivado)

```batch
cd cocotb_test
run.bat 42 xsim
```

### How It Works

1. **`gen_test.py`** generates random RV32I instructions and runs them through a Python golden model
2. **`iverilog`/`xsim`** compiles and simulates the RTL with the same instructions
3. **`compare.py`** checks every register and memory word against the golden model

### Test Results

Verified with multiple random seeds — **all tests pass**:

```
=======================================================
  Golden Model vs RTL  (seed=42)
=======================================================
  PASS  x 1 = 0x00000052
  PASS  x 2 = 0x0000000F
  ...
  TOTAL: 36 PASSED, 0 FAILED
  >>> ALL TESTS PASSED! <<<
=======================================================
```

## Tools Used

- **Vivado 2024.2** — Synthesis and xsim simulation
- **Icarus Verilog 13.0** — Open-source simulation (via WSL)
- **Python 3** — Golden model and verification scripts
