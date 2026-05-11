@echo off
REM ============================================================
REM  run.bat — Golden Model vs RTL Verification
REM  Usage:  run.bat [seed] [iverilog|xsim]
REM ============================================================
setlocal

set SEED=%1
if "%SEED%"=="" set SEED=42

set SIM=%2
if "%SIM%"=="" set SIM=xsim

set BUILD=sim_build

echo ============================================================
echo   RV32I Golden Model vs RTL  seed=%SEED%  sim=%SIM%
echo ============================================================
echo.

REM ── Step 1: Generate ────────────────────────────────────────
echo [1/3] Generating random program...
python gen_test.py --seed %SEED% --outdir %BUILD%
if errorlevel 1 ( echo GENERATION FAILED & exit /b 1 )
echo.

REM ── Step 2: Simulate ────────────────────────────────────────
if "%SIM%"=="iverilog" (
    echo [2/3] Simulating with Icarus Verilog...
    cd %BUILD%
    iverilog -g2012 -o tb_sim.vvp -s tb_golden -I . ^
        ..\tb_golden.v ^
        "..\..\pp\pp.srcs\sources_1\new\ALU.v" ^
        "..\..\pp\pp.srcs\sources_1\new\alu_four.v" ^
        "..\..\pp\pp.srcs\sources_1\new\alu_pc.v" ^
        "..\..\pp\pp.srcs\sources_1\new\bj_det.v" ^
        "..\..\pp\pp.srcs\sources_1\new\controlpath.v" ^
        "..\..\pp\pp.srcs\sources_1\new\data_mem.v" ^
        "..\..\pp\pp.srcs\sources_1\new\extender_offsethandler.v" ^
        "..\..\pp\pp.srcs\sources_1\new\hazard_unit.v" ^
        "..\..\pp\pp.srcs\sources_1\new\instruction.v" ^
        "..\..\pp\pp.srcs\sources_1\new\mux_32.v" ^
        "..\..\pp\pp.srcs\sources_1\new\mux_32_3in.v" ^
        "..\..\pp\pp.srcs\sources_1\new\pc_.v" ^
        "..\..\pp\pp.srcs\sources_1\new\pp_stage_2.v" ^
        "..\..\pp\pp.srcs\sources_1\new\pp_stage_3.v" ^
        "..\..\pp\pp.srcs\sources_1\new\pp_stage_4.v" ^
        "..\..\pp\pp.srcs\sources_1\new\pp_stage_5.v" ^
        "..\..\pp\pp.srcs\sources_1\new\reg_file_.v" ^
        "..\..\pp\pp.srcs\sources_1\new\top_module.v"
    if errorlevel 1 ( echo COMPILE FAILED & cd .. & exit /b 1 )
    vvp tb_sim.vvp
    cd ..
) else (
    echo [2/3] Simulating with Vivado xsim...
    set "PATH=D:\Vivado\2024.2\bin;%PATH%"
    cd %BUILD%
    call xvlog --incr --relax -prj compile.prj -log xvlog.log >nul 2>&1
    if errorlevel 1 ( echo COMPILE FAILED & type xvlog.log & cd .. & exit /b 1 )
    call xelab --incr --debug typical --relax --mt 2 -L xil_defaultlib --snapshot tb_golden_snap xil_defaultlib.tb_golden -log elaborate.log >nul 2>&1
    if errorlevel 1 ( echo ELABORATE FAILED & cd .. & exit /b 1 )
    call xsim tb_golden_snap --runall -log simulate.log >nul 2>&1
    cd ..
)

echo       Simulation complete.
echo.

REM ── Step 3: Compare ─────────────────────────────────────────
echo [3/3] Comparing RTL vs Golden Model...
python compare.py --build %BUILD% --seed %SEED%

endlocal
