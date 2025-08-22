module reg_en #(parameter N=8) (
    input logic clk, reset, en,
    input logic [N-1:0] d,
    output logic [N-1:0] q
    );
    always_ff @(posedge clk) begin
        if (reset) q <= '0;
        else if (en) q <= d;
    end
endmodule