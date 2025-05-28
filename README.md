# riscv-processor
A 32-bit RISC-V processor implementation in Verilog.

RISC-V Processor (RV32I) Implementation

Overview

This project implements a 32-bit RISC-V processor supporting the RV32I base instruction set. The design features a 5-stage pipeline (Fetch, Decode, Execute, Memory, Write-back) and includes data forwarding to handle RAW hazards. It is synthesized for a Xilinx Artix-7 FPGA using Vivado and verified with a SystemVerilog testbench.

Features
5-stage pipeline architecture
Supports RV32I instructions: ADD, SUB, ADDI, LW, SW, BEQ
Data forwarding for RAW hazard resolution
Synthesized for Xilinx Artix-7 FPGA
Testbench with sample test cases

Tools and Languages
Languages: Verilog, SystemVerilog
Tools: Xilinx Vivado 2023.1, ModelSim
Simulation: Tests ADD, ADDI, and basic instruction sequences

Directory Structure
src/: Verilog source files for processor modules
testbench/: SystemVerilog testbench
scripts/: Synthesis and simulation scripts
docs/: Block diagrams, synthesis reports, and design notes

How to Run
Clone the repository: git clone https://github.com/AbhinavPabba0502/riscv-processor
Open Vivado and source scripts/synthesis.tcl to synthesize the design.
Run simulation using scripts/simulate.do in ModelSim.
View waveforms in docs/riscv.vcd (generated during simulation).

Results
Area: ~12,500 LUTs on Artix-7 (estimated)
Max Frequency: ~100 MHz (estimated)
Simulation: Verified ADD, ADDI instructions
See docs/synthesis_report.txt for detailed metrics (after synthesis).

Block Diagram

Challenges and Solutions
Challenge: Resolving data hazards in the pipeline.
Solution: Implemented data forwarding to bypass ALU results to earlier stages.
See docs/design_notes.md for details.

Future Improvements
Add support for RV32M (multiply/divide) instructions.
Enhance testbench for 100% functional coverage.
Optimize for power using low-power synthesis techniques.

Contact
For feedback or questions, reach out via GitHub or apabb0502@gmail.com.
