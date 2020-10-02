// Memory map:
// 00000000-0001ffff - IRAM
// f0000000-00000fff - UART
// f0010000-00001fff - LPT
// f0100000-00001fff - Flag Device TM

`timescale 1 ns / 1 ps
`default_nettype none

module axi4_interconnect #(
    parameter AWIDTH = 32,
    parameter DWIDTH = 32
) (
    input clk,
    input resetn,

    // Slave 0 (CPU)
    input reg                   axi_s0_awvalid,
    output reg                  axi_s0_awready = 0,
    input reg      [AWIDTH-1:0] axi_s0_awaddr,
    input reg      [       2:0] axi_s0_awprot,
    input reg                   axi_s0_wvalid,
    output reg                  axi_s0_wready = 0,
    input reg      [DWIDTH-1:0] axi_s0_wdata,
    input reg      [       3:0] axi_s0_wstrb,
    output reg                  axi_s0_bvalid = 0,
    input reg                   axi_s0_bready,
    input reg                   axi_s0_arvalid,
    output reg                  axi_s0_arready = 0,
    input reg      [AWIDTH-1:0] axi_s0_araddr,
    input reg      [       2:0] axi_s0_arprot,
    output reg                  axi_s0_rvalid = 0,
    input reg                   axi_s0_rready,
    output reg     [DWIDTH-1:0] axi_s0_rdata,

    // Slave 1 (LPT DMA)
    input reg                   axi_s1_awvalid,
    output reg                  axi_s1_awready = 0,
    input reg      [AWIDTH-1:0] axi_s1_awaddr,
    input reg      [       2:0] axi_s1_awprot,
    input reg                   axi_s1_wvalid,
    output reg                  axi_s1_wready = 0,
    input reg      [DWIDTH-1:0] axi_s1_wdata,
    input reg      [       3:0] axi_s1_wstrb,
    output reg                  axi_s1_bvalid = 0,
    input reg                   axi_s1_bready,
    input reg                   axi_s1_arvalid,
    output reg                  axi_s1_arready = 0,
    input reg      [AWIDTH-1:0] axi_s1_araddr,
    input reg      [       2:0] axi_s1_arprot,
    output reg                  axi_s1_rvalid = 0,
    input reg                   axi_s1_rready,
    output reg     [DWIDTH-1:0] axi_s1_rdata,

    // Master 0 (IRAM)
    output reg                  axi_m0_awvalid = 0,
    input reg                   axi_m0_awready,
    output reg     [AWIDTH-1:0] axi_m0_awaddr,
    output reg            [2:0] axi_m0_awprot,
    output reg                  axi_m0_wvalid = 0,
    input reg                   axi_m0_wready,
    output reg     [DWIDTH-1:0] axi_m0_wdata,
    output reg            [3:0] axi_m0_wstrb,
    input reg                   axi_m0_bvalid,
    output reg                  axi_m0_bready = 0,
    output reg                  axi_m0_arvalid = 0,
    input reg                   axi_m0_arready,
    output reg     [AWIDTH-1:0] axi_m0_araddr,
    output reg            [2:0] axi_m0_arprot,
    input reg                   axi_m0_rvalid,
    output reg                  axi_m0_rready = 0,
    input reg      [DWIDTH-1:0] axi_m0_rdata,

    // Master 1 (UART)
    output reg                  axi_m1_awvalid = 0,
    input reg                   axi_m1_awready,
    output reg     [AWIDTH-1:0] axi_m1_awaddr,
    output reg            [2:0] axi_m1_awprot,
    output reg                  axi_m1_wvalid = 0,
    input reg                   axi_m1_wready,
    output reg     [DWIDTH-1:0] axi_m1_wdata,
    output reg            [3:0] axi_m1_wstrb,
    input reg                   axi_m1_bvalid,
    output reg                  axi_m1_bready = 0,
    output reg                  axi_m1_arvalid = 0,
    input reg                   axi_m1_arready,
    output reg     [AWIDTH-1:0] axi_m1_araddr,
    output reg            [2:0] axi_m1_arprot,
    input reg                   axi_m1_rvalid,
    output reg                  axi_m1_rready = 0,
    input reg      [DWIDTH-1:0] axi_m1_rdata,

    // Master 2 (LPT)
    output reg                  axi_m2_awvalid = 0,
    input reg                   axi_m2_awready,
    output reg     [AWIDTH-1:0] axi_m2_awaddr,
    output reg            [2:0] axi_m2_awprot,
    output reg                  axi_m2_wvalid = 0,
    input reg                   axi_m2_wready,
    output reg     [DWIDTH-1:0] axi_m2_wdata,
    output reg            [3:0] axi_m2_wstrb,
    input reg                   axi_m2_bvalid,
    output reg                  axi_m2_bready = 0,
    output reg                  axi_m2_arvalid = 0,
    input reg                   axi_m2_arready,
    output reg     [AWIDTH-1:0] axi_m2_araddr,
    output reg            [2:0] axi_m2_arprot,
    input reg                   axi_m2_rvalid,
    output reg                  axi_m2_rready = 0,
    input reg      [DWIDTH-1:0] axi_m2_rdata,

    // Master 3 (Flag device TM xD)
    output reg                  axi_m3_awvalid = 0,
    input reg                   axi_m3_awready,
    output reg     [AWIDTH-1:0] axi_m3_awaddr,
    output reg            [2:0] axi_m3_awprot,
    output reg                  axi_m3_wvalid = 0,
    input reg                   axi_m3_wready,
    output reg     [DWIDTH-1:0] axi_m3_wdata,
    output reg            [3:0] axi_m3_wstrb,
    input reg                   axi_m3_bvalid,
    output reg                  axi_m3_bready = 0,
    output reg                  axi_m3_arvalid = 0,
    input reg                   axi_m3_arready,
    output reg     [AWIDTH-1:0] axi_m3_araddr,
    output reg            [2:0] axi_m3_arprot,
    input reg                   axi_m3_rvalid,
    output reg                  axi_m3_rready = 0,
    input reg      [DWIDTH-1:0] axi_m3_rdata
);

