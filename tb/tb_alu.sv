module tb_alu;

  parameter N = 8;
  logic [N-1:0] a, b, y;
  logic z, n, c, v;
  alu_op_e op;

  // Instantiate the ALU
  alu #(N) dut (
    .a(a),
    .b(b),
    .op(op),
    .y(y),
    .z(z),
    .n(n),
    .c(c),
    .v(v)
  );

  // Task to run 10 random tests for a given operation
  task run_tests(input alu_op_e operation, input string op_name);
    begin
      op = operation;
      $display("\n--- Testing %s ---", op_name);
      for (int i = 0; i < 10; i++) begin
        a = $urandom_range(0, 255);
        b = $urandom_range(0, 255);
        #1;
        $display("Test %0d: a=%0d, b=%0d, y=%0d, z=%b, n=%b, c=%b, v=%b",
                 i, a, b, y, z, n, c, v);
      end
    end
  endtask

  initial begin
    $display("Starting ALU testbench...");

    run_tests(ALU_ADD,  "ALU_ADD");
    run_tests(ALU_SUB,  "ALU_SUB");
    run_tests(ALU_AND,  "ALU_AND");
    run_tests(ALU_OR,   "ALU_OR");
    run_tests(ALU_XOR,  "ALU_XOR");
    run_tests(ALU_PASS, "ALU_PASS");

    $display("\nAll tests completed.");
    $finish;
  end

endmodule