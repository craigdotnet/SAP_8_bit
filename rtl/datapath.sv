`include "rtl/reg_en.sv"
`include "rtl/alu.sv"
module datapath #(
    parameter N = 8
    )(
    input logic clk,
    input logic reset,

    // Control signals
    input alu_op_e op,      // ALU operation type
    input logic en_A,       // Enable write to register A
    input logic en_B,       // Enable write to register B
    input logic sel_A,      // Select input for register A
    input logic sel_B,      // Select input for register B
    input logic load_out,   // Load output from ALU

    // Inputs
    input logic [N-1:0] bus_in,     // Input data bus
    input logic [N-1:0] imm_data,   // Immediate data input

    // Outputs
    output logic [N-1:0] q_A, q_B,  // Outputs from registers
    output logic [N-1:0] alu_y,     // Output from ALU
    output logic [N-1:0] out_reg,   // Output register (if needed)
    output logic z, n, c, v         // Flags from ALU operation 
);

    // ----------------------------------------
    // Internal Signals
    // ----------------------------------------
    logic [N-1:0] d_A, d_B; // Data inputs for registers

    // ----------------------------------------
    // Register Instantiations
    // ----------------------------------------
    reg_en #(N) regA (.clk(clk), .reset(reset), .en(en_A), .d(d_A), .q(q_A));
    reg_en #(N) regB (.clk(clk), .reset(reset), .en(en_B), .d(d_B), .q(q_B));

    // ----------------------------------------
    // ALU Instantiation
    // ----------------------------------------
    alu alu (
        .a(q_A),
        .b(q_B),
        .op(op),      // Operation type from control signals
        .y(alu_y),    // Output from ALU
        .z(z),        // Zero flag 
        .n(n),        // Negative flag
        .c(c),        // Carry flag
        .v(v)         // Overflow flag
    );

    // ----------------------------------------
    // Output Register (Optional)
    // ----------------------------------------
    reg_en #(N) outRegister (
        .clk(clk),
        .reset(reset),
        .en(load_out), // Enable output register when load_out is high
        .d(alu_y),     // Data input from ALU output
        .q(out_reg)    // Output from the output register
    );

    // ----------------------------------------
    // Input Selection Logic
    // ----------------------------------------
    assign d_A = (sel_A) ? bus_in : imm_data; // Select input for register A
    assign d_B = (sel_B) ? bus_in : imm_data; // Select input for register B

endmodule