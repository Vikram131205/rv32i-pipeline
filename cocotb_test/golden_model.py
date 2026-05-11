"""
Simple RV32I Golden Model — Executes instructions in-order.
Used to generate expected register/memory state for pipeline verification.
"""

def mask32(v):
    return v & 0xFFFFFFFF

def signed32(v):
    v = mask32(v)
    return v - 0x100000000 if v >= 0x80000000 else v

def sign_ext(val, bits):
    """Sign-extend a `bits`-wide value to 32 bits."""
    if val & (1 << (bits - 1)):
        val |= mask32(~((1 << bits) - 1))
    return mask32(val)


class RV32I:
    """Minimal RV32I architectural simulator (no pipeline, just ISA semantics)."""

    def __init__(self):
        self.regs = [0] * 32
        self.dmem = {}          # word_addr -> 32-bit value

    def run(self, program):
        """Execute a list of 32-bit instructions sequentially."""
        for inst in program:
            self._exec(inst)

    # ── private ──────────────────────────────────────────────
    def _exec(self, inst):
        op  = inst & 0x7F
        rd  = (inst >> 7) & 0x1F
        f3  = (inst >> 12) & 0x7
        rs1 = (inst >> 15) & 0x1F
        rs2 = (inst >> 20) & 0x1F
        f7  = (inst >> 25) & 0x7F

        a = self.regs[rs1]
        b = self.regs[rs2]

        imm_i = sign_ext(inst >> 20, 12)
        imm_s = sign_ext(((inst >> 25) << 5) | ((inst >> 7) & 0x1F), 12)

        result = 0

        if op == 0x33:                          # R-type
            if   f3 == 0 and f7 == 0x20: result = mask32(a - b)
            elif f3 == 0:                result = mask32(a + b)
            elif f3 == 1:                result = mask32(a << (b & 0x1F))
            elif f3 == 2:                result = int(signed32(a) < signed32(b))
            elif f3 == 3:                result = int(a < b)
            elif f3 == 4:                result = mask32(a ^ b)
            elif f3 == 5 and f7 == 0x20: result = mask32(signed32(a) >> (b & 0x1F))
            elif f3 == 5:                result = a >> (b & 0x1F)
            elif f3 == 6:                result = mask32(a | b)
            elif f3 == 7:                result = mask32(a & b)
            if rd: self.regs[rd] = result

        elif op == 0x13:                        # I-type ALU
            shamt = imm_i & 0x1F
            if   f3 == 0: result = mask32(a + imm_i)
            elif f3 == 1: result = mask32(a << shamt)
            elif f3 == 2: result = int(signed32(a) < signed32(imm_i))
            elif f3 == 3: result = int(a < imm_i)
            elif f3 == 4: result = mask32(a ^ imm_i)
            elif f3 == 5 and f7 == 0x20: result = mask32(signed32(a) >> shamt)
            elif f3 == 5: result = a >> shamt
            elif f3 == 6: result = mask32(a | imm_i)
            elif f3 == 7: result = mask32(a & imm_i)
            if rd: self.regs[rd] = result

        elif op == 0x03 and f3 == 2:            # LW
            addr = mask32(a + imm_i)
            word_addr = (addr >> 2) & 0xFF
            if rd: self.regs[rd] = self.dmem.get(word_addr, 0)

        elif op == 0x23 and f3 == 2:            # SW
            addr = mask32(a + imm_s)
            word_addr = (addr >> 2) & 0xFF
            self.dmem[word_addr] = b
