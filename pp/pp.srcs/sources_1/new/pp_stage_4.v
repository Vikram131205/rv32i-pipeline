`timescale 1ns / 1ps


module pp_stage_4(
input clk,
input reset,

input RegWrite_s3,MemWrite_s3,
input [1:0] ResultSrc_s3,
input [31:0] result,
input [31:0] write_datamem,
input [31:0] four_pc_s3,
input w_s3,hw_s3,b_s3,
input [4:0] RdE,
output reg RegWrite_s4,MemWrite_s4,
output reg [1:0] ResultSrc_s4,
output reg [31:0] result_s4,
output reg [31:0] write_datamem_s4,
output reg [31:0] four_pc_s4,
output reg w_s4,hw_s4,b_s4,
output reg [4:0] RdM
    );
    always @(posedge clk) begin
    if(reset) begin
    RegWrite_s4 <= 0;
    MemWrite_s4 <= 0;
    ResultSrc_s4 <= 0;
    result_s4 <=0;
    write_datamem_s4 <=0;
    four_pc_s4 <= 0;
    w_s4 <= 0 ; hw_s4 <= 0 ; b_s4 <= 0;
    RdM <= 0;
    end
    else begin
    RegWrite_s4 <= RegWrite_s3;
    MemWrite_s4 <= MemWrite_s3;
    ResultSrc_s4 <= ResultSrc_s3;
    result_s4 <=result;
    write_datamem_s4 <=write_datamem;
    four_pc_s4 <= four_pc_s3;
    w_s4 <= w_s3 ; hw_s4 <= hw_s3 ; b_s4 <= b_s3;
    RdM <= RdE;
    end
    end
endmodule
