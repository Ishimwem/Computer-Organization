module part3
	(
		input clock, resetn, ld, start,
		input [2:0] colour,
		output [7:0] X,
		output [7:0] Y,
		output [2:0] C
		);
	
	wire ldc, wren, enable, fenable, cenable,dirX, dirY;
	wire [28:0] dout;
	wire [3:0] fout;
	wire [7:0] xout, yout;
	
	
	control c0(.ldc(ldc), .enable(enable), .wren(wren), .start(start),
					.ld(ld), .clock(clock), .resetn(resetn));
	
	delay_counter dc(.q(dout), .clock(clock), .resetn(resetn), .enable(enable));
	assign fenable = (dout == 29'b0) ? 1 : 0;
	
	frame_counter f1(.q(fout), .resetn(resetn), .clock(clock), .enable(fenable));
	assign cenable = (fout == 4'b1111) ? 1 : 0;
	
	Counter_X cx1(.q(xout), .resetn(resetn), .clock(clock), .enable(cenable), .dirX(dirX));
	Counter_Y cy1(.q(yout), .resetn(resetn), .clock(clock), .enable(cenable), .dirY(dirY));
	
	horizontal h1(.direction(dirX), .x(xout), .clock(clock), .resetn(resetn));
	vertical v1(.direction(dirY), .y(yout), .clock(clock), .resetn(resetn));
	
	datapath da(.cout(C), .xout(X), .yout(Y), .clock(clock), .resetn(resetn), 
				.enable(enable), .ldc(ldc), .colour(colour), .x(xout), .y(yout));
	
endmodule

//delays by 1/60th second
module delay_counter(q, clock, resetn, enable);
	
	input clock, resetn, enable;
	output reg [28:0] q;

	always @(posedge clock)
	begin
		if (resetn == 1'b0)
			q <= 29'b10001111000011010001011111111;
		else if (enable == 1'b1)
			begin
				if (q == 0)
					q <= 29'b10001111000011010001011111111;
				else
				q <= q - 1'b1 ;
				
			end
	end


endmodule

//counts 15 frames
module frame_counter(q, resetn, clock, enable);

	input clock, resetn, enable;
	output reg [3:0] q;

	always @(posedge clock)
	begin
		if(!resetn)
			q <= 4'b0000;
		else if(enable)
		begin
			if(q == 4'b1111)
				q <= 4'b0000;
			else
				q <= q + 1'b1;
		end
	end

endmodule

// counter for x: keeps track of the current position of x
module Counter_X(q, resetn, clock, enable, dirX);

	input clock, resetn, enable, dirX;
	output reg [7:0] q;

	always @(posedge clock)
	begin
		if(!resetn)
			q <= 8'b0;
		else if(enable)
		begin
			if (dirX == 1'b0)
				q <= q - 1'b1;
			else
				q <= q + 1'b1;
		end
	end

endmodule

//counter for y: keeps track of the current position of y
module Counter_Y(q, resetn, clock, enable, dirY);

	input clock, resetn, enable, dirY;
	output reg [7:0] q;

	always @(posedge clock)
	begin
		if(!resetn)
			q <= 8'b00111100;
		else if(enable)
		begin
			if (dirY == 1'b0)
				q <= q - 1'b1;
			else
				q <= q + 1'b1;
		end
	end

endmodule

//keeps track of the horizontal direction of the box (left or right)
module horizontal(direction, x, clock, resetn);

	input [7:0]x;
	input clock, resetn;
	output reg direction; //1 is for right and 0 for left
	
	always @(posedge clock)
	begin
		if(!resetn)
			direction <= 1'b1;
		else if (direction)
		begin
			if (x + 1'b1 == 8'b10100000)
				direction = 1'b0;		
		end
		else if (!direction)
		begin
			if (x - 1'b1 == 8'b00000000)
				direction = 1'b1;		
		end
			
	end

endmodule

//keeps track of the vertical direction of the box (up or down)
module vertical(direction, y, clock, resetn);

	input [7:0]y;
	input clock, resetn;
	output reg direction; //1 is for up and 0 for down
	
	always @(posedge clock)
	begin
		if(!resetn)
			direction <= 1'b1;
		else if (direction)
		begin
			if (y + 1'b1 == 8'b01111000)
				direction = 1'b0;		
		end
		else if (!direction)
		begin
			if (y - 1'b1 == 8'b00000000)
				direction = 1'b1;		
		end
			
	end

endmodule

module datapath(cout, xout, yout, clock, resetn, enable,ldc, colour, x, y);
	input clock, resetn, enable,ldc;
	input [2:0] colour;
	//input [6:0] coord;
	input [7:0] x, y;
	output [2:0] cout;
	output [7:0] xout, yout;
	
   //reg [3:0] xcount, ycount;
	reg [7:0] X, Y;
	reg [2:0] C;
	wire [3:0] count;
	
	always @(posedge clock)
	begin
		if(!resetn)
		begin
			X <= 8'b0;
			Y <= 8'b01111000;
			C <= 3'b000;
		end
		else 
		begin
			if(ldc)
				C <= colour;
			X <= x;
			Y <= y;

		end
	end
	
	

	counter c0(count, resetn, clock, enable);

	
	assign xout = X + count[3:2];
	assign yout = Y + count[1:0];
	assign cout = C;

endmodule

//counts up to 4 pixels in both x and y direction to draw a 4x4 box
module counter(xcount, resetn, clock, enable);

	input clock, resetn, enable;
	output reg [3:0] xcount;

	always @(posedge clock)
	begin
		if(!resetn)
			xcount <= 4'b0000;
		else if(enable)
		begin
			if(xcount == 4'b1111)
				xcount <= 4'b0000;
			else
				xcount <= xcount + 1'b1;
		end
	end

endmodule

//control
module control(ldc, enable, wren, start, ld, clock, resetn); //KEY[1] KEY[3]
	input clock, resetn, start, ld;
	output reg ldc, enable, wren;
	
	reg [1:0] current_state, next_state;
	localparam 	load_c = 2'd0, load_c_wait = 2'd1, draw = 2'd2, move = 2'd3;
				
	reg [3:0] xcount;
	
				
	always @(*)
	begin
		case(current_state)
			load_c: next_state = ld ? load_c_wait : load_c; 
			load_c_wait : next_state = start ? draw : load_c_wait;
			draw : next_state = start ? move: draw;
			move: next_state = load_c;
			default:     next_state = load_c;
		endcase
	end
	
	always @(*) 
	begin
		
		ldc = 1'b0;
		enable = 1'b0;
		wren = 1'b0;

		
		case (current_state)
			load_c: begin
				ldc = 1'b1;
			end
			draw: begin
				wren = 1'b1;
			end
			move: begin
				wren = 1'b1;
				enable = 1'b1;
			end
			
		endcase
	end
	
	always @(posedge clock) 
	begin
		if (!resetn)
			current_state <= load_c;
		else
			current_state <= next_state;
	end
endmodule


