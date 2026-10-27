


module	space_and_time_shifter	(
	
					input		logic	clk,
					input		logic	resetN,
					input 	logic signed	[10:0] pixelX,				// current VGA pixel -- global value (can be ignored)
					input 	logic signed	[10:0] pixelY,
									
					output 	logic				[10:0] offset_x,			// offset inside bracket from top left position 
					output 	logic				[10:0] offset_y,
					output 	logic 		 			 placement_flag	// decide when we need to draw something in the next module
);


parameter unsigned DISPLAY_AREA_Y = 416;
parameter unsigned DISPLAY_AREA_X = 608;

localparam logic 	signed	[10:0] topLeftX = 16;  		// position on the screen 	-- location of top left
localparam logic	signed	[10:0] topLeftY = 16;    	// can be negative , if the object is partliy outside 	-- location of top left

logic next_placement_flag;


logic [10:0] raw_offset_x;
logic [10:0] raw_offset_y;
logic [5:0]  delayed_msb_x;
logic [5:0]  delayed_msb_y;

assign raw_offset_x = (pixelX - topLeftX);	 //calculate relative offsets from top left corner allways a positive number 
assign raw_offset_y = (pixelY - topLeftY);

assign offset_x	= {delayed_msb_x, raw_offset_x[4:0]};
assign offset_y	= {delayed_msb_y, raw_offset_y[4:0]};

assign next_placement_flag = ( 	(pixelX >= topLeftX) && (pixelX < topLeftX + DISPLAY_AREA_X) &&
											(pixelY >= topLeftY) && (pixelY < topLeftY + DISPLAY_AREA_Y) 		);

									
									
									
									
always_ff@(posedge clk or negedge resetN) begin
	
	if (!resetN) begin

		placement_flag <= 0;
		delayed_msb_x  <= 6'b0;
		delayed_msb_y  <= 6'b0;
		
	end
	
	else begin
	
		// defaults
		placement_flag <= 0;
		
		
		// one clock cycle delay
		placement_flag <= next_placement_flag;
		delayed_msb_x  <= raw_offset_x[10:5];
		delayed_msb_y  <= raw_offset_y[10:5];

		
	end
	
 end									
									
endmodule