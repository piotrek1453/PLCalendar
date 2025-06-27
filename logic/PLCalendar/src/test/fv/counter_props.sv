module binary_counter_props (
    input logic countIn,
    input logic resetIn,
    input logic [COUNTER_LEN-1:0] countOut,
    input logic overflowOut
);
  parameter COUNTER_LEN = 32;

  // Property 1: Reset zeroes the counter
  property p_reset;
    resetIn == 0 |=> (countOut == 0 && overflowOut == 0);
  endproperty
  assert property (p_reset);

  // Property 2: Overflow only at max value
  property p_overflow;
    (countOut == '1 && countIn) |=> overflowOut;
  endproperty
  assert property (p_overflow);

  // Property 3: No overflow during counting
  property p_no_early_overflow;
    (countOut != '1) |=> !overflowOut;
  endproperty
  assert property (p_no_early_overflow);
endmodule
