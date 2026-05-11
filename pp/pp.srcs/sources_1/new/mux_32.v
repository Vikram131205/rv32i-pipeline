`timescale 1ns / 1ps

module mux_32(
input reset,
input [31:0] a,b,
input s,
output reg [31:0] res
    );
    always @(*) begin
    if(reset)
    res = 32'd0;
    else begin
    case(s)
    1'b0 : res = a;
    1'b1 : res = b;
    default : res = 32'd0;
    endcase
    end
    end
endmodule



