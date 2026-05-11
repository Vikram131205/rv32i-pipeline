`timescale 1ns / 1ps


module alu_pc(
input [31:0] four_pc,
input signed [31:0] offset,
output reg signed [31:0] updated_pc,
input reset
    );
    always @(*) begin
    if(reset)
    updated_pc = 32'd0;
    else 
    updated_pc =$signed(four_pc) + $signed(offset) ;
    end
endmodule

