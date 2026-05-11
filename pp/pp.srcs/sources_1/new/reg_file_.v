`timescale 1ns / 1ps

module reg_file_#(parameter depth_reg = 32 , 
parameter d_width = 32)(
input clk,flush,
input [$clog2(depth_reg)-1:0] rs_addr,
input [$clog2(depth_reg)-1:0] rt_addr,
input [$clog2(depth_reg)-1:0] rd_addr,
input [d_width-1:0] write_data,
output reg [d_width-1:0] r_data_1,r_data_2,
input RegWrite
    );
     reg [d_width-1:0] mem [0 : depth_reg-1];
     initial begin
     $readmemh("register_file_counting.hex",mem);
     end
     // Write on negedge so value is available for combinational read
     // before the next posedge (textbook 5-stage pipeline solution)
     always @(negedge clk) begin
     if(RegWrite && (rd_addr != 5'd0))  // also protect x0
     mem[rd_addr] <= write_data;
     end
     always @(*) begin
     if(flush) begin 
     r_data_1 = 0;
     r_data_2 = 0;
     end
     else begin
     r_data_1 = mem[rs_addr];
     r_data_2 = mem[rt_addr];
     end
     end
     
endmodule