wire request_pending = axi_s0_arvalid | axi_s0_awvalid |
                       axi_s1_arvalid | axi_s1_awvalid;

wire s0_pending = axi_s0_arvalid | axi_s0_awvalid;
wire s1_pending = axi_s1_arvalid | axi_s1_awvalid;

wire read_pending = axi_s0_arvalid | axi_s1_arvalid;
wire write_pending = axi_s0_awvalid | axi_s1_awvalid;

wire read_finished = (axi_s0_rready & axi_s0_rvalid) |
                     (axi_s1_rready & axi_s1_rvalid);

wire write_finished = (axi_s0_bready & axi_s0_bvalid) |
                      (axi_s1_bready & axi_s1_bvalid);

reg [1:0] masterno = 0;
reg read = 0;
reg write = 0;
wire busy = read | write;

reg [AWIDTH-1:0] request_addr = 0;

// Select master and action, get action address.
always @(posedge clk) begin
    if (~resetn) begin
        read <= 0;
        write <= 0;
        masterno <= 0;
        request_addr <= 0;
    end else begin
        if (~busy & request_pending) begin
            // Have to priority encode here...
            if (s0_pending) begin
                masterno <= 0;
            end else if (s1_pending) begin
                masterno <= 1;
            end
            if (read_pending) begin
                read <= 1;
                write <= 0;
                request_addr <= s0_pending ? axi_s0_araddr :
                                s1_pending ? axi_s1_araddr : 0;
            end else if (write_pending) begin
                read <= 0;
                write <= 1;
                request_addr <= s0_pending ? axi_s0_awaddr :
                                s1_pending ? axi_s1_awaddr : 0;
            end
        end else if (busy) begin
            if (read & read_finished) begin
                read <= 0;
            end else if (write & write_finished) begin
                write <= 0;
            end
        end
    end
end

