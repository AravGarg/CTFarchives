`default_nettype none
`timescale 1 ns / 1 ps

module top (
    // System clock & reset.
    input clk,
    input resetn,
    output trap,

    // System clock-synchronous lpt FIFO to MAC.
    input  [31:0] lpt_in_data,
    input         lpt_in_valid,
    output        lpt_in_ready,
    output [31:0] lpt_out_data,
    output        lpt_out_valid,
    input         lpt_out_ready,

    // Serial debug.
    output uart_tx
);

// AXI Memory CPU Interface
wire        axi_cpu_awvalid;
wire        axi_cpu_awready;
wire [31:0] axi_cpu_awaddr;
wire [ 2:0] axi_cpu_awprot;
wire        axi_cpu_wvalid;
wire        axi_cpu_wready;
wire [31:0] axi_cpu_wdata;
wire [ 3:0] axi_cpu_wstrb;
wire        axi_cpu_bvalid;
wire        axi_cpu_bready;
wire        axi_cpu_arvalid;
wire        axi_cpu_arready;
wire [31:0] axi_cpu_araddr;
wire [ 2:0] axi_cpu_arprot;
wire        axi_cpu_rvalid;
wire        axi_cpu_rready;
wire [31:0] axi_cpu_rdata;

// AXI Memory Slave Interface
wire        axi_mem_awvalid;
wire        axi_mem_awready;
wire [31:0] axi_mem_awaddr;
wire [ 2:0] axi_mem_awprot;
wire        axi_mem_wvalid;
wire        axi_mem_wready;
wire [31:0] axi_mem_wdata;
wire [ 3:0] axi_mem_wstrb;
wire        axi_mem_bvalid;
wire        axi_mem_bready;
wire        axi_mem_arvalid;
wire        axi_mem_arready;
wire [31:0] axi_mem_araddr;
wire [ 2:0] axi_mem_arprot;
wire        axi_mem_rvalid;
wire        axi_mem_rready;
wire [31:0] axi_mem_rdata;

// AXI UART Slave Interface
wire        axi_uart_awvalid;
wire        axi_uart_awready;
wire [31:0] axi_uart_awaddr;
wire [ 2:0] axi_uart_awprot;
wire        axi_uart_wvalid;
wire        axi_uart_wready;
wire [31:0] axi_uart_wdata;
wire [ 3:0] axi_uart_wstrb;
wire        axi_uart_bvalid;
wire        axi_uart_bready;
wire        axi_uart_arvalid;
wire        axi_uart_arready;
wire [31:0] axi_uart_araddr;
wire [ 2:0] axi_uart_arprot;
wire        axi_uart_rvalid;
wire        axi_uart_rready;
wire [31:0] axi_uart_rdata;

// AXI lpt Slave Interface
wire        axi_lpt_awvalid;
wire        axi_lpt_awready;
wire [31:0] axi_lpt_awaddr;
wire [ 2:0] axi_lpt_awprot;
wire        axi_lpt_wvalid;
wire        axi_lpt_wready;
wire [31:0] axi_lpt_wdata;
wire [ 3:0] axi_lpt_wstrb;
wire        axi_lpt_bvalid;
wire        axi_lpt_bready;
wire        axi_lpt_arvalid;
wire        axi_lpt_arready;
wire [31:0] axi_lpt_araddr;
wire [ 2:0] axi_lpt_arprot;
wire        axi_lpt_rvalid;
wire        axi_lpt_rready;
wire [31:0] axi_lpt_rdata;

// AXI lpt DMA Interface
wire        axi_lpt_dma_awvalid;
wire        axi_lpt_dma_awready;
wire [31:0] axi_lpt_dma_awaddr;
wire [ 2:0] axi_lpt_dma_awprot;
wire        axi_lpt_dma_wvalid;
wire        axi_lpt_dma_wready;
wire [31:0] axi_lpt_dma_wdata;
wire [ 3:0] axi_lpt_dma_wstrb;
wire        axi_lpt_dma_bvalid;
wire        axi_lpt_dma_bready;
wire        axi_lpt_dma_arvalid;
wire        axi_lpt_dma_arready;
wire [31:0] axi_lpt_dma_araddr;
wire [ 2:0] axi_lpt_dma_arprot;
wire        axi_lpt_dma_rvalid;
wire        axi_lpt_dma_rready;
wire [31:0] axi_lpt_dma_rdata;

