typedef enum logic [2:0] {
    SRC_ZERO, SRC_A, SRC_B, SRC_ALU, SRC_MEM, SRC_IMM
} bus_src_e;

module bus #(
    parameter N = 8
)(
    input  logic [N-1:0] alu_y,
    input  logic [N-1:0] q_A,
    input  logic [N-1:0] q_B,
    input  logic [N-1:0] ram_dout,
    input  logic [N-1:0] imm_data,
    input  bus_src_e     sel_bus,  // Control which source drives bus
    output logic [N-1:0] bus_out
);

    always_comb begin
        unique case (sel_bus)
            SRC_ZERO: bus_out = '0;               // Zero source
            SRC_A   : bus_out = q_A;              // Register A
            SRC_B   : bus_out = q_B;              // Register B
            SRC_ALU : bus_out = alu_y;            // ALU output
            SRC_MEM : bus_out = ram_dout;         // Memory output
            SRC_IMM : bus_out = imm_data;         // Immediate data
            default : bus_out = '0;               // Default case
        endcase
    end

endmodule
