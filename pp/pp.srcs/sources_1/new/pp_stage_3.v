`timescale 1ns / 1ps


module pp_stage_3(
input clk,
input reset,
input flush,
input stall,

input  RegWrite,MemWrite,Jump,Branch,ALUSrc,
input [1:0] ResultSrc,
input [3:0] alucontrol,
input w,hw,b,
input [31:0] r_data_1,r_data_2,
input  [31:0] next_addr_s2, 
input  [31:0] four_pc_s2,
input [31:0] offset,
input [2:0] funct3,
input [4:0] Rs1D , Rs2D, RdD,

output reg  RegWrite_s3,MemWrite_s3,Jump_s3,Branch_s3,ALUSrc_s3,
output reg [1:0] ResultSrc_s3,
output reg [3:0] alucontrol_s3,
output reg w_s3,hw_s3,b_s3,
output reg [31:0] r_data_1_s3,r_data_2_s3,
output reg  [31:0] next_addr_s3, 
output reg  [31:0] four_pc_s3,
output reg [31:0] offset_s3,
output reg [2:0] funct3_s3,
output reg [4:0] Rs1E , Rs2E , RdE
    );
    always @(posedge clk) begin
    if(reset | flush | stall) begin
    RegWrite_s3 <= 0;
    MemWrite_s3 <= 0;
    Jump_s3 <= 0;
    Branch_s3 <= 0;
    ALUSrc_s3 <= 0;
    ResultSrc_s3 <=0;
    alucontrol_s3 <=0;
    w_s3 <= 0; hw_s3 <= 0; b_s3 <= 0;
    r_data_1_s3 <= 0;
    r_data_2_s3 <= 0;
    next_addr_s3 <=0;
    four_pc_s3 <= 0;
    offset_s3 <=0;
    funct3_s3 <= 0;
    Rs1E <= 0;
    Rs2E <= 0;
    RdE <= 0;
    end
    else begin
    RegWrite_s3 <= RegWrite;
    MemWrite_s3 <= MemWrite;
    Jump_s3 <= Jump;
    Branch_s3 <= Branch;
    ALUSrc_s3 <= ALUSrc;
    ResultSrc_s3 <= ResultSrc;
    alucontrol_s3 <=alucontrol;
    w_s3 <= w; hw_s3 <= hw; b_s3 <= b;
    r_data_1_s3 <= r_data_1;
    r_data_2_s3 <= r_data_2 ;
    next_addr_s3 <=next_addr_s2;
    four_pc_s3 <= four_pc_s2 ;
    offset_s3 <=offset;
    funct3_s3 <= funct3;
    Rs1E <= Rs1D;
    Rs2E <= Rs2D;
    RdE <= RdD;
    end
    end
endmodule