// AXI Flag Device TM Slave Interface
wire        axi_flag_awvalid;
wire        axi_flag_awready;
wire [31:0] axi_flag_awaddr;
wire [ 2:0] axi_flag_awprot;
wire        axi_flag_wvalid;
wire        axi_flag_wready;
wire [31:0] axi_flag_wdata;
wire [ 3:0] axi_flag_wstrb;
wire        axi_flag_bvalid;
wire        axi_flag_bready;
wire        axi_flag_arvalid;
wire        axi_flag_arready;
wire [31:0] axi_flag_araddr;
wire [ 2:0] axi_flag_arprot;
wire        axi_flag_rvalid;
wire        axi_flag_rready;
wire [31:0] axi_flag_rdata;

// Interrupts

wire        lpt_irq_rx;
wire        lpt_irq_rx_full;
wire        lpt_irq_tx;
wire [31:0] cpu_irq = {
                        1'b0, 1'b0, 1'b0, 1'b0,
                        1'b0, 1'b0, 1'b0, 1'b0, 
                        1'b0, 1'b0, 1'b0, 1'b0, 
                        1'b0, 1'b0, 1'b0, 1'b0, 
                        1'b0, 1'b0, 1'b0, 1'b0, 
                        1'b0, 1'b0, 1'b0, 1'b0, 
                        1'b0, 1'b0, 1'b0, 1'b0,
                        lpt_irq_rx, lpt_irq_rx_full, lpt_irq_tx, 1'b0 };

wire [31:0] cpu_eoi;

// AXI Memory Slave

axi4_memory #(
    .AXI_TEST(0),
    .VERBOSE(0)
) mem (
    .clk(clk),
   	.mem_axi_awvalid (axi_mem_awvalid ),
	.mem_axi_awready (axi_mem_awready ),
	.mem_axi_awaddr  (axi_mem_awaddr  ),
	.mem_axi_awprot  (axi_mem_awprot  ),
	.mem_axi_wvalid  (axi_mem_wvalid  ),
	.mem_axi_wready  (axi_mem_wready  ),
	.mem_axi_wdata   (axi_mem_wdata   ),
	.mem_axi_wstrb   (axi_mem_wstrb   ),
	.mem_axi_bvalid  (axi_mem_bvalid  ),
	.mem_axi_bready  (axi_mem_bready  ),
	.mem_axi_arvalid (axi_mem_arvalid ),
	.mem_axi_arready (axi_mem_arready ),
	.mem_axi_araddr  (axi_mem_araddr  ),
	.mem_axi_arprot  (axi_mem_arprot  ),
	.mem_axi_rvalid  (axi_mem_rvalid  ),
	.mem_axi_rready  (axi_mem_rready  ),
    .mem_axi_rdata   (axi_mem_rdata   )
);

initial begin
    $readmemh("./firmware.hex", mem.memory);
end

// AXI UART Slave
axi4_uart #(
) uart (
    .clk(clk),
    .resetn(resetn),
    .uart_tx(uart_tx),
   	.axi_awvalid (axi_uart_awvalid ),
	.axi_awready (axi_uart_awready ),
	.axi_awaddr  (axi_uart_awaddr  ),
	.axi_awprot  (axi_uart_awprot  ),
	.axi_wvalid  (axi_uart_wvalid  ),
	.axi_wready  (axi_uart_wready  ),
	.axi_wdata   (axi_uart_wdata   ),
	.axi_wstrb   (axi_uart_wstrb   ),
	.axi_bvalid  (axi_uart_bvalid  ),
	.axi_bready  (axi_uart_bready  ),
	.axi_arvalid (axi_uart_arvalid ),
	.axi_arready (axi_uart_arready ),
	.axi_araddr  (axi_uart_araddr  ),
	.axi_arprot  (axi_uart_arprot  ),
	.axi_rvalid  (axi_uart_rvalid  ),
	.axi_rready  (axi_uart_rready  ),
    .axi_rdata   (axi_uart_rdata   )
);

