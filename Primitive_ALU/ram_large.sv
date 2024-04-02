`timescale 1ns / 1ps
`include "decoder.sv"
`include "ram.sv"

module single_port_sync_ram_large #(
  parameter ADDR_WIDTH = 16,
  parameter DATA_WIDTH = 8,
  parameter DATA_WIDTH_SHIFT = 1
) (
  input wire clk,
  input wire [ADDR_WIDTH-1:0] addr,
  inout wire [DATA_WIDTH-1:0] data,
  input wire cs_input,
  input wire we,
  input wire oe
);

  wire [3:0] cs;
  wire [DATA_WIDTH-1:0] data_internal[4];

  decoder #(.ENCODE_WIDTH(2)) dec (
    .in(addr[ADDR_WIDTH-1:ADDR_WIDTH-2]),
    .out(cs)
  );

  generate
    genvar i;
    for (i = 0; i < 4; i = i + 1) begin : ram_instances_gen
      single_port_sync_ram #(
        .ADDR_WIDTH(ADDR_WIDTH - 2), // Adjusted the ADDR_WIDTH
        .DATA_WIDTH(DATA_WIDTH),
        .LENGTH(1 << (ADDR_WIDTH - 2))
      ) ram_instance (
        .clk(clk),
        .addr(addr[ADDR_WIDTH-1:2]), // Adjusted the addr width
        .data(data_internal[i]),
        .cs(cs[i]),
        .we(we),
        .oe(oe)
      );
    end
  endgenerate

  // Concatenate the data from each instance
  assign data = {data_internal[3], data_internal[2], data_internal[1], data_internal[0]};

endmodule
