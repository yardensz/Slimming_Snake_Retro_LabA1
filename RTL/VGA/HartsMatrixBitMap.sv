// HartsMatrixBitMap File 
// A two level bitmap. dosplaying harts on the screen Feb 2025 
//(c) Technion IIT, Department of Electrical Engineering 2025 


import custom_types ::* ; // import all things in the package 

module	HartsMatrixBitMap	(	
					input	logic	clk,
					input	logic	resetN,
					input logic	[10:0] offsetX,// offset from top left position 
					input logic	[10:0] offsetY,
					input	logic	InsideRectangle, //input that the pixel is within a bracket 
					input logic start_of_frame,
					
					
					////////
					input logic [4:0] head_y,
					input logic [5:0] head_x, 	
					input snakepart head_pos, 		// "from" snakepart
					
					input logic [4:0] neck_y,
					input logic [5:0] neck_x, 	
					input snakepart neck_pos, 		// "from" snakepart
					
					input logic [4:0] butt_y,
					input logic [5:0] butt_x, 	
					
					input logic [4:0] tail_y,
					input logic [5:0] tail_x, 	
					input snakepart tail_pos, 		// "from" snakepart
					//////
					input logic manual_reset,
					
				
				

					output	logic	snake_draw_req, 					// requesting to draw a snake body part
					output	logic	[7:0] RGBout, 						//rgb value from the bitmap 
					output	logic	head_draw_req, 					// requesting to draw a snake body part
					output 	logic [987:0] flat_snake_matrix		// NEW 1D Flat Bus Output (13 * 19 * 4 = 988)

					
 ) ;  
 
 
 

localparam logic [7:0] TRANSPARENT_ENCODING = 8'hFF ;// RGB value in the bitmap representing a transparent pixel 


localparam  logic [9:0] TILE_NUMBER_OF_X_BITS = 5;  // 2^5 = 32  every object 
localparam  logic [9:0] TILE_NUMBER_OF_Y_BITS = 5;  // 2^5 = 32 

localparam  int MAZE_NUMBER_OF__X_BITS = 5;  		// 19 -> 2^5 = 32 , how many bits are needed in the X direction for a full matrix // 2^4 = 16 / /the maze of the objects 
localparam  int MAZE_NUMBER_OF__Y_BITS = 4;  		// 14 -> 2^4 = 16 , how many bits are needed in the Y direction for a full matrix // 2^3 = 8 

//-----

localparam  logic [9:0] TILE_WIDTH_X = 10'b1 << TILE_NUMBER_OF_X_BITS ;
localparam  logic [9:0] TILE_HEIGHT_Y = 10'b1 <<  TILE_NUMBER_OF_Y_BITS ;
localparam  logic [10:0] MAZE_WIDTH_X = 11'd19 ; 										// set the maze X size (amont of tiles)
localparam  logic [10:0] MAZE_HEIGHT_Y = 11'd13 ; 										// set the maze Y size (amont of tiles)
									



 logic [9:0] offsetX_LSB  ;
 logic [9:0] offsetY_LSB  ; 
 logic [10:0] offsetX_MSB ;
 logic [10:0] offsetY_MSB ;
 logic [9:0] address  ;
 logic [0:15][7:0] color	; // [0:15] is the number of tiles, if you want to add one more tile, you will need to write [0:16], this way color[#] will take all the RGB value of the row in the matrix.
 
 logic is_rgbout_head_address; 	// does the address of heads mifs connected to head address?

 
 assign is_rgbout_head_address = ( 	(RGBout == color[head_up]) 	|| 
												(RGBout == color[head_left]) 	||
												(RGBout == color[head_right]) ||
												(RGBout == color[head_down]) 
											); // is RGBout contains head of snake???
 
 
 assign offsetX_LSB  = offsetX[(TILE_NUMBER_OF_X_BITS-1):0] ; 																  // get lower bits 
 assign offsetY_LSB  = offsetY[(TILE_NUMBER_OF_Y_BITS-1):0] ;																  // get lower bits 
 assign offsetX_MSB  = offsetX[(TILE_NUMBER_OF_X_BITS + MAZE_NUMBER_OF__X_BITS - 1 ):TILE_NUMBER_OF_X_BITS] ; // get higher bits 
 assign offsetY_MSB  = offsetY[(TILE_NUMBER_OF_Y_BITS + MAZE_NUMBER_OF__Y_BITS - 1 ):TILE_NUMBER_OF_Y_BITS] ; // get higher bits 
 assign address = (offsetY_LSB*TILE_WIDTH_X + offsetX_LSB);