// AXI lpt
axi4_lpt lpt (
    .clk(clk),
    .resetn(resetn),
    
    // Control interface.
   	.axi_slave_awvalid (axi_lpt_awvalid ),
	.axi_slave_awready (axi_lpt_awready ),
	.axi_slave_awaddr  (axi_lpt_awaddr  ),
	.axi_slave_awprot  (axi_lpt_awprot  ),
	.axi_slave_wvalid  (axi_lpt_wvalid  ),
	.axi_slave_wready  (axi_lpt_wready  ),
	.axi_slave_wdata   (axi_lpt_wdata   ),
	.axi_slave_wstrb   (axi_lpt_wstrb   ),
	.axi_slave_bvalid  (axi_lpt_bvalid  ),
	.axi_slave_bready  (axi_lpt_bready  ),
	.axi_slave_arvalid (axi_lpt_arvalid ),
	.axi_slave_arready (axi_lpt_arready ),
	.axi_slave_araddr  (axi_lpt_araddr  ),
	.axi_slave_arprot  (axi_lpt_arprot  ),
	.axi_slave_rvalid  (axi_lpt_rvalid  ),
	.axi_slave_rready  (axi_lpt_rready  ),
    .axi_slave_rdata   (axi_lpt_rdata   ),

    // DMA interface.
   	.axi_master_awvalid (axi_lpt_dma_awvalid ),
	.axi_master_awready (axi_lpt_dma_awready ),
	.axi_master_awaddr  (axi_lpt_dma_awaddr  ),
	.axi_master_awprot  (axi_lpt_dma_awprot  ),
	.axi_master_wvalid  (axi_lpt_dma_wvalid  ),
	.axi_master_wready  (axi_lpt_dma_wready  ),
	.axi_master_wdata   (axi_lpt_dma_wdata   ),
	.axi_master_wstrb   (axi_lpt_dma_wstrb   ),
	.axi_master_bvalid  (axi_lpt_dma_bvalid  ),
	.axi_master_bready  (axi_lpt_dma_bready  ),
	.axi_master_arvalid (axi_lpt_dma_arvalid ),
	.axi_master_arready (axi_lpt_dma_arready ),
	.axi_master_araddr  (axi_lpt_dma_araddr  ),
	.axi_master_arprot  (axi_lpt_dma_arprot  ),
	.axi_master_rvalid  (axi_lpt_dma_rvalid  ),
	.axi_master_rready  (axi_lpt_dma_rready  ),
    .axi_master_rdata   (axi_lpt_dma_rdata   ),

    // Physical interface
    .lpt_in_data(lpt_in_data),
    .lpt_in_valid(lpt_in_valid),
    .lpt_in_ready(lpt_in_ready),
    .lpt_out_data(lpt_out_data),
    .lpt_out_valid(lpt_out_valid),
    .lpt_out_ready(lpt_out_ready),

    // IRQ
    .irq_rx_done(lpt_irq_rx),
    .irq_rx_full(lpt_irq_rx_full),
    .irq_tx_done(lpt_irq_tx)
);

// FlagDeviceTM
axi4_flagdevicetm flagdevicetm (
    .clk(clk),
    .resetn(resetn),

    // Control interface.
    .axi_slave_awvalid (axi_flag_awvalid ),
    .axi_slave_awready (axi_flag_awready ),
    .axi_slave_awaddr  (axi_flag_awaddr  ),
    .axi_slave_awprot  (axi_flag_awprot  ),
    .axi_slave_wvalid  (axi_flag_wvalid  ),
    .axi_slave_wready  (axi_flag_wready  ),
    .axi_slave_wdata   (axi_flag_wdata   ),
    .axi_slave_wstrb   (axi_flag_wstrb   ),
    .axi_slave_bvalid  (axi_flag_bvalid  ),
    .axi_slave_bready  (axi_flag_bready  ),
    .axi_slave_arvalid (axi_flag_arvalid ),
    .axi_slave_arready (axi_flag_arready ),
    .axi_slave_araddr  (axi_flag_araddr  ),
    .axi_slave_arprot  (axi_flag_arprot  ),
    .axi_slave_rvalid  (axi_flag_rvalid  ),
    .axi_slave_rready  (axi_flag_rready  ),
    .axi_slave_rdata   (axi_flag_rdata   )
);

