# SAP_8_bit
SystemVerilog - 8 bit SAP CPU.  Fully functional, but some of the opcodes are not defined, and some do not have logic programmed yet

This is the classic 8 bit SAP usually done in 1st year class.  It works, but I am about to expand on it so I am not spending any more time to add additional opcodes or add the logic.
This is extremely simple with a single FETCH/EXECUTE cycle (no instruction counter).  Obviously an instruction counter needs to be added, but for now this was just a proof-of-concept.

The testbench tb_top.sv is where you can add a simple program and is setup with the init_mem[x] . . . code.
Also, the tasks in the top_module are solely there to assist in debugging and can be removed if programming on an FPGA board.

If you are testing on a platform (such as EDA Playground), you will need to combine all of the modules into 1 and make sure the typedef statements are at the very top.
Then add the tb_top.sv testbench and simulate.  You do not need waveforms as the top_module does a before/after mem dump and shows a few registers for sanity checks.
