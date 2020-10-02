`timescale 1 ns / 1 ps
`default_nettype none

module axi4_uart #(
    parameter DIVIDER = 100 // 1000000 baud @100MHz
) (
    input clk,
    input resetn,

    output reg uart_tx,

    input reg             axi_awvalid,
    output reg        axi_awready = 0,
    input reg      [31:0] axi_awaddr,
    input reg      [ 2:0] axi_awprot,
    input reg             axi_wvalid,
    output reg            axi_wready = 0,
    input reg      [31:0] axi_wdata,
    input reg      [ 3:0] axi_wstrb,
    output reg            axi_bvalid = 0,
    input reg             axi_bready,
    input reg             axi_arvalid,
    output reg            axi_arready = 0,
    input reg      [31:0] axi_araddr,
    input reg      [ 2:0] axi_arprot,
    output reg            axi_rvalid = 0,
    input reg             axi_rready,
    output reg     [31:0] axi_rdata
);

// Tie off reads.

assign axi_arready = axi_arvalid;
assign axi_rvalid = axi_rready;

// Tx FIFO.
reg [7:0] fifo_tx_in_data;
reg       fifo_tx_in_valid;
reg       fifo_tx_in_ready;
reg [7:0] fifo_tx_out_data;
reg       fifo_tx_out_valid;
reg       fifo_tx_out_ready;
fifo #(
    .WIDTH(8),
    .DEPTH(64)
) fifo_tx (
    .clk(clk),
    .resetn(resetn),

    .in_data(fifo_tx_in_data),
    .in_ready(fifo_tx_in_ready),
    .in_valid(fifo_tx_in_valid),
    .out_data(fifo_tx_out_data),
    .out_ready(fifo_tx_out_ready),
    .out_valid(fifo_tx_out_valid)
);

`define STATE_IDLE  4'b0000
`define STATE_START 4'b0001
`define STATE_BIT0  4'b0010
`define STATE_BIT1  4'b0011
`define STATE_BIT2  4'b0100
`define STATE_BIT3  4'b0101
`define STATE_BIT4  4'b0110
`define STATE_BIT5  4'b0111
`define STATE_BIT6  4'b1000
`define STATE_BIT7  4'b1001
`define STATE_STOP  4'b1010

reg [3:0] state = `STATE_IDLE;
reg [3:0] next_state;
wire busy = state != `STATE_IDLE;

reg write_tx = 0;
reg write_error = 0;

always @(posedge clk) begin
    if (~resetn) begin
        axi_awready <= 0;
        write_tx <= 0;
        write_error <= 0;

    end else begin
        if (axi_awvalid && ~axi_awready && fifo_tx_in_ready) begin
            axi_awready <= 1;
        end else if (axi_awvalid && axi_awready) begin
            axi_awready <= 0;
            if (axi_awaddr == 32'b0)
                write_tx <= 1;
            else
                write_error <= 0;
        end else if (axi_bvalid & axi_bready) begin
            write_tx <= 0;
            write_error <= 0;
        end
    end
end

reg [31:0] write_data_latched = 0;
wire write_start = write_tx && axi_wvalid && axi_wready;

always @(posedge clk) begin
    if (~resetn) begin
        axi_wready <= 0;
    end else begin
        if (write_tx || write_error) begin
            if (axi_wvalid && ~axi_wready) begin
                write_data_latched <= axi_wdata;
                axi_wready <= 1;
            end else if (axi_wvalid & axi_wready) begin
                axi_wready <= 0;
            end
        end
    end
end
assign fifo_tx_in_data = write_data_latched[7:0];
assign fifo_tx_in_valid = (axi_wvalid & axi_wready);

always @(posedge clk) begin
    if (~resetn) begin
        axi_bvalid <= 0;
     end else begin
         if (axi_wvalid & axi_wready) begin
             if (!axi_bvalid) begin
                 axi_bvalid <= 1;
             end
         end else if (axi_bvalid & axi_bready) begin
             axi_bvalid <= 0;
         end
     end
end

always @(posedge clk) begin
    if (~resetn) begin
        state <= `STATE_IDLE;
    end else begin
        state <= next_state;
    end
end

reg [$clog2(DIVIDER)-1:0] downcounter = 0;
wire dc_strobe = downcounter == 0;
reg dc_start;

always @(posedge clk) begin
    if (~resetn) begin
        downcounter <= 0;
    end else begin
        if (dc_start) begin
            downcounter <= DIVIDER;
        end else if (~dc_strobe) begin
            downcounter <= downcounter - 1;
        end
    end
end

reg [7:0] tx_data = 0;
always @(posedge clk) begin
    if (~resetn) begin
        tx_data <= 0;
    end else begin
        case (state)
            `STATE_IDLE: begin
                if (fifo_tx_out_valid) begin
                    tx_data <= fifo_tx_out_data;
                end
            end
        endcase
    end
end

always @(*) begin
    dc_start = 0;
    fifo_tx_out_ready = 0;
    case (state)
        `STATE_IDLE: begin
            uart_tx = 1;
            fifo_tx_out_ready = 1;
            if (fifo_tx_out_valid) begin
                next_state = `STATE_START;
                dc_start = 1;
            end
        end
        `STATE_START: begin
            uart_tx = 0;
            if (dc_strobe) begin
                next_state <= `STATE_BIT0;
                dc_start = 1;
            end
        end
        `STATE_BIT0: begin
            uart_tx = tx_data[0];
            if (dc_strobe) begin
                next_state <= `STATE_BIT1;
                dc_start = 1;
            end
        end
        `STATE_BIT1: begin
            uart_tx = tx_data[1];
            if (dc_strobe) begin
                next_state <= `STATE_BIT2;
                dc_start = 1;
            end
        end
        `STATE_BIT2: begin
            uart_tx = tx_data[2];
            if (dc_strobe) begin
                next_state <= `STATE_BIT3;
                dc_start = 1;
            end
        end
        `STATE_BIT3: begin
            uart_tx = tx_data[3];
            if (dc_strobe) begin
                next_state <= `STATE_BIT4;
                dc_start = 1;
            end
        end
        `STATE_BIT4: begin
            uart_tx = tx_data[4];
            if (dc_strobe) begin
                next_state <= `STATE_BIT5;
                dc_start = 1;
            end
        end
        `STATE_BIT5: begin
            uart_tx = tx_data[5];
            if (dc_strobe) begin
                next_state <= `STATE_BIT6;
                dc_start = 1;
            end
        end
        `STATE_BIT6: begin
            uart_tx = tx_data[6];
            if (dc_strobe) begin
                next_state <= `STATE_BIT7;
                dc_start = 1;
            end
        end
        `STATE_BIT7: begin
            uart_tx = tx_data[7];
            if (dc_strobe) begin
                next_state <= `STATE_STOP;
                dc_start = 1;
            end
        end
        `STATE_STOP: begin
            uart_tx = 1;
            if (dc_strobe) begin
                next_state <= `STATE_IDLE;
            end
        end
    endcase
end

endmodule

