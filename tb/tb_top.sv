`timescale 1ns / 1ps

module cpu_tb;

  // Clock and reset
  logic clk;
  logic rst;
  
  logic [7:0] out_port;
  logic z_flag;
  
  // Instantiate CPU
  top_module uut (
    .clk(clk),
    .reset(rst),
    .out_port(out_port),
    .z_flag(z_flag)
  );

  // Clock generation
  always #5 clk = ~clk; // 100MHz clock

  // Program to load into RAM
  logic [7:0] init_mem [0:15];

  initial begin
    // Initialize clock and reset
    clk = 0;
    rst = 1;

    // Sample program:
    //init_mem[0] = 8'b0001_0100; // LDA 0x04
    //init_mem[1] = 8'b0010_0101; // ADD 0x05
    //init_mem[2] = 8'b0100_0110; // STA 0x06
    //init_mem[3] = 8'b1111_0000; // HLT
    //init_mem[4] = 8'd6;         // Data at address 0x04
    //init_mem[5] = 8'd10;        // Data at address 0x05
    //init_mem[6] = 8'hff;		// Will store result here
    
    init_mem[0] = 8'h55;	//LDI #5
    init_mem[1] = 8'h4A;	//STA d10
    init_mem[2] = 8'h1B;    //LDA 0x0B
    init_mem[3] = 8'h2A;    //ADD 0x0A
    init_mem[4] = 8'h4C;    //STA 0x0C
    init_mem[5] = 8'hF0;	//HLT
    init_mem[11] = 8'h08;	//Initial Value of 8

    // Load program into RAM
    uut.load_memory(init_mem, 16);

    // Release reset
    #20 rst = 0;
  end


  initial begin
    $display("Dumping Memory");
    uut.memory_dump_pretty(0,16);
    $display("XXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXX");
  end
  
  // Monitor key signals
  initial begin
    $display("Time\tPC\topcode\toperand\tzFlag\tA_q");
    $monitor("%0t\t%0d\t%h\t%0d\t%b\t%b", $time, uut.pc_q, uut.opcode, uut.operand, uut.z_flag, uut.A_q);
  end

  
  // End simulation when halted
  always @(posedge clk) begin
    if (uut.halt) begin
      uut.memory_dump(0,16);
      $display("CPU halted at time %0t", $time);
      $finish;
    end
  end
  
  
  initial
    begin
      $dumpfile("dump.vcd");
      $dumpvars(0);
    end

endmodule