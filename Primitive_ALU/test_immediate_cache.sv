`timescale 1ns / 1ps
`include "cache.sv"

module test_immediate_cache;
  // Parameters
  parameter ADDR_WIDTH = 16;
  parameter DATA_WIDTH = 8;
  parameter CACHE_SIZE = 16;

  // Signals
  reg clk;
  reg [ADDR_WIDTH-1:0] addr;
  reg [DATA_WIDTH-1:0] mem_data;
  reg cs_input, we, oe;
  wire [DATA_WIDTH-1:0] cache_data;

  // Instantiate immediate_cache module
  immediate_cache #(
    .ADDR_WIDTH(ADDR_WIDTH),
    .DATA_WIDTH(DATA_WIDTH),
    .CACHE_SIZE(CACHE_SIZE)
  ) imm_cache (
    .clk(clk),
    .addr(addr),
    .mem_data(mem_data),
    .cs_input(cs_input),
    .we(we),
    .oe(oe),
    .cache_data(cache_data)
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
    addr = 8'b0000_0000;
    mem_data = 8'b1010_1010;
    cs_input = 1;
    we = 1;
    oe = 0;

    // Wait for a few clock cycles
    #10;

    // Read from cache (hit)
    we = 0;
    oe = 1;
    // Assuming cache hit, data should be read from cache
    if (cache_data !== mem_data) $display("Error: Cache read mismatch!");

    // Wait for a few clock cycles
    #10;

    // Read from cache (miss)
    addr = 8'b0000_0100; // Change address to simulate a cache miss
    // Assuming cache miss, data should be read from mem_data
    if (cache_data !== mem_data) $display("Error: Cache read mismatch!");

    // Finish simulation
    $stop;
  end
endmodule
