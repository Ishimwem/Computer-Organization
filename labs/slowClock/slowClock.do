vlib work

vlog -timescale 1ns/1ps slowClock.v

vsim slowClock

log {/*}
add wave {/*}

force {load[3: 0]} 2#0000

force {clock} 0 0, 1 1 -r 2

force {reset_n} 1 0, 0 5, 1 10

force {par_load} 0

force {enable} 1

force {freq[1:	0]}  2#01


run 1000000ns