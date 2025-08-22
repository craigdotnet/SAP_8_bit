typedef enum logic [0:0] {
    FETCH=1'b0, EXEC=1'b1
} phase_e;

typedef enum logic [3:0] {
    OP_NOP=4'h0, OP_LDA=4'h1, OP_ADD=4'h2, OP_SUB=4'h3, OP_STA=4'h4,
    OP_LDI=4'h5, OP_JMP=4'h6, OP_JZ =4'h7, OP_OUT=4'h8, OP_HLT=4'hF
} opcode_e;

typedef enum logic [2:0] {
    ALU_ADD, ALU_SUB, ALU_AND, ALU_OR, ALU_XOR, ALU_PASS
} alu_op_e;

typedef enum logic [2:0] {
    SRC_ZERO, SRC_A, SRC_B, SRC_ALU, SRC_MEM, SRC_IMM
} bus_src_e;

module control_unit #(
    parameter N = 8
)(
    input  logic clk,
    input  logic reset,
    input  logic [3:0] opcode, operand, // Current instruction opcode
    input  logic z,                     // Zero flag from ALU
    input  logic [N-1:0] bus,           // Data bus input from datapath
    output phase_e phase,               // Current phase of operation
    output logic halt,                  // Halt signal
    //datapath control signals
    output logic ir_load,               // Load instruction register
    output logic pc_inc,                // Increment program counter
    output logic pc_load,               // Load program counter with new value
    output logic [N-1:0] pc_d,          // Data to load into program counter
    output logic A_en,                  // Enable write to register A
    output logic B_en,                  // Enable write to register B
    output logic OUT_en,                // Enable output register
    output logic mem_we,                // Memory write enable
    output logic [N-1:0] mem_din,       // Data to write to memory
    output bus_src_e bus_sel,           // Select source for the bus
    output logic bsel,                  // Select ALU B input source
    output alu_op_e alu_op              // ALU operation type
);

    phase_e phase_q, phase_d;           // State register for current phase
  	logic halt_q, halt_d;
    
    // State Register
    always_ff @(posedge clk or posedge reset) begin
        if (reset) begin
            phase_q <= FETCH;   // Reset to FETCH phase
            halt_q <= 0;          // Reset halt signal
        end else begin
          phase_q <= (halt_q ? phase_q : phase_d); // Update phase unless halted
          halt_q  <= halt_d;
        end
    end
    assign phase = phase_q;     // Expose current phase
  	assign halt	 = halt_q;		// Expose halt phase


    always_comb begin
        // Default control signals
        ir_load=0; pc_inc=0; pc_load=0; pc_d='0; A_en=0; B_en=0; OUT_en=0;
        mem_we=0; mem_din='0; bus_sel=SRC_ZERO; alu_op=ALU_ADD; bsel=0;
      	// Default next-state values
      	phase_d = FETCH;
        halt_d  = halt_q;

        case (phase_q)
            FETCH: begin
                ir_load = 1;    // Instruction register load <= MEM[PC]
                pc_inc  = 1;    // Increment program counter
                phase_d = EXEC;
            end

            EXEC: begin
              	phase_d = FETCH;	//Default transition back to FETCH
                unique case (opcode)
                    OP_NOP: ; // No operation, do nothing
                    OP_LDA: begin A_en = 1; bus_sel = SRC_MEM; end                                  // RAM -> A
                    OP_LDI: begin A_en = 1; bus_sel = SRC_IMM; end                                  // Immediate -> A
                    OP_ADD: begin A_en = 1; bus_sel = SRC_ALU; alu_op = ALU_ADD; bsel = 1; end      // ADD A + B
                    //OP_AND: begin A_en = 1; bus_sel = SRC_ALU; alu_op = ALU_AND; bsel = 1; end      // AND A + B
                    //OP_OR:  begin A_en = 1; bus_sel = SRC_ALU; alu_op = ALU_OR;  bsel = 1; end      // OR A + B
                    //OP_XOR: begin A_en = 1; bus_sel = SRC_ALU; alu_op = ALU_XOR; bsel = 1; end      // XOR A + B
                    OP_SUB: begin A_en = 1; bus_sel = SRC_ALU; alu_op = ALU_SUB; bsel = 1; end      // SUB A - B
                    OP_STA: begin           bus_sel = SRC_A;                                        // ALU output to memory
                                            mem_we = 1;                                             // Enable memory write
                                            mem_din = bus; end                                      // Write ALU output to memory
                    OP_JMP: begin pc_load = 1; pc_d = {4'b0000,operand}; end                        // Jump to address in operand
                    OP_JZ:  begin if (z) begin pc_load = 1; pc_d = {4'b0000,operand}; end end       // Jump if zero flag is set
                    OP_OUT: begin OUT_en = 1; bus_sel = SRC_ALU; end                                // Output ALU result
                    OP_HLT: begin phase_d = phase_q; halt_d = 1; end                                  // Halt the CPU
                    default: halt_d = 1; // Unknown opcode, halt the CPU
                endcase
            end
        endcase
    end
endmodule
