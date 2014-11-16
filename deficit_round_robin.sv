module deficit_round_robin
#(
  PKT_QS_CNT   = 4,    // number of packet queues (flows)
  QUANTUM_SIZE = 500   // size of the quantum
)

(
  input                                 clk_i,
  input                                 rst_i,
  input [PKT_QS_CNT-1:0][15:0]          size_i,
  input [PKT_QS_CNT-1:0]                size_val_i,
  input                                 ready_i,    // "ready" signal from next module

  output logic [$clog2(PKT_QS_CNT)-1:0] read_o,
  output logic                          read_val_o
);

logic [$clog2(PKT_QS_CNT)-1:0]          pntr_cnt;   // round robin pointer counter
logic [PKT_QS_CNT-1:0][15:0]            dft_cnt;    // flow deficit value  

// deficit is bigger or equal size
assign dft_bgr_size = ( size_i[pntr_cnt] <= dft_cnt[pntr_cnt] ) && size_val_i[pntr_cnt];

// deficit is smaller than size
assign dft_smr_size = ( size_i[pntr_cnt] >  dft_cnt[pntr_cnt] ) && size_val_i[pntr_cnt];

logic dft_bgr_size_d1;
logic dft_smr_size_d1;

always_ff @( posedge clk_i )
  begin
    dft_bgr_size_d1 <= dft_bgr_size;
  end

always_ff @( posedge clk_i )
  begin
    dft_smr_size_d1 <= dft_smr_size;
  end

// which flow to check
always_ff @( posedge clk_i )
  begin
    if( rst_i )
      pntr_cnt <= 0;
    else
      if( ready_i && dft_bgr_size )
        pntr_cnt <= pntr_cnt;
          else
            if( ready_i )
              pntr_cnt <= pntr_cnt + 1;
  end

// check and increment\decrement flow deficit value
always_ff @( posedge clk_i )
  begin
    if( rst_i )
      for( int i = 0; i < PKT_QS_CNT; i++ )
        dft_cnt[i] <= QUANTUM_SIZE;
    else
      if( dft_smr_size_d1 && !read_val_o )
        dft_cnt[pntr_cnt] <= dft_cnt[pntr_cnt] + QUANTUM_SIZE;
      else
        if( dft_bgr_size )
          dft_cnt[pntr_cnt] <= dft_cnt[pntr_cnt] - size_i[pntr_cnt];
  end

always_comb 
  begin
    if( dft_bgr_size )
      read_o <= pntr_cnt;
    else
      read_o <= 0;
  end

assign read_val_o = dft_bgr_size;

//==============STATISTICS===

logic [PKT_QS_CNT-1:0][31:0] stc_cnt; // statistics counter

always_ff @( posedge clk_i )
  begin
    if( rst_i )
      for( int j = 0; j < PKT_QS_CNT; j++ )
        stc_cnt[j] <= 0;
    else
      if( read_val_o )
        stc_cnt[pntr_cnt] <= stc_cnt[pntr_cnt] + size_i[pntr_cnt];
  end

endmodule
