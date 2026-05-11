`timescale 1ns / 1ps

module hazard_unit(
input reset,
input [4:0] Rs1E , Rs2E , RdM , RdW,
input RegWrite_s4 , RegWrite_s5,
input [1:0] ResultSrc_s3,
input [4:0] RdE,
input [4:0] Rs1D, Rs2D,
output [1:0] ForwardAE , ForwardBE,
output stall
    );
    
    // Load-Use hazard detection
    // If the instruction in EX is a Load (ResultSrc_s3 == 2'b01)
    // and the instruction in ID wants to read its destination register
    wire load_in_EX = (ResultSrc_s3 == 2'b01);
    assign stall = load_in_EX && (RdE != 5'd0) && ((RdE == Rs1D) || (RdE == Rs2D));

    // ForwardAE for rs1
    assign ForwardAE = (reset == 1'b1) ? 2'b00 : 
                       ((RegWrite_s4 == 1'b1) & (RdM != 5'd0) & (RdM == Rs1E)) ? 2'b10 :
                       ((RegWrite_s5 == 1'b1) & (RdW != 5'd0) & (RdW == Rs1E)) ? 2'b01 : 2'b00;
    // ForwardBE for rs2
    assign ForwardBE = (reset == 1'b1) ? 2'b00 : 
                       ((RegWrite_s4 == 1'b1) & (RdM != 5'd0) & (RdM == Rs2E)) ? 2'b10 :
                       ((RegWrite_s5 == 1'b1) & (RdW != 5'd0) & (RdW == Rs2E)) ? 2'b01 : 2'b00;
                       
    
endmodule
