`timescale 1ns / 1ps
module controlpath(
input flush,
input [11:0] imm,
input reset,
input [6:0] ins,
input [2:0] funct3,
input [6:0] funct7,
output reg RegWrite,MemWrite,Jump,Branch,ALUSrc,
output reg [1:0] ResultSrc,
output reg [2:0] imsrc,
output reg [3:0] alucontrol,
output reg w,hw,b
    );
    always @(*) begin
    
    if(reset | flush) begin
    w=1;hw=0;b=0;
    Branch = 0;
    Jump = 0;
    RegWrite = 0;
    MemWrite = 0;
    ALUSrc = 0;
    ResultSrc = 2'b00;
    imsrc = 3'b000;
    alucontrol = 4'd0;
    end
    else begin
    case(ins) 
    7'b0110011 : begin // R type
    Branch = 0;
    Jump = 0;
    RegWrite = 1;
    MemWrite = 0;
    ALUSrc = 0;
    ResultSrc = 2'b00;
    imsrc = 3'b000;
    w = 1;hw=0;b=0;
    case(funct3)
    3'b000 : begin
    if(funct7 == 7'd0)
    alucontrol = 4'd0;
    else
    alucontrol = 4'd1;
    end
    3'b100 : alucontrol = 4'd5;
    3'b110 : alucontrol = 4'd3;
    3'b111 : alucontrol = 4'd4;
    3'b001 : alucontrol = 4'd2;
    3'b101 : begin
    if(funct7 == 7'd0) 
    alucontrol = 4'd7;
    else 
    alucontrol = 4'd8;
    end
    3'b010 : alucontrol = 4'd9;
    3'b011 : alucontrol = 4'd6;
    endcase
    end
    7'b0010011 : begin  // I type
    
    w = 1;hw=0;b=0;
    Branch = 0;
    Jump = 0;
    RegWrite = 1;
    MemWrite = 0;
    ALUSrc = 1;
    ResultSrc = 2'b00;
    imsrc = 3'b101;
    case(funct3)
    3'b000 : alucontrol = 4'd0;
    3'b100 : alucontrol = 4'd5;
    3'b110 : alucontrol = 4'd3;
    3'b111 : alucontrol = 4'd4;
    3'b001 : alucontrol = 4'd2;
    3'b101 : begin
    if(imm[11:5] == 7'd0) 
    alucontrol = 4'd7;
    else 
    alucontrol = 4'd8;
    end
    3'b010 : alucontrol = 4'd9;
    3'b011 : alucontrol = 4'd6;
    endcase
    end
    
    7'b0000011 : begin// load (I type)
    Branch = 0;
    Jump = 0;
    RegWrite = 1;
    MemWrite = 0;
    ALUSrc = 1;
    ResultSrc = 2'b01;
    imsrc = 3'b000;
    alucontrol = 4'd0;
    case(funct3)
    3'b000 : begin
    b=1;hw=0;w=0;
    end
    3'b001 : begin
    hw=1;w=0;b=0;
    end
    3'b010 : begin
    w=1;hw=0;b=0;
    end
    3'b100 : begin
    b=1;hw=0;w=0;
    end
    3'b101 : begin
    hw=1;b=0;w=0;
    end
    endcase
    end
    
    7'b0100011 : begin //store (S type)
    Branch = 0;
    Jump = 0;
    RegWrite = 0;
    MemWrite = 1;
    ALUSrc = 1;
    ResultSrc = 2'b00;
    imsrc = 3'b010;
    alucontrol = 4'd0;
    case(funct3) 
    3'b000 : begin
    b=1;hw=0;w=0;
    end
    3'b001 : begin
    hw=1;b=0;w=0;
    end
    3'b010 : begin
    w=1;hw=0;b=0;
    end
    endcase
    end
    
    7'b1100011 : begin // (B Type)
    w=1;b=0;hw=0;
    Branch = 1;
    Jump = 0;
    RegWrite = 0;
    MemWrite = 0;
    ALUSrc = 0;
    ResultSrc = 2'b00;
    imsrc = 3'b011;
    alucontrol = 4'd0;
    end
    
    7'b1101111 : begin //(J Type)
    w=1;hw=0;b=0;
    Branch = 0;
    Jump = 1;
    RegWrite = 1;
    MemWrite = 0;
    ALUSrc = 1;
    ResultSrc = 2'b10;
    imsrc = 3'b100;
    alucontrol = 4'd0;
    end
    default : begin
    w=1;hw=0;b=0;
    Branch = 0;
    Jump = 0;
    RegWrite = 0;
    MemWrite = 0;
    ALUSrc = 0;
    ResultSrc = 2'b00;
    imsrc = 3'b000;
    alucontrol = 4'd0;
    end
   endcase
   end
   end
endmodule

