module shifter(LEDR, SW, KEY);

	input [9:0]SW;
	input [3:0]KEY;
	input [7:0]LEDR;

	shifterMain s1(.OutShifter(LEDR[7:0]),.loadVal(SW[7:0]), .reset_n(SW[9]), .load_n(KEY[1]),
			.shift(KEY[2]), .asr(KEY[3]), .clock(KEY[0]));


endmodule

module shifterMain(OutShifter, loadVal, reset_n, load_n, shift, asr, clock);

	input [7:0]loadVal;
	input reset_n;
	input load_n;
	input shift;
	input asr;
	input clock;
	output [7:0]OutShifter;
	wire out0, out1, out2, out3, out4, out5, out6, out7;
	reg in1;

	always @(*)
	begin
		if (asr == 1'b0)
			in1 <= 0;
		else
			in1 <= loadVal[7]; 
	end
	
	shifterBit s0(.Out(out0), .loadBit(loadVal[7]), .in(in1), .shift(shift), 
			.load_n(load_n), .clock(clock), .reset_n(reset_n));

	shifterBit s1(.Out(out1), .loadBit(loadVal[6]), .in(out0), .shift(shift), 
			.load_n(load_n), .clock(clock), .reset_n(reset_n));

	shifterBit s2(.Out(out2), .loadBit(loadVal[5]), .in(out1), .shift(shift), 
			.load_n(load_n), .clock(clock), .reset_n(reset_n));

	shifterBit s3(.Out(out3), .loadBit(loadVal[4]), .in(out2), .shift(shift), 
			.load_n(load_n), .clock(clock), .reset_n(reset_n));

	shifterBit s4(.Out(out4), .loadBit(loadVal[3]), .in(out3), .shift(shift), 
			.load_n(load_n), .clock(clock), .reset_n(reset_n));

	shifterBit s5(.Out(out5), .loadBit(loadVal[2]), .in(out4), .shift(shift), 
			.load_n(load_n), .clock(clock), .reset_n(reset_n));

	shifterBit s6(.Out(out6), .loadBit(loadVal[1]), .in(out5), .shift(shift), 
			.load_n(load_n), .clock(clock), .reset_n(reset_n));

	shifterBit s7(.Out(out7), .loadBit(loadVal[0]), .in(out6), .shift(shift), 
			.load_n(load_n), .clock(clock), .reset_n(reset_n));

	assign OutShifter[7:0] = {out0, out1, out2, out3, out4, out5, out6, out7};

endmodule

module shifterBit(Out, loadBit, in, shift, load_n, clock, reset_n);

	input loadBit, in, shift, load_n, clock, reset_n;
	output Out;
	wire w1;
	wire w2;
	mux2to1 m1(.x(Out), .y(in), .s(shift), .m(w1));
	mux2to1 m2(.x(loadBit), .y(w1), .s(load_n), .m(w2));
	flipflop f1(.q(Out), .clock(clock), .d(w2), .reset_n(reset_n));
	

endmodule

module mux2to1(x, y, s, m);
    input x; //selected when s is 0
    input y; //selected when s is 1
    input s; //select signal
    output m; //output
  
    assign m = s & y | ~s & x;

endmodule

module flipflop( q,clock, d, reset_n);

	input clock;
	input d;
	input reset_n;
	output reg q;

	always @(posedge clock)
	begin
		if (reset_n == 1'b0)
			q <= 1'b0;
		else
			q <= d; 
	end
	
endmodule