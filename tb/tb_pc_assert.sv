module tb_pc;

  parameter N = 8;
  logic clk, reset;
  logic inc, load;
  logic [N-1:0] d;
  logic [N-1:0] q;

  // Instantiate the DUT
  pc #(N) dut (
    .clk(clk),
    .reset(reset),
    .inc(inc),
    .load(load),
    .d(d),
    .q(q)
  );

  // Clock generation
  initial clk = 0;
  always #5 clk = ~clk;

  // Test sequence
  initial begin
    reset = 1;
    inc   = 0;
    load  = 0;
    d     = 8'b0;

    // Wait for a couple of clock cycles
    repeat(2) @(posedge clk);
    reset = 0;

    // Test INC: q should increment to 1
    inc   = 1;
    load  = 0;
    @(posedge clk);
    inc   = 0;
    assert(q == 8'h01) else $fatal(1,"INC failed: q=%h, expected 01", q);

    // Test LOAD: q should load 0xF0
    load  = 1;
    d     = 8'hF0;
    @(posedge clk);
    load  = 0;
    assert(q == 8'hF0) else $fatal(1,"LOAD failed: q=%h, expected F0", q);

    // Test INC again: q should increment to 0xF1
    inc   = 1;
    load  = 0;
    @(posedge clk);
    inc   = 0;
    assert(q == 8'hF1) else $fatal(1,"INC after LOAD failed: q=%h, expected F1", q);

    // Test simultaneous LOAD & INC: LOAD should take priority, q = 0xF0
    inc   = 1;
    load  = 1;
    d     = 8'hF0;
    @(posedge clk);
    load  = 0;
    inc   = 0;
    assert(q == 8'hF0) else $fatal(1,"LOAD & INC failed: q=%h, expected F0", q);

    $display("All assertions passed.");
    $finish;
  end

endmodule