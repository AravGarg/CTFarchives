// A simple, slow FIFO.
`timescale 1 ns / 1 ps

`default_nettype none

module fifo #(
    parameter WIDTH = 32,
    parameter DEPTH = 16
)(
    input clk,
    input resetn,

    input  [WIDTH-1:0] in_data,
    input              in_valid,
    output             in_ready,

    output [WIDTH-1:0] out_data,
    output             out_valid,
    input              out_ready
);

localparam DEPTH_LOG2 = $clog2(DEPTH);
// Only accept powers-of-two depths.
initial assert((1 << DEPTH_LOG2) == DEPTH);

// Read/write pointers to the memory.
reg [DEPTH_LOG2-1:0] wr_ptr = 0;
reg [DEPTH_LOG2-1:0] rd_ptr = 0;
// The memory itself.
reg [WIDTH-1:0] mem [0:DEPTH-1];

wire [DEPTH_LOG2-1:0] wr_ptr_nxt = wr_ptr + 1'b1;
wire full  = (wr_ptr_nxt == rd_ptr);
wire empty = (rd_ptr == wr_ptr);

// Implement write.
always @(posedge clk)
    mem[wr_ptr] <= in_data;

// FIFO write
always @(posedge clk) begin
    if (!resetn) begin
        wr_ptr <= 0;
    end else begin
        if (in_valid & !full) begin
            wr_ptr <= wr_ptr + 1'b1;
        end
    end
end

// FIFO read
always @(posedge clk) begin
    if (!resetn) begin
        rd_ptr <= 0;
    end else begin
        if (out_ready & !empty) begin
            rd_ptr <= rd_ptr + 1'b1;
        end
    end
end

// Wire things up.
assign in_ready = !full;
assign out_data = mem[rd_ptr];
assign out_valid = !empty;

endmodule
