module alu2(LEDR, HEX0, HEX4, HEX5, SW, KEY);
	input [9:0] SW;
	input [0:0] KEY;
	
	output [9:0] LEDR;
	output [6:0] HEX0;
	//output [6:0] HEX1;
	//output [6:0] HEX2;
	//output [6:0] HEX3;
	output [6:0] HEX4;
	output [6:0] HEX5;
	
	wire [7:0] aluoutput;
	
	//aluoperations alu1(aluoutput[7:0], SW[3:0], aluoutput[3:0], SW[7:5], SW[9], KEY[0]);
	aluoperations alu1(aluoutput[7:0], SW[3:0], SW[7:5], SW[9], KEY[0]);
	assign LEDR[7:0] = aluoutput[7:0];
	
	wire[3:0] binary_zero;
	assign binary_zero[3:0] = 4'b0;
	
	seven_seg_decoder H0(HEX0[6:0], SW[3:0]); //A
	//seven_seg_decoder H1(HEX1[6:0], binary_zero); //0
	//seven_seg_decoder H2(HEX2[6:0], SW[7:4]); //A
	//seven_seg_decoder H3(HEX3[6:0], binary_zero); //0
	seven_seg_decoder H4(HEX4[6:0], aluoutput[3:0]);
	seven_seg_decoder H5(HEX5[6:0], aluoutput[7:4]);
	
endmodule

//module aluoperations(ALUout, A, B, functions, reset_n, clock);
module aluoperations(ALUout, A, functions, reset_n, clock);	
	input [3:0] A;
	//input [3:0] B;
	input [2:0] functions;
	input reset_n;
	input clock;
	output [7:0] ALUout;
	
	reg [7:0] q;
	reg [3:0] B;
	reg [7:0] outp;
	
	always @(posedge clock) // Triggered every time clock rises
	begin
		if (reset_n == 1'b0) // When reset_n is 0
									// Note this is tested on every rising clock edge
			begin
				q[7:0] <= 8'b0; 				// Set q to 0 .
				B[3:0] <= q[3:0];
			end
		else 
			begin// When reset_n is not 0
				q[7:0] <= outp[7:0];	 	// Store the value of d in q
				B[3:0] <= q[3:0];
			end
	end
	
	//wire [3:0] B;
	
	wire [3:0] a1, a2;

	four_bit_ripple_adder fbra1(a1, {A, 4'b0001});
	four_bit_ripple_adder fbra2(a2, {A, B});

	mux8to1 m(outp[7:0], A, B, {{4{1'b0}}, a1}, {{4{1'b0}}, a2}, functions[2:0]);
	assign ALUout[7:0] = outp[7:0];
	
endmodule

module mux8to1(Output, A, B, i0, i1, MuxSelect);

	input [7:0] i0, i1;
	input [3:0] A, B;
	input [2:0] MuxSelect;
	output [7:0] Output;
	
	reg [7:0] Out;
	
	always @(*)
	begin
		case(MuxSelect[2:0]) 
			3'b000 : Out = i0; 
			3'b001 : Out = i1;
			3'b010 : Out = ({{4{1'b0}}, (A + B)});
			3'b011 : Out = {{(A[3:0]^B[3:0]), (A[3:0]|B[3:0])}};
			3'b100 : Out = {{7{1'b0}}, |{A,B}}; 
			3'b101 : Out = {{4{1'b0}}, B << A};
			3'b110 : Out = {{4{1'b0}}, B >> A};
			3'b111 : Out = {{4'b0}, A*B};
			default : Out = 8'b0;
		endcase
	end
	
	assign Output [7:0] = Out;
	
endmodule

module four_bit_ripple_adder(Output, Input);
	input [7:0] Input;
	output[3:0] Output;
    
	wire c1, c2, c3, c4;
	
	full_adder FA1(Output[0], c1, Input[4], Input[0], 1'b0);
   full_adder FA2(Output[1], c2, Input[5], Input[1], c1);
   full_adder FA3(Output[2], c3, Input[6], Input[2], c2);
   full_adder FA4(Output[3], c4, Input[7], Input[3], c3);

endmodule

module full_adder(sum, cout, a, b, cin);
	output sum, cout;
	input a, b, cin;
	
	assign sum = a^b^cin;
	assign cout = (a&b)|(cin&(a^b));

endmodule


//Seven segment decoder for BCD inputs from 0 to F

module seven_seg_decoder(HEXO, S);
	input [3:0] S;
	output [6:0] HEXO;
	
	//assigning the seven segments
	assign HEXO[0]=(~S[3]&~S[2]&~S[1]&S[0])|(~S[3]&S[2]&~S[1]&~S[0])|(S[3]&S[2]&~S[1]&S[0])|(S[3]&~S[2]&S[1]&S[0]);
	assign HEXO[1]=(S[3]&S[2]&~S[0])|(~S[3]&S[2]&~S[1]&S[0])|(S[3]&S[1]&S[0])|(S[2]&S[1]&~S[0]);
	assign HEXO[2]=(~S[3]&~S[2]&S[1]&~S[0])|(S[3]&S[2]&S[1])|(S[3]&S[2]&~S[0]);
	assign HEXO[3]=(S[2]&S[1]&S[0])|(S[3]&~S[2]&S[1]&~S[0])|(~S[3]&S[2]&~S[1]&~S[0])|(~S[3]&~S[2]&~S[1]&S[0]);
	assign HEXO[4]=(~S[3]&S[2]&~S[1])|(~S[3]&S[1]&S[0])|(~S[2]&~S[1]&S[0]);
	assign HEXO[5]=(S[3]&S[2]&~S[1]&S[0])|(~S[3]&~S[2]&S[0])|(~S[3]&~S[2]&S[1])|(~S[3]&S[1]&S[0]);
	assign HEXO[6]=(~S[3]&~S[2]&~S[1])|(~S[3]&S[2]&S[1]&S[0])|(S[3]&S[2]&~S[1]&~S[0]);
	

endmodule