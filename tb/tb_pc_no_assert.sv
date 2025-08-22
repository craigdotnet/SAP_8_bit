module tb_pc;
  
  parameter N = 8;
  logic clk, reset;
  logic inc, load;
  logic [N-1:0] d;
  logic [N-1:0] q;
  
  pc #(8) dut (
    .clk(clk),
    .reset(reset),
    .inc(inc),
    .load(load),
    .d(d),
    .q(q)
  );
  
  always #5 clk = ~clk;
  
  initial begin
    reset	= 1;
    inc		= 0;
    load	= 0;
    d		= 8'b0;
    clk		= 0;
    
    repeat(2) @(posedge clk);
    reset	= 0;
    
    // Test INC
    inc		= 1;
    load	= 0;
    
    @(posedge clk);
    inc		= 0;
    $display("q=%h (expect q=1) ",q);
    
    
    // Test LOAD
    inc		= 0;
    load	= 1;
    d		= 8'hF0;
    @(posedge clk);
    load	= 0;
    $display("q=%h (expect q=f0) ",q);
    
    // Test INC
    inc		= 1;
    load	= 0;
    
    @(posedge clk);
    inc		= 0;
    $display("q=%h (expect q=f1) ",q);
    
    // Test LOAD & INC
    inc		= 1;
    load	= 1;
    d		= 8'hF0;
    @(posedge clk);
    load	= 0;
    $display("q=%h (expect q=f0) ",q);
    
    $finish;
  end
endmodule