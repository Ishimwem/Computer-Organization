vlib work

vlog -timescale 1ns/1ns morseCode.v

vsim morseCode

log {/*}
add wave {/*}


force {letter[2: 0]} 2#110
force {display} 1 0, 0 20
force {clock} 0 0, 1 10 -r 20
force {reset_n} 1 0, 0 1, 1 2
run 1800ns