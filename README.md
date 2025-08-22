# SystemVerilog – 8-bit SAP CPU

This project implements a simplified 8-bit Simple-As-Possible (SAP) CPU using SystemVerilog.  
It is based on the classic design often introduced in first-year computer architecture courses.  

<ins>Current Status</ins>  
- Fully functional core with basic operations implemented  
- Some opcodes are not yet defined, and a few have no logic implemented  
- Single FETCH/EXECUTE cycle (no instruction counter yet)  
- Designed as a proof-of-concept for future expansion  
- <ins>Note:</ins> An instruction counter and additional opcodes will be added in future iterations, but the current version prioritizes demonstrating the core concept.  

<ins>Testbench</ins>  
The provided testbench tb_top.sv allows you to:  
- Load a simple program using the init_mem[x] initialization method  
- Run simulations to validate functionality  
- Use built-in debug tasks for easier troubleshooting (these can be removed for FPGA deployment and are located in the top_module.sv)

<ins>Simulation Notes</ins>  
  When testing on platforms such as EDA Playground:  
- Combine all module files into a single file and place the typedef statements at the top (Several modules have duplicate typedef statements, or `include statements. Discard these as they are only included if you are testing the module separate of all the others.)  
- Include the tb_top.sv testbench for simulation (the other testbenches included are only used if you want to test each module separately.) 
- Waveforms are optional—the top_module provides memory dumps before and after execution, along with key register values for quick verification
