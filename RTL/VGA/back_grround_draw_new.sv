module	back_ground_draw_new	(	

					input	logic	clk,
					input	logic	resetN,
					input 	logic	[10:0]	pixelX,
					input 	logic	[10:0]	pixelY,

					output	logic	[7:0]	BG_RGB
);


// -------------------- sizes ------------------:

const int	xFrameSize	=	640; 
const int	yFrameSize	=	480; 
const int	top_or_sides_offset =  16;
const int 	bottom_Offset = 48;

const logic [18:0] STORAGE_SIZE = xFrameSize * yFrameSize * 2;

const int board_top_left_x =  top_or_sides_offset; 
const int board_top_left_y =  top_or_sides_offset; 
const int board_buttom_right_x =  xFrameSize - top_or_sides_offset; 
const int board_buttom_right_y =  yFrameSize - bottom_Offset; 

//--------------------- colors -------------------

localparam  logic [7:0] txt_color  = 8'b111_000_00 ;
localparam  logic [7:0] frame_color_a  = 8'b100_100_01 ; //inner frame color - dark gray
localparam  logic [7:0] frame_color_b  = 8'b101_101_10 ;  //outer frame color grayl
localparam  logic [7:0] base_color  = 8'b110_110_10 ;  //base background color- light gray

localparam  logic [7:0] checkerbaord_color_a  = 8'b101_111_10 ;  //a green
localparam  logic [7:0] checkerbaord_color_b  = 8'b011_110_00 ;  //diffrent green

//------------------------ memory ----------------

lpm_rom #(
    .LPM_WIDTH(2),
    .LPM_WIDTHAD(19),
	 .LPM_NUMWORDS(307200),
    .LPM_FILE("RTL/VGA/4colorBG.mif"),
	   .LPM_TYPE               ("LPM_ROM"),
      .LPM_ADDRESS_CONTROL    ("REGISTERED"), 
		.LPM_OUTDATA            ("UNREGISTERED"), 
		.AUTO_CARRY_CHAINS      ("ON"),
		.AUTO_CASCADE_BUFFERS   ("ON"),
	   .INTENDED_DEVICE_FAMILY ("Cyclone V")  
) rom_inst (
    .address(address),
	 .inclock(clk),
    .q(memcolor)
);
//-------------------- logic -------------
logic inside_screen;
logic [18:0] address;
logic inside_board_condition, checkerboard_color_a_condition;
logic inside_board_condition_d, checkerboard_color_a_condition_d;
logic	[10:0]	adjusted_pixelX, adjusted_pixelY; 
logic [1:0] memcolor;
//----------- what to draw when --------------

always_comb begin
	address = pixelY * xFrameSize + pixelX;
	
	inside_screen = (pixelX < xFrameSize) && (pixelY < yFrameSize);
	
	inside_board_condition = (pixelX >= board_top_left_x)
								&&	 (pixelX < board_buttom_right_x)
								&&  (pixelY >= board_top_left_y)
								&&  (pixelY < board_buttom_right_y);
								
	//to check what color to draw in the checkerboard pattern we:
	//		1. subtract offset
	//		2. figure out the row / colomb number by dividing by 32
	//		3. check pairity for the divided number
	//		4. if pairity is same draw one color if diffrent draw another
	//instead of actually dividing by  32 and checking pairity we achive 
	//	- the same effect by looking at bit 5.
	
	adjusted_pixelX = pixelX - 16;
	adjusted_pixelY = pixelY - 16;
	
	checkerboard_color_a_condition = (adjusted_pixelX[5] == adjusted_pixelY[5]); 
end

//------------ drawing with the always flip flopp ---------

always_ff@(posedge clk or negedge resetN)
begin
	if(!resetN) begin
		BG_RGB <= 0;
		inside_board_condition_d <= 0;
        checkerboard_color_a_condition_d <= 0;
	end
	else begin
			//for timing reasons create a delayed signal
			inside_board_condition_d <= inside_board_condition;
			checkerboard_color_a_condition_d <= checkerboard_color_a_condition;
	
	
		BG_RGB <= 8'b000_000_00;
		if(inside_screen) begin
			if(inside_board_condition_d)
				begin
					
					BG_RGB <= (checkerboard_color_a_condition_d) ?
									checkerbaord_color_a : checkerbaord_color_b;
				
				end
			else begin
				
				case (memcolor) //may need adjusting
					1: BG_RGB <= txt_color;
					3: BG_RGB <= base_color;
					2: BG_RGB <= frame_color_a;
					0:	BG_RGB <= frame_color_b;			
				endcase
		
			end
	end
 	end 
end


endmodule 