module axi4_lite #(
  parameter int SELECT_DIR = 0,  // Implements AXI bus direction / 0 = Manager / 1 = Subordinate / 2 = Both
  parameter int DATA_WIDTH = 32, // Width of the AXI data
  parameter int ADDR_WIDTH = 32  // Width of the AXI address
)(
  input logic aclk,
  input logic aresetn,
  interface   axi_if
);

typedef enum logic [1:0] {ST_PROC = 2'b00, ST_COMP = 2'b01, ST_RDY  = 2'b10} axi_states_e;
(* keep = "true" *) axi_states_e rd_man_prgrss_d, rd_man_prgrss, wr_man_prgrss, rd_sub_prgrss, wr_sub_prgrss;

// Address space and data registers
           logic [ADDR_WIDTH-1:0] REG_ADDR;
localparam logic [ADDR_WIDTH-1:0] REG_ADDR_0 = ADDR_WIDTH'('h00);
localparam logic [ADDR_WIDTH-1:0] REG_ADDR_1 = ADDR_WIDTH'('h04);
localparam logic [ADDR_WIDTH-1:0] REG_ADDR_2 = ADDR_WIDTH'('h08);
localparam logic [ADDR_WIDTH-1:0] REG_ADDR_3 = ADDR_WIDTH'('h0C);
localparam logic [ADDR_WIDTH-1:0] REG_ADDR_4 = ADDR_WIDTH'('h10);
localparam logic [ADDR_WIDTH-1:0] REG_ADDR_5 = ADDR_WIDTH'('h14);
localparam logic [ADDR_WIDTH-1:0] REG_ADDR_6 = ADDR_WIDTH'('h18);
localparam logic [ADDR_WIDTH-1:0] REG_ADDR_7 = ADDR_WIDTH'('h1C);

