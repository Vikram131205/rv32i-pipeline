"""
Random instruction generator for RV32I pipeline verification.
Generates a program, runs it through the golden model,
writes the hex file, and produces expected results.
"""
import random
from golden_model import RV32I, mask32

# ── Encoders ─────────────────────────────────────────────────
def enc_r(f7, rs2, rs1, f3, rd):
    return (f7<<25)|(rs2<<20)|(rs1<<15)|(f3<<12)|(rd<<7)|0x33

def enc_i(imm, rs1, f3, rd, op=0x13):
    return ((imm&0xFFF)<<20)|(rs1<<15)|(f3<<12)|(rd<<7)|op

def enc_s(imm, rs2, rs1, f3=2):
    return (((imm>>5)&0x7F)<<25)|(rs2<<20)|(rs1<<15)|(f3<<12)|((imm&0x1F)<<7)|0x23

NOP = 0x00000013

# ── R-type operations table: (funct3, funct7, name) ─────────
R_OPS = [
    (0, 0x00, "add"), (0, 0x20, "sub"),
    (1, 0x00, "sll"), (2, 0x00, "slt"), (3, 0x00, "sltu"),
    (4, 0x00, "xor"), (5, 0x00, "srl"), (5, 0x20, "sra"),
    (6, 0x00, "or"),  (7, 0x00, "and"),
]

# ── I-type operations table: (funct3, funct7_or_None, name) ─
I_OPS = [
    (0, None, "addi"), (4, None, "xori"), (6, None, "ori"), (7, None, "andi"),
    (1, 0x00, "slli"), (5, 0x00, "srli"), (5, 0x20, "srai"),
    (2, None, "slti"), (3, None, "sltiu"),
]


def generate_program(seed=42, n_alu=20, n_mem=6):
    """
    Generate a random RV32I test program.
    Returns: (list_of_instructions, golden_model_instance)
    """
    rng = random.Random(seed)
    prog = []
    log  = []

    # Phase 1: Initialize registers x1-x8 with known values
    init_vals = [rng.randint(1, 100) for _ in range(8)]
    for i, v in enumerate(init_vals, start=1):
        prog.append(enc_i(v, 0, 0, i))            # addi xi, x0, v
        log.append(f"addi x{i}, x0, {v}")

    # Also init a negative value in x9
    prog.append(enc_i((-5) & 0xFFF, 0, 0, 9))     # addi x9, x0, -5
    log.append("addi x9, x0, -5")

    src_regs = list(range(1, 10))  # x1 .. x9 available as sources
    next_rd  = 10                  # x10 onwards for results

    # Phase 2: Random ALU instructions
    for _ in range(n_alu):
        rd = next_rd
        next_rd += 1
        if next_rd > 28: next_rd = 10  # wrap around (keep x29-x31 free)

        if rng.random() < 0.5:
            # R-type
            f3, f7, name = rng.choice(R_OPS)
            rs1 = rng.choice(src_regs)
            rs2 = rng.choice(src_regs)
            # For shifts, keep rs2 small to avoid masking confusion
            prog.append(enc_r(f7, rs2, rs1, f3, rd))
            log.append(f"{name} x{rd}, x{rs1}, x{rs2}")
        else:
            # I-type
            f3, f7, name = rng.choice(I_OPS)
            rs1 = rng.choice(src_regs)
            if f7 is not None:
                # shift: shamt 0-31
                shamt = rng.randint(0, 15)
                imm = (f7 << 5) | shamt
            else:
                imm = rng.randint(-50, 50) & 0xFFF
            prog.append(enc_i(imm, rs1, f3, rd))
            log.append(f"{name} x{rd}, x{rs1}, {imm}")

        src_regs.append(rd)  # result can be used as source

    # Phase 3: Store some values to memory, then load them back
    for i in range(0, n_mem, 2):
        src = rng.choice(src_regs)
        offset = i * 4       # word-aligned addresses: 0, 8, 16, ...
        prog.append(enc_s(offset, src, 0))                  # sw src, offset(x0)
        log.append(f"sw x{src}, {offset}(x0)")

        # Insert a NOP to avoid load-use stall (keep it simple)
        prog.append(NOP)
        log.append("nop")

        ld_rd = next_rd; next_rd += 1
        if next_rd > 28: next_rd = 10
        prog.append(enc_i(offset, 0, 2, ld_rd, 0x03))      # lw ld_rd, offset(x0)
        log.append(f"lw x{ld_rd}, {offset}(x0)")

    # Phase 4: One explicit load-use hazard test (no NOP between)
    prog.append(enc_s(24, src_regs[0], 0))     # sw x?, 24(x0)
    log.append(f"sw x{src_regs[0]}, 24(x0)")
    prog.append(enc_i(24, 0, 2, 29, 0x03))    # lw x29, 24(x0)
    log.append("lw x29, 24(x0)")
    prog.append(enc_r(0, 29, src_regs[1], 0, 30))  # add x30, x?, x29  [HAZARD]
    log.append(f"add x30, x{src_regs[1]}, x29  [LOAD-USE HAZARD]")

    # Drain pipeline with NOPs
    for _ in range(8):
        prog.append(NOP)

    # Run golden model
    model = RV32I()
    model.run(prog)

    return prog, model, log


