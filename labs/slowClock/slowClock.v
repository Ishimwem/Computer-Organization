

module slowClock(mainout, load, clock, reset_n, par_load, enable, freq);

	input clock, enable, par_load, reset_n;
	input [1:0] freq;
	input [3:0] load;
	output [3:0] mainout;
	
	wire [27:0] rd1, rd2, rd3;
	reg en;
	
	RateDivider r1(.q( rd1), .d({2'b00, 26'd49999999}), .clock(clock),
						.reset_n(reset_n), .enable(enable));
						
	RateDivider r2(.q( rd2), .d({1'b0, 27'd99999999}), .clock(clock),
						.reset_n(reset_n), .enable(enable));
	
	RateDivider r3(.q( rd3), .d({28'd499999999}), .clock(clock),
						.reset_n(reset_n), .enable(enable));
	
	always @(*)
		begin
			case(freq)
				2'b00: en = enable;
				2'b01: en = (rd1 == 0) ? 1 : 0;
				2'b10: en = (rd2 == 0) ? 1 : 0;
				2'b11: en = (rd3 == 0) ? 1 : 0;
			endcase
		end
		
	DisplayCounter d1(.q(mainout), .d(load), .clock(clock), .reset_n(reset_n),
							.par_load(par_load), .enable(en));

endmodule

//display counter
module DisplayCounter(q, d, clock, reset_n, par_load, enable);

input [3:0] d;
input clock, reset_n, par_load, enable;
output reg [3:0] q;

always @(posedge clock)
begin
if (reset_n == 1'b0)
	q <= 0;
else if (par_load == 1'b1)
	q <= d;
else if (enable == 1'b1)
	q <= q + 1'b1 ;

end

endmodule

// Rate divider
module RateDivider(q, d, clock, reset_n, enable);

input [27:0] d;
input clock, reset_n, enable;
output reg [27:0] q;

always @(posedge clock)
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