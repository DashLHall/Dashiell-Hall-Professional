`timescale 1ns / 1ps
`include "ram_large_1a.sv"

module testram1a;

  // Parameters
  parameter ADDR_WIDTH = 16;
  parameter DATA_WIDTH = 8;
  parameter DATA_WIDTH_SHIFT = 1;

  // Signals
  reg clk;
  reg [ADDR_WIDTH-1:0] addr;
  reg [DATA_WIDTH-1:0] data;
  reg cs_input, we, oe;

  // Instantiate the RAM module
  single_port_sync_ram_large_1a #(
    .ADDR_WIDTH(ADDR_WIDTH),
    .DATA_WIDTH(DATA_WIDTH),
    .DATA_WIDTH_SHIFT(DATA_WIDTH_SHIFT)
  ) ram_instance (
    .clk(clk),
    .addr(addr),
    .data(data),
    .cs_input(cs_input),
    .we(we),
    .oe(oe)
  );

  // Clock generation
  initial begin
    $dumpfile("dump.vcd");
    $dumpvars;
    clk = 0;
    forever #5 clk = ~clk;
  end

  // Test scenario
  initial begin
    // Initialize inputs
    addr = 16'h0000;
    data = 8'b0000_0000;
    cs_input = 1;
    we = 1;
    oe = 0;

    // Wait for a few clock cycles
    #10;

    // Write to memory
    addr = 16'h0001;
    data = 8'b1010_1010;
    we = 1;
    oe = 0;
    cs_input = 1;
    #10;

    // Read from memory
    addr = 16'h0001;
    we = 0;
    oe = 1;
    cs_input = 1;
    #10;

    // Finish simulation
    $stop;
  end
endmodule
