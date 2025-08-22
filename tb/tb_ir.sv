module tb_ir;

  logic clk, reset, load;
  logic [7:0] din;
  logic [3:0] opcode;
  logic [3:0] operand;

  // Instantiate the DUT
  ir dut (
    .clk(clk),
    .reset(reset),
    .load(load),
    .din(din),
    .opcode(opcode),
    .operand(operand)
  );

  // Clock generation
  initial clk = 0;
  always #5 clk = ~clk;

  // Test sequence
  initial begin
    reset   = 1;
    load    = 0;
    din     = 0;

    // Wait for a couple of clock cycles
    repeat(2) @(posedge clk);
    reset = 0;
    
    $display("din=%h opcode=%h operand=%h", din, opcode, operand);
    
    //LOAD = 0
    @(posedge clk)
    din = 8'hE5;
    $display("din=%h opcode=%h operand=%h", din, opcode, operand);

	//LOAD = 1
    load = 1;
    @(posedge clk)
    load = 0;
    $display("din=%h opcode=%h operand=%h", din, opcode, operand);
    
    
    $finish;
  end

endmodule