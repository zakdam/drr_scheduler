module deficit_round_robin_tb;

  parameter PKT_QS_CNT   = 4;
  parameter QUANTUM_SIZE = 500;

// input ports
  logic                        clk;
  logic                        arst;
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
    arst = 1'b1;
    @( posedge clk );
    @( posedge clk );
    arst <= 1'b0;
  end

initial
  begin
    ready = 1'b0;
    @( posedge clk );
    @( posedge clk );
    ready <= 1'b1;
  end

// some transit logic
  logic [$clog2(PKT_QS_CNT)-1:0] addr_tr;
  logic                          val_tr;
  logic [PKT_QS_CNT-1:0][15:0]   size_tr;

deficit_round_robin drr(
  .clk_i      ( clk      ),
  .arst_i     ( arst     ),
  .size_i     ( size_tr  ),
  .ready_i    ( ready    ),

  .read_o     ( addr_tr  ),
  .read_val_o ( val_tr   )
);

drr_tester dt(
  .arst_i     ( arst     ),
  .cng_addr_i ( addr_tr  ),
  .cng_val_i  ( val_tr   ),

  .size_o     ( size_tr  )

);

endmodule
