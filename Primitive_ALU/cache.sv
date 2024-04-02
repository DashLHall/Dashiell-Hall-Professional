module immediate_cache (
  input wire clk,
  input wire [ADDR_WIDTH-1:0] addr,
  input wire [DATA_WIDTH-1:0] mem_data,
  input wire cs_input,
  input wire we,
  input wire oe,
  output reg [DATA_WIDTH-1:0] cache_data
);
  parameter CACHE_SIZE = 16; // Adjust the cache size as needed

  reg [DATA_WIDTH-1:0] cache_memory[CACHE_SIZE];
  reg [ADDR_WIDTH-1:0] cache_tags[CACHE_SIZE];
  reg [ADDR_WIDTH-1:0] cache_index;
  reg hit;

  // Cache index calculation
  always @* begin
    cache_index = addr[ADDR_WIDTH-1:ADDR_WIDTH-$clog2(CACHE_SIZE)];
  end

  // Cache hit detection
  always @(posedge clk) begin
    hit = 0;
    if (cs_input & oe) begin
      if (cache_tags[cache_index] == addr[ADDR_WIDTH-1:ADDR_WIDTH-$clog2(CACHE_SIZE)]) begin
        hit = 1;
      end
    end
  end

  // Cache read and write
  always @(posedge clk) begin
    if (cs_input) begin
      if (we) begin
        // Write to cache and memory
        cache_memory[cache_index] <= mem_data;
        cache_tags[cache_index] <= addr[ADDR_WIDTH-1:ADDR_WIDTH-$clog2(CACHE_SIZE)];
      end else begin
        // Read from cache or memory
        if (hit) begin
          cache_data <= cache_memory[cache_index];
        end else begin
          // Cache miss, read from memory
          cache_data <= mem_data;
        end
      end
    end
  end
endmodule
