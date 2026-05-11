`timescale 1ns / 1ps

module alu_four(
input flush,
input[31:0] next_addr,
output  [31:0] four_pc
    );
    
    assign four_pc =   next_addr + 32'd4;
    
endmodule


