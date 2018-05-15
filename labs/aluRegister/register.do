# Set the working dir, where all compiled Verilog goes.
vlib work

# Compile all Verilog modules in mux.v to working dir;
# could also have multiple Verilog files.
# The timescale argument defines default time unit
# (used when no unit is specified), while the second number
# defines precision (all times are rounded to this value)
vlog -timescale 1ns/1ns aluRegister.v

# Load simulation using mux as the top level simulation module.
vsim aluRegister

# Log all signals and add some signals to waveform window.
log {/*}
# add wave {/*} would add all items in top level simulation module.
add wave {/*}

#A signals
force {SW[0]} 0 0, 1 20 -repeat 40
force {SW[1]} 0 0, 1 40 -r 80
force {SW[2]} 0 0, 1 80 -r 160
force {SW[3]} 0 0, 1 160 -r 320

#Select signals
force {SW[5]} 0 0, 1 20 -repeat 40
force {SW[6]} 0 0, 1 40 -r 80
force {SW[7]} 0 0, 1 80 -r 160

#reser_n signals
force {SW[9]} 0 0, 1 20 -repeat 40

#clock signal
force {KEY[0]} 0 0 , 1 20 -repeat 40


run 180ns