// PicoRV32 core
picorv32_axi #(
    .ENABLE_MUL(1),
    .ENABLE_DIV(1),
    .COMPRESSED_ISA(1),
    .ENABLE_IRQ(1)
) cpu (
    .clk(clk),
    .resetn(resetn),
    .trap(trap),
    .irq(cpu_irq),
    .eoi(cpu_eoi),
    .mem_axi_awvalid(axi_cpu_awvalid),
    .mem_axi_awready(axi_cpu_awready),
    .mem_axi_awaddr (axi_cpu_awaddr ),
    .mem_axi_awprot (axi_cpu_awprot ),
    .mem_axi_wvalid (axi_cpu_wvalid ),
    .mem_axi_wready (axi_cpu_wready ),
    .mem_axi_wdata  (axi_cpu_wdata  ),
    .mem_axi_wstrb  (axi_cpu_wstrb  ),
    .mem_axi_bvalid (axi_cpu_bvalid ),
    .mem_axi_bready (axi_cpu_bready ),
    .mem_axi_arvalid(axi_cpu_arvalid),
    .mem_axi_arready(axi_cpu_arready),
    .mem_axi_araddr (axi_cpu_araddr ),
    .mem_axi_arprot (axi_cpu_arprot ),
    .mem_axi_rvalid (axi_cpu_rvalid ),
    .mem_axi_rready (axi_cpu_rready ),
    .mem_axi_rdata  (axi_cpu_rdata  )
);

