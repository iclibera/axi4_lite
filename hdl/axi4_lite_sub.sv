module axi4_lite_sub #(
  parameter int DATA_WIDTH = 32, // Width of the AXI data
  parameter int ADDR_WIDTH = 32  // Width of the AXI address
)(
  input logic         aclk,
  input logic         aresetn,
  axi4_if.subordinate s_axi
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

logic [1:0] read_progress  = ST_RD_ADDR;
logic [1:0] write_progress = ST_WR_ADDR;
logic [ADDR_WIDTH-1:0] read_address;
logic [ADDR_WIDTH-1:0] write_address;

// Address space and data registers
logic [ADDR_WIDTH-1:0] REG_ADDR_0 = ADDR_WIDTH'('h00);
logic [ADDR_WIDTH-1:0] REG_ADDR_1 = ADDR_WIDTH'('h04);
logic [ADDR_WIDTH-1:0] REG_ADDR_2 = ADDR_WIDTH'('h08);
logic [ADDR_WIDTH-1:0] REG_ADDR_3 = ADDR_WIDTH'('h0C);
logic [ADDR_WIDTH-1:0] REG_ADDR_4 = ADDR_WIDTH'('h10);
logic [ADDR_WIDTH-1:0] REG_ADDR_5 = ADDR_WIDTH'('h14);
logic [ADDR_WIDTH-1:0] REG_ADDR_6 = ADDR_WIDTH'('h18);
logic [ADDR_WIDTH-1:0] REG_ADDR_7 = ADDR_WIDTH'('h1C);

logic [DATA_WIDTH-1:0] default_value  = ADDR_WIDTH'('b0);
logic [DATA_WIDTH-1:0] data0 = ADDR_WIDTH'('b0);
logic [DATA_WIDTH-1:0] data1 = ADDR_WIDTH'('b0);
logic [DATA_WIDTH-1:0] data2 = ADDR_WIDTH'('b0);
logic [DATA_WIDTH-1:0] data3 = ADDR_WIDTH'('b0);
logic [DATA_WIDTH-1:0] data4 = ADDR_WIDTH'('b0);
logic [DATA_WIDTH-1:0] data5 = ADDR_WIDTH'('b0);
logic [DATA_WIDTH-1:0] data6 = ADDR_WIDTH'('b0);
logic [DATA_WIDTH-1:0] data7 = ADDR_WIDTH'('b0);

always_ff @(posedge aclk or negedge aresetn) begin
  if (aresetn) begin
    s_axi.rresp <= 1'b0;
    case (read_progress)
      ST_RD_ADDR: begin
        s_axi.arready <= 1'b0;
        if (s_axi.arvalid) begin
          read_address <= s_axi.araddr;
          s_axi.arready <= 1'b1;
          read_progress <= ST_RD_DATA;
        end
      end
      ST_RD_DATA: begin
        s_axi.arready <= 1'b0;
        if (s_axi.rready) begin
          case (read_address)
            REG_ADDR_0: s_axi.rdata <= data0;
            REG_ADDR_1: s_axi.rdata <= data1;
            REG_ADDR_2: s_axi.rdata <= data2;
            REG_ADDR_3: s_axi.rdata <= data3;
            REG_ADDR_4: s_axi.rdata <= data4;
            REG_ADDR_5: s_axi.rdata <= data5;
            REG_ADDR_6: s_axi.rdata <= data6;
            REG_ADDR_7: s_axi.rdata <= data7;
            default: s_axi.rdata <= ADDR_WIDTH'('b0);
          endcase
          s_axi.rvalid <= 1'b1;
          read_progress <= ST_RD_DATA_2;
        end
      end
      ST_RD_DATA_2: begin
        s_axi.rvalid <= 1'b0;
        s_axi.rdata  <= ADDR_WIDTH'('b0);
        read_progress <= ST_RD_COMPLETE;
      end
      ST_RD_COMPLETE: begin
        if (~s_axi.rready) begin
          s_axi.rvalid <= 1'b0;
          read_progress <= ST_RD_ADDR;
        end
      end
      default: begin
        read_progress <= ST_RD_ADDR;
        s_axi.rdata   <= 32'b0;
      end
    endcase

    case(write_progress)
        ST_WR_ADDR: begin
          s_axi.awready <= 1'b0;
          if (s_axi.awvalid) begin
            s_axi.awready <= 1'b1;
            write_address <= s_axi.awaddr;
            write_progress <= ST_WR_DATA;
          end
        end
        ST_WR_DATA: begin
          s_axi.awready <= 1'b0;
          if (s_axi.wvalid) begin
            s_axi.wready <= 1'b1;
            case(write_address)
              REG_ADDR_0: data0 <= s_axi.wdata;
              REG_ADDR_1: data1 <= s_axi.wdata;
              REG_ADDR_2: data2 <= s_axi.wdata;
              REG_ADDR_3: data3 <= s_axi.wdata;
              REG_ADDR_4: data4 <= s_axi.wdata;
              REG_ADDR_5: data5 <= s_axi.wdata;
              REG_ADDR_6: data6 <= s_axi.wdata;
              REG_ADDR_7: data7 <= s_axi.wdata;
              default: default_value <= s_axi.wdata;
            endcase
            write_progress <= ST_WR_DATA_2;
          end
        end
        ST_WR_DATA_2: begin
          if (s_axi.bready) begin
            s_axi.wready <= 1'b0;
            s_axi.bresp  <= 2'b00;
            s_axi.bvalid <= 1'b1;
            write_progress <= ST_WR_COMPLETE;
          end
        end
        ST_WR_COMPLETE: begin
          s_axi.bresp  <= 2'b00;
          s_axi.bvalid <= 1'b0;
          write_progress <= ST_WR_ADDR;
        end
        default: begin
          write_progress <= ST_WR_ADDR;
          default_value  <= s_axi.wdata;
        end
    endcase
  end
  else begin
    read_progress  <= ST_RD_ADDR;
    write_progress <= ST_WR_ADDR;
    s_axi.rvalid   <= 1'b0;
    s_axi.arready  <= 1'b0;
    s_axi.rresp    <= 2'b0;
    s_axi.awready  <= 1'b0;
    s_axi.wready   <= 1'b0;
    s_axi.bresp    <= 2'b00;
    s_axi.bvalid   <= 1'b0;
    data1          <= ADDR_WIDTH'('b0);
    data2          <= ADDR_WIDTH'('b0);
  end
end
endmodule