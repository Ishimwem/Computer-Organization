
module aluRegister(LEDR, HEX0, HEX4, HEX5, SW, KEY);
	
	input [9:0] SW;
	input [2:0] KEY;
	output [9:0] LEDR;
	output [6:0] HEX0;
	output [6:0] HEX4;
	output [6:0] HEX5;

	sevenSegmentsDecoder h1(.HEXout(HEX0[6:0]), .In(SW[3:0]));

	wire [7:0]ans;

	aluRegMain a1(.regOut(ans[7:0]), .clock(KEY[0]), .reset_n(SW[9]), .A(SW[3:0]), .func(SW[7:5]));

	assign LEDR[7:0] = ans[7:0];
	
	sevenSegmentsDecoder h3(.HEXout(HEX4[6:0]), .In(ans[3:0]));
	sevenSegmentsDecoder h4(.HEXout(HEX5[6:0]), .In(ans[7:4]));

	
endmodule

//intermadiate module
module aluRegMain(regOut, clock, reset_n, A, func);

	input clock, reset_n;
	wire [7:0]d;
	input [2:0]func;
	input [3:0]A;
	output [7:0]regOut;

	wire [3:0]w1, w2;
	
	register r1(.q(regOut[7:0]), .clock(clock), .d(d[7:0]), .reset_n(reset_n));

	rippleCarrierAdder addOne(.outAdder(w1), .operands({A,4'b0001}));
	rippleCarrierAdder AaddB(.outAdder(w2), .operands({A,regOut[3:0]}));
	
	mux7 m1(.Out(d[7:0]), .i1({{4{1'b0}},w1}), .i2({{4{1'b0}},w2}), .i3({{4{1'b0}}, A + regOut[3:0]}),
		 .i4({A|regOut[3:0], A^regOut[3:0]}), .i5({{7{1'b0}},|{A,regOut[3:0]}}),.i6({{4{1'b0}}, regOut[3:0]<<A}),
		 .i7({{4{1'b0}}, regOut[3:0]>>A}),.i8({{4{1'b0}}, A*regOut[3:0]}), .MuxSelect(func[2:0]));

endmodule

//Register code
module register( q,clock, d, reset_n);

	input clock;
	input [7:0]d;
	input reset_n;
	output reg[7:0]q;

	always @(posedge clock)
	begin
		if (reset_n == 1'b0)
			q[7:0] <= 8'b00000000;
		else
			q[7:0] <= d[7:0]; 
	end
	
endmodule

//a rippler carried adder
module rippleCarrierAdder(outAdder,operands);

	input [7:0] operands;
	output [3:0] outAdder;
	
	wire carry1;
	wire carry2;
	wire carry3;
	wire carry4;
	
	full_adder f1(.S(outAdder[3]), .cout(carry1), .A(operands[7]), .B(operands[3]), .cin(1'b0));
	full_adder f2(.S(outAdder[2]), .cout(carry2), .A(operands[6]), .B(operands[2]), .cin(carry1));
	full_adder f3(.S(outAdder[1]), .cout(carry3), .A(operands[5]), .B(operands[1]), .cin(carry2));
	full_adder f4(.S(outAdder[0]), .cout(carry4), .A(operands[4]), .B(operands[0]), .cin(carry3));

endmodule

//full adder
module full_adder(S,cout,A,B,cin);
	output S, cout;
	input A, B, cin;
	assign S = A^B^cin;
	assign cout = (A&B)|(cin&(A^B));
endmodule

// 7 to 1 multiplexer
module mux7(Out, i1, i2, i3, i4, i5, i6, i7,i8, MuxSelect);

	input [7:0] i1, i2, i3, i4, i5, i6, i7, i8;
	input [2:0] MuxSelect;
	output reg [7:0]Out;

	always @(*)
	begin
		case(MuxSelect [2:0]) 
			3'b000 : Out[7:0] = i1; 
			3'b001 : Out[7:0] = i2; 
			3'b010 : Out[7:0] = i3;
			3'b011 : Out[7:0] = i4;
			3'b100 : Out[7:0] = i5;
			3'b101 : Out[7:0] = i6;
			3'b110 : Out[7:0] = i7;
			3'b111 : Out[7:0] = i8;
			
			default : Out = 3'bx;
		endcase
	end
	
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