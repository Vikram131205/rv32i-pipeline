`timescale 1ns / 1ps
module instruction(
input flush,
input reset,
input [31:0] next_addr, // byte addresable address 
output reg [31:0] ins
    );
    reg [31:0] ins_mem [0:255]; // 256 lines each line 4 bytes 
                                // 1024 valid address 10 bits to address
    // last 2 bits are block offset
    // bits 9-2 will tell which line the instruction is being fetched from                      
    always @(*) begin
    
    
    ins = ins_mem[next_addr[9:2]];
   
    end
    initial $readmemh("rv32i_real.hex", ins_mem);
endmodule
