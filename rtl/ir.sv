module ir (
    input  logic clk, reset, load,
    input  logic [7:0] din,
    output logic [3:0] opcode,
    output logic [3:0] operand
);

logic [7:0] q;

always_ff @(posedge clk) begin
    if (reset)     q <= 8'b0;
    else if (load) q <= din;
end

assign opcode  = q[7:4];
assign operand = q[3:0];

endmodule