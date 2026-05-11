module bj_det(
input reset,
input Branch,Jump,
input [2:0] funct3,
input zero,l_t_u,g_t_u,n_e,l_t_s,g_t_s,
output reg bj
    );
    reg  w1,w2,w3,w4,w5,w6;

    always @(*) begin
        // 1. Default Assignment (Crucial for combinational logic)
        // If no condition is met, bj should be 0.
        bj = 0; 
        
        if(reset) begin
            // 2. Reset condition overrides everything
            bj = 0;
        end
        else begin
            if(Branch) begin
                // Initialize temporary flags for the current evaluation
                w1 = 0; w2 = 0; w3 = 0; w4 = 0; w5 = 0; w6 = 0; 
                
                case(funct3)
                    // BEQ (Equal)
                    3'b000 : w1 = zero; 
                    // BNE (Not Equal)
                    3'b001 : w2 = n_e;
                    // BLT (Less Than Signed)
                    3'b100 : w3 = l_t_s;
                    // BGE (Greater Than or Equal Signed) - This is usually NOT BLT's inverse, but let's follow your code's intent
                    // NOTE: Your code implies BGT (Greater Than Signed) for 3'b101.
                    // The standard RISC-V for 3'b101 is BGE (Branch Greater Than or Equal).
                    // If it's BGE: w4 = l_t_s ? 0 : 1; // If not less than (i.e., greater than or equal)
                    // Following your code's variable:
                    3'b101 : w4 = g_t_s | zero; // BGE: greater OR equal signed
                    // BLTU (Less Than Unsigned)
                    3'b110 : w5 = l_t_u;
                    // BGEU (Greater Than or Equal Unsigned)
                    // NOTE: Your code implies BGTU (Greater Than Unsigned) for 3'b111.
                    // Following your code's variable:
                    3'b111 : w6 = g_t_u | zero; // BGEU: greater OR equal unsigned
                    // Default Case (Should only happen if funct3 is 3'b010 or 3'b011)
                    // A default case setting w1=1 for unknown funct3 might be an error or a specific design choice.
                    default : w1 = 1; 
                endcase
                
                // If any of the branch conditions are met, the branch is taken.
                bj = (w1 | w2 | w3 | w4 | w5 | w6); 

            end
            // Check Jump if Branch is not active
            else if(Jump) begin
                bj = 1; // Jump is always taken
            end
            // ELSE: bj is already 0 from the default assignment at the start.
        end
    end
    
endmodule


