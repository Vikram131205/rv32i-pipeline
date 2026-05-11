`timescale 1ns / 1ps

module testbench#(parameter depth_reg = 32 , 
parameter d_width = 32)(
    );
reg reset;
reg clk;
wire [31:0] addr;
wire [31:0] next_addr;
wire [31:0] ins;
wire [31:0] four_pc;
wire RegWrite,MemWrite,Jump,Branch,ALUSrc;
wire [1:0] ResultSrc;
wire [2:0] imsrc;
wire [3:0] alucontrol;
wire w,hw,b;
wire [11:0] imm;
wire [6:0] opcode;
wire [2:0] funct3;
wire [6:0] funct7;
wire [$clog2(depth_reg)-1:0] rs_addr;
wire [$clog2(depth_reg)-1:0] rt_addr;
wire [$clog2(depth_reg)-1:0] rd_addr;
wire [d_width-1:0] write_data;
wire [d_width-1:0] r_data_1,r_data_2;
wire [24:0] ins_offset;
wire [31:0] offset;
wire [31:0] read_data_1,read_data_2;
wire [31:0] result;
wire zero,l_t_u,g_t_u,n_e,l_t_s,g_t_s;
wire [31:0] updated_pc;
wire bj;
wire [31:0] read_data;

wire   [31:0] next_addr_s2;
wire   [31:0] ins_s2;
wire   [31:0] four_pc_s2;
wire   RegWrite_s3,MemWrite_s3,Jump_s3,Branch_s3,ALUSrc_s3;
wire  [1:0] ResultSrc_s3;
wire  [3:0] alucontrol_s3;
wire  w_s3,hw_s3,b_s3;
wire  [31:0] r_data_1_s3,r_data_2_s3;
wire   [31:0] next_addr_s3; 
wire   [31:0] four_pc_s3;
wire  [31:0] offset_s3;
wire  RegWrite_s4,MemWrite_s4;
wire [1:0] ResultSrc_s4;
wire  [31:0] result_s4;
wire  [31:0] write_datamem_s4;
wire [31:0] four_pc_s4;
wire   RegWrite_s5;
wire  [1:0] ResultSrc_s5;
wire  [31:0] result_s5;
wire  [31:0] read_data_s5;
wire  [31:0] four_pc_s5;
wire [2:0] funct3_s3;
wire w_s4,hw_s4,b_s4;
wire flush;
wire [4:0] Rs1E, Rs2E, RdE;
wire [4:0] Rs1D, Rs2D, RdD;
wire [4:0] RdM, RdW;
wire [1:0] ForwardAE, ForwardBE;
wire [31:0] true1, true2;

initial clk = 0;
always #5 clk = ~clk;

top_module uut (
    .clk(clk),
    .reset(reset),
    .flush(flush),
    .addr(addr),
    .next_addr(next_addr),
    .ins(ins),
    .four_pc(four_pc),

    .RegWrite(RegWrite),
    .MemWrite(MemWrite),
    .Jump(Jump),
    .Branch(Branch),
    .ALUSrc(ALUSrc),

    .ResultSrc(ResultSrc),
    .imsrc(imsrc),
    .alucontrol(alucontrol),

    .w(w),
    .hw(hw),
    .b(b),

    .imm(imm),
    .opcode(opcode),
    .funct3(funct3),
    .funct7(funct7),

    .rs_addr(rs_addr),
    .rt_addr(rt_addr),
    .rd_addr(rd_addr),

    .write_data(write_data),
    .r_data_1(r_data_1),
    .r_data_2(r_data_2),

    .ins_offset(ins_offset),
    .offset(offset),

    .read_data_1(read_data_1),
    .read_data_2(read_data_2),

    .result(result),

    .zero(zero),
    .l_t_u(l_t_u),
    .g_t_u(g_t_u),
    .n_e(n_e),
    .l_t_s(l_t_s),
    .g_t_s(g_t_s),

    .updated_pc(updated_pc),
    .bj(bj),
    .read_data(read_data),

    
    .next_addr_s2(next_addr_s2),
    .ins_s2(ins_s2),
    .four_pc_s2(four_pc_s2),

    
    .RegWrite_s3(RegWrite_s3),
    .MemWrite_s3(MemWrite_s3),
    .Jump_s3(Jump_s3),
    .Branch_s3(Branch_s3),
    .ALUSrc_s3(ALUSrc_s3),

    .ResultSrc_s3(ResultSrc_s3),
    .alucontrol_s3(alucontrol_s3),

    .w_s3(w_s3),
    .hw_s3(hw_s3),
    .b_s3(b_s3),

    .r_data_1_s3(r_data_1_s3),
    .r_data_2_s3(r_data_2_s3),

    .next_addr_s3(next_addr_s3),
    .four_pc_s3(four_pc_s3),
    .offset_s3(offset_s3),
    .funct3_s3(funct3_s3),

    
    .RegWrite_s4(RegWrite_s4),
    .MemWrite_s4(MemWrite_s4),
    .ResultSrc_s4(ResultSrc_s4),

    .result_s4(result_s4),
    .write_datamem_s4(write_datamem_s4),
    .four_pc_s4(four_pc_s4),

    .w_s4(w_s4),
    .hw_s4(hw_s4),
    .b_s4(b_s4),

    
    .RegWrite_s5(RegWrite_s5),
    .ResultSrc_s5(ResultSrc_s5),

    .result_s5(result_s5),
    .read_data_s5(read_data_s5),
    .four_pc_s5(four_pc_s5),
    
    .Rs1E(Rs1E),
    .Rs2E(Rs2E),
    .RdE(RdE),
    .Rs1D(Rs1D),
    .Rs2D(Rs2D),
    .RdD(RdD),
    .RdM(RdM),
    .RdW(RdW),
    .ForwardAE(ForwardAE),
    .ForwardBE(ForwardBE),
    .true1(true1),
    .true2(true2)
);

// ============================================================
// Self-checking test
// ============================================================
integer pass_count, fail_count;

task check_reg;
    input [4:0] reg_num;
    input [31:0] expected;
    input [255:0] description;
    reg [31:0] actual;
    begin
        actual = uut.uut4.mem[reg_num];
        if (actual === expected) begin
            $display("  PASS: x%0d = 0x%08H (expected 0x%08H) %0s", reg_num, actual, expected, description);
            pass_count = pass_count + 1;
        end else begin
            $display("  FAIL: x%0d = 0x%08H (expected 0x%08H) %0s ***", reg_num, actual, expected, description);
            fail_count = fail_count + 1;
        end
    end
endtask

task check_dmem;
    input [31:0] word_addr;
    input [31:0] expected;
    input [255:0] description;
    reg [31:0] actual;
    begin
        actual = uut.uut11.mem[word_addr];
        if (actual === expected) begin
            $display("  PASS: dmem[%0d] = 0x%08H (expected 0x%08H) %0s", word_addr, actual, expected, description);
            pass_count = pass_count + 1;
        end else begin
            $display("  FAIL: dmem[%0d] = 0x%08H (expected 0x%08H) %0s ***", word_addr, actual, expected, description);
            fail_count = fail_count + 1;
        end
    end
endtask

// Wire for stall signal observation
wire stall_sig = uut.stall;

initial begin
    pass_count = 0;
    fail_count = 0;
    
    $display("===========================================================");
    $display("  RISC-V 5-Stage Pipeline - Load-Use Hazard Verification");
    $display("===========================================================");
    
    // Reset
    reset = 1; 
    #15;  // 1.5 clock cycles of reset
    reset = 0;
    
    // Monitor pipeline execution with stall signal
    $display("\n--- Pipeline Execution Trace ---");
    $display("Time   | PC      | Instruction | Flush | Stall | ForwardAE | ForwardBE");
    
    // Run for enough cycles (with stalls, need more cycles)
    repeat (60) begin
        @(posedge clk);
        $display("%0t | 0x%04H | 0x%08H | %b     | %b     | %b         | %b", 
                 $time, next_addr, ins_s2, flush, stall_sig, ForwardAE, ForwardBE);
    end
    
    // Wait a few more cycles for everything to settle
    repeat (5) @(posedge clk);
    
    // ============================================================
    //  REGISTER VERIFICATION
    // ============================================================
    $display("\n===========================================================");
    $display("  Register File Verification");
    $display("===========================================================");
    
    $display("\n--- Basic R/I-type Tests ---");
    check_reg(0,  32'h00000000, "hardwired zero");
    check_reg(1,  32'h00000005, "addi x1, x0, 5");
    check_reg(2,  32'h0000000A, "addi x2, x0, 10");
    check_reg(3,  32'h0000000F, "add x3, x1, x2 = 15");
    check_reg(4,  32'h00000005, "sub x4, x2, x1 = 5");
    
    $display("\n--- LOAD-USE HAZARD Test 1: lw x10 -> add x11=x10+x1 ---");
    check_reg(10, 32'h0000000F, "lw x10, 0(x0) = 15");
    check_reg(11, 32'h00000014, "add x11, x10, x1 = 20 [LOAD-USE on x10]");
    check_reg(12, 32'h0000001E, "add x12, x11, x2 = 30 [fwd from x11]");
    
    $display("\n--- LOAD-USE HAZARD Test 2: lw x13 -> sub x14=x12-x13 ---");
    check_reg(13, 32'h00000005, "lw x13, 4(x0) = 5");
    check_reg(14, 32'h00000019, "sub x14, x12, x13 = 25 [LOAD-USE on x13 rs2]");
    
    $display("\n--- LOAD-USE HAZARD Test 3: lw x15 -> sw x15 (store data) ---");
    check_reg(15, 32'h00000005, "lw x15, 8(x0) = 5");
    
    $display("\n--- LOAD no-hazard Test: lw x16, then independent addi ---");
    check_reg(16, 32'h0000000F, "lw x16, 0(x0) = 15 [no hazard next]");
    check_reg(17, 32'h0000002A, "addi x17, x0, 42 [independent]");
    
    $display("\n--- Branch Flush Test ---");
    check_reg(18, 32'h0000004D, "addi x18, x0, 77 [branch target, 99 flushed]");
    
    $display("\n--- LOAD with 1-cycle gap (no stall needed) ---");
    check_reg(19, 32'h00000005, "lw x19, 4(x0) = 5");
    check_reg(20, 32'h00000005, "addi x20, x0, 5 [independent gap]");
    check_reg(21, 32'h0000000A, "add x21, x19, x20 = 10 [fwd, no stall]");
    
    $display("\n--- LOAD-USE HAZARD Test 6: back-to-back loads + use ---");
    check_reg(22, 32'h0000000F, "lw x22, 0(x0) = 15");
    check_reg(23, 32'h00000005, "lw x23, 4(x0) = 5");
    check_reg(24, 32'h00000014, "add x24, x22, x23 = 20 [LOAD-USE on x23]");
    
    // ============================================================
    //  DATA MEMORY VERIFICATION
    // ============================================================
    $display("\n===========================================================");
    $display("  Data Memory Verification");
    $display("===========================================================");
    
    check_dmem(0, 32'h0000000F, "sw x3, 0(x0) = 15");
    check_dmem(1, 32'h00000005, "sw x4, 4(x0) = 5");
    check_dmem(2, 32'h00000005, "sw x1, 8(x0) = 5");
    check_dmem(3, 32'h00000005, "sw x15, 12(x0) = 5 [LOAD-USE store test]");
    
    // ============================================================
    //  FINAL REPORT
    // ============================================================
    $display("\n===========================================================");
    $display("  RESULTS: %0d PASSED, %0d FAILED", pass_count, fail_count);
    if (fail_count == 0)
        $display("  >>> ALL TESTS PASSED! <<<");
    else
        $display("  >>> SOME TESTS FAILED <<<");
    $display("===========================================================");
    
    $finish;
end
endmodule
