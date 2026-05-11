`timescale 1ns / 1ps

module mux_32_3in(
input reset,
input [31:0] a,b,c,
input [1:0] s,
output reg [31:0] res
    );
    always @(*) begin
    if(reset)
    res = 32'd0;
    else begin
    case(s)
    2'b00 : res = a;
    2'b01 : res = b;
    2'b10 : res = c;
    default : res = 32'd0;
    endcase
    end
    end
endmodule
