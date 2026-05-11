"""
compare.py — Compare RTL dump against golden model expected results.
Usage: python compare.py --build sim_build --seed 42
"""
import json, argparse, os


def main():
    parser = argparse.ArgumentParser()
    parser.add_argument("--build", default="sim_build")
    parser.add_argument("--seed",  type=int, default=42)
    args = parser.parse_args()

    # Load golden model expected state
    with open(os.path.join(args.build, "expected.json")) as f:
        expected = json.load(f)

    # Load RTL dump
    dump_path = os.path.join(args.build, "rtl_dump.txt")
    if not os.path.exists(dump_path):
        print("ERROR: rtl_dump.txt not found — simulation may have failed.")
        return

    rtl_regs, rtl_mem = {}, {}
    with open(dump_path) as f:
        for line in f:
            parts = line.strip().split()
            if len(parts) == 3:
                kind, idx, val = parts[0], int(parts[1]), int(parts[2])
                if val < 0: val = val & 0xFFFFFFFF
                if kind == "REG": rtl_regs[idx] = val & 0xFFFFFFFF
                elif kind == "MEM": rtl_mem[idx] = val & 0xFFFFFFFF

    # Compare
    print(f"{'='*55}")
    print(f"  Golden Model vs RTL  (seed={args.seed})")
    print(f"{'='*55}")

    passed, failed = 0, 0

    print("\n  --- Registers ---")
    for i in range(32):
        exp = expected["regs"][str(i)]
        act = rtl_regs.get(i, 0)
        if act == exp:
            if exp != 0: print(f"  PASS  x{i:2d} = 0x{act:08X}")
            passed += 1
        else:
            print(f"  FAIL  x{i:2d}  RTL=0x{act:08X}  Golden=0x{exp:08X}  ***")
            failed += 1

    print("\n  --- Data Memory ---")
    all_addrs = set(int(k) for k in expected["dmem"]) | set(a for a in rtl_mem if rtl_mem[a])
    for addr in sorted(all_addrs):
        exp = expected["dmem"].get(str(addr), 0)
        act = rtl_mem.get(addr, 0)
        if act == exp:
            print(f"  PASS  mem[{addr:2d}] = 0x{act:08X}")
            passed += 1
        else:
            print(f"  FAIL  mem[{addr:2d}]  RTL=0x{act:08X}  Golden=0x{exp:08X}  ***")
            failed += 1

    print(f"\n{'='*55}")
    print(f"  TOTAL: {passed} PASSED, {failed} FAILED")
    if failed == 0:
        print(f"  >>> ALL TESTS PASSED! <<<")
    else:
        print(f"  >>> SOME TESTS FAILED <<<")
    print(f"{'='*55}")


if __name__ == "__main__":
    main()
