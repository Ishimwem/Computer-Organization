// Part 2 skeleton

module part2
	(
		CLOCK_50,						//	On Board 50 MHz
		// Your inputs and outputs here
        KEY,
        SW,
		// The ports below are for the VGA output.  Do not change.
		VGA_CLK,   						//	VGA Clock
		VGA_HS,							//	VGA H_SYNC
		VGA_VS,							//	VGA V_SYNC
		VGA_BLANK_N,						//	VGA BLANK
		VGA_SYNC_N,						//	VGA SYNC
		VGA_R,   						//	VGA Red[9:0]
		VGA_G,	 						//	VGA Green[9:0]
		VGA_B   						//	VGA Blue[9:0]
	);

	input			CLOCK_50;				//	50 MHz
	input   [9:0]   SW;
	input   [3:0]   KEY;

	// Declare your inputs and outputs here
	// Do not change the following outputs
	output			VGA_CLK;   				//	VGA Clock
	output			VGA_HS;					//	VGA H_SYNC
	output			VGA_VS;					//	VGA V_SYNC
	output			VGA_BLANK_N;				//	VGA BLANK
	output			VGA_SYNC_N;				//	VGA SYNC
	output	[9:0]	VGA_R;   				//	VGA Red[9:0]
	output	[9:0]	VGA_G;	 				//	VGA Green[9:0]
	output	[9:0]	VGA_B;   				//	VGA Blue[9:0]
	
	wire resetn;
	assign resetn = KEY[0];
	
	// Create the colour, x, y and writeEn wires that are inputs to the controller.
	wire [2:0] colour;
	wire [7:0] x;
	wire [6:0] y;
	wire writeEn, clock;
	wire ld_x, ld_y, ld_c, enable;
	wire [27:0]rout;
	// Create an Instance of a VGA controller - there can be only one!
	// Define the number of colours as well as the initial background
	// image file (.MIF) for the controller.
	vga_adapter VGA(
			.resetn(resetn),
			.clock(CLOCK_50),
			.colour(colour),
			.x(x),
			.y(y),
			.plot(writeEn),
			/* Signals for the DAC to drive the monitor. */
			.VGA_R(VGA_R),
			.VGA_G(VGA_G),
			.VGA_B(VGA_B),
			.VGA_HS(VGA_HS),
			.VGA_VS(VGA_VS),
			.VGA_BLANK(VGA_BLANK_N),
			.VGA_SYNC(VGA_SYNC_N),
			.VGA_CLK(VGA_CLK));
		defparam VGA.RESOLUTION = "160x120";
		defparam VGA.MONOCHROME = "FALSE";
		defparam VGA.BITS_PER_COLOUR_CHANNEL = 1;
		defparam VGA.BACKGROUND_IMAGE = "black.mif";
			
	// Put your code here. Your code should produce signals x,y,colour and writeEn/plot
	// for the VGA controller, in addition to any other functionality your design may require.
    
    // Instansiate datapath
	// datapath d0(...);

    // Instansiate FSM control
    // control c0(...);
	 RateDivider r0(.q(rout), .d({2'b00, 26'd49999999}), .clock(CLOCK_50), .reset_n(resetn), .enable(enable));
	 assign clock = (rout == 0) ? 1 : 0;
	 
	 control c0(
    .clk(clock),
    .resetn(resetn),
    .go(KEY[3]),
	 .ld_x(ld_x),
	 .ld_y(ld_x),
	 .ld_c(ld_c),
	 .enable(enable), 
	 .plot(writeEn)
    );
	 
	 data_path d0(
    .clk(clock),
    .resetn(resetn),
    .data_in(SW[6:0]),
	 .colour(SW[9:7]),
    .ld_x(ld_x),
	 .ld_y(ld_x),
	 .ld_c(ld_c),
	 .enable(enable),
    .X(x),
	 .Y(y),
	 .C(colour)
    );
    
	 
endmodule

module intermediate(colour, x, y, writeEn, data_in, clk, resetn, go, c);

	output [2:0] colour;
	output [7:0] x;
	output [6:0] y;
	output writeEn;
	input [6:0] data_in;
	input clk, resetn, go;
	input [2:0] c;
	//wire clock;
	wire ld_x, ld_y, ld_c, enable;
	wire [27:0]rout;
	
	
	 
	 control c0(
    .clk(clk),
    .resetn(resetn),
    .go(go),
	 .ld_x(ld_x),
	 .ld_y(ld_x),
	 .ld_c(ld_c),
	 .enable(enable), 
	 .plot(writeEn)
    );
	 
	 data_path d0(
    .clk(clk),
    .resetn(resetn),
    .data_in(data_in[6:0]),
	 .colour(c[2:0]),
    .ld_x(ld_x),
	 .ld_y(ld_x),
	 .ld_c(ld_c),
	 .enable(enable),
    .X(x),
	 .Y(y),
	 .C(colour)
    );

