module deficit_round_robin
#(
  PKT_QS_CNT   = 4,    // number of packet queues (flows)
  QUANTUM_SIZE = 500   // size of the quantum
)

(
  //input request,
  input                                 clk_i,
  input                                 arst_i,
  input [PKT_QS_CNT-1:0][15:0]          size_i,
  input                                 ready_i,    // "ready" signal from next module

  output logic [$clog2(PKT_QS_CNT)-1:0] read_o,
  output logic                          read_val_o
);

logic [$clog2(PKT_QS_CNT)-1:0]          pntr_cnt;   // round robin pointer counter
logic [PKT_QS_CNT-1:0][15:0]            dft_cnt;    // flow deficit value  

// which flow to check
always_ff @( posedge clk_i )
  begin
    if( arst_i )
      pntr_cnt <= 0;
    else
      if( ready_i && ( size_i[pntr_cnt] <= dft_cnt[pntr_cnt] ) )
        pntr_cnt <= pntr_cnt;
          else
            if( ready_i )
              pntr_cnt <= pntr_cnt + 1;
  end

// check and increment\decrement flow deficit value
always_ff @( posedge clk_i )
  begin
    if( arst_i )
      for( int i = 0; i < PKT_QS_CNT; i++ )
        dft_cnt[i] <= QUANTUM_SIZE;
    else
      if( ( ( size_i[pntr_cnt] ) > dft_cnt[pntr_cnt] ) && !read_val_o )
        dft_cnt[pntr_cnt] <= dft_cnt[pntr_cnt] + QUANTUM_SIZE;
      else
        if( ( size_i[pntr_cnt] ) <= dft_cnt[pntr_cnt] )
          dft_cnt[pntr_cnt] <= dft_cnt[pntr_cnt] - size_i[pntr_cnt];
  end

always_ff @( posedge clk_i ) 
  begin
    if( arst_i )  
      read_o <= 0;
    else
      if( ( size_i[pntr_cnt] ) <= dft_cnt[pntr_cnt] )
        read_o <= pntr_cnt;
      else
        read_o <= 0;
  end

always_ff @( posedge clk_i ) 
  begin
    if( arst_i )  
      read_val_o <= 0;
    else
      if( ( size_i[pntr_cnt] ) <= dft_cnt[pntr_cnt] )
        read_val_o <= 1;
      else
        read_val_o <= 0;
  end

endmodule
