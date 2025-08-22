typedef enum logic [2:0] {
    ALU_ADD, ALU_SUB, ALU_AND, ALU_OR, ALU_XOR, ALU_PASS
} alu_op_e;

module alu #(parameter N=8) (
    input  logic [N-1:0] a, b,
    input  alu_op_e op,
    output logic [N-1:0] y,
    output logic z, n, c, v
);

    // Flags:   Z = Zero
    //          N = Negative
    //          C = Carry
    //          V = Overflow

    logic [N:0] sum;

    always_comb begin
        y = '0; sum = '0; c = 1'b0; v = 1'b0;

        unique case (op)
            ALU_ADD: begin
                sum = a + b;
                y   = sum[N-1:0];
                c   = sum[N];                               // carry-out for addition
                v   = (a[N-1]==b[N-1]) && (y[N-1]!=a[N-1]); // overflow
            end

            ALU_SUB: begin
                sum = {1'b0,a} - {1'b0,b};                  // extend to N+1 bits
                y   = sum[N-1:0];
                c   = a >= b;                               // proper borrow/carry flag
                v   = (a[N-1]!=b[N-1]) && (y[N-1]!=a[N-1]); // overflow
            end

            ALU_AND: y = a & b;
            ALU_OR : y = a | b;
            ALU_XOR: y = a ^ b;
            ALU_PASS: y = a;

            default: y = '0;
        endcase
    end

    assign z = (y==0);
    assign n = y[N-1];

endmodule
