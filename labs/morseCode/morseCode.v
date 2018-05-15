
module morseCode(mainout, letter, reset_n, clock, display);

	input [2:0] letter;
	input reset_n, clock, display;
	output mainout;	
	
	wire en;
	reg par_load, enable;
	wire [24:0] rd1;
	wire [13:0] w1;
	
	always @(negedge display, negedge reset_n)
	begin
	if (reset_n == 1'b0)
		begin
		par_load <= 1'b1;
		enable <= 1'b0;
		end
	else if (display == 1'b0)
		begin
		par_load <= 1'b0;
		enable <= 1'b1;
		end

	end
	
	LUT l1(.lutout(w1[13:0]), .letter(letter[2:0]));
	
	RateDivider r1(.q( rd1[24:0]), .d(25'd24999999), .clock(clock),
						.reset_n(reset_n), .enable(enable));
						
	assign en = (rd1 == 0) ? 1 : 0;
	
	register rg1(.regout(mainOut),.clock(clock), .d(w1[13:0]), .reset_n(reset_n),
						.enable(en), .par_load(par_load));


endmodule

module LUT(lutout, letter);

	input [2:0]letter;
	output reg [13:0] lutout;
	
	always @(*)
	begin
		case(letter [2:0]) 
			3'b000 : lutout = {5'b10101, {9{1'b0}}}; 
			3'b001 : lutout = {3'b111, {11{1'b0}}}; 
			3'b010 : lutout = {7'b1010111, {7{1'b0}}};
			3'b011 : lutout = {9'b101010111, {5{1'b0}}};
			3'b100 : lutout = {9'b101110111, {5{1'b0}}};
			3'b101 : lutout = {11'b11101010111, {3{1'b0}}};
			3'b110 : lutout = {13'b1110101110111, 1'b0};
			3'b111 : lutout = {11'b11101110101, {3{1'b0}}};
			
			default : lutout = 3'bx;
		endcase
	end

endmodule

// Rate divider
module RateDivider(q, d, clock, reset_n, enable);

input [24:0] d;
input clock, reset_n, enable;
output reg [24:0] q;

always @(posedge clock, negedge reset_n)
begin
if (reset_n == 1'b0)
	q <= d;
else if (enable == 1'b1)
	begin
		if (q == 0)
			q <= d;
		else
		q <= q - 1'b1 ;
		
	end

end

endmodule

// shift register
module register( regout,clock, d, reset_n, enable, par_load);

	input clock;
	input [13:0]d;
	input reset_n, enable, par_load;
	output reg regout;
	reg [13:0] q;

	always @(posedge clock, negedge reset_n)
	begin
		if (reset_n == 1'b0)
			begin
			q <= {14{1'b0}};
			regout <= 1'b0;
			end
		else if (par_load == 1'b1)
			begin
			q <= d;
			regout <= 1'b0;
			end
		else if (enable == 1'b1)
			begin
			regout <= q[13];
			q <= q << 1'b1;
			end
			 
	end
	
endmodule
