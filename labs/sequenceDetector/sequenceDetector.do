vlib work

vlog -timescale 1ns/1ns sequenceDetector.v

vsim sequenceDetector

log {/*}
add wave {/*}
force {SW[0]} 0 0, 1 15
force {SW[1]} 0 0, 1 5 -r 20
force {KEY[0]} 0 0, 1 10 -r 20

run 400 ns