// Select slave.
wire [2:0] slaveno = ~busy ? 0 :
                     // RAM is selected by top 16 bits being 0
                     ((request_addr & 32'hFFFF0000) == 32'h00000000) ? 0 :
                     // Peripherals are selected by top 4 bits being f
                     ((request_addr & 32'hF0000000) == 32'hF0000000) ? (
                         // UART
                         (( request_addr & 32'h0FFF0000) == 32'h00000000) ? 1 :
                         // LPT
                         (( request_addr & 32'h0FFF0000) == 32'h00010000) ? 2 :
                         // Flag Device TM
                         (( request_addr & 32'h0FFF0000) == 32'h00100000) ? 3 :
                         0
                     ) :
                     // Everything else goes to RAM, yolo.
                     0;

// Calculate target address.
wire [AWIDTH-1:0] slave_addr = ~busy ? 0 :
                               (slaveno == 0) ? (request_addr & 32'h0001FFFF) :
                               (slaveno == 1) ? (request_addr & 32'h0000FFFF) :
                               (slaveno == 2) ? (request_addr & 32'h0000FFFF) :
                               (slaveno == 3) ? (request_addr & 32'h0000FFFF) :
                               0;

// Internal signals from slave to master.
wire int_awready =            (slaveno == 0) ? axi_m0_awready :
                              (slaveno == 1) ? axi_m1_awready :
                              (slaveno == 2) ? axi_m2_awready :
                              (slaveno == 3) ? axi_m3_awready : 0;
wire int_wready =             (slaveno == 0) ? axi_m0_wready :
                              (slaveno == 1) ? axi_m1_wready :
                              (slaveno == 2) ? axi_m2_wready :
                              (slaveno == 3) ? axi_m3_wready : 0;
wire int_bvalid =             (slaveno == 0) ? axi_m0_bvalid :
                              (slaveno == 1) ? axi_m1_bvalid :
                              (slaveno == 2) ? axi_m2_bvalid :
                              (slaveno == 3) ? axi_m3_bvalid : 0;
wire int_arready =            (slaveno == 0) ? axi_m0_arready :
                              (slaveno == 1) ? axi_m1_arready :
                              (slaveno == 2) ? axi_m2_arready :
                              (slaveno == 3) ? axi_m3_arready : 0;
wire int_rvalid =             (slaveno == 0) ? axi_m0_rvalid :
                              (slaveno == 1) ? axi_m1_rvalid :
                              (slaveno == 2) ? axi_m2_rvalid :
                              (slaveno == 3) ? axi_m3_rvalid : 0;
wire [DWIDTH-1:0] int_rdata = (slaveno == 0) ? axi_m0_rdata :
                              (slaveno == 1) ? axi_m1_rdata :
                              (slaveno == 2) ? axi_m2_rdata :
                              (slaveno == 3) ? axi_m3_rdata : 32'h0;

// Internal signals from master to slave.
wire int_awvalid            = (masterno == 0) ? axi_s0_awvalid :
                              (masterno == 1) ? axi_s1_awvalid : 0;
wire [2:0] int_awprot       = (masterno == 0) ? axi_s0_awprot :
                              (masterno == 1) ? axi_s1_awprot : 3'h0;
wire int_wvalid             = (masterno == 0) ? axi_s0_wvalid :
                              (masterno == 1) ? axi_s1_wvalid : 0;
wire [DWIDTH-1:0] int_wdata = (masterno == 0) ? axi_s0_wdata :
                              (masterno == 1) ? axi_s1_wdata : 32'h0;
wire [3:0] int_wstrb        = (masterno == 0) ? axi_s0_wstrb :
                              (masterno == 1) ? axi_s1_wstrb : 4'h0;
wire int_bready             = (masterno == 0) ? axi_s0_bready :
                              (masterno == 1) ? axi_s1_bready : 0;
wire int_arvalid            = (masterno == 0) ? axi_s0_arvalid :
                              (masterno == 1) ? axi_s1_arvalid : 0;
wire [2:0] int_arprot       = (masterno == 0) ? axi_s0_arprot :
                              (masterno == 1) ? axi_s1_arprot : 3'h0;
wire int_rready             = (masterno == 0) ? axi_s0_rready :
                              (masterno == 1) ? axi_s1_rready : 0;
                           
// Wire signals from slave to master.
always @(*) begin
    if (resetn & busy & (masterno == 0)) begin
        axi_s0_awready = int_awready;
        axi_s0_wready = int_wready;
        axi_s0_bvalid = int_bvalid;
        axi_s0_arready = int_arready;
        axi_s0_rvalid = int_rvalid;
        axi_s0_rdata = int_rdata;
    end else begin
        axi_s0_awready = 0;
        axi_s0_wready = 0;
        axi_s0_bvalid = 0;
        axi_s0_arready = 0;
        axi_s0_rvalid = 0;
        axi_s0_rdata = 0;
    end
end
always @(*) begin
    if (resetn & busy & (masterno == 1)) begin
        axi_s1_awready = int_awready;
        axi_s1_wready = int_wready;
        axi_s1_bvalid = int_bvalid;
        axi_s1_arready = int_arready;
        axi_s1_rvalid = int_rvalid;
        axi_s1_rdata = int_rdata;
    end else begin
        axi_s1_awready = 0;
        axi_s1_wready = 0;
        axi_s1_bvalid = 0;
        axi_s1_arready = 0;
        axi_s1_rvalid = 0;
        axi_s1_rdata = 32'h0;
    end
end

// Wire signals from master to slave.
always @(*) begin
    if (resetn & busy & (slaveno == 0)) begin
        axi_m0_awvalid = int_awvalid;
        axi_m0_awaddr = slave_addr;
        axi_m0_awprot = int_awprot;
        axi_m0_wvalid = int_wvalid;
        axi_m0_wdata = int_wdata;
        axi_m0_wstrb = int_wstrb;
        axi_m0_bready = int_bready;
        axi_m0_arvalid = int_arvalid;
        axi_m0_araddr = slave_addr;
        axi_m0_arprot = int_arprot;
        axi_m0_rready = int_rready;
    end else begin
        axi_m0_awvalid = 0;
        axi_m0_awaddr = 32'h0;
        axi_m0_awprot = 3'h0;
        axi_m0_wvalid = 0;
        axi_m0_wdata = 32'h0;
        axi_m0_wstrb = 4'h0;
        axi_m0_bready = 0;
        axi_m0_arvalid = 0;
        axi_m0_araddr = 32'h0;
        axi_m0_arprot = 3'h0;
        axi_m0_rready = 0;
    end
end
always @(*) begin
    if (resetn & busy & (slaveno == 1)) begin
        axi_m1_awvalid = int_awvalid;
        axi_m1_awaddr = slave_addr;
        axi_m1_awprot = int_awprot;
        axi_m1_wvalid = int_wvalid;
        axi_m1_wdata = int_wdata;
        axi_m1_wstrb = int_wstrb;
        axi_m1_bready = int_bready;
        axi_m1_arvalid = int_arvalid;
        axi_m1_araddr = slave_addr;
        axi_m1_arprot = int_arprot;
        axi_m1_rready = int_rready;
    end else begin
        axi_m1_awvalid = 0;
        axi_m1_awaddr = 32'h0;
        axi_m1_awprot = 3'h0;
        axi_m1_wvalid = 0;
        axi_m1_wdata = 32'h0;
        axi_m1_wstrb = 4'h0;
        axi_m1_bready = 0;
        axi_m1_arvalid = 0;
        axi_m1_araddr = 32'h0;
        axi_m1_arprot = 3'h0;
        axi_m1_rready = 0;
    end
end
always @(*) begin
    if (resetn & busy & (slaveno == 2)) begin
        axi_m2_awvalid = int_awvalid;
        axi_m2_awaddr = slave_addr;
        axi_m2_awprot = int_awprot;
        axi_m2_wvalid = int_wvalid;
        axi_m2_wdata = int_wdata;
        axi_m2_wstrb = int_wstrb;
        axi_m2_bready = int_bready;
        axi_m2_arvalid = int_arvalid;
        axi_m2_araddr = slave_addr;
        axi_m2_arprot = int_arprot;
        axi_m2_rready = int_rready;
    end else begin
        axi_m2_awvalid = 0;
        axi_m2_awaddr = 32'h0;
        axi_m2_awprot = 3'h0;
        axi_m2_wvalid = 0;
        axi_m2_wdata = 32'h0;
        axi_m2_wstrb = 4'h0;
        axi_m2_bready = 0;
        axi_m2_arvalid = 0;
        axi_m2_araddr = 32'h0;
        axi_m2_arprot = 3'h0;
        axi_m2_rready = 0;
    end
end
always @(*) begin
    if (resetn & busy & (slaveno == 3)) begin
        axi_m3_awvalid = int_awvalid;
        axi_m3_awaddr = slave_addr;
        axi_m3_awprot = int_awprot;
        axi_m3_wvalid = int_wvalid;
        axi_m3_wdata = int_wdata;
        axi_m3_wstrb = int_wstrb;
        axi_m3_bready = int_bready;
        axi_m3_arvalid = int_arvalid;
        axi_m3_araddr = slave_addr;
        axi_m3_arprot = int_arprot;
        axi_m3_rready = int_rready;
    end else begin
        axi_m3_awvalid = 0;
        axi_m3_awaddr = 32'h0;
        axi_m3_awprot = 3'h0;
        axi_m3_wvalid = 0;
        axi_m3_wdata = 32'h0;
        axi_m3_wstrb = 4'h0;
        axi_m3_bready = 0;
        axi_m3_arvalid = 0;
        axi_m3_araddr = 32'h0;
        axi_m3_arprot = 3'h0;
        axi_m3_rready = 0;
    end
end

endmodule : axi4_interconnect
