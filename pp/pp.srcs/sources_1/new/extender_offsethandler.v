`timescale 1ns / 1ps


module extender_offsethandler(
input flush,
input [2:0] funct3,
input [31:7] ins,
input [2:0] imsrc,
output reg signed [31:0] offset
    );
    wire [11:0] ins_i,ins_s;
    wire [12:0] ins_b;
    wire [20:0] ins_j;
   
    assign ins_i = ins[31:20];
    assign ins_s = {ins[31:25],ins[11:7]};
    assign ins_b = {ins[31],ins[7],ins[30:25],ins[11:8],1'b0};
    assign ins_j = {ins[31],ins[19:12],ins[20],ins[30:21],1'b0};
    always @(*) begin
    if(flush)
    offset = 0;
    else begin
    case(imsrc)
    3'b000 : // signed 12 - 32 bit (I type)
    offset = (ins_i[11]) ? {{20{1'b1}},ins_i[11:0]} : {{20{1'b0}} , ins_i[11:0]};
    3'b001 : // unsigned 12 -32 bit (I type)
    offset = {{20{1'b0}},ins_i[11:0]};
    3'b010 : // signed 12 -32 bit (S type)
    offset = (ins_s[11]) ? {{20{1'b1}},ins_s[11:0]} : {{20{1'b0}} , ins_s[11:0]};
    3'b011 : // signed 13 - 32 bit (B type)
    offset = (ins_b[12]) ? {{19{1'b1}},ins_b[12:0]} : {{19{1'b0}} , ins_b[12:0]};
    3'b100 : // signed 21 - 32 bit (J type)
    offset =  (ins_j[20]) ? {{11{1'b1}},ins_j[20:0]} : {{11{1'b0}} , ins_j[20:0]};
    3'b101 : begin
    if((funct3 == 3'b001)|(funct3 == 3'b101))
    offset = {{27{1'b0}}, ins[24:20]};  // 5-bit shamt, zero-extended
    else 
    offset = (ins_i[11]) ? {{20{1'b1}},ins_i[11:0]} : {{20{1'b0}} , ins_i[11:0]}; 
    end
    
    endcase
    end
    end
    
endmodule