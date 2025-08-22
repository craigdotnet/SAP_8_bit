module tb_ram8x256;

    // Testbench signals
    logic clk;
    logic [7:0] addr;
    logic [7:0] din;
    logic we;
    logic [7:0] dout;

    // Instantiate the RAM
    ram8x256 dut (
        .clk(clk),
        .addr(addr),
        .din(din),
        .we(we),
        .dout(dout)
    );

    // Clock generation: 10ns period
    always #5 clk = ~clk;

    // Test procedure
    initial begin
        // Initialize signals
        clk = 0;
        addr = 0;
        din = 0;
        we = 0;

        // Wait for global reset
        #1; //allow signal propagation
        @(posedge clk);

        // Write data to several addresses
        for (int i = 0; i < 10; i++) begin
            addr = i;
            din = i + 100;
            we = 1;
            #1;  // allow signal propagation
            @(posedge clk);
        end

        // Disable write
        we = 0;

        // Read back and check values
        for (int i = 0; i < 10; i++) begin
            addr = i;
            #1; // Small delay for read to settle  (Just for testbenches, not needed in HDL)
            @(posedge clk);
            #1;
            $display("Read addr %0d: dout = %0d (expected %0d)", addr, dout, i + 100);
            if (dout !== (i + 100)) begin
                $error("Mismatch at addr %0d: got %0d, expected %0d", addr, dout, i + 100);
            end
        end

        $display("RAM test completed successfully.");
        $finish;
    end
  
    
  initial
    begin
      $dumpfile("dump.vcd");
      $dumpvars(0);
    end

endmodule