module pc #(parameter N=8) (
    input  logic clk, reset,
    input  logic inc, load,
    input  logic [N-1:0] d,
    output logic [N-1:0] q
);

    always_ff @(posedge clk) begin
        if (reset) q <= '0;
        else if (load) q <= d;
        else if (inc) q <= q + 1'b1;
    end

endmodule