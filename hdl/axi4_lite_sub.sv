module axi4_lite_sub #(
parameter int C_AXI_DATA_WIDTH = 32, // Width of the AXI data
parameter int C_AXI_ADDR_WIDTH = 32  // Width of the AXI address
)(
input  logic clk,
input  logic resetn,

// R ADDR
input  logic [C_AXI_ADDR_WIDTH-1:0] s_axi_araddr,
input  logic                        s_axi_arvalid,
output logic                        s_axi_arready,
// R DATA
output logic                        s_axi_rvalid,
input  logic                        s_axi_rready,
output logic [C_AXI_DATA_WIDTH-1:0] s_axi_rdata,
// R COMPLETE
output logic [1:0]                  s_axi_rresp,

// W ADDR
input  logic [C_AXI_ADDR_WIDTH-1:0] s_axi_awaddr,
input  logic                        s_axi_awvalid,
output logic                        s_axi_awready,
// W DATA
input  logic [C_AXI_DATA_WIDTH-1:0] s_axi_wdata,
input  logic                        s_axi_wvalid,
output logic                        s_axi_wready,
// W COMPLETE
output logic [1:0]                  s_axi_bresp,
output logic                        s_axi_bvalid,
input  logic                        s_axi_bready
);

typedef enum logic [1:0] {
  ST_RD_ADDR      = 2'b00,
  ST_RD_DATA      = 2'b01,
  ST_RD_DATA_2    = 2'b10,
  ST_RD_COMPLETE  = 2'b11
} axi_rd_states_e;

typedef enum logic [1:0] {
  ST_WR_ADDR      = 2'b00,
  ST_WR_DATA      = 2'b01,
  ST_WR_DATA_2    = 2'b10,
  ST_WR_COMPLETE  = 2'b11
} axi_wr_states_e;

logic [1:0]  read_progress  = ST_RD_ADDR;
logic [1:0]  write_progress = ST_WR_ADDR;

logic [C_AXI_ADDR_WIDTH-1:0] read_address;
logic [C_AXI_ADDR_WIDTH-1:0] write_address;
logic [C_AXI_ADDR_WIDTH-1:0] DEVICE_VERSION  = C_AXI_ADDR_WIDTH'('h00);
logic [C_AXI_ADDR_WIDTH-1:0] SOMETHING_COUNT = C_AXI_ADDR_WIDTH'('h20);

logic [C_AXI_DATA_WIDTH-1:0] dumb  = C_AXI_ADDR_WIDTH'('b0);
logic [C_AXI_DATA_WIDTH-1:0] data1 = C_AXI_ADDR_WIDTH'('b0);
logic [C_AXI_DATA_WIDTH-1:0] data2 = C_AXI_ADDR_WIDTH'('b0);

always_ff @(posedge clk) begin
// Call CDC to process resetn
end

always_ff @(posedge clk) begin
  if (resetn) begin
    s_axi_rresp <= 1'b0;
    case (read_progress)
      ST_RD_ADDR: begin
        s_axi_arready <= 1'b0;
        if (s_axi_arvalid) begin
          read_address <= s_axi_araddr;
          s_axi_arready <= 1'b1;
          read_progress <= ST_RD_DATA;
        end
      end
      ST_RD_DATA: begin
        s_axi_arready <= 1'b0;
        if (s_axi_rready) begin
          case (read_address)
            DEVICE_VERSION: begin
              s_axi_rdata <= data1;
            end
            SOMETHING_COUNT: begin
              s_axi_rdata <= data2;
            end
            default: s_axi_rdata <= 32'b0;
          endcase
          s_axi_rvalid <= 1'b1;
          read_progress <= ST_RD_DATA_2;
        end
      end
      ST_RD_DATA_2: begin
        s_axi_rvalid <= 1'b0;
        s_axi_rdata  <= 32'b0;
        read_progress <= ST_RD_COMPLETE;
      end
      ST_RD_COMPLETE: begin
        if (~s_axi_rready) begin
          s_axi_rvalid <= 1'b0;
          read_progress <= ST_RD_ADDR;
        end
      end
      default: s_axi_rdata <= 32'b0;
    endcase

    case(write_progress)
        ST_WR_ADDR: begin
          s_axi_awready <= 1'b0;
          if (s_axi_awvalid) begin
            s_axi_awready <= 1'b1;
            write_address <= s_axi_awaddr;
            write_progress <= ST_WR_DATA;
          end
        end
        ST_WR_DATA: begin
          s_axi_awready <= 1'b0;
          if (s_axi_wvalid) begin
            s_axi_wready <= 1'b1;
            case(write_address)
              DEVICE_VERSION: begin
                data1 <= s_axi_wdata;
              end
              SOMETHING_COUNT: begin
                data2 <= s_axi_wdata;
              end
              default: dumb <= s_axi_wdata;
            endcase
            write_progress <= ST_WR_DATA_2;
          end
        end
        ST_WR_DATA_2: begin
          if (s_axi_bready) begin
            s_axi_wready <= 1'b0;
            s_axi_bresp  <= 2'b00;
            s_axi_bvalid <= 1'b1;
            write_progress <= ST_WR_COMPLETE;
          end
        end
        ST_WR_COMPLETE: begin
          s_axi_bresp  <= 2'b00;
          s_axi_bvalid <= 1'b0;
          write_progress <= ST_WR_ADDR;
        end
        default: dumb <= s_axi_wdata;
    endcase
  end
  else begin
    read_progress  <= ST_RD_ADDR;
    write_progress <= ST_WR_ADDR;
    s_axi_rvalid   <= 1'b0;
    s_axi_arready  <= 1'b0;
    s_axi_rresp    <= 2'b0;
    s_axi_awready  <= 1'b0;
    s_axi_wready   <= 1'b0;
    s_axi_bresp    <= 2'b00;
    s_axi_bvalid   <= 1'b0;
    data1          <= 32'b0;
    data2          <= 32'b0;
  end
end
endmodule