endmodule

module control(
    input clk,
    input resetn,
    input go,

    output reg  ld_x, ld_y, ld_c, enable, plot
    //output clock
    );

    reg [3:0] current_state, next_state;
	 //wire clock;
	 wire [27:0] rout;
    
    localparam  S_LOAD_X        = 4'd0,
                S_LOAD_X_WAIT   = 4'd1,
                S_LOAD_Y        = 4'd2,
                S_LOAD_Y_WAIT   = 4'd3,
                S_CYCLE_0       = 4'd4;
    
    // Next state logic aka our state table
    always@(*)
    begin: state_table 
            case (current_state)
                S_LOAD_X: next_state = go ? S_LOAD_X_WAIT : S_LOAD_X; // Loop in current state until value is input
                S_LOAD_X_WAIT: next_state = go ? S_LOAD_X_WAIT : S_LOAD_Y; // Loop in current state until go signal goes low
                S_LOAD_Y: next_state = go ? S_LOAD_Y_WAIT : S_LOAD_Y; // Loop in current state until value is input
                S_LOAD_Y_WAIT: next_state = go ? S_LOAD_Y_WAIT : S_CYCLE_0; // Loop in current state until go signal goes low
                
                S_CYCLE_0: next_state = S_LOAD_X;

					 default:     next_state = S_LOAD_X;
        endcase
    end // state_table
   

    // Output logic aka all of our datapath control signals
    always @(*)
    begin: enable_signals
        // By default make all our signals 0
     
        ld_x = 1'b0;
        ld_y = 1'b0;
        ld_c = 1'b0;
		  enable = 1'b0;
		  plot = 1'b0;

        case (current_state)
            S_LOAD_X: begin
                ld_x = 1'b1;
                end
            S_LOAD_Y: begin
                ld_y = 1'b1;
                end
            S_CYCLE_0: begin
                ld_c = 1'b1;
					 enable = 1'b1;
					 plot = 1'b1;
            end
				
        // default:    // don't need default since we already made sure all of our outputs were assigned a value at the start of the always block
        endcase
    end // enable_signals
   
    // current_state registers
	 
	 //RateDivider r0(.q(rout), .d({2'b00, 26'd49999999}), .clock(clk), .reset_n(resetn), .enable(enable));
	 //assign clock = (rout == 0) ? 1 : 0;
	 
    always@(posedge clk)
    begin: state_FFs
        if(!resetn)
            current_state <= S_LOAD_X;
        else
            current_state <= next_state;
    end // state_FFS
endmodule

module data_path(
    input clk,
    input resetn,
    input [6:0] data_in,
	 input [2:0] colour,
    input ld_x, ld_y,ld_c, enable,
    output [7:0] X,
	 output [6:0] Y,
	 output [2:0] C
    );
    
    // input registers
    reg [7:0] x;
	 reg [6:0] y;
	 reg [2:0] c;
	 wire yen;
	wire [1:0]cx, cy, ro;
    
    // Registers a, b, c, x with respective input logic
    always @ (posedge clk) begin
        if (!resetn) begin
            x <= 8'd0; 
            y <= 7'd0; 
            c <= 2'd0; 
        end
        else begin
            if (ld_x)
                x <= {1'b0, data_in};
            if (ld_y)
                y <= data_in;
            if (ld_c)
                c <= colour;
        end
    end
	 
	 DisplayCounter countx(.q(cx), .clock(clk), .reset_n(resetn), .enable(enable));
	 RateCounter r1(.q(ro), .clock(clk), .reset_n(resetn), .enable(enable));
	 assign yen = (ro == 0) ? 1 : 0;
	 DisplayCounter county(.q(cy), .clock(clk), .reset_n(resetn), .enable(yen));
	 
	 assign X = x + cx;
	 assign Y = y + cy;
	 assign C = c;
	 
endmodule

//counter from 0 to 4
module DisplayCounter(q,clock, reset_n, enable);

	input clock, reset_n, enable;
	output reg [1:0] q;

	always @(posedge clock)
	begin
		if (reset_n == 1'b0)
			q <= 2'b00;
		
		else if (enable == 1'b1)
		begin
			if (q == 2'b11)
				q<= 2'b00;
			else
				q <= q + 1'b1 ;
		end

	end
endmodule

//rateCounter
module RateCounter(q,clock, reset_n, enable);

	input clock, reset_n, enable;
	output reg [1:0] q;

	always @(posedge clock)
	begin
		if (reset_n == 1'b0)
			q <= 2'b11;
		
		else if (enable == 1'b1)
		begin
			if (q == 2'b00)
				q<= 2'b11;
			else
				q <= q - 1'b1 ;
		end

	end
endmodule

//rateDivider
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

