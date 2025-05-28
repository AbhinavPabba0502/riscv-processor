# Synthesis script for Vivado
create_project riscv_project ./riscv_project -part xc7a100tcsg324-1
add_files -norecurse src/riscv_top.v src/instruction_memory.v src/register_file.v src/alu.v src/control_unit.v src/data_memory.v
synth_design -top riscv_top -part xc7a100tcsg324-1
report_utilization -file docs/synthesis_report.txt
report_timing_summary -file docs/timing_report.txt