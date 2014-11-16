module drr_tester
#(
  PKT_QS_CNT = 4
)

(
  input                               clk_i,
  input                               rst_i,
  input [$clog2(PKT_QS_CNT)-1:0]      cng_addr_i, // address to change
  input                               cng_val_i,  // change is valid

  output logic [PKT_QS_CNT-1:0][15:0] size_o,
  output logic [PKT_QS_CNT-1:0]       size_val_o
);

// assigns for hardcode testing 

// assign size_o[0] = 200;
// assign size_o[1] = 600;
// assign size_o[2] = 200;
// assign size_o[3] = 1800;

assign size_val_o[0] = 1;
assign size_val_o[1] = 1;
assign size_val_o[2] = 1;
assign size_val_o[3] = 1;


initial
  begin
    // zero time
    for( int i = 0; i < PKT_QS_CNT; i++ )
      size_o[i] = $urandom_range( 64, 1500 );
    // change condition
    forever
    begin
      @( posedge clk_i );
      if( cng_val_i )
        size_o[cng_addr_i] <= $urandom_range( 64, 1500 );
    end
  end


endmodule
