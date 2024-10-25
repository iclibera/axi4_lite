module axi4_lite_sub #(
  parameter int DATA_WIDTH = 32, // Width of the AXI data
  parameter int ADDR_WIDTH = 32  // Width of the AXI address
)(
  input logic         aclk,
  input logic         aresetn,
  axi4_if.subordinate s_axi
);

typedef enum logic [1:0] {
  ST_PROC = 2'b00,
  ST_COMP = 2'b01,
  ST_RDY  = 2'b10
} axi_states_e;
(* keep = "true" *) axi_states_e rd_prgrss, wr_prgrss;

// Address space and data registers
localparam logic [ADDR_WIDTH-1:0] REG_ADDR_0 = ADDR_WIDTH'('h00);
localparam logic [ADDR_WIDTH-1:0] REG_ADDR_1 = ADDR_WIDTH'('h04);
localparam logic [ADDR_WIDTH-1:0] REG_ADDR_2 = ADDR_WIDTH'('h08);
localparam logic [ADDR_WIDTH-1:0] REG_ADDR_3 = ADDR_WIDTH'('h0C);
localparam logic [ADDR_WIDTH-1:0] REG_ADDR_4 = ADDR_WIDTH'('h10);
localparam logic [ADDR_WIDTH-1:0] REG_ADDR_5 = ADDR_WIDTH'('h14);
localparam logic [ADDR_WIDTH-1:0] REG_ADDR_6 = ADDR_WIDTH'('h18);
localparam logic [ADDR_WIDTH-1:0] REG_ADDR_7 = ADDR_WIDTH'('h1C);

logic [ADDR_WIDTH-1:0] wr_addr;
logic [DATA_WIDTH-1:0] default_value, data0, data1, data2, data3, data4, data5, data6, data7;

// Always FF block comes out of reset synchronously, resets asynchronously
always_ff @(posedge aclk or negedge aresetn) begin
  if (aresetn) begin
    // AXI4-Lite read
    case (rd_prgrss)
      ST_PROC: begin
        s_axi.rresp <= 2'b00;
        s_axi.rvalid  <= 1'b0;
        s_axi.rdata   <= ADDR_WIDTH'('b0);
        if (s_axi.arvalid) begin
          s_axi.arready <= 1'b1;
          case (s_axi.araddr)
            // Register Space
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
          rd_prgrss <= ST_COMP;
        end
      end
      ST_COMP: begin
        s_axi.arready <= 1'b0;        
        if (s_axi.rready) begin
          s_axi.rvalid  <= 1'b1;         
          s_axi.rresp   <= 2'b00;
          rd_prgrss     <= ST_PROC;          
        end
      end
      default: begin
        rd_prgrss     <= ST_PROC;
        s_axi.rresp   <= 2'b00;
        s_axi.arready <= 1'b0;
        s_axi.rdata   <= 32'b0;
        s_axi.rvalid  <= 1'b0;
      end
    endcase
    
    // AXI4-Lite write
    case(wr_prgrss)
        ST_PROC: begin
          s_axi.bvalid  <= 1'b0;
          s_axi.bresp   <= 2'b00;
          s_axi.awready <= 1'b0;
          if (s_axi.awvalid) begin
            s_axi.awready <= 1'b1;
            wr_addr       <= s_axi.awaddr;
            wr_prgrss     <= ST_COMP;
          end
        end
        ST_COMP: begin
          s_axi.awready <= 1'b0;
          s_axi.wready  <= 1'b1;
          if (s_axi.wvalid) begin            
            case(wr_addr)
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
            s_axi.wready <= 1'b0;
            wr_prgrss    <= ST_RDY;
          end
        end
        ST_RDY: begin
          if (s_axi.bready) begin
            s_axi.bresp  <= 2'b00;
            s_axi.bvalid <= 1'b1;
            wr_prgrss    <= ST_PROC;
          end
        end
        default: begin
          wr_prgrss      <= ST_PROC;
          s_axi.awready  <= 1'b0;
          s_axi.wready   <= 1'b0;
          s_axi.bresp    <= 2'b00;
          s_axi.bvalid   <= 1'b0;
          data0          <= DATA_WIDTH'('b0);
          data1          <= DATA_WIDTH'('b0);
          data2          <= DATA_WIDTH'('b0);
          data3          <= DATA_WIDTH'('b0);
          data4          <= DATA_WIDTH'('b0);
          data5          <= DATA_WIDTH'('b0);
          data6          <= DATA_WIDTH'('b0);
          data7          <= DATA_WIDTH'('b0);
          default_value  <= DATA_WIDTH'('b0);
        end
    endcase
  end
  else begin
    // Reset condition
    rd_prgrss      <= ST_PROC;
    wr_prgrss      <= ST_PROC;
    s_axi.arready  <= 1'b0;
    s_axi.rdata    <= DATA_WIDTH'('b0);
    s_axi.rvalid   <= 1'b0;
    s_axi.rresp    <= 2'b0;
    s_axi.awready  <= 1'b0;
    s_axi.wready   <= 1'b0;
    s_axi.bresp    <= 2'b00;
    s_axi.bvalid   <= 1'b0;
    data0          <= DATA_WIDTH'('b0);
    data1          <= DATA_WIDTH'('b0);
    data2          <= DATA_WIDTH'('b0);
    data3          <= DATA_WIDTH'('b0);
    data4          <= DATA_WIDTH'('b0);
    data5          <= DATA_WIDTH'('b0);
    data6          <= DATA_WIDTH'('b0);
    data7          <= DATA_WIDTH'('b0);
    default_value  <= DATA_WIDTH'('b0);
  end
end
endmodule