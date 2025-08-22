`timescale 1ns/1ps

module tb_datapath;

  parameter N = 8;

  // DUT Signals
  logic clk, reset;
  alu_op_e op;
  logic en_A, en_B, sel_A, sel_B, load_out;
  logic [N-1:0] bus_in, imm_data;
  logic [N-1:0] q_A, q_B, alu_y, out_reg;
  logic z, n, c, v;

  // Instantiate DUT
  datapath #(N) dut (
    .clk(clk), .reset(reset),
    .op(op), .en_A(en_A), .en_B(en_B),
    .sel_A(sel_A), .sel_B(sel_B), .load_out(load_out),
    .bus_in(bus_in), .imm_data(imm_data),
    .q_A(q_A), .q_B(q_B), .alu_y(alu_y),
    .out_reg(out_reg), .z(z), .n(n), .c(c), .v(v)
  );

  // Clock Generation
  always #5 clk = ~clk;

  // Helper Task: Load values into A and B
  task load_regs(input logic [N-1:0] a_val, b_val, input logic use_bus);
    begin
      if (use_bus) begin
        bus_in = a_val; sel_A = 1; en_A = 1; #10 en_A = 0;
        bus_in = b_val; sel_B = 1; en_B = 1; #10 en_B = 0;
      end else begin
        imm_data = a_val; sel_A = 0; en_A = 1; #10 en_A = 0;
        imm_data = b_val; sel_B = 0; en_B = 1; #10 en_B = 0;
      end
    end
  endtask

  // Helper Task: Perform ALU operation and check result
  task test_alu_op(input alu_op_e test_op, input logic [N-1:0] a, b, expected_y);
    begin
      load_regs(a, b, 0);
      op = test_op;
      #10;
      load_out = 1; #10 load_out = 0;

      $display("Testing %s: A=%h, B=%h, Y=%h", test_op.name(), a, b, alu_y);
      assert(alu_y == expected_y)
        else $error("ALU %s failed: expected %h, got %h", test_op.name(), expected_y, alu_y);
    end
  endtask

  initial begin
    $display("Starting enhanced datapath testbench...");
    clk = 0; reset = 1;
    en_A = 0; en_B = 0; sel_A = 0; sel_B = 0; load_out = 0;
    bus_in = 0; imm_data = 0; op = ALU_PASS;

    // Reset
    #10 reset = 0;

    // Test ADD
    test_alu_op(ALU_ADD, 8'h0A, 8'h05, 8'h0F);

    // Test SUB
    test_alu_op(ALU_SUB, 8'h0A, 8'h05, 8'h05);

    // Test AND
    test_alu_op(ALU_AND, 8'hF0, 8'h0F, 8'h00);

    // Test OR
    test_alu_op(ALU_OR, 8'hF0, 8'h0F, 8'hFF);

    // Test XOR
    test_alu_op(ALU_XOR, 8'hAA, 8'h55, 8'hFF);

    // Test PASS
    load_regs(8'h3C, 8'h00, 0);
    op = ALU_PASS; #10;
    assert(alu_y == q_A)
      else $error("PASS failed: expected %h, got %h", q_A, alu_y);

    // Final check
    #20;
    $display("All tests completed.");
    $finish;
  end

endmodule