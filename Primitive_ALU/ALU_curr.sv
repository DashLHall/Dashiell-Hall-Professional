timescale 1ns / 1ps

module alu(
    input [15:0] A, B,  // ALU 16-bit Inputs
    input [2:0] ALU_Sel, // ALU Selection
    output reg [15:0] ALU_Out // ALU 16-bit Output
);

    reg [15:0] ALU_Result;

    always @*
    begin
        case (ALU_Sel)
            3'b001: // Addition
                ALU_Result = A + B;
            3'b010: // Subtraction
                ALU_Result = A - B;
            3'b100: // Clear
                ALU_Result = 16'b0;
            3'b011: // NOT
                ALU_Result = ~A;
            3'b101: // OR
                ALU_Result = A | B;
            3'b110: // AND
                ALU_Result = A & B;
            default: ALU_Result = A;
        endcase
    end

    assign ALU_Out = ALU_Result; // ALU output

endmodule