// AXI4-Lite manager to be implemented
if (SELECT_DIR == 0) begin
  logic [DATA_WIDTH-1:0] m_rd_data, m_wr_data;
  logic [2:0] m_controller;
  logic reg_man_read;

  // Manager controller
  always_ff @(posedge aclk or negedge aresetn) begin
    if (aresetn) begin
      case (m_controller)
        3'd0: begin
          reg_man_read <= 1'b1;
          REG_ADDR     <= REG_ADDR_0;
          m_controller <= 3'd1;
          $display("#1");
        end
        3'd1: begin
          REG_ADDR     <= REG_ADDR_1;
          if ((rd_man_prgrss == ST_PROC) && (rd_man_prgrss_d == ST_COMP)) begin
            m_controller <= 3'd2;
            $display("#2");
          end
        end
        3'd2: begin
          REG_ADDR     <= REG_ADDR_2;
          if ((rd_man_prgrss == ST_PROC) && (rd_man_prgrss_d == ST_COMP)) begin
            m_controller <= 3'd3;
            $display("#3");
          end
        end
        3'd3: begin
          REG_ADDR     <= REG_ADDR_3;
          if ((rd_man_prgrss == ST_PROC) && (rd_man_prgrss_d == ST_COMP)) begin
            m_controller <= 3'd4;
            $display("#4");
          end
        end
        3'd4: begin
          REG_ADDR     <= REG_ADDR_4;
          if ((rd_man_prgrss == ST_PROC) && (rd_man_prgrss_d == ST_COMP)) begin
            m_controller <= 3'd5;
            $display("#5");
          end
        end
        3'd5: begin
          REG_ADDR     <= REG_ADDR_5;
          if ((rd_man_prgrss == ST_PROC) && (rd_man_prgrss_d == ST_COMP)) begin
            m_controller <= 3'd6;
            $display("#6");
          end
        end
        3'd6: begin
          REG_ADDR     <= REG_ADDR_6;
          if ((rd_man_prgrss == ST_PROC) && (rd_man_prgrss_d == ST_COMP)) begin
            m_controller <= 3'd7;
            $display("#7");
          end
        end
        3'd7: begin
          REG_ADDR     <= REG_ADDR_7;
          if ((rd_man_prgrss == ST_PROC) && (rd_man_prgrss_d == ST_COMP)) begin
            reg_man_read <= 1'b0;
            m_controller <= 3'd7;
            $display("#8");
          end
        end
      endcase
    end else begin
      m_controller <= 3'd0;
      REG_ADDR     <= REG_ADDR_0;
      reg_man_read <= 1'b0;
    end
  end

  // Always FF block comes out of reset synchronously, resets asynchronously
  always_ff @(posedge aclk or negedge aresetn) begin
    if (aresetn) begin
      rd_man_prgrss_d <= rd_man_prgrss;
      // AXI4-Lite read
      case (rd_man_prgrss)
        ST_PROC: begin
          if (reg_man_read) begin
            axi_if.rready  <= 1'b0;
            axi_if.araddr  <= REG_ADDR;  // Assign respective address
            axi_if.arvalid <= 1'b1;
            if (axi_if.arready) begin
              axi_if.rready <= 1'b1;
              rd_man_prgrss <= ST_COMP;
            end
          end
        end
        ST_COMP: begin
          if (axi_if.rvalid && !axi_if.rresp) begin
            m_rd_data     <= axi_if.rdata;   // Assign respective data
            axi_if.rready <= 1'b0;
            $display("READ DATA: %h", axi_if.rdata);
            rd_man_prgrss <= ST_PROC;
          end
        end
        default: begin
          rd_man_prgrss  <= ST_PROC;
          axi_if.rready  <= 1'b0;
          axi_if.arvalid <= 1'b0;
          axi_if.araddr  <= ADDR_WIDTH'('h0);
          m_rd_data      <= DATA_WIDTH'('h0);
        end
      endcase

      // // AXI4-Lite write
      // case(wr_man_prgrss)
      //   ST_PROC: begin
      //     axi_if.wvalid  <= 1'b0;
      //     axi_if.awaddr  <= REG_ADDR; // Assign respective address
      //     axi_if.awvalid <= 1'b1;
      //     if (axi_if.awready) begin
      //       axi_if.awaddr  <= ADDR_WIDTH'('b0);
      //       axi_if.awvalid <= 1'b0;
      //       axi_if.bready  <= 1'b1;
      //     end
      //     if (axi_if.wready) begin
      //       axi_if.wvalid <= 1'b1;
      //       axi_if.wdata  <= m_wr_data;  // Assign respective data
      //       wr_man_prgrss <= ST_COMP;
      //     end
      //   end
      //   ST_COMP: begin
      //     axi_if.wvalid <= 1'b0;
      //     axi_if.wdata  <= DATA_WIDTH'('h0);
      //     if (!axi_if.bresp && axi_if.bvalid) begin
      //       axi_if.bready <= 1'b0;
      //       wr_man_prgrss <= ST_PROC;
      //     end
      //   end
      //   default: begin
      //     wr_man_prgrss  <= ST_PROC;
      //     axi_if.wvalid  <= 1'b0;
      //     axi_if.awaddr  <= ADDR_WIDTH'('h0);
      //     axi_if.awvalid <= 1'b0;
      //     axi_if.bready  <= 1'b0;
      //     axi_if.wdata   <= DATA_WIDTH'('b0);
      //   end
      // endcase
    end else begin
      // Reset condition
      rd_man_prgrss  <= ST_PROC;
      wr_man_prgrss  <= ST_PROC;
      axi_if.rready  <= 1'b0;
      axi_if.arvalid <= 1'b0;
      axi_if.araddr  <= ADDR_WIDTH'('h0);
      m_rd_data      <= DATA_WIDTH'('h0);
      // m_wr_data      <= DATA_WIDTH'('h0);
      axi_if.wvalid  <= 1'b0;
      axi_if.awaddr  <= ADDR_WIDTH'('h0);
      axi_if.awvalid <= 1'b0;
      axi_if.bready  <= 1'b0;
      axi_if.wdata   <= DATA_WIDTH'('b0);
    end
  end
end

