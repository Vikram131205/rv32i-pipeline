`timescale 1ns / 1ps
//
// Auto-verification testbench for cocotb-style golden model testing.
// Runs the program, then dumps register file + data memory to a file.
//
module tb_golden #(parameter depth_reg = 32, parameter d_width = 32)();

reg reset, clk;

// All the top_module wires
wire [31:0] addr, next_addr, ins, four_pc;
wire RegWrite, MemWrite, Jump, Branch, ALUSrc;
wire [1:0] ResultSrc;
wire [2:0] imsrc;
wire [3:0] alucontrol;
wire w, hw, b;
wire [11:0] imm;
wire [6:0] opcode, funct7;
wire [2:0] funct3;
wire [4:0] rs_addr, rt_addr, rd_addr;
wire [31:0] write_data, r_data_1, r_data_2;
wire [24:0] ins_offset;
wire [31:0] offset, read_data_1, read_data_2, result;
wire zero, l_t_u, g_t_u, n_e, l_t_s, g_t_s;
wire [31:0] updated_pc, read_data;
wire bj, flush;
wire [31:0] next_addr_s2, ins_s2, four_pc_s2;
wire RegWrite_s3, MemWrite_s3, Jump_s3, Branch_s3, ALUSrc_s3;
wire [1:0] ResultSrc_s3;
wire [3:0] alucontrol_s3;
wire w_s3, hw_s3, b_s3;
wire [31:0] r_data_1_s3, r_data_2_s3, next_addr_s3, four_pc_s3, offset_s3;
wire RegWrite_s4, MemWrite_s4;
wire [1:0] ResultSrc_s4;
wire [31:0] result_s4, write_datamem_s4, four_pc_s4;
wire w_s4, hw_s4, b_s4;
wire RegWrite_s5;
wire [1:0] ResultSrc_s5;
wire [31:0] result_s5, read_data_s5, four_pc_s5;
wire [2:0] funct3_s3;
wire [4:0] Rs1E, Rs2E, RdE, Rs1D, Rs2D, RdD, RdM, RdW;
wire [1:0] ForwardAE, ForwardBE;
wire [31:0] true1, true2;

initial clk = 0;
always #5 clk = ~clk;

top_module uut (
    .clk(clk), .reset(reset), .flush(flush),
    .addr(addr), .next_addr(next_addr), .ins(ins), .four_pc(four_pc),
    .RegWrite(RegWrite), .MemWrite(MemWrite), .Jump(Jump), .Branch(Branch), .ALUSrc(ALUSrc),
    .ResultSrc(ResultSrc), .imsrc(imsrc), .alucontrol(alucontrol),
    .w(w), .hw(hw), .b(b), .imm(imm), .opcode(opcode), .funct3(funct3), .funct7(funct7),
    .rs_addr(rs_addr), .rt_addr(rt_addr), .rd_addr(rd_addr),
    .write_data(write_data), .r_data_1(r_data_1), .r_data_2(r_data_2),
    .ins_offset(ins_offset), .offset(offset),
    .read_data_1(read_data_1), .read_data_2(read_data_2),
    .result(result), .zero(zero), .l_t_u(l_t_u), .g_t_u(g_t_u), .n_e(n_e), .l_t_s(l_t_s), .g_t_s(g_t_s),
    .updated_pc(updated_pc), .bj(bj), .read_data(read_data),
    .next_addr_s2(next_addr_s2), .ins_s2(ins_s2), .four_pc_s2(four_pc_s2),
    .RegWrite_s3(RegWrite_s3), .MemWrite_s3(MemWrite_s3), .Jump_s3(Jump_s3),
    .Branch_s3(Branch_s3), .ALUSrc_s3(ALUSrc_s3),
    .ResultSrc_s3(ResultSrc_s3), .alucontrol_s3(alucontrol_s3),
    .w_s3(w_s3), .hw_s3(hw_s3), .b_s3(b_s3),
    .r_data_1_s3(r_data_1_s3), .r_data_2_s3(r_data_2_s3),
    .next_addr_s3(next_addr_s3), .four_pc_s3(four_pc_s3), .offset_s3(offset_s3), .funct3_s3(funct3_s3),
    .RegWrite_s4(RegWrite_s4), .MemWrite_s4(MemWrite_s4), .ResultSrc_s4(ResultSrc_s4),
    .result_s4(result_s4), .write_datamem_s4(write_datamem_s4), .four_pc_s4(four_pc_s4),
    .w_s4(w_s4), .hw_s4(hw_s4), .b_s4(b_s4),
    .RegWrite_s5(RegWrite_s5), .ResultSrc_s5(ResultSrc_s5),
    .result_s5(result_s5), .read_data_s5(read_data_s5), .four_pc_s5(four_pc_s5),
    .Rs1E(Rs1E), .Rs2E(Rs2E), .RdE(RdE), .Rs1D(Rs1D), .Rs2D(Rs2D), .RdD(RdD),
    .RdM(RdM), .RdW(RdW), .ForwardAE(ForwardAE), .ForwardBE(ForwardBE),
    .true1(true1), .true2(true2)
);

integer i, dump_file;
initial begin
    // Reset
    reset = 1;
    #15;
    reset = 0;

    // Run long enough for all instructions to drain
    #3000;

    // Dump register file and data memory to a file
    dump_file = $fopen("rtl_dump.txt", "w");

    // Registers
    for (i = 0; i < 32; i = i + 1)
        $fwrite(dump_file, "REG %0d %0d\n", i, uut.uut4.mem[i]);

    // Data memory (first 32 words)
    for (i = 0; i < 32; i = i + 1)
        $fwrite(dump_file, "MEM %0d %0d\n", i, uut.uut11.mem[i]);

    $fclose(dump_file);
    $display("RTL dump written to rtl_dump.txt");
    $finish;
end

endmodule
