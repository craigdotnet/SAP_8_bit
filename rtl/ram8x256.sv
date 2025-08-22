module ram8x256 (
    input  logic       clk,
    input  logic [7:0] addr,
    input  logic [7:0] din,
    input  logic       we,
    output logic [7:0] dout
);

    logic [7:0] mem [0:255];

    assign dout = mem[addr];  //Read available immediately
    always_ff @(posedge clk) begin
        if (we) mem[addr] <= din;
    end

endmodule