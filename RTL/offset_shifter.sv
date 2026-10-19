


module	offset_shifter	(	
					input		logic	clk,
					input		logic	resetN,
					input 	logic signed	[10:0] pixelX,				// current VGA pixel -- global value (can be ignored)
					input 	logic signed	[10:0] pixelY,
					input 	logic signed	[10:0] topLeftX,  		// position on the screen 											-- location of top left
					input 	logic	signed	[10:0] topLeftY,    		// can be negative , if the object is partliy outside 	-- location of top left
					
					
					
					output 	logic	[10:0] offsetX,						// offset inside bracket from top left position 
					output 	logic	[10:0] offsetY,
					output 	logic 		 placement_flag
);

 


assign offsetX	= (pixelX - topLeftX); //calculate relative offsets from top left corner allways a positive number 
assign offsetY	= (pixelY - topLeftY);

assign placement_flag = (pixelX >= topLeftX) && (pixelX < topLeftX + 608) &&
                        (pixelY >= topLeftY) && (pixelY < topLeftY + 416);

 
endmodule 