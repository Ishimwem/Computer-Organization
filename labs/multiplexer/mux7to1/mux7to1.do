# Set the working dir, where all compiled Verilog goes.
vlib work

# Compile all Verilog modules in mux.v to working dir;
# could also have multiple Verilog files.
# The timescale argument defines default time unit
# (used when no unit is specified), while the second number
# defines precision (all times are rounded to this value)
vlog -timescale 1ns/1ns mux7to1.v

# Load simulation using mux as the top level simulation module.
vsim mux7to1

# Log all signals and add some signals to waveform window.
log {/*}
# add wave {/*} would add all items in top level simulation module.
add wave {/*}

force {SW[0]} 1
force {SW[1]} 1
force {SW[2]} 0
force {SW[3]} 1
force {SW[4]} 0
force {SW[5]} 0
force {SW[6]} 1
#Select signals
force {SW[7]} 0 0 , 1 10 ns -repeat 20
force {SW[8]} 0 0 , 1 20 ns -repeat 40
force {SW[9]} 0 0 , 1 40 ns -repeat 80

run 40ns