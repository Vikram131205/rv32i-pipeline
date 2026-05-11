`timescale 1ns / 1ps
module pc_(
input reset,
input clk,
input stall,
input [31:0] addr,
output reg [31:0] next_addr
    );
    always @(posedge clk) begin
    if(reset) begin
    next_addr <= 32'd0;
    end
    else if(!stall) begin
    next_addr <= addr;
    end
    // implicitly: else next_addr <= next_addr;
    end
endmodule