def write_hex(program, path):
    with open(path, 'w') as f:
        for inst in program:
            f.write(f"{inst:08X}\n")


if __name__ == "__main__":
    import argparse, json, os

    parser = argparse.ArgumentParser(description="Generate RV32I test program")
    parser.add_argument("--seed",   type=int, default=42)
    parser.add_argument("--outdir", type=str, default="sim_build")
    args = parser.parse_args()

    prog, model, log = generate_program(seed=args.seed)
    os.makedirs(args.outdir, exist_ok=True)

    # Write instruction hex
    write_hex(prog, os.path.join(args.outdir, "rv32i_real.hex"))

    # Write register init (all zeros)
    with open(os.path.join(args.outdir, "register_file_counting.hex"), "w") as f:
        for _ in range(32): f.write("00000000\n")

    # Write data memory init (all zeros)
    with open(os.path.join(args.outdir, "data_mem_file.hex"), "w") as f:
        for _ in range(32): f.write("00000000\n")

    # Write expected results (golden model state)
    expected = {
        "regs": {str(i): model.regs[i] for i in range(32)},
        "dmem": {str(k): v for k, v in model.dmem.items()},
    }
    with open(os.path.join(args.outdir, "expected.json"), "w") as f:
        json.dump(expected, f, indent=2)

    # Write xvlog project file (for Vivado xsim)
    rtl_dir = os.path.abspath(os.path.join(os.path.dirname(__file__), "..", "pp", "pp.srcs", "sources_1", "new"))
    tb_file = os.path.abspath(os.path.join(os.path.dirname(__file__), "tb_golden.v"))
    rtl_files = [
        "ALU.v", "alu_four.v", "alu_pc.v", "bj_det.v", "controlpath.v",
        "data_mem.v", "extender_offsethandler.v", "hazard_unit.v", "instruction.v",
        "mux_32.v", "mux_32_3in.v", "pc_.v", "pp_stage_2.v", "pp_stage_3.v",
        "pp_stage_4.v", "pp_stage_5.v", "reg_file_.v", "top_module.v",
    ]
    with open(os.path.join(args.outdir, "compile.prj"), "w") as f:
        f.write("verilog xil_defaultlib \\\n")
        for rf in rtl_files:
            f.write(f'"{os.path.join(rtl_dir, rf)}" \\\n')
        f.write(f'"{tb_file}" \\\n')
        f.write("\nnosort\n")

    # Print summary
    print(f"Generated {len(prog)} instructions (seed={args.seed})")
    for i, (inst, desc) in enumerate(zip(prog, log)):
        print(f"  0x{i*4:02X}: {inst:08X}  {desc}")
    print(f"Files written to {args.outdir}/")
