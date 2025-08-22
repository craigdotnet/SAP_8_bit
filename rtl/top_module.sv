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
`include "rtl\alu.sv"

module top_module (
  input  logic       clk,
  input  logic       reset,
  output logic [7:0] out_port,
  output logic       z_flag
);
  
  // Tasks for testbench use
  task load_memory(input logic [7:0] data[], input int size);
    for (int i = 0; i < size; i++) begin
      u_ram.mem[i] = data[i];
    end
  endtask
  task memory_dump(input int start_addr = 0, input int end_addr = 255);
    $display("------ RAM Memory Dump [%0d to %0d] ------", start_addr, end_addr);
    for (int i = start_addr; i <= end_addr; i++) begin
      $display("mem[%0d] = 0x%02h", i, u_ram.mem[i]);
    end
    $display("------------------------------------------");
  endtask
  task memory_dump_pretty(input int start_addr = 0, input int end_addr = 255);
    $display("------ RAM Memory Dump [%0d to %0d] ------", start_addr, end_addr);
    for (int i = start_addr; i <= end_addr; i++) begin
      $write("0x%02h ", u_ram.mem[i]);
      if ((i - start_addr + 1) % 8 == 0 || i == end_addr)
        $write("\n");
    end
    $display("------------------------------------------");
  endtask

  
  // Wires
  logic [7:0] A_q, B_q, bus, alu_y, mem_dout;
  logic [7:0] pc_q; logic [3:0] opcode, operand;
  logic z,n,c,v; bus_src_e bus_sel; phase_e phase; 
  logic halt;

  //Control signals
  logic pc_inc, pc_load;
  logic [7:0] pc_d;

  logic ir_load;

  logic A_en, B_en, OUT_en;

  logic mem_we;
  logic [7:0] mem_din;
  logic [7:0] mem_addr;

   alu_op_e alu_op;

  // ALU Input B select
  logic [7:0] alu_b;

  // PC + IR + RAM
  pc          u_pc(.clk, .reset, .inc(pc_inc), .load(pc_load), .d(pc_d), .q(pc_q));
  ram8x256    u_ram(.clk, .addr(mem_addr), .din(mem_din), .we(mem_we), .dout(mem_dout));
  ir          u_ir(.clk, .reset, .load(ir_load), .din(mem_dout), .opcode(opcode), .operand(operand));

  // Registers
  reg_en      u_regA(.clk, .reset, .en(A_en), .d(bus), .q(A_q));
  reg_en      u_regB(.clk, .reset, .en(B_en), .d(bus), .q(B_q));
  reg_en      u_out (.clk, .reset, .en(OUT_en), .d(bus), .q(out_port));

  // ALU
  alu         u_alu(.a(A_q), .b(alu_b), .op(alu_op), .y(alu_y), .z(z), .n(n), .c(c), .v(v));
  assign z_flag = z;

  // Addressing
  assign mem_addr = (phase==FETCH) ? pc_q : {4'b0000, operand};

  // ALU B input comes either from B or directly RAM (so ADD can be 1 cycle)
  typedef enum logic {BSEL_B=1'b0, BSEL_MEM=1'b1} bsel_e;
  logic bsel;
  assign alu_b = (bsel==BSEL_MEM) ? mem_dout : B_q;

  // Bus mux
  always_comb begin
    unique case (bus_sel)
      SRC_ZERO: bus = 8'h00;
      SRC_A   : bus = A_q;
      SRC_B   : bus = B_q;
      SRC_ALU : bus = alu_y;
      SRC_MEM : bus = mem_dout;
      SRC_IMM : bus = {4'b0000, operand};
      default : bus = 8'h00;
    endcase
  end

  // Control Unit (you implement): drives ir_load, pc_inc, pc_load, pc_d, A_en, B_en,
  // OUT_en, mem_we, mem_din, bus_sel, bsel, alu_op, phase, halt
  //control u_ctrl(.*);
  control_unit u_ctrl(.clk(clk), .reset(reset), .opcode(opcode), .operand(operand),
                      .z(z), .bus(bus), .phase(phase), .halt(halt), .ir_load(ir_load),
                      .pc_inc(pc_inc), .pc_load(pc_load), .pc_d(pc_d),
                      .A_en(A_en), .B_en(B_en), .OUT_en(OUT_en),
                      .mem_we(mem_we), .mem_din(mem_din), .bus_sel(bus_sel), .bsel(bsel), .alu_op(alu_op));
endmodule

