//SW[9] select signal

//LEDR[0] output display

module mux2(LEDR, SW);
    input [9:0] SW;
    output [9:0] LEDR;

    mux4to1 u0(
        .u(SW[0]),
        .v(SW[1]),
        .w(SW[2]),
		  .x(SW[3]),
		  .s0(SW[8]),
		  .s1(SW[9]),
        .m(LEDR[0])
        );
endmodule

module mux4to1(u,v,w,x,s0,s1,m);
	input u; // selected when s1 is 0 and s0 is 0
	input v; // selected when s1 is 0 and s0 is 1
	input w; //selected when s1 is 1 and s0 is 0
	input x; //selected when s1 is 1 and s0 is 1
	input s0;
	input s1;
	output m;
	
	wire connection1;
	wire connection2;
	
	mux2to1 m0(
        .x(u),
        .y(v),
        .s(s0),
        .n(connection1)
        );
		  
	mux2to1 m1(
        .x(w),
        .y(x),
        .s(s0),
        .n(connection2)
        );
		  
	mux2to1 m2(
        .x(connection1),
        .y(connection2),
        .s(s1),
        .n(m)
        );
		   
endmodule


module mux2to1(x, y, s, n);
	input x; //selected when s is 0
	input y; //selected when s is 1
   input s; //select signal
   output n; //output
  
    assign n = s & y | ~s & x;

endmodule