

import packaged_food ::* ; // import all types of foods 
import custom_types::*;



module	food_draw	(	
					input	logic					clk,
					input	logic					resetN,	
					input logic					[10:0] offsetX,					// offset from top left  position 
					input logic					[10:0] offsetY,
					input	logic					placement_flag, 					// input that the pixel is within a bracket 
					input logic 				start_of_frame,
					input food_option 		food_type,							// which type of food to generate. 
					
					input logic 				[5:0] food_tile_x,				// location in X where to place the food (random)
					input logic 				[4:0] food_tile_y,
					input logic 				draw_req,
					input logic 				food_collision, 					// if a food collision has occure
					input logic 				[5:0] snake_head_x ,
					input logic 				[4:0] snake_head_y,
					input logic					food_gen_flag,						// if we can generate food at the location (Y/N)
					input gamestate			game_state,							// what is the stage in the game we are on
					input logic 				soft_board_reset,
					
					
					
					output	logic				food_draw_req, 					//output that the pixel should be dispalyed 
					output	logic				[7:0] RGBout,  					//rgb value from the bitmap
					output	food_option 	drawn_food, 						// details which kind of food was generated.
					output	logic				rand_draw_req,
					output 	logic 			[987:0] flat_food_matrix,		// NEW 1D Flat Bus Output (13 * 19 * 4 = 988)
					output	logic 			food_gen_done

 );
 

localparam logic [7:0] TRANSPARENT_ENCODING = 8'hFF ; // RGB value in the bitmap representing a transparent pixel 


localparam  logic [9:0] TILE_NUMBER_OF_X_BITS = 5; 	// 2^5 = 32  every object 
localparam  logic [9:0] TILE_NUMBER_OF_Y_BITS = 5; 	// 2^5 = 32 

localparam  int MAZE_NUMBER_OF__X_BITS = 5;				// 19 -> 2^5 = 32 , how many bits are needed in the X direction for a full matrix // 2^4 = 16 / /the maze of the objects 
localparam  int MAZE_NUMBER_OF__Y_BITS = 4;  			// 14 -> 2^4 = 16 , how many bits are needed in the Y direction for a full matrix // 2^3 = 8 

//-----

localparam  logic [9:0] 	TILE_WIDTH_X 	= 10'b1 << 	TILE_NUMBER_OF_X_BITS ;
localparam  logic [9:0] 	TILE_HEIGHT_Y 	= 10'b1 <<  TILE_NUMBER_OF_Y_BITS ;
localparam  logic [10:0] 	MAZE_WIDTH_X 	= 11'd19 ; 										// set the maze X size (amont of tiles)
localparam  logic [10:0] 	MAZE_HEIGHT_Y 	= 11'd13 ; 										// set the maze Y size (amont of tiles)
									

									
 logic [9:0] 			offsetX_LSB ;
 logic [9:0] 			offsetY_LSB ; 
 logic [10:0] 			offsetX_MSB ;
 logic [10:0] 			offsetY_MSB ;
 logic [9:0] 			address ;
 logic [0:15][7:0] 	color ;
 
 
 

 assign offsetX_LSB  = offsetX[(TILE_NUMBER_OF_X_BITS-1):0] ; 																  // get lower bits 
 assign offsetY_LSB  = offsetY[(TILE_NUMBER_OF_Y_BITS-1):0] ;																  // get lower bits 
 assign offsetX_MSB  = offsetX[(TILE_NUMBER_OF_X_BITS + MAZE_NUMBER_OF__X_BITS - 1 ):TILE_NUMBER_OF_X_BITS] ; // get higher bits 
 assign offsetY_MSB  = offsetY[(TILE_NUMBER_OF_Y_BITS + MAZE_NUMBER_OF__Y_BITS - 1 ):TILE_NUMBER_OF_Y_BITS] ; // get higher bits 
 assign address 		= (offsetY_LSB*TILE_WIDTH_X + offsetX_LSB);
// Explain: the inputs offsetX and offsetY are both talking about the enteir display, 
//				the LSB and MSB are spliting those values.
//				MSB - the tiles location on screen (MSB = position in the matrix)
//				LSB - position within a tile (LSB = postion inside a tile)




 
 logic [0:(MAZE_HEIGHT_Y-1)][0:(MAZE_WIDTH_X-1)] [3:0]	food_matrix ; 					// 19X13 grid 
 
 assign flat_food_matrix = food_matrix;	
	

 logic [0:(MAZE_HEIGHT_Y-1)][0:(MAZE_WIDTH_X-1)] [3:0]  	defualt_food_matrix_lvl1 = // defult table to load on reset 

