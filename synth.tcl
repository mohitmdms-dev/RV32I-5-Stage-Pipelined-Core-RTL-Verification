# Import Yosys commands into the Tcl environment
yosys -import

# Use Tcl's built-in glob to safely find all Verilog files on Windows
set verilog_files [glob -nocomplain rtl/top/*.v rtl/core/*.v rtl/memory/*.v]

# Loop through the list and read each file with SystemVerilog support
foreach file $verilog_files {
    read_verilog -sv $file
}

# Synthesize the top-level processor (This automatically runs ABC mapping)
synth -top riscv_core

# Calculate and print the Longest Topological Path (Critical Path Timing)
ltp

# Print the final hardware statistics (Gate count)
stat