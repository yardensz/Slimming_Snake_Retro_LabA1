module TripleDigitNumber	(	

					input		logic				clk,
					input		logic				resetN,
					
					input 	logic signed	[10:0] pixelX,				// current VGA pixel
					input 	logic signed	[10:0] pixelY,
					
					input 	logic	[19:0] 	number, 				// digit to display
					
					output	logic				drawingRequest, 	//output that the pixel should be dispalyed 
					output	logic	[7:0]		RGBout
);

		parameter 	logic	[10:0] 	top_left_x = 0; // offset from top left position 
		parameter 	logic	[10:0] 	top_left_y = 0;
		parameter int number_of_zeros_to_keep = 3;
		parameter logic [7:0] color = 8'hE0;
		
localparam int digits = 5; //how many digits?
localparam logic [10:0] digit_width = 11'd16;
localparam logic [10:0] digit_hight = 11'd32;
localparam logic [10:0] digit_SPACING = 11'd4;

logic [4:0] insideRect; // to know in which digit (if any) the VGA "scanner beam" is curuuntly in.

logic [3:0] currunt_digit;  // will contain the digit the vga is looking at
logic [10:0] currunt_offsetX; 

logic is_y_in_range;

//logic raw_drawingRequest;

logic	[7:0]		raw_RGBout;
NumbersBitMap #(.digit_color(color)) //only 1 instance of digit_display is needed to access the mif data
	digit_display( 
   .clk(clk),
	.resetN(resetN),
	.offsetX(currunt_offsetX),
	.offsetY(pixelY - top_left_y),
	.InsideRectangle(delayed_insideRect),
	.digit(currunt_digit),
	.drawingRequest(drawingRequest),
	.RGBout(RGBout)
		);
		
	
		
	always_comb begin
		
		is_y_in_range = (pixelY  >= top_left_y ) &&  (pixelY < top_left_y + digit_hight);
		
		for (int i = 0; i < digits; i++)
			begin
				insideRect[i] = (pixelX  >= top_left_x + (digits - i -1) * (digit_width + digit_SPACING))				//left limit
								&&  (pixelX < top_left_x + (digits - i -1) * (digit_width + digit_SPACING) + digit_width)//right limit
								&&	is_y_in_range																									//y limit ,
								&& ((number >> (i * 4) != 0) || i < number_of_zeros_to_keep );	//	if leading zero do not draw box, unless you wanna keep zeros
			end 
			
		//determining what is the curuunt digit and offset;
		//defaults
		//drawingRequest = raw_drawingRequest;
		currunt_digit = 0;
		currunt_offsetX =0;
		
		
		if (insideRect[4]) begin
			currunt_digit = number[19:16];
			currunt_offsetX = pixelX - top_left_x;
		
		end else if (insideRect[3]) begin
			currunt_digit = number[15:12];
			currunt_offsetX = pixelX - (top_left_x +  1 * (digit_width + digit_SPACING));
			
		end else if (insideRect[2]) begin
		
			currunt_digit = number[11:8];
			currunt_offsetX = pixelX - (top_left_x +  2 * (digit_width + digit_SPACING));
			
			
		end else if (insideRect[1]) begin
		
			currunt_digit = number[7:4];
			currunt_offsetX = pixelX - (top_left_x +  3 * (digit_width + digit_SPACING));
			
		end else if (insideRect[0]) begin
		
			currunt_digit = number[3:0];
			currunt_offsetX = pixelX - (top_left_x + 4 * (digit_width + digit_SPACING));
			
		end

		
		
		
	end// always_comb
	
	//adding adelay for proper VGA timing :(
	 
	logic delayed_insideRect;
	
	always_ff @(posedge clk or negedge resetN) begin
	
		if(!resetN)
			delayed_insideRect <= 0;
		else
			delayed_insideRect <= |insideRect; // true if inside any of the rectangles
	end //always_ff
	
		
	endmodule