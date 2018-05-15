// a 7 to 1 multiplexer

module mux7to1(LEDR, SW);
	
	input [9:0] SW;
	output [9:0] LEDR;
	
	mux7 m0(.OutMux(LEDR[0]), .Input(SW[6:0]), .MuxSelect(SW[9:7]));

endmodule


module mux7(OutMux, Input, MuxSelect);

	input [6:0] Input;
	input [2:0] MuxSelect;
	output OutMux;
	reg Out;
	
	always @(*)
	begin
		case(MuxSelect [2:0]) 
			3'b000 : Out = Input[0]; 
			3'b001 : Out = Input[1]; 
			3'b010 : Out = Input[2];
			3'b011 : Out = Input[3];
			3'b100 : Out = Input[4];
			3'b101 : Out = Input[5];
			3'b110 : Out = Input[6];
			
			default : Out = 3'bx;
		endcase
	end

	assign OutMux = Out;
	
endmodule