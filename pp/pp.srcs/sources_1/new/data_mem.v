`timescale 1ns / 1ps


module data_mem#(parameter depth_mem = 256,
parameter d_width = 32)(
input clk,
input MemWrite,
input [9:0] addr,
input [31:0] write_data,
input w,hw,b,
output reg [31:0] read_data

    );
   reg [31:0] word_data;
     reg [31:0] mem [0 : 31];
     initial begin
     $readmemh("data_mem_file.hex", mem);
     
     end
     // Read logic — little-endian (RISC-V standard)
     always @(MemWrite,addr,write_data,w,hw,b) begin
        word_data = mem[addr[9:2]]; 
        if(w)
        read_data = word_data;
        else if(hw) begin
        if(addr[1] == 0)
        read_data = {{16{1'b0}},word_data[15:0]};   // lower half-word
        else 
        read_data = {{16{1'b0}},word_data[31:16]};   // upper half-word
        end
        else if(b) begin
        case(addr[1:0])
        2'b00 : read_data = {{24{1'b0}},word_data[7:0]};    // byte 0 = bits[7:0]
        2'b01 : read_data = {{24{1'b0}},word_data[15:8]};   // byte 1 = bits[15:8]
        2'b10 : read_data = {{24{1'b0}},word_data[23:16]};  // byte 2 = bits[23:16]
        2'b11 : read_data = {{24{1'b0}},word_data[31:24]};  // byte 3 = bits[31:24]
        endcase
        end
        
        end
        
        // Write logic — little-endian
        always @(posedge clk) begin
    if (MemWrite) begin
        case ({w, hw, b})
            3'b100:  // SW
                mem[addr[9:2]] <= write_data;

            3'b010:  // SH
                if (addr[1] == 0)
                    mem[addr[9:2]][15:0] <= write_data[15:0];   // lower half
                else
                    mem[addr[9:2]][31:16] <= write_data[15:0];  // upper half

            3'b001:  // SB
                case (addr[1:0])
                    2'b00: mem[addr[9:2]][7:0]   <= write_data[7:0];  // byte 0
                    2'b01: mem[addr[9:2]][15:8]  <= write_data[7:0];  // byte 1
                    2'b10: mem[addr[9:2]][23:16] <= write_data[7:0];  // byte 2
                    2'b11: mem[addr[9:2]][31:24] <= write_data[7:0];  // byte 3
                endcase
        endcase
    end
end
    endmodule 