// Explain: the inputs offsetX and offsetY are both talking about the enteir display, 
//				the LSB and MSB are spliting those values.
//				MSB - the tiles location on screen (MSB = position in the matrix)
//				LSB - position within a tile (LSB = postion inside a tile)


 
// the screen is 640*480  or  20 * 15 squares of 32*32  bits ,  we wiil round up to 8 *16 
// this is the bitmap  of the maze , if there is a specific value  the  whole 32*32 rectange will be drawn on the screen
// there are  16 options of differents kinds of 32*32 squares 
// all numbers here are hard coded to simplify the understanding 



logic [0:(MAZE_HEIGHT_Y-1)][0:(MAZE_WIDTH_X-1)] [3:0]  MazeBitMapMask ; // 19X13 grid

	assign flat_snake_matrix = MazeBitMapMask;
	

logic [0:(MAZE_HEIGHT_Y-1)][0:(MAZE_WIDTH_X-1)] [3:0]   MazeDefaultBitMapMask = // defult table to load on reset 

{{76'h0_0_0_0_0_0_0_0_0_0_0_0_0_0_0_0_0_0_0},

 {76'h0_0_0_0_0_0_0_0_0_0_0_0_0_0_0_0_0_0_0},
 
 {76'h0_0_0_0_0_0_0_0_0_0_0_0_0_0_0_0_0_0_0},
 
 {76'h0_0_0_0_0_0_0_0_0_0_0_0_0_0_0_0_0_0_0},
 
 {76'h0_0_0_0_0_0_0_0_0_0_0_0_0_0_0_0_0_0_0},
 
 {76'h0_0_0_0_0_0_0_0_0_0_0_0_0_0_0_0_0_0_0},
			  // head here   ↴
 {76'h0_0_0_0_0_8_d_d_d_d_0_0_0_0_0_0_0_0_0}, // 
 
 {76'h0_0_0_0_0_0_0_0_0_0_0_0_0_0_0_0_0_0_0},
 
 {76'h0_0_0_0_0_0_0_0_0_0_0_0_0_0_0_0_0_0_0},
 
 {76'h0_0_0_0_0_0_0_0_0_0_0_0_0_0_0_0_0_0_0},
 
 {76'h0_0_0_0_0_0_0_0_0_0_0_0_0_0_0_0_0_0_0},
 
 {76'h0_0_0_0_0_0_0_0_0_0_0_0_0_0_0_0_0_0_0},
 
 {76'h0_0_0_0_0_0_0_0_0_0_0_0_0_0_0_0_0_0_0}};        // 19*4 (bits) = 76 (size also needed to be chagne in the top params)





lpm_rom #(
    .LPM_WIDTH(8),
    .LPM_WIDTHAD(10),
	 .LPM_NUMWORDS(1024),
    .LPM_FILE("RTL/SNAKE_TILES/body_horizontal.mif"), // the .mif file that show the moving part
	   .LPM_TYPE               ("LPM_ROM"),
      .LPM_ADDRESS_CONTROL    ("REGISTERED"), 
		.LPM_OUTDATA            ("UNREGISTERED"), 
		.AUTO_CARRY_CHAINS      ("ON"),
		.AUTO_CASCADE_BUFFERS   ("ON"),
	   .INTENDED_DEVICE_FAMILY ("Cyclone V")  
) rom_inst2 (
    .address(address),
	 .inclock(clk),
	// .outclock(clk),
    .q(color[body_horizontal])
); 

lpm_rom #(
    .LPM_WIDTH(8),
    .LPM_WIDTHAD(10),
	 .LPM_NUMWORDS(1024),
    .LPM_FILE("RTL/SNAKE_TILES/body_vertial.mif"), // the .mif file that show the moving part
	   .LPM_TYPE               ("LPM_ROM"),
      .LPM_ADDRESS_CONTROL    ("REGISTERED"), 
		.LPM_OUTDATA            ("UNREGISTERED"), 
		.AUTO_CARRY_CHAINS      ("ON"),
		.AUTO_CASCADE_BUFFERS   ("ON"),
	   .INTENDED_DEVICE_FAMILY ("Cyclone V")  
) rom_inst3 (
    .address(address),
	 .inclock(clk),
	// .outclock(clk),
    .q(color[body_vertical])
);

lpm_rom #(
    .LPM_WIDTH(8),
    .LPM_WIDTHAD(10),
	 .LPM_NUMWORDS(1024),
    .LPM_FILE("RTL/SNAKE_TILES/corner_down_right.mif"), // the .mif file that show the moving part
	   .LPM_TYPE               ("LPM_ROM"),
      .LPM_ADDRESS_CONTROL    ("REGISTERED"), 
		.LPM_OUTDATA            ("UNREGISTERED"), 
		.AUTO_CARRY_CHAINS      ("ON"),
		.AUTO_CASCADE_BUFFERS   ("ON"),
	   .INTENDED_DEVICE_FAMILY ("Cyclone V")  
) rom_inst4 (
    .address(address),
	 .inclock(clk),
	// .outclock(clk),
    .q(color[turn4])
);

lpm_rom #(
    .LPM_WIDTH(8),
    .LPM_WIDTHAD(10),
	 .LPM_NUMWORDS(1024),
    .LPM_FILE("RTL/SNAKE_TILES/corner_left_down.mif"), // the .mif file that show the moving part
	   .LPM_TYPE               ("LPM_ROM"),
      .LPM_ADDRESS_CONTROL    ("REGISTERED"), 
		.LPM_OUTDATA            ("UNREGISTERED"), 
		.AUTO_CARRY_CHAINS      ("ON"),
		.AUTO_CASCADE_BUFFERS   ("ON"),
	   .INTENDED_DEVICE_FAMILY ("Cyclone V")  
) rom_inst5 (
    .address(address),
	 .inclock(clk),
	// .outclock(clk),
    .q(color[turn3])
);


lpm_rom #(
    .LPM_WIDTH(8),
    .LPM_WIDTHAD(10),
	 .LPM_NUMWORDS(1024),
    .LPM_FILE("RTL/SNAKE_TILES/corner_right_up.mif"), // the .mif file that show the moving part
	   .LPM_TYPE               ("LPM_ROM"),
      .LPM_ADDRESS_CONTROL    ("REGISTERED"), 
		.LPM_OUTDATA            ("UNREGISTERED"), 
		.AUTO_CARRY_CHAINS      ("ON"),
		.AUTO_CASCADE_BUFFERS   ("ON"),
	   .INTENDED_DEVICE_FAMILY ("Cyclone V")  
) rom_inst6 (
    .address(address),
	 .inclock(clk),
	// .outclock(clk),
    .q(color[turn1])
);


lpm_rom #(
    .LPM_WIDTH(8),
    .LPM_WIDTHAD(10),
	 .LPM_NUMWORDS(1024),
    .LPM_FILE("RTL/SNAKE_TILES/corner_up_left.mif"), // the .mif file that show the moving part
	   .LPM_TYPE               ("LPM_ROM"),
      .LPM_ADDRESS_CONTROL    ("REGISTERED"), 
		.LPM_OUTDATA            ("UNREGISTERED"), 
		.AUTO_CARRY_CHAINS      ("ON"),
		.AUTO_CASCADE_BUFFERS   ("ON"),
	   .INTENDED_DEVICE_FAMILY ("Cyclone V")  
) rom_inst7 (
    .address(address),
	 .inclock(clk),
	// .outclock(clk),
    .q(color[turn2])
);


lpm_rom #(
    .LPM_WIDTH(8),
    .LPM_WIDTHAD(10),
	 .LPM_NUMWORDS(1024),
    .LPM_FILE("RTL/SNAKE_TILES/head_down.mif"), // the .mif file that show the moving part
	   .LPM_TYPE               ("LPM_ROM"),
      .LPM_ADDRESS_CONTROL    ("REGISTERED"), 
		.LPM_OUTDATA            ("UNREGISTERED"), 
		.AUTO_CARRY_CHAINS      ("ON"),
		.AUTO_CASCADE_BUFFERS   ("ON"),
	   .INTENDED_DEVICE_FAMILY ("Cyclone V")  
) rom_inst8 (
    .address(address),
	 .inclock(clk),
	// .outclock(clk),
    .q(color[head_down])
);


lpm_rom #(
    .LPM_WIDTH(8),
    .LPM_WIDTHAD(10),
	 .LPM_NUMWORDS(1024),
    .LPM_FILE("RTL/SNAKE_TILES/head_left.mif"), // the .mif file that show the moving part
	   .LPM_TYPE               ("LPM_ROM"),
      .LPM_ADDRESS_CONTROL    ("REGISTERED"), 
		.LPM_OUTDATA            ("UNREGISTERED"), 
		.AUTO_CARRY_CHAINS      ("ON"),
		.AUTO_CASCADE_BUFFERS   ("ON"),
	   .INTENDED_DEVICE_FAMILY ("Cyclone V")  
) rom_inst9 (
    .address(address),
	 .inclock(clk),
	// .outclock(clk),
    .q(color[head_left])
);


lpm_rom #(
    .LPM_WIDTH(8),
    .LPM_WIDTHAD(10),
	 .LPM_NUMWORDS(1024),
    .LPM_FILE("RTL/SNAKE_TILES/head_right.mif"), // the .mif file that show the moving part
	   .LPM_TYPE               ("LPM_ROM"),
      .LPM_ADDRESS_CONTROL    ("REGISTERED"), 
		.LPM_OUTDATA            ("UNREGISTERED"), 
		.AUTO_CARRY_CHAINS      ("ON"),
		.AUTO_CASCADE_BUFFERS   ("ON"),
	   .INTENDED_DEVICE_FAMILY ("Cyclone V")  
) rom_inst10 (
    .address(address),
	 .inclock(clk),
	// .outclock(clk),
    .q(color[head_right])
);


lpm_rom #(
    .LPM_WIDTH(8),
    .LPM_WIDTHAD(10),
	 .LPM_NUMWORDS(1024),
    .LPM_FILE("RTL/SNAKE_TILES/head_up.mif"), // the .mif file that show the moving part
	   .LPM_TYPE               ("LPM_ROM"),
      .LPM_ADDRESS_CONTROL    ("REGISTERED"), 
		.LPM_OUTDATA            ("UNREGISTERED"), 
		.AUTO_CARRY_CHAINS      ("ON"),
		.AUTO_CASCADE_BUFFERS   ("ON"),
	   .INTENDED_DEVICE_FAMILY ("Cyclone V")  
) rom_inst11 (
    .address(address),
	 .inclock(clk),
	// .outclock(clk),
    .q(color[head_up])
);


lpm_rom #(
    .LPM_WIDTH(8),
    .LPM_WIDTHAD(10),
	 .LPM_NUMWORDS(1024),
    .LPM_FILE("RTL/SNAKE_TILES/tail_down.mif"), // the .mif file that show the moving part
	   .LPM_TYPE               ("LPM_ROM"),
      .LPM_ADDRESS_CONTROL    ("REGISTERED"), 
		.LPM_OUTDATA            ("UNREGISTERED"), 
		.AUTO_CARRY_CHAINS      ("ON"),
		.AUTO_CASCADE_BUFFERS   ("ON"),
	   .INTENDED_DEVICE_FAMILY ("Cyclone V")  
) rom_inst12 (
    .address(address),
	 .inclock(clk),
	// .outclock(clk),
    .q(color[tail_down])
);


lpm_rom #(
    .LPM_WIDTH(8),
    .LPM_WIDTHAD(10),
	 .LPM_NUMWORDS(1024),
    .LPM_FILE("RTL/SNAKE_TILES/tail_left.mif"), // the .mif file that show the moving part
	   .LPM_TYPE               ("LPM_ROM"),
      .LPM_ADDRESS_CONTROL    ("REGISTERED"), 
		.LPM_OUTDATA            ("UNREGISTERED"), 
		.AUTO_CARRY_CHAINS      ("ON"),
		.AUTO_CASCADE_BUFFERS   ("ON"),
	   .INTENDED_DEVICE_FAMILY ("Cyclone V")  
) rom_inst13 (
    .address(address),
	 .inclock(clk),
	// .outclock(clk),
    .q(color[tail_left])
);


lpm_rom #(
    .LPM_WIDTH(8),
    .LPM_WIDTHAD(10),
	 .LPM_NUMWORDS(1024),
    .LPM_FILE("RTL/SNAKE_TILES/tail_right.mif"), // the .mif file that show the moving part
	   .LPM_TYPE               ("LPM_ROM"),
      .LPM_ADDRESS_CONTROL    ("REGISTERED"), 
		.LPM_OUTDATA            ("UNREGISTERED"), 
		.AUTO_CARRY_CHAINS      ("ON"),
		.AUTO_CASCADE_BUFFERS   ("ON"),
	   .INTENDED_DEVICE_FAMILY ("Cyclone V")  
) rom_inst14 (
    .address(address),
	 .inclock(clk),
	// .outclock(clk),
    .q(color[tail_right])
);


lpm_rom #(
    .LPM_WIDTH(8),
    .LPM_WIDTHAD(10),
	 .LPM_NUMWORDS(1024),
    .LPM_FILE("RTL/SNAKE_TILES/tail_up.mif"), // the .mif file that show the moving part
	   .LPM_TYPE               ("LPM_ROM"),
      .LPM_ADDRESS_CONTROL    ("REGISTERED"), 
		.LPM_OUTDATA            ("UNREGISTERED"), 
		.AUTO_CARRY_CHAINS      ("ON"),
		.AUTO_CASCADE_BUFFERS   ("ON"),
	   .INTENDED_DEVICE_FAMILY ("Cyclone V")  
) rom_inst15 (
    .address(address),
	 .inclock(clk),
	// .outclock(clk),
    .q(color[tail_up])
);


 

