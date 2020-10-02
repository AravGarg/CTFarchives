`timescale 1 ns / 1 ps
module axi4_lpt (
    input clk,
    input resetn,

    // Bidirectional LPT.
    input  [31:0] lpt_in_data,
    input            lpt_in_valid,
    output           lpt_in_ready,
    output [31:0] lpt_out_data,
    output           lpt_out_valid,
    input            lpt_out_ready,

    // AXI slave (control registers) 
    input reg         axi_slave_awvalid,
    output reg        axi_slave_awready = 0,
    input reg  [31:0] axi_slave_awaddr,
    input reg  [ 2:0] axi_slave_awprot,
    input reg         axi_slave_wvalid,
    output reg        axi_slave_wready = 0,
    input reg  [31:0] axi_slave_wdata,
    input reg  [ 3:0] axi_slave_wstrb,
    output reg        axi_slave_bvalid = 0,
    input reg         axi_slave_bready,
    input reg         axi_slave_arvalid,
    output reg        axi_slave_arready = 0,
    input reg  [31:0] axi_slave_araddr,
    input reg  [ 2:0] axi_slave_arprot,
    output reg        axi_slave_rvalid = 0,
    input reg         axi_slave_rready,
    output reg [31:0] axi_slave_rdata,

    // AXI master (DMA)
    output reg        axi_master_awvalid = 0,
    input reg         axi_master_awready,
    output reg [31:0] axi_master_awaddr,
    output reg  [2:0] axi_master_awprot,
    output reg        axi_master_wvalid = 0,
    input reg         axi_master_wready,
    output reg [31:0] axi_master_wdata,
    output reg  [3:0] axi_master_wstrb,
    input reg         axi_master_bvalid,
    output reg        axi_master_bready = 0,
    output reg        axi_master_arvalid = 0,
    input reg         axi_master_arready,
    output reg [31:0] axi_master_araddr,
    output reg  [2:0] axi_master_arprot,
    input reg         axi_master_rvalid,
    output reg        axi_master_rready = 0,
    input reg  [31:0] axi_master_rdata,

    // IRQ
    output irq_rx_done, // Generate interupt if the last received byte is a nullbyte
    output irq_rx_full,
    output irq_tx_done
);

/// Control registers.

// Master state.
reg [31:0] ctrl_state = 32'b0;
wire       ctrl_state_enable_rx           = ctrl_state[0];
wire       ctrl_state_enable_tx           = ctrl_state[1];

// RX ring buffer controls.
reg [31:0] ctrl_rx_buffer_start_ptr = 32'b0;
reg [31:0] ctrl_rx_buffer_end_ptr   = 32'b0;
reg [31:0] ctrl_rx_buffer_rx_ptr   = 32'b0;
reg rx_done;

// TX ring buffer controls.
reg [31:0] ctrl_tx_buffer_start_ptr = 32'b0;
reg [31:0] ctrl_tx_buffer_end_ptr   = 32'b0;

// Control register write from AXI.
reg [31:0] latched_ctrl_awaddr;
reg        latched_ctrl_awaddr_en = 0;
reg [31:0] latched_ctrl_wdata;
reg        latched_ctrl_wdata_en = 0;

// awaddr handshake
always @(posedge clk) begin
    if (!resetn) begin
        latched_ctrl_awaddr_en <= 0;
    end else begin
        if (axi_slave_bvalid & axi_slave_bready) begin
            latched_ctrl_awaddr_en <= 0;
        end else if (axi_slave_awready & axi_slave_awvalid) begin
            latched_ctrl_awaddr <= axi_slave_awaddr;
            latched_ctrl_awaddr_en <= 1;
        end
    end
end

// wdata handshake
always @(posedge clk) begin
    if (!resetn) begin
        latched_ctrl_wdata_en <= 0;
    end else begin
        if (axi_slave_bvalid & axi_slave_bready) begin
            latched_ctrl_wdata_en <= 0;
        end else if (axi_slave_wready & axi_slave_wvalid) begin
            latched_ctrl_wdata <= axi_slave_wdata;
            latched_ctrl_wdata_en <= 1;
        end
    end
end

// return handshake
wire latched_ctrl_en = latched_ctrl_awaddr_en & latched_ctrl_wdata_en;

always @(posedge clk) begin
    if (!resetn) begin
        ctrl_rx_buffer_start_ptr <= 32'b0;
        ctrl_rx_buffer_end_ptr <= 32'b0;
        ctrl_rx_buffer_rx_ptr <= 32'b0;

        ctrl_tx_buffer_start_ptr <= 32'b0;
        ctrl_tx_buffer_end_ptr <= 32'b0;
    end else begin
        if (latched_ctrl_en) begin
            if (latched_ctrl_awaddr == 32'h0)
                ctrl_state <= latched_ctrl_wdata;
            if (latched_ctrl_awaddr == 32'h4) begin
                ctrl_rx_buffer_start_ptr <= latched_ctrl_wdata;
                ctrl_rx_buffer_rx_ptr <= latched_ctrl_wdata;
            end
            if (latched_ctrl_awaddr == 32'h8)
                ctrl_rx_buffer_end_ptr <= latched_ctrl_wdata;
            if (latched_ctrl_awaddr == 32'hc) begin
                ctrl_rx_buffer_rx_ptr <= ctrl_rx_buffer_start_ptr;
                rx_done <= 0;
            end
            if (latched_ctrl_awaddr == 32'h10) begin
                ctrl_tx_buffer_start_ptr <= latched_ctrl_wdata;
                ctrl_tx_buffer_end_ptr <= latched_ctrl_wdata;
            end
            if (latched_ctrl_awaddr == 32'h14) begin
                ctrl_tx_buffer_end_ptr <= latched_ctrl_wdata;
            end
        end
    end
end

assign axi_slave_awready = !latched_ctrl_awaddr_en;
assign axi_slave_wready = !latched_ctrl_wdata_en;
assign axi_slave_bvalid = latched_ctrl_awaddr_en & latched_ctrl_wdata_en;

// Control register read from AXI.
reg [31:0] latched_ctrl_araddr;
reg        latched_ctrl_araddr_en = 0;

always @(posedge clk) begin
    if (!resetn) begin
        latched_ctrl_araddr_en <= 0;
    end else begin
        if (axi_slave_rvalid & axi_slave_rready) begin
            latched_ctrl_araddr_en <= 0;
        end else if (axi_slave_arvalid & axi_slave_arready) begin
            latched_ctrl_araddr <= axi_slave_araddr;
            latched_ctrl_araddr_en <= 1;
        end
    end
end

assign axi_slave_arready = !latched_ctrl_araddr_en;
assign axi_slave_rvalid = latched_ctrl_araddr_en;
assign axi_slave_rdata = latched_ctrl_araddr == 32'h0 ? ctrl_state :
                         latched_ctrl_araddr == 32'h4 ? ctrl_rx_buffer_start_ptr :
                         latched_ctrl_araddr == 32'h8 ? ctrl_rx_buffer_end_ptr :
                         latched_ctrl_araddr == 32'hc ? ctrl_rx_buffer_rx_ptr :
                         latched_ctrl_araddr == 32'h10 ? ctrl_tx_buffer_start_ptr :
                         latched_ctrl_araddr == 32'h14 ? ctrl_tx_buffer_end_ptr : 0;

// Handle FIFO read.
reg          [31:0] latched_rx;
reg          [31:0] latched_waddr;
reg terminator;
reg send;
reg rx_done_irq;

wire axi_master_w_idle = !axi_master_awvalid & !axi_master_wvalid & !axi_master_bvalid;
wire space_left = ((ctrl_rx_buffer_end_ptr - ctrl_rx_buffer_rx_ptr - 4) >= 0);
wire fifo_rx = ctrl_state_enable_rx & axi_master_w_idle & lpt_in_valid & space_left & (!rx_done);

assign lpt_in_ready = ctrl_state_enable_rx & axi_master_w_idle & space_left & (!rx_done);

// Read from FIFO and make DMA write to RAM
always @(posedge clk) begin
    rx_done_irq <= 0;
    terminator <= 0;
    if (!resetn) begin
        latched_rx <= 32'b0;
        latched_waddr <= 32'b0;
        send <= 0;
        rx_done <= 0;

        axi_master_awvalid <= 0;
        axi_master_awaddr <= 32'b0;
        axi_master_awprot <= 3'b0;
        axi_master_wvalid <= 0;
        axi_master_wstrb <= 4'b0;
        axi_master_wdata <= 32'b0;
        axi_master_wstrb <= 4'b0;
        axi_master_bready <= 0;
    end else begin
        if (fifo_rx) begin
            if (lpt_in_data == 32'h0a0a0a0a) begin
                terminator <= 1;
                rx_done <= 1;
            end else begin
                latched_rx <= lpt_in_data;
                latched_waddr <= ctrl_rx_buffer_rx_ptr;
                send <= 1;
            end
        end

        if (send & axi_master_w_idle) begin
            axi_master_awaddr <= latched_waddr;
            axi_master_awvalid <= 1;
            axi_master_wvalid <= 1;
            axi_master_wdata <= latched_rx;
            axi_master_wstrb <= 4'b1111;
            axi_master_bready <= 1;

            ctrl_rx_buffer_rx_ptr <= ctrl_rx_buffer_rx_ptr + 4;
            rx_done <= (ctrl_rx_buffer_rx_ptr + 4) == ctrl_rx_buffer_end_ptr;
            rx_done_irq <= (ctrl_rx_buffer_rx_ptr + 4) == ctrl_rx_buffer_end_ptr;
            send <= 0;
        end else begin
            if (axi_master_awvalid & axi_master_awready) begin
                axi_master_awvalid <= 0;
            end
            if (axi_master_wvalid & axi_master_wready) begin
                axi_master_wvalid <= 0;
            end
            if (axi_master_bvalid & axi_master_bready) begin
                axi_master_bready <= 0;
            end
        end
    end
end

// Route IRQ
reg tx_done;
assign irq_rx_done = ctrl_state_enable_rx & terminator;
assign irq_rx_full = ctrl_state_enable_rx & rx_done_irq & !terminator;
assign irq_tx_done = ctrl_state_enable_tx & tx_done;

// Transmit latch.
reg          lpt_out_valid_latch;
reg          [31:0] tx_latch;
wire axi_master_r_idle = !axi_master_arvalid & !axi_master_rvalid & !axi_master_rready;

// Read from RAM using DMA - send the read result to the serial port
always @(posedge clk) begin
    lpt_out_valid_latch <= 0;
    tx_done <= 0;
    if (!resetn) begin
        axi_master_araddr <= 32'b0;
        axi_master_arvalid <= 0;
        axi_master_rready <= 0;
        tx_latch <= 0;
    end else begin
        if (lpt_out_ready && ctrl_state_enable_tx && ctrl_tx_buffer_start_ptr != ctrl_tx_buffer_end_ptr & axi_master_r_idle) begin
            axi_master_arvalid <= 1;
            axi_master_araddr <= ctrl_tx_buffer_start_ptr;
            axi_master_rready <= 1;
        end else begin
            if (axi_master_arvalid & axi_master_arready) begin
                axi_master_arvalid <= 0;
            end
            if (axi_master_rvalid & axi_master_rready) begin
                axi_master_rready <= 0;
                tx_latch <= axi_master_rdata;
                lpt_out_valid_latch <= 1;
                ctrl_tx_buffer_start_ptr <= ctrl_tx_buffer_start_ptr + 4;
                tx_done <= (ctrl_tx_buffer_start_ptr + 4) == ctrl_tx_buffer_end_ptr;
            end
        end
    end
end

assign lpt_out_valid = lpt_out_valid_latch;
assign lpt_out_data = tx_latch;

endmodule : axi4_lpt
