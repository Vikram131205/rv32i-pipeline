# ============================================================
#  RV32I Pipeline — Golden Model Verification
# ============================================================
#  Usage (run from WSL):
#    make                — generate, compile, simulate, compare
#    make SEED=123       — use a different random seed
#    make clean          — remove build artifacts
# ============================================================

SEED   ?= 42
BUILD  = sim_build
RTL    = ../pp/pp.srcs/sources_1/new
TB     = tb_golden.v

SRCS   = $(wildcard $(RTL)/*.v) $(TB)

.PHONY: all generate compile simulate compare clean

all: generate compile simulate compare

generate:
	@echo "[1/4] Generating random program (seed=$(SEED))..."
	@mkdir -p $(BUILD)
	@python3 gen_test.py --seed $(SEED) --outdir $(BUILD)

compile: generate
	@echo "[2/4] Compiling with Icarus Verilog..."
	@cd $(BUILD) && iverilog -g2012 -o tb_sim.vvp -s tb_golden $(addprefix ../,$(SRCS))

simulate: compile
	@echo "[3/4] Running simulation..."
	@cd $(BUILD) && vvp tb_sim.vvp

compare: simulate
	@echo "[4/4] Comparing RTL vs Golden Model..."
	@python3 compare.py --build $(BUILD) --seed $(SEED)

clean:
	rm -rf $(BUILD)
