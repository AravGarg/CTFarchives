`timescale 1 ns / 1 ps
module axi4_flagdevicetm (
    input clk,
    input resetn,

    // AXI slave (control registers)
    input         axi_slave_awvalid,
    output        axi_slave_awready = 0,
    input  [31:0] axi_slave_awaddr,
    input  [ 2:0] axi_slave_awprot,
    input         axi_slave_wvalid,
    output        axi_slave_wready = 0,
    input  [31:0] axi_slave_wdata,
    input  [ 3:0] axi_slave_wstrb,
    output        axi_slave_bvalid = 0,
    input         axi_slave_bready,
    input         axi_slave_arvalid,
    output        axi_slave_arready = 0,
    input  [31:0] axi_slave_araddr,
    input  [ 2:0] axi_slave_arprot,
    output        axi_slave_rvalid = 0,
    input         axi_slave_rready,
    output reg [31:0] axi_slave_rdata
);

/*
MEMORY LAYOUT:
0x00 - 0x0f --- PIN1 | PIN2 | PIN3 | PIN4 | ... | PIN15
0x10 - 0x13 --- CHECK_START // WRITING TO THIS REG WILL START PIN CHECKING
0x14 - 0x17 --- DEVICE_STATUS // 0 - idle, 1 - in progress
0x18 - 0x1b --- PIN_STATUS // 0 - wrong, 1 - correct
0x20 - ...  --- FLAG1 | FLAG2 | FLAG3 | ...
*/

/// State
    reg[7:0] delay;
    reg [3:0] ctr;
    reg [7:0] correct_pin[15:0];
    reg [7:0] pin_bytes[15:0];
    reg device_status = 1'b0;
    reg pin_status = 1'b0;
    reg [7:0] flag[15:0];

    // Setup flag and correct_pin
    initial begin
        // SAMPLE FLAG
        flag[0] = 8'h53;
        flag[1] = 8'h45;
        flag[2] = 8'h43;
        flag[3] = 8'h4f;
        flag[4] = 8'h4e;
        flag[5] = 8'h44;
        flag[6] = 8'h5f;
        flag[7] = 8'h46;
        flag[8] = 8'h4c;
        flag[9] = 8'h41;
        flag[10] = 8'h47;
        flag[11] = 8'h30;
        flag[12] = 8'h30;
        flag[13] = 8'h30;
        flag[14] = 8'h30;
        flag[15] = 8'h30;

        // SAMPLE Correct PIN
        correct_pin[0] = 8'hff;
        correct_pin[1] = 8'haa;
        correct_pin[2] = 8'hbb;
        correct_pin[3] = 8'b0;
        correct_pin[4] = 8'b0;
        correct_pin[5] = 8'b0;
        correct_pin[6] = 8'b0;
        correct_pin[7] = 8'b0;
        correct_pin[8] = 8'b0;
        correct_pin[9] = 8'b0;
        correct_pin[10] = 8'b0;
        correct_pin[11] = 8'b0;
        correct_pin[12] = 8'b0;
        correct_pin[13] = 8'b0;
        correct_pin[14] = 8'b0;
        correct_pin[15] = 8'b0;
        
    end

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

    // Write to addr
    always @(posedge clk) begin
        if (!resetn) begin
            pin_bytes[0] <= 8'b0;
        end else begin
            if (latched_ctrl_en) begin
                if (latched_ctrl_awaddr < 32'h10) begin
                    pin_bytes[latched_ctrl_awaddr+0] <= latched_ctrl_wdata[8*1-1:8*0];
                    pin_bytes[latched_ctrl_awaddr+1] <= latched_ctrl_wdata[8*2-1:8*1];
                    pin_bytes[latched_ctrl_awaddr+2] <= latched_ctrl_wdata[8*3-1:8*2];
                    pin_bytes[latched_ctrl_awaddr+3] <= latched_ctrl_wdata[8*4-1:8*3];
                end else if (latched_ctrl_awaddr == 32'h10) begin
                    // Start flag check
                    device_status <= 1;
                    pin_status <= 0;
                    ctr <= 4'h0;
                    delay <= 8'h0;
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

    // Read from addr
    always_comb begin
        if (latched_ctrl_araddr < 32'h10) begin
            axi_slave_rdata[8*1-1:8*0] = pin_bytes[latched_ctrl_araddr + 0];
            axi_slave_rdata[8*2-1:8*1] = pin_bytes[latched_ctrl_araddr + 1];
            axi_slave_rdata[8*3-1:8*2] = pin_bytes[latched_ctrl_araddr + 2];
            axi_slave_rdata[8*4-1:8*3] = pin_bytes[latched_ctrl_araddr + 3];
        end else if (latched_ctrl_araddr == 32'h14) begin
            axi_slave_rdata = {31'b0, device_status};
        end else if (latched_ctrl_araddr == 32'h18) begin
            axi_slave_rdata = {31'b0, pin_status};
        end else if (latched_ctrl_araddr >= 32'h20 && latched_ctrl_araddr < 32'h30 && pin_status) begin
            axi_slave_rdata[8*1-1:8*0] = flag[latched_ctrl_araddr - 32'h20 + 0];
            axi_slave_rdata[8*2-1:8*1] = flag[latched_ctrl_araddr - 32'h20 + 1];
            axi_slave_rdata[8*3-1:8*2] = flag[latched_ctrl_araddr - 32'h20 + 2];
            axi_slave_rdata[8*4-1:8*3] = flag[latched_ctrl_araddr - 32'h20 + 3];
        end else begin
            axi_slave_rdata = 0;
        end
    end

    // PIN checking
    always @(posedge clk) begin
        if (device_status) begin
            delay <= delay + 1;
            if (delay == 8'hff) begin
                if (pin_bytes[ctr] == correct_pin[ctr]) begin
                    ctr <= ctr + 1;
                    if(ctr == 4'hf) begin
                        device_status <= 0;
                        pin_status <= 1;
                    end
                end else begin
                    device_status <= 0;
                    pin_status <= 0;
                end
            end
        end
    end
endmodule : axi4_flagdevicetm
