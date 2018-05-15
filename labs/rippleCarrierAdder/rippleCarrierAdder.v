module rippleCarrierAdder(LEDR, SW);

	input [9:0]SW;
	output [9:0] LEDR;
	
	wire carry1;
	wire carry2;
	wire carry3;
	
	full_adder f1(.S(LEDR[3]), .cout(carry1), .A(SW[7]), .B(SW[3]), .cin(SW[8]));
	full_adder f2(.S(LEDR[2]), .cout(carry2), .A(SW[6]), .B(SW[2]), .cin(carry1));
	full_adder f3(.S(LEDR[1]), .cout(carry3), .A(SW[5]), .B(SW[1]), .cin(carry2));
	full_adder f4(.S(LEDR[0]), .cout(LEDR[4]), .A(SW[4]), .B(SW[0]), .cin(carry3));

endmodule

module full_adder(S,cout,A,B,cin);
	output S, cout;
	input A, B, cin;
	assign S = A^B^cin;
	assign cout = (A&B)|(cin&(A^B));
endmodule