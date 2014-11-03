module drr_tester
#(
  PKT_QS_CNT = 4
)

(
  input                               arst_i,
  input [$clog2(PKT_QS_CNT)-1:0]      cng_addr_i, // address to change
  input                               cng_val_i,  // change is valid

  output logic [PKT_QS_CNT-1:0][15:0] size_o
);

// assigns for testing 
// assign size_o[0] = 50;
// assign size_o[1] = 300;
// assign size_o[2] = 200;
// assign size_o[3] = 1800;


always_comb
  begin
    if( arst_i )
      for( int i = 0; i < PKT_QS_CNT; i++ )
        size_o[i] = $urandom_range( 100, 2600 );
    else
      if( cng_val_i )
        size_o[cng_addr_i] = $urandom_range( 100, 2600 );
  end


endmodule
