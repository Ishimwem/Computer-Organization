vlib work

vlog -timescale 1ns/1ns vgaAdapter.v

vsim intermediate

log {/*}
add wave {/*}

force {go} 1 0, 0 25 -r 50
force {resetn} 0 0,1 100
force {clk} 0 0,1 4 -r 8 
force {data_in} 7'b0000000 0, 7'b00000010 10
force {c} 3'b010 
run 1000ns