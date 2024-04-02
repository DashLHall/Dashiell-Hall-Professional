`timescale 1 ns / 1 ps
`include "alu.sv"

module test_cpu;
  parameter ADDR_WIDTH = 16;
  parameter DATA_WIDTH = 8;
  
  reg osc;
  localparam period = 10;

  wire clk; 
  assign clk = osc; 

  reg cs;
  reg we;
  reg oe;
  integer i;
  reg [ADDR_WIDTH-1:0] MAR;
  wire [DATA_WIDTH-1:0] data;
  reg [DATA_WIDTH-1:0] testbench_data;
  assign data = !oe ? testbench_data : 'hz;

  single_port_sync_ram_large #(.DATA_WIDTH(DATA_WIDTH)) ram (
    .clk(clk),
    .addr(MAR),
    .data(data[DATA_WIDTH-1:0]),
    .cs_input(cs),
    .we(we),
    .oe(oe)
  );
  
  reg [15:0] A;
  reg [15:0] B;
  reg [15:0] ALU_Out;
  reg [2:0] ALU_Sel; // Changed to 3-bit wide for consistency
  alu alu16 (
    .A(A),
    .B(B),
    .ALU_Sel(ALU_Sel),
    .ALU_Out(ALU_Out)
  );
  
  reg [15:0] PC = 'h100;
  reg [15:0] IR = 'h0;
  reg [15:0] MBR = 'h0;
  reg [15:0] AC = 'h0;

  initial osc = 1; // Init clk = 1 for positive-edge triggered
  always begin // Clock wave
    #period osc = ~osc;
  end

  initial begin
    $dumpfile("dump.vcd");
    $dumpvars;
    // Multiplication by addition program
    @(posedge clk) MAR <= 'h100; we <= 1; cs <= 1; oe <= 0; testbench_data <= 'h110C;
    @(posedge clk) MAR <= 'h101; we <= 1; cs <= 1; oe <= 0; testbench_data <= 'h210E;
    @(posedge clk) MAR <= 'h102; we <= 1; cs <= 1; oe <= 0; testbench_data <= 'h110D;
    @(posedge clk) MAR <= 'h103; we <= 1; cs <= 1; oe <= 0; testbench_data <= 'h310B;
    @(posedge clk) MAR <= 'h104; we <= 1; cs <= 1; oe <= 0; testbench_data <= 'h210D;
    @(posedge clk) MAR <= 'h105; we <= 1; cs <= 1; oe <= 0; testbench_data <= 'h110E;
    @(posedge clk) MAR <= 'h106; we <= 1; cs <= 1; oe <= 0; testbench_data <= 'h310F;
    @(posedge clk) MAR <= 'h107; we <= 1; cs <= 1; oe <= 0; testbench_data <= 'h210E;
    @(posedge clk) MAR <= 'h108; we <= 1; cs <= 1; oe <= 0; testbench_data <= 'h8400;
    @(posedge clk) MAR <= 'h109; we <= 1; cs <= 1; oe <= 0; testbench_data <= 'h9102;
    @(posedge clk) MAR <= 'h10A; we <= 1; cs <= 1; oe <= 0; testbench_data <= 'h7000;
    @(posedge clk) MAR <= 'h10B; we <= 1; cs <= 1; oe <= 0; testbench_data <= 'h0005;
    @(posedge clk) MAR <= 'h10C; we <= 1; cs <= 1; oe <= 0; testbench_data <= 'h0007;
    @(posedge clk) MAR <= 'h10D; we <= 1; cs <= 1; oe <= 0; testbench_data <= 'h0000;
    @(posedge clk) MAR <= 'h10E; we <= 1; cs <= 1; oe <= 0; testbench_data <= 'h0000;
    @(posedge clk) MAR <= 'h10F; we <= 1; cs <= 1; oe <= 0; testbench_data <= 'hFFFF;
    
    
    @(posedge clk) PC <= 'h100;
    
    for (i = 0; i < 62; i = i+1) begin
          // Fetch
          @(posedge clk) MAR <= PC; we <= 0; cs <= 1; oe <= 1;
          @(posedge clk) IR <= data;
          @(posedge clk) PC <= PC + 1;
          // Decode and execute
      case(IR[15:12])
        4'b0001: begin
              @(posedge clk) MAR <= IR[11:0];
              @(posedge clk) MBR <= data;
              @(posedge clk) AC <= MBR;
        end 
		4'b0010: begin
              @(posedge clk) MAR <= IR[11:0];
              @(posedge clk) MBR <= AC;
              @(posedge clk) we <= 1; oe <= 0; testbench_data <= MBR;      
        end
        4'b0011: begin
              @(posedge clk) MAR <= IR[11:0];
          	@(posedge clk) MBR <= data;
          	@(posedge clk) ALU_Sel <= 3'b010; // Set ALU_Sel for subtraction
          	@(posedge clk) A <= AC; // Set A for ALU input
          	@(posedge clk) B <= MBR; // Set B for ALU input
          	@(posedge clk) AC <= ALU_Out;
        end
        4'b0111: begin
              @(posedge clk) PC <= PC - 1;
        end
        4'b1000: begin
          @(posedge clk)
          if(IR[11:10]==2'b01 && AC == 0) PC <= PC + 1;
          else if(IR[11:10]==2'b00 && AC < 0) PC <= PC + 1;
          else if(IR[11:10]==2'b10 && AC > 0) PC <= PC + 1;
        end
        4'b1001: begin
              @(posedge clk) PC <= IR[11:0];
        end
        4'b1010: begin
          @(posedge clk) AC <= 0;
        end
        4'b1011: begin
            // Jump instruction
            @(posedge clk) PC <= AC;
        end
        4'b1100: begin
            // Halt instruction
            $display("Halt instruction encountered. Stopping simulation.");
            $finish;
        end
        4'b1101: begin
            // Skip instruction
            PC <= PC + 1; // Skip the next instruction
        end
        4'b1110: begin // Return
            @(posedge clk) PC <= MBR;  // Assuming MBR contains the return address
        end
        4'b0101: begin // Jal
            @(posedge clk) MAR <= IR[11:0];
            @(posedge clk) MBR <= PC + 1;  // Save the return address in MBR
            @(posedge clk) AC <= MBR;  // Set the link register with the return address
            @(posedge clk) PC <= data;  // Jump to the target address
        end
        4'b1111: begin // AND
            @(posedge clk) MAR <= IR[11:0];
            @(posedge clk) MBR <= data;
            @(posedge clk) ALU_Sel <= 3'b110;  // Set ALU_Sel for AND operation
            @(posedge clk) A <= AC;  // Set A for ALU input
            @(posedge clk) B <= MBR;  // Set B for ALU input
            @(posedge clk) AC <= ALU_Out;  // Store the result in AC
        end
        4'b1100: begin // OR
            @(posedge clk) MAR <= IR[11:0];
            @(posedge clk) MBR <= data;
            @(posedge clk) ALU_Sel <= 3'b101;  // Set ALU_Sel for OR operation
            @(posedge clk) A <= AC;  // Set A for ALU input
            @(posedge clk) B <= MBR;  // Set B for ALU input
            @(posedge clk) AC <= ALU_Out;  // Store the result in AC
        end
        4'b0000: begin // NOT
            @(posedge clk) MAR <= IR[11:0];
            @(posedge clk) MBR <= data;
            @(posedge clk) ALU_Sel <= 3'b011;  // Set ALU_Sel for NOT operation
            @(posedge clk) A <= MBR;  // Set A for ALU input
            @(posedge clk) B <= 16'h0;  // Set B to zero for NOT operation
            @(posedge clk) AC <= ALU_Out;  // Store the result in AC
        end
	      // Vector addition instruction
	4'b0010_0000: begin
	    @(posedge clk) MAR <= IR[11:0];
	    @(posedge clk) MBR <= data;
	    @(posedge clk) ALU_Sel <= 3'b000; // Set ALU_Sel for vector addition
	    @(posedge clk) A[7:0] <= AC[7:0]; // Set A for ALU input (first vector)
	    @(posedge clk) B[7:0] <= MBR[7:0]; // Set B for ALU input (second vector)
	    @(posedge clk) AC[7:0] <= ALU_Out[7:0]; // Store the result in AC (result vector)
	end
      endcase
    end
      
    @(posedge clk) MAR <= 'h10D; we <= 0; cs <= 1; oe <= 1;
    
    @(posedge clk)
   #20 $finish;
  end

endmodule