{{76'h0_0_0_0_0_0_0_0_0_0_0_0_0_0_0_0_0_0_0},

 {76'h0_0_0_0_0_0_0_0_0_0_0_0_0_0_0_0_0_0_0},
 
 {76'h0_0_0_0_0_0_0_0_0_0_0_0_0_0_0_0_0_0_0},
 
 {76'h0_0_0_0_0_0_0_0_0_0_0_0_0_0_0_0_0_0_0},
 
 {76'h0_0_0_0_0_0_0_0_0_0_0_0_0_0_0_0_0_0_0},
 
 {76'h0_0_0_0_0_0_0_0_0_0_0_0_0_0_0_0_0_0_0},
			  
 {76'h0_0_0_0_0_0_0_0_0_0_0_0_0_0_0_0_0_0_0}, 
 
 {76'h0_0_0_0_0_0_0_0_0_0_0_0_0_0_0_0_0_0_0},
 
 {76'h0_0_0_0_0_0_0_0_0_0_0_0_0_0_0_0_0_0_0},
 
 {76'h0_0_0_0_0_0_0_0_0_0_0_0_0_0_0_0_0_0_0},
 
 {76'h0_0_0_0_0_0_0_0_0_0_0_0_0_0_0_0_0_0_0},
 
 {76'h0_0_0_0_0_0_0_0_0_0_0_0_0_0_0_0_0_0_0},
 
 {76'h0_0_0_0_0_0_0_0_0_0_0_0_0_0_0_0_0_0_0}}; 
 
 
 
 
 
 
  logic [0:(MAZE_HEIGHT_Y-1)][0:(MAZE_WIDTH_X-1)] [3:0]  	defualt_food_matrix_lvl2 = // defult table to load on reset 

{{76'h0_0_0_0_0_0_0_0_0_0_0_0_0_0_0_0_0_0_0},

 {76'h0_0_0_0_0_0_0_0_0_0_0_0_0_0_0_0_0_0_0},
 
 {76'h0_0_0_0_0_4_4_4_4_0_0_0_0_0_0_0_0_0_0},
 
 {76'h0_0_0_0_0_0_0_0_0_0_0_0_0_0_0_0_0_0_0},
 
 {76'h0_0_0_0_0_0_0_0_0_0_0_0_0_0_0_0_0_0_0},
 
 {76'h0_0_0_0_0_0_0_0_0_0_0_0_0_0_0_0_0_0_0},
			  
 {76'h0_0_0_0_0_0_0_0_0_0_0_0_0_0_0_0_0_0_0}, 
 
 {76'h0_0_0_0_0_0_0_0_0_0_0_0_0_0_0_0_0_0_0},
 
 {76'h0_0_0_0_0_0_0_0_0_0_0_0_0_0_0_0_0_0_0},
 
 {76'h0_0_0_0_0_0_0_0_0_0_0_0_0_0_4_0_0_0_0},
 
 {76'h0_0_0_0_0_0_0_0_0_0_0_0_0_0_4_0_0_0_0},
 
 {76'h0_0_0_0_0_0_0_0_0_0_0_0_0_4_4_0_0_0_0},
 
 {76'h0_0_0_0_0_0_0_0_0_0_0_0_0_0_0_0_0_0_0}};
 
 
 
 
  logic [0:(MAZE_HEIGHT_Y-1)][0:(MAZE_WIDTH_X-1)] [3:0]  	defualt_food_matrix_lvl3 = // defult table to load on reset 

{{76'h0_0_0_0_0_0_0_0_0_0_0_0_0_0_0_0_0_0_0},

 {76'h0_0_4_4_4_0_0_0_0_0_0_0_0_0_0_0_0_0_0},
 
 {76'h0_0_4_0_0_0_0_4_4_4_4_4_4_0_0_0_0_0_0},
 
 {76'h0_0_4_0_0_0_0_0_0_0_0_0_0_0_0_0_0_0_0},
 
 {76'h0_0_4_0_0_0_4_4_4_4_4_4_4_0_0_0_0_0_0},
 
 {76'h0_0_0_0_0_0_0_0_0_0_0_0_0_0_0_0_0_0_0},
			  
 {76'h0_0_0_0_0_0_0_0_0_0_0_0_0_4_4_0_0_0_0}, 
 
 {76'h0_0_0_0_0_0_0_0_0_0_0_0_0_0_0_4_0_0_0},
 
 {76'h0_0_0_0_0_0_0_0_0_0_0_0_0_4_0_0_4_0_0},
 
 {76'h0_0_0_0_0_0_0_0_0_0_0_0_0_0_4_0_0_4_0},
 
 {76'h0_0_0_0_0_0_0_0_0_0_0_0_0_0_0_4_0_0_0},
 
 {76'h0_0_0_0_0_0_0_0_0_0_0_0_0_0_0_0_4_0_0},
 
 {76'h0_0_0_0_0_0_0_0_0_0_0_0_0_0_0_0_0_0_0}};



lpm_rom #(
    .LPM_WIDTH(8),
    .LPM_WIDTHAD(10),
	 .LPM_NUMWORDS(1024),
    .LPM_FILE("RTL/apple.mif"),
	   .LPM_TYPE               ("LPM_ROM"),
      .LPM_ADDRESS_CONTROL    ("REGISTERED"), 
		.LPM_OUTDATA            ("UNREGISTERED"), 
		.AUTO_CARRY_CHAINS      ("ON"),
		.AUTO_CASCADE_BUFFERS   ("ON"),
	   .INTENDED_DEVICE_FAMILY ("Cyclone V")  
) rom_inst1 (
    .address(address),
	 .inclock(clk),
	// .outclock(clk),
    .q(color[red_apple])
);

 
lpm_rom #(
    .LPM_WIDTH(8),
    .LPM_WIDTHAD(10),
	 .LPM_NUMWORDS(1024),
    .LPM_FILE("RTL/ham.mif"), 
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
    .q(color[hamburger])
); 

lpm_rom #(
    .LPM_WIDTH(8),
    .LPM_WIDTHAD(10),
	 .LPM_NUMWORDS(1024),
    .LPM_FILE("RTL/mushroom.mif"), 
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
    .q(color[mushroom])
);

lpm_rom #(
    .LPM_WIDTH(8),
    .LPM_WIDTHAD(10),
	 .LPM_NUMWORDS(1024),
    .LPM_FILE("RTL/wall.mif"), 
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
    .q(color[wall])
);

 

//==----------------------------------------------------------------------------------------------------------------=
always_ff@(posedge clk or negedge resetN)
begin

	if(!resetN) begin
		RGBout 			<= 8'h00;
		food_matrix 	<= defualt_food_matrix_lvl1; // copy default tabel 
		food_gen_done 	<= 0;
		drawn_food		<= air;
	end
	
	
	else begin
	
		RGBout <= TRANSPARENT_ENCODING ; 			// default 
	
	
	
		if (soft_board_reset) begin 
		
			case (game_state)			// choosing the correct board according to the level
						 start 			: food_matrix <= defualt_food_matrix_lvl1;
						 lvl1 			: food_matrix <= defualt_food_matrix_lvl1;  							 
						 lvl2 			: food_matrix <= defualt_food_matrix_lvl2;
						 lvl3				: food_matrix <= defualt_food_matrix_lvl3;
						 victory			: food_matrix <= defualt_food_matrix_lvl1;
						 game_over		: food_matrix <= defualt_food_matrix_lvl1;
						 default			: food_matrix <= defualt_food_matrix_lvl1; 	 	
			endcase
			
			
			
			food_gen_done 	<= 0;
			drawn_food		<= air;
			
			
			
		end
	
		
		else begin // if not board reset
		
		
			if (food_collision) begin 
			
					food_matrix[snake_head_y][snake_head_x] <= air; // deleting the food the the snake eat.
			end 
			
			
			
			
			// ---- delaying after one clock the signle to "done" and making sure that "done" actually happend after drawing ---- 
			if (!food_gen_flag) begin

				food_gen_done <= 0;

			end

			
			else if (draw_req && !food_gen_done) begin

				 food_matrix[food_tile_y][food_tile_x] <= food_type;
				 drawn_food                            <= food_type;
				 food_gen_done                         <= 1;
			end
			
		end // end if not board reset	
			
			
			
			
		//------ sending data out ------- 	
			
		if (placement_flag == 1'b1) begin 
		   	case (food_matrix[offsetY_MSB][offsetX_MSB])
					 air 			: RGBout <= TRANSPARENT_ENCODING;
			   	 red_apple 	: RGBout <= color[red_apple];  							 
					 hamburger 	: RGBout <= color[hamburger];
					 mushroom	: RGBout <= color[mushroom];
					 wall			: RGBout <= color[wall];
					 default		: RGBout <= TRANSPARENT_ENCODING ; 
					 
						
				endcase
		end // end sending data out 
		
	end // end of "else" - syncrenized part
end	// end of "awlwaysff"



//==----------------------------------------------------------------------------------------------------------------=
// decide if to draw the pixel or not 
assign food_draw_req = (RGBout != TRANSPARENT_ENCODING ) ? 1'b1 : 1'b0 ; // need to draw food (already placed food)

assign rand_draw_req = ( 	(RGBout != TRANSPARENT_ENCODING) &&
									(food_matrix[food_tile_y][food_tile_x] != air)
									
								) ? 1'b1 : 1'b0 ; // if we output some kind of food AND that there is empty spot to draw more food

  
endmodule