//==----------------------------------------------------------------------------------------------------------------=
always_ff@(posedge clk or negedge resetN)
begin
	if(!resetN) begin
		RGBout 			<=	TRANSPARENT_ENCODING;
		MazeBitMapMask <= MazeDefaultBitMapMask ;  //  copy default tabel 
	end
	else begin
	
		if(manual_reset)
			MazeBitMapMask <= MazeDefaultBitMapMask ;
	
		RGBout <= TRANSPARENT_ENCODING ; 					// default 
		
		//if (start_of_frame) begin 								// update ONLY upon every frame
			MazeBitMapMask[butt_y][butt_x] <= nothing;
			MazeBitMapMask[neck_y][neck_x] <= neck_pos; 
			MazeBitMapMask[head_y][head_x] <= head_pos; 
			MazeBitMapMask[tail_y][tail_x] <= tail_pos;
		//end
			
			
		//------ sending data out ------- 	
			// Explain: this part checks what data is in a tile in the matrix, then it choose to output the wanted tile (from the MIF files).
			
		if (InsideRectangle == 1'b1)	
			begin 
		   	case (MazeBitMapMask[offsetY_MSB][offsetX_MSB])
					head_up 				: RGBout <= color[head_up];
					head_left 			: RGBout <= color[head_left];  							 
					head_down 			: RGBout <= color[head_down]; 
					head_right 			: RGBout <= color[head_right];
					body_vertical 		: RGBout <= color[body_vertical];
					body_horizontal 	: RGBout <= color[body_horizontal];
					turn1 				: RGBout <= color[turn1];
					turn2 				: RGBout <= color[turn2];
					turn3 				: RGBout <= color[turn3];
					turn4 				: RGBout <= color[turn4];
					tail_up 				: RGBout <= color[tail_up];
					tail_left 			: RGBout <= color[tail_left];
					tail_down 			: RGBout <= color[tail_down];
					tail_right 			: RGBout <= color[tail_right];
					nothing 				: RGBout <= TRANSPARENT_ENCODING;// color[nothing];
					4'd15 				: RGBout <= color[4'd15]; 			// heart for debugging
					default 				: RGBout <= TRANSPARENT_ENCODING; 
				endcase
			end 
	end
end



//==----------------------------------------------------------------------------------------------------------------=
// decide if to draw the pixel or not 
assign snake_draw_req = ( (RGBout != TRANSPARENT_ENCODING) && !(is_rgbout_head_address) ) ? 1'b1 : 1'b0 ; 	// is item not head and not transperent?

// decide if to draw head pixel or not 
assign head_draw_req  = ( (RGBout != TRANSPARENT_ENCODING) &&  (is_rgbout_head_address) ) ? 1'b1 : 1'b0;		// output 1 when there is a head (for now this will not be used for printing - just to collosion.






endmodule

















