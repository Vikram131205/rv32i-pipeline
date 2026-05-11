`timescale 1ns / 1ps

module ALU(

input [31:0]read_data_1,read_data_2,
input [3:0] alucontrol,
output reg [31:0] result,
output reg zero,l_t_u,g_t_u,n_e,l_t_s,g_t_s
    );
    reg signed [31:0] a,b;
    
    always @(*) begin
    a = read_data_1;
    b = read_data_2;
    case(alucontrol) 
    4'd0 : result = read_data_1 + read_data_2;
    4'd1 : result = read_data_1 - read_data_2;
    4'd2 : result = read_data_1 << read_data_2[4:0];  // SLL: use lower 5 bits
    4'd3 : result = read_data_1 | read_data_2;
    4'd4 : result = read_data_1 & read_data_2;
    4'd5 : result = read_data_1 ^ read_data_2;
    4'd6 : result = (read_data_1 < read_data_2); // sltu
    4'd7 : result = read_data_1 >> read_data_2[4:0];  // SRL: use lower 5 bits
    4'd8 : result = a >>> read_data_2[4:0];            // SRA: use signed 'a' + lower 5 bits
    4'd9 : result = ( a < b ) ? 1 : 0; // slt
    default : result = read_data_1 + read_data_2;
    endcase
    
    // BUG #14 fix: compute comparison flags inside always block
    zero = (read_data_1 == read_data_2);
    n_e = ~zero;
    l_t_u = (read_data_1 < read_data_2) ? 1'b1 : 1'b0;
    g_t_u = (read_data_1 > read_data_2) ? 1'b1 : 1'b0;
    l_t_s = (a < b) ? 1'b1 : 1'b0;
    g_t_s = (a > b) ? 1'b1 : 1'b0;
    end
endmodule


