module counter(HEX0, HEX1, SW, KEY);
	
	input [1:0]SW;
	input [0:0] KEY;
	output [6:0] HEX0;
	output [6:0] HEX1;
	
	wire [7:0] w1;
	
	counterMain m1(.Q(w1[7:0]), .enable(SW[1]), .clock(KEY[0]), .clear_b(SW[0]));
	
	sevenSegmentsDecoder h1(.HEXout(HEX0[6:0]), .In(w1[3:0]));
	sevenSegmentsDecoder h2(.HEXout(HEX1[6:0]), .In(w1[7:4]));

endmodule

module counterMain(Q, enable, clock, clear_b);

	input enable, clock, clear_b;
	output [7:0]Q;
	wire out7, out6, out5, out4, out3, out2, out1;
	
	Tflipflop t7(.q(Q[7]), .T(enable), .clear_b(clear_b), .clock(clock));
	assign out7 = Q[7] & enable;
	
	Tflipflop t6(.q(Q[6]), .T(out7), .clear_b(clear_b), .clock(clock));
	assign out6 = Q[6] & out7; 
	
	Tflipflop t5(.q(Q[5]), .T(out6), .clear_b(clear_b), .clock(clock));
	assign out5 = Q[5] & out6;
	
	Tflipflop t4(.q(Q[4]), .T(out5), .clear_b(clear_b), .clock(clock));
	assign out4 = Q[4] & out5;
	
	Tflipflop t3(.q(Q[3]), .T(out4), .clear_b(clear_b), .clock(clock));
	assign out3 = Q[3] & out4;
	
	Tflipflop t2(.q(Q[2]), .T(out3), .clear_b(clear_b), .clock(clock));
	assign out2 = Q[2] & out3;
	
	Tflipflop t1(.q(Q[1]), .T(out2), .clear_b(clear_b), .clock(clock));
	assign out1 = Q[1] & out2;
	
	Tflipflop t0(.q(Q[0]), .T(out1), .clear_b(clear_b), .clock(clock));
	

endmodule

//T flip flop module
module Tflipflop(q, T, clear_b, clock);
	
	input T, clear_b, clock;
	output q;
	
	reg ttfout;
	
	wire d;
	assign d = ~T & q | T & ~q;
	
	always @(posedge clock, negedge clear_b)
	begin
		if (clear_b == 1'b0)
			 ttfout <= 1'b0;
		else
			ttfout <= d; 
	end
	
	assign q = ttfout;


endmodule

// A seven segments HEX decoder
module sevenSegmentsDecoder(HEXout,In);

input [3:0]In;
output [6:0]HEXout;

assign HEXout[0] = (~In[3]&~In[2]&~In[1]&In[0]|
		~In[3]&In[2]&~In[1]&~In[0]|
		In[3]&In[2]&~In[1]&In[0]|
		In[3]&~In[2]&In[1]&In[0]);

assign HEXout[1] = (~In[3]&In[2]&~In[1]&In[0]|
		In[3]&In[2]&~In[0]|
		In[3]&In[1]&In[0]|
		In[2]&In[1]&~In[0]);

assign HEXout[2] = (~In[3]&~In[2]&In[1]&~In[0]|
		In[3]&In[2]&In[1]|
		In[3]&In[2]&~In[0]);

assign HEXout[3] = (~In[3]&In[2]&~In[1]&~In[0]|
		In[3]&~In[2]&In[1]&~In[0]|
		In[2]&In[1]&In[0]|
		~In[2]&~In[1]&In[0]);

assign HEXout[4] = (~In[3]&In[0]|
		~In[3]&In[2]&~In[1]|
		In[3]&In[2]&~In[1]&In[0]|
		~In[2]&~In[1]&In[0]);

assign HEXout[5] = (In[3]&In[2]&~In[1]&In[0]|
		~In[3]&~In[2]&In[0]|
		~In[3]&~In[2]&In[1]|
		~In[3]&In[1]&In[0]);

assign HEXout[6] = (~In[3]&~In[2]&~In[1]|
		~In[3]&In[2]&In[1]&In[0]|
		In[3]&In[2]&~In[1]&~In[0]);

endmodule
