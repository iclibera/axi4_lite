`timescale 1ns/1ps

import axi_vip_pkg::*;
import vip_axi_vip_0_pkg::*;

module testbench;
// Testbench signals
logic aclk, aresetn;

// Localparameters
localparam int DATA_WIDTH = 32;
localparam int ADDR_WIDTH = 32;

// Handle for AXI-VIP 
design_1_axi_vip_0_0_mst_t vip_axi_vip_00_mst;

// AXI VIP control signals
localparam xil_axi_resp_t C_EXP_RESP = XIL_AXI_RESP_OKAY;
xil_axi_prot_t            prot       = '0;
xil_axi_ulong             waddr;
xil_axi_resp_t            bresp;
logic [31:0]              wdata;

xil_axi_ulong             raddr;
xil_axi_resp_t            rresp;
logic [31:0]              rdata;
logic [31:0]              rdata_exp;

// AXI interface
axi4_if #(.DATA_WIDTH(DATA_WIDTH), .ADDR_WIDTH(ADDR_WIDTH)) axi();

// Instantiate the AXI module
axi4_lite_sub #(.DATA_WIDTH(DATA_WIDTH), .ADDR_WIDTH(ADDR_WIDTH))
axi_slv (
  .aclk(aclk),
  .aresetn(aresetn),
  .s_axi(axi.subordinate)
  );

// AXI VIP parameters are fixed in the source files
// Parameters can be altered from source files
vip_axi_vip_0 axi_mst(
  .aclk(aclk),
  .aresetn(aresetn),
  .m_axi_awaddr(axi.awaddr),
  .m_axi_awvalid(axi.awvalid),
  .m_axi_awready(axi.awready),
  .m_axi_wdata(axi.wdata),
  .m_axi_wvalid(axi.wvalid),
  .m_axi_wready(axi.wready),
  .m_axi_bresp(axi.bresp),
  .m_axi_bvalid(axi.bvalid),
  .m_axi_bready(axi.bready),
  .m_axi_araddr(axi.araddr),
  .m_axi_arvalid(axi.arvalid),
  .m_axi_arready(axi.arready),
  .m_axi_rdata(axi.rdata),
  .m_axi_rresp(axi.rresp),
  .m_axi_rvalid(axi.rvalid),
  .m_axi_rready(axi.rready)
);

initial begin : START_vip_axi_vip_0_MASTER
  vip_axi_vip_00_mst = new("vip_axi_vip_00_mst", testbench.axi_mst.inst.IF);
  vip_axi_vip_00_mst.start_master();
end

// Clock generation
initial begin
  aclk = 0;
  forever #2ns aclk = ~aclk; // 100MHz clock
end

// Active-low reset generation tasks
task deassertReset();
  aresetn = 1'b1;
endtask

task assertReset();
  aresetn = 1'b0;
endtask

// Necessary tasks
task readReg (input logic [31:0] regAddr);
  vip_axi_vip_00_mst.AXI4LITE_READ_BURST(regAddr, prot, raddr, rresp);
  $display("AXI4L read @ address 0x%h : 0x%h", regAddr, raddr);
endtask

task readRegReturn (input logic [31:0] regAddr, output logic [31:0] readData);
  vip_axi_vip_00_mst.AXI4LITE_READ_BURST(regAddr, prot, readData, rresp);
  $display("AXI4L read @ address 0x%h : 0x%h", regAddr, readData);
endtask

task writeReg (input logic [31:0] regAddr, input logic [31:0] writeData);
  vip_axi_vip_00_mst.AXI4LITE_WRITE_BURST(regAddr, prot, writeData, rresp);
  $display("AXI4L write @ address 0x%h : 0x%h", regAddr, writeData);
endtask

task compareReg (input logic [31:0] regAddr, input logic [31:0] expectedData);
  vip_axi_vip_00_mst.AXI4LITE_READ_BURST(regAddr, prot, raddr, rresp);
  assert (raddr == expectedData) begin
    $display("Check - AXI4L read @ address 0x%h : 0x%h", regAddr, raddr);
  end else begin
    $display("Fail - AXI4L read @ address 0x%h : 0x%h - Expected : 0x%h", regAddr, raddr, expectedData);
  end
endtask

// Simulation
initial begin
  assertReset();
  #20us;
  deassertReset();

  $display("Read - Write - 1");
  compareReg(32'h00, 32'h0);
  writeReg(32'h00, 32'hDEAD_BEEF);
  compareReg(32'h00, 32'hDEAD_BEEF);

  $display("Read - Write - 2");
  compareReg(32'h04, 32'h0);
  writeReg(32'h04, 32'hADAD_ABAB);
  compareReg(32'h04, 32'hADAD_ABAB);

  assertReset();
  #20us;
  deassertReset();

  $display("Read - Write - 3");
  compareReg(32'h00, 32'h0);
  writeReg(32'h00, 32'hBEBE_BABA);
  compareReg(32'h00, 32'hBEBE_BABA);

  $display("Read - Write - 4");
  compareReg(32'h04, 32'h0);
  writeReg(32'h04, 32'hDADA_BBBB);
  compareReg(32'h04, 32'hDADA_BBBB);

  assertReset();

  #50us;
  $finish;
end

endmodule