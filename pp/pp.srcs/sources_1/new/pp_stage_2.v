`timescale 1ns / 1ps


module pp_stage_2(
input clk,
input reset,
input flush,
input stall,

input [31:0] next_addr, 
input [31:0] ins,
input  [31:0] four_pc,

output reg  [31:0] next_addr_s2, 
output reg  [31:0] ins_s2,
output reg  [31:0] four_pc_s2
    );
    always @(posedge clk) begin
    if(reset | flush) begin
    next_addr_s2 <= 0;
    ins_s2 <= 32'h00000013; // NOP: addi x0, x0, 0
    four_pc_s2 <= 0;
    end
    else if(!stall) begin
    next_addr_s2 <= next_addr;
    ins_s2 <= ins;
    four_pc_s2 <= four_pc;
    end
    // implicitly: else hold values
    end
endmodule
