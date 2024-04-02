`timescale 1ns / 1ps

module tb_alu;

  // Inputs
  reg [15:0] A, B;
  reg [2:0] ALU_Sel;

  // Outputs
  reg [15:0] ALU_Out;

  // Instantiate the ALU module
  alu uut(
    .A(A),
    .B(B),
    .ALU_Sel(ALU_Sel),
    .ALU_Out(ALU_Out)
  );

  // Initial block for simulation
    initial begin
    // Initialize inputs
    A = 16'b0011;
    B = 16'b0101;

    // Addition
    ALU_Sel = 3'b001;
    #10;
    $display("Result of A + B (Addition): %b", ALU_Out);

    // Subtraction
    ALU_Sel = 3'b010;
    #10;
    $display("Result of A - B (Subtraction): %b", ALU_Out);

    // Clear
    ALU_Sel = 3'b100;
    #10;
    $display("Result of Clear (Set to 0): %b", ALU_Out);

    // NOT
    ALU_Sel = 3'b011;
    #10;
    $display("Result of NOT A: %b", ALU_Out);

    // OR
    ALU_Sel = 3'b101;
    #10;
    $display("Result of A OR B: %b", ALU_Out);

    // AND
    ALU_Sel = 3'b110;
    #10;
    $display("Result of A AND B: %b", ALU_Out);

    $stop;
  end

endmodule
