`timescale 1ns/1ps

module tb01_unit_test;
    import axi_vip_pkg::*;
    import vip_axi_vip_0_pkg::*;

    // Testbench signals
    logic aclk;
    logic aresetn;
    logic [31:0] s_axi_awaddr;
    logic s_axi_awvalid;
    logic s_axi_awready;
    logic [31:0] s_axi_wdata;
    logic s_axi_wvalid;
    logic s_axi_wready;
    logic [1:0] s_axi_bresp;
    logic s_axi_bvalid;
    logic s_axi_bready;
    logic [31:0] s_axi_araddr;
    logic s_axi_arvalid;
    logic s_axi_arready;
    logic [31:0] s_axi_rdata;
    logic [1:0] s_axi_rresp;
    logic s_axi_rvalid;
    logic s_axi_rready;

    design_1_axi_vip_0_0_mst_t vip_axi_vip_00_mst;

    localparam xil_axi_resp_t C_EXP_RESP = XIL_AXI_RESP_OKAY;
    xil_axi_prot_t            prot       = '0;
    xil_axi_ulong             waddr;
    xil_axi_resp_t            bresp;
    logic [31:0]              wdata;

    xil_axi_ulong             raddr;
    xil_axi_resp_t            rresp;
    logic [31:0]              rdata;
    logic [31:0]              rdata_exp;

    // Instantiate the AXI module
    axi_sub axi_slv(
        .clk(aclk),
        .resetn(aresetn),
        .s_axi_araddr(s_axi_araddr),
        .s_axi_arvalid(s_axi_arvalid),
        .s_axi_arready(s_axi_arready),
        .s_axi_rvalid(s_axi_rvalid),
        .s_axi_rready(s_axi_rready),
        .s_axi_rdata(s_axi_rdata),
        .s_axi_rresp(s_axi_rresp),
        .s_axi_awaddr(s_axi_awaddr),
        .s_axi_awvalid(s_axi_awvalid),
        .s_axi_awready(s_axi_awready),
        .s_axi_wdata(s_axi_wdata),
        .s_axi_wvalid(s_axi_wvalid),
        .s_axi_wready(s_axi_wready),
        .s_axi_bresp(s_axi_bresp),
        .s_axi_bvalid(s_axi_bvalid),
        .s_axi_bready(s_axi_bready)
    );

    vip_axi_vip_0 axi_mst(
        .aclk(aclk),
        .aresetn(aresetn),
        .m_axi_awaddr(s_axi_awaddr),
        .m_axi_awvalid(s_axi_awvalid),
        .m_axi_awready(s_axi_awready),
        .m_axi_wdata(s_axi_wdata),
        .m_axi_wvalid(s_axi_wvalid),
        .m_axi_wready(s_axi_wready),
        .m_axi_bresp(s_axi_bresp),
        .m_axi_bvalid(s_axi_bvalid),
        .m_axi_bready(s_axi_bready),
        .m_axi_araddr(s_axi_araddr),
        .m_axi_arvalid(s_axi_arvalid),
        .m_axi_arready(s_axi_arready),
        .m_axi_rdata(s_axi_rdata),
        .m_axi_rresp(s_axi_rresp),
        .m_axi_rvalid(s_axi_rvalid),
        .m_axi_rready(s_axi_rready)
    );

    initial begin : START_vip_axi_vip_0_MASTER
        vip_axi_vip_00_mst = new("vip_axi_vip_00_mst", tb01_test_unit.axi_mst.inst.IF);
        vip_axi_vip_00_mst.start_master();
    end

    // Clock generation
    initial begin
        aclk = 0;
        forever #5ns aclk = ~aclk; // 100MHz clock
    end

    // Reset generation
    initial begin
        aresetn = 1'b0;
        #100us;
        aresetn = 1'b1;
    end

    initial begin
        $display("#READ1");
        raddr = 32'h0;
        $display("AXI Read at address: 0x%h", raddr);
        vip_axi_vip_00_mst.AXI4LITE_READ_BURST(raddr, prot, rdata, rresp);
        $display("Data read: 0x%h", rdata);

        $display("#WRITE1");
        waddr = 32'h0;
        wdata = 32'hDEAD_BEEF;
        $display("AXI Write at address: 0x%h with data: 0x%h", waddr, wdata);
        vip_axi_vip_00_mst.AXI4LITE_WRITE_BURST(waddr, prot, wdata, bresp);

        $display("#READ1");
        raddr = 32'h0;
        $display("AXI Read at address: 0x%h", raddr);
        vip_axi_vip_00_mst.AXI4LITE_READ_BURST(raddr, prot, rdata, rresp);
        $display("Data read: 0x%h", rdata);


        $display("#READ2");
        raddr = 32'h20;
        $display("AXI Read at address: 0x%h", raddr);
        vip_axi_vip_00_mst.AXI4LITE_READ_BURST(raddr, prot, rdata, rresp);
        $display("Data read: 0x%h", rdata);

        $display("#WRITE2");
        waddr = 32'h20;
        wdata = 32'hADAD_ABAB;
        $display("AXI Write at address: 0x%h with data: 0x%h", waddr, wdata);
        vip_axi_vip_00_mst.AXI4LITE_WRITE_BURST(waddr, prot, wdata, bresp);

        $display("#READ2");
        raddr = 32'h20;
        $display("AXI Read at address: 0x%h", raddr);
        vip_axi_vip_00_mst.AXI4LITE_READ_BURST(raddr, prot, rdata, rresp);
        $display("Data read: 0x%h", rdata);

        #100us;
        $finish;
    end

endmodule