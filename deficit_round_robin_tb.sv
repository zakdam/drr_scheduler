module deficit_round_robin_tb;

  parameter PKT_QS_CNT   = 4;
  parameter QUANTUM_SIZE = 500;

// input ports
  logic                        clk;
  logic                        rst;
  logic                        ready;

initial
  begin
    clk = 1'b0;
    forever
      begin
        #10 clk <= ~clk;
      end
  end

initial
  begin
    rst = 1'b0;
    @( posedge clk );
    rst = 1'b1;
    @( posedge clk );
    rst <= 1'b0;
  end

initial
  begin
    ready = 1'b0;
    @( posedge clk );
    @( posedge clk );
    ready <= 1'b1;
  end

// transit wires
  wire [$clog2(PKT_QS_CNT)-1:0] addr_w;
  wire                          val_w;
  wire [PKT_QS_CNT-1:0][15:0]   size_w;
  wire [PKT_QS_CNT-1:0]         size_val_w;

deficit_round_robin drb(
  .clk_i      ( clk        ),
  .rst_i      ( rst        ),
  .size_i     ( size_w     ),
  .size_val_i ( size_val_w ),
  .ready_i    ( ready      ),

  .read_o     ( addr_w     ),
  .read_val_o ( val_w      )
);

drr_tester dt(
  .clk_i      ( clk        ),
  .rst_i      ( rst        ),
  .cng_addr_i ( addr_w     ),
  .cng_val_i  ( val_w      ),
 
  .size_o     ( size_w     ),
  .size_val_o ( size_val_w )
);

endmodule