// AXI4-Lite subordinate to be implemented
if (SELECT_DIR == 1) begin
  logic [ADDR_WIDTH-1:0] wr_addr;
  logic [DATA_WIDTH-1:0] default_value,
                         register_content_0, register_content_1, register_content_2, register_content_3,
                         register_content_4, register_content_5, register_content_6, register_content_7;

  // Always FF block comes out of reset synchronously, resets asynchronously
  always_ff @(posedge aclk or negedge aresetn) begin
    if (aresetn) begin
      // AXI4-Lite read
      case (rd_sub_prgrss)
        ST_PROC: begin
          axi_if.rresp  <= 2'b00;
          axi_if.rvalid <= 1'b0;
          axi_if.rdata  <= DATA_WIDTH'('b0);
          if (axi_if.arvalid) begin
            axi_if.arready <= 1'b1;
            case (axi_if.araddr)
              // Register Space
              REG_ADDR_0: axi_if.rdata <= 32'hABAB_DEDE; // register_content_0;
              REG_ADDR_1: axi_if.rdata <= 32'hCECE_BBBB; // register_content_1;
              REG_ADDR_2: axi_if.rdata <= 32'hABCD_DEFA; // register_content_2;
              REG_ADDR_3: axi_if.rdata <= 32'hABAB_DEDE; // register_content_3;
              REG_ADDR_4: axi_if.rdata <= 32'hABAB_DEDE; // register_content_4;
              REG_ADDR_5: axi_if.rdata <= 32'hABAB_DEDE; // register_content_5;
              REG_ADDR_6: axi_if.rdata <= 32'hABAB_DEDE; // register_content_6;
              REG_ADDR_7: axi_if.rdata <= 32'hFBCE_BBBA; // register_content_7;
              default: axi_if.rdata <= DATA_WIDTH'('b0);
            endcase
            rd_sub_prgrss <= ST_COMP;
          end
        end
        ST_COMP: begin
          axi_if.arready <= 1'b0;
          if (axi_if.rready) begin
            axi_if.rvalid  <= 1'b1;
            axi_if.rresp   <= 2'b00;
            rd_sub_prgrss  <= ST_PROC;
          end
        end
        default: begin
          rd_sub_prgrss  <= ST_PROC;
          axi_if.rresp   <= 2'b00;
          axi_if.arready <= 1'b0;
          axi_if.rdata   <= 32'b0;
          axi_if.rvalid  <= 1'b0;
        end
      endcase

      // AXI4-Lite write
      case(wr_sub_prgrss)
        ST_PROC: begin
          axi_if.bvalid  <= 1'b0;
          axi_if.bresp   <= 2'b00;
          axi_if.awready <= 1'b0;
          if (axi_if.awvalid) begin
            axi_if.awready <= 1'b1;
            wr_addr        <= axi_if.awaddr;
            wr_sub_prgrss  <= ST_COMP;
          end
        end
        ST_COMP: begin
          axi_if.awready <= 1'b0;
          axi_if.wready  <= 1'b1;
          if (axi_if.wvalid) begin
            case(wr_addr)
              REG_ADDR_0: register_content_0 <= axi_if.wdata;
              REG_ADDR_1: register_content_1 <= axi_if.wdata;
              REG_ADDR_2: register_content_2 <= axi_if.wdata;
              REG_ADDR_3: register_content_3 <= axi_if.wdata;
              REG_ADDR_4: register_content_4 <= axi_if.wdata;
              REG_ADDR_5: register_content_5 <= axi_if.wdata;
              REG_ADDR_6: register_content_6 <= axi_if.wdata;
              REG_ADDR_7: register_content_7 <= axi_if.wdata;
              default: default_value <= axi_if.wdata;
            endcase
            axi_if.wready <= 1'b0;
            wr_sub_prgrss <= ST_RDY;
          end
        end
        ST_RDY: begin
          if (axi_if.bready) begin
            axi_if.bresp  <= 2'b00;
            axi_if.bvalid <= 1'b1;
            wr_sub_prgrss <= ST_PROC;
          end
        end
        default: begin
          wr_sub_prgrss      <= ST_PROC;
          axi_if.awready     <= 1'b0;
          axi_if.wready      <= 1'b0;
          axi_if.bresp       <= 2'b00;
          axi_if.bvalid      <= 1'b0;
          register_content_0 <= DATA_WIDTH'('b0);
          register_content_1 <= DATA_WIDTH'('b0);
          register_content_2 <= DATA_WIDTH'('b0);
          register_content_3 <= DATA_WIDTH'('b0);
          register_content_4 <= DATA_WIDTH'('b0);
          register_content_5 <= DATA_WIDTH'('b0);
          register_content_6 <= DATA_WIDTH'('b0);
          register_content_7 <= DATA_WIDTH'('b0);
          default_value      <= DATA_WIDTH'('b0);
        end
      endcase
    end else begin
      // Reset condition
      rd_sub_prgrss      <= ST_PROC;
      wr_sub_prgrss      <= ST_PROC;
      axi_if.arready     <= 1'b0;
      axi_if.rdata       <= DATA_WIDTH'('b0);
      axi_if.rvalid      <= 1'b0;
      axi_if.rresp       <= 2'b0;
      axi_if.awready     <= 1'b0;
      axi_if.wready      <= 1'b0;
      axi_if.bresp       <= 2'b00;
      axi_if.bvalid      <= 1'b0;
      register_content_0 <= DATA_WIDTH'('b0);
      register_content_1 <= DATA_WIDTH'('b0);
      register_content_2 <= DATA_WIDTH'('b0);
      register_content_3 <= DATA_WIDTH'('b0);
      register_content_4 <= DATA_WIDTH'('b0);
      register_content_5 <= DATA_WIDTH'('b0);
      register_content_6 <= DATA_WIDTH'('b0);
      register_content_7 <= DATA_WIDTH'('b0);
      default_value      <= DATA_WIDTH'('b0);
    end
  end
end
endmodule : axi4_lite