// Interconnect
axi4_interconnect inter (
    .clk(clk),
    .resetn(resetn),

    // Master 0: CPU
    .axi_s0_awvalid(axi_cpu_awvalid),
    .axi_s0_awready(axi_cpu_awready),
    .axi_s0_awaddr (axi_cpu_awaddr),
    .axi_s0_awprot (axi_cpu_awprot),
    .axi_s0_wvalid (axi_cpu_wvalid),
    .axi_s0_wready (axi_cpu_wready),
    .axi_s0_wdata  (axi_cpu_wdata),
    .axi_s0_wstrb  (axi_cpu_wstrb),
    .axi_s0_bvalid (axi_cpu_bvalid),
    .axi_s0_bready (axi_cpu_bready),
    .axi_s0_arvalid(axi_cpu_arvalid),
    .axi_s0_arready(axi_cpu_arready),
    .axi_s0_araddr (axi_cpu_araddr),
    .axi_s0_arprot (axi_cpu_arprot),
    .axi_s0_rvalid (axi_cpu_rvalid),
    .axi_s0_rready (axi_cpu_rready),
    .axi_s0_rdata  (axi_cpu_rdata),

    // Master 1: lpt DMA
    .axi_s1_awvalid(axi_lpt_dma_awvalid),
    .axi_s1_awready(axi_lpt_dma_awready),
    .axi_s1_awaddr (axi_lpt_dma_awaddr),
    .axi_s1_awprot (axi_lpt_dma_awprot),
    .axi_s1_wvalid (axi_lpt_dma_wvalid),
    .axi_s1_wready (axi_lpt_dma_wready),
    .axi_s1_wdata  (axi_lpt_dma_wdata),
    .axi_s1_wstrb  (axi_lpt_dma_wstrb),
    .axi_s1_bvalid (axi_lpt_dma_bvalid),
    .axi_s1_bready (axi_lpt_dma_bready),
    .axi_s1_arvalid(axi_lpt_dma_arvalid),
    .axi_s1_arready(axi_lpt_dma_arready),
    .axi_s1_araddr (axi_lpt_dma_araddr),
    .axi_s1_arprot (axi_lpt_dma_arprot),
    .axi_s1_rvalid (axi_lpt_dma_rvalid),
    .axi_s1_rready (axi_lpt_dma_rready),
    .axi_s1_rdata  (axi_lpt_dma_rdata),

    // Slave 0: RAM
    .axi_m0_awvalid(axi_mem_awvalid),
    .axi_m0_awready(axi_mem_awready),
    .axi_m0_awaddr (axi_mem_awaddr),
    .axi_m0_awprot (axi_mem_awprot),
    .axi_m0_wvalid (axi_mem_wvalid),
    .axi_m0_wready (axi_mem_wready),
    .axi_m0_wdata  (axi_mem_wdata),
    .axi_m0_wstrb  (axi_mem_wstrb),
    .axi_m0_bvalid (axi_mem_bvalid),
    .axi_m0_bready (axi_mem_bready),
    .axi_m0_arvalid(axi_mem_arvalid),
    .axi_m0_arready(axi_mem_arready),
    .axi_m0_araddr (axi_mem_araddr),
    .axi_m0_arprot (axi_mem_arprot),
    .axi_m0_rvalid (axi_mem_rvalid),
    .axi_m0_rready (axi_mem_rready),
    .axi_m0_rdata  (axi_mem_rdata),

    // Slave 1: UART
    .axi_m1_awvalid(axi_uart_awvalid),
    .axi_m1_awready(axi_uart_awready),
    .axi_m1_awaddr (axi_uart_awaddr),
    .axi_m1_awprot (axi_uart_awprot),
    .axi_m1_wvalid (axi_uart_wvalid),
    .axi_m1_wready (axi_uart_wready),
    .axi_m1_wdata  (axi_uart_wdata),
    .axi_m1_wstrb  (axi_uart_wstrb),
    .axi_m1_bvalid (axi_uart_bvalid),
    .axi_m1_bready (axi_uart_bready),
    .axi_m1_arvalid(axi_uart_arvalid),
    .axi_m1_arready(axi_uart_arready),
    .axi_m1_araddr (axi_uart_araddr),
    .axi_m1_arprot (axi_uart_arprot),
    .axi_m1_rvalid (axi_uart_rvalid),
    .axi_m1_rready (axi_uart_rready),
    .axi_m1_rdata  (axi_uart_rdata),

    // Slave 2: RAM
    .axi_m2_awvalid(axi_lpt_awvalid),
    .axi_m2_awready(axi_lpt_awready),
    .axi_m2_awaddr (axi_lpt_awaddr),
    .axi_m2_awprot (axi_lpt_awprot),
    .axi_m2_wvalid (axi_lpt_wvalid),
    .axi_m2_wready (axi_lpt_wready),
    .axi_m2_wdata  (axi_lpt_wdata),
    .axi_m2_wstrb  (axi_lpt_wstrb),
    .axi_m2_bvalid (axi_lpt_bvalid),
    .axi_m2_bready (axi_lpt_bready),
    .axi_m2_arvalid(axi_lpt_arvalid),
    .axi_m2_arready(axi_lpt_arready),
    .axi_m2_araddr (axi_lpt_araddr),
    .axi_m2_arprot (axi_lpt_arprot),
    .axi_m2_rvalid (axi_lpt_rvalid),
    .axi_m2_rready (axi_lpt_rready),
    .axi_m2_rdata  (axi_lpt_rdata),

    // Slave 3: Flag Device TM
    .axi_m3_awvalid(axi_flag_awvalid),
    .axi_m3_awready(axi_flag_awready),
    .axi_m3_awaddr (axi_flag_awaddr),
    .axi_m3_awprot (axi_flag_awprot),
    .axi_m3_wvalid (axi_flag_wvalid),
    .axi_m3_wready (axi_flag_wready),
    .axi_m3_wdata  (axi_flag_wdata),
    .axi_m3_wstrb  (axi_flag_wstrb),
    .axi_m3_bvalid (axi_flag_bvalid),
    .axi_m3_bready (axi_flag_bready),
    .axi_m3_arvalid(axi_flag_arvalid),
    .axi_m3_arready(axi_flag_arready),
    .axi_m3_araddr (axi_flag_araddr),
    .axi_m3_arprot (axi_flag_arprot),
    .axi_m3_rvalid (axi_flag_rvalid),
    .axi_m3_rready (axi_flag_rready),
    .axi_m3_rdata  (axi_flag_rdata)
);

endmodule
