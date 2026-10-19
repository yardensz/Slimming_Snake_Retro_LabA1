//final draft
import custom_types::*;


module gamestate_image_display(	
					input		logic				clk,
					input		logic				resetN,
					input 	logic	[10:0] 	pixelX,				// offset from top left position 
					input 	logic	[10:0] 	pixelY,
					input 	     gamestate game_state,			// curuunt state of game
					input logic toggle_bg_color,
					
					output	logic				drawingRequest, 	//output that the pixel should be dispalyed 
					output	logic	[7:0]		RGBout
);


localparam logic [18:0] WIDTH = 12'd640;
localparam logic [18:0] HIGHT = 12'd480;
logic [18:0] address ;

logic is_pixel_in_screen, is_pixel_in_screen_d;

logic  color_start, color_game_over, color_victory, chosen_color, draw_somthing;

assign address = pixelY * WIDTH + pixelX;

 
parameter  logic	[7:0] drawing_color = 8'hf0 ; //set the color of the iamge
parameter  logic	[7:0] BG_color = 8'hdd ;
	

// --- 1. Start Screen ROM ---
lpm_rom #(
    .LPM_WIDTH(1),
    .LPM_WIDTHAD(19),
    .LPM_NUMWORDS(307200),
    .LPM_FILE("RTL/game_state_mifs/startScreen.mif"),
    .LPM_TYPE("LPM_ROM"),
    .LPM_ADDRESS_CONTROL("REGISTERED"),
    .LPM_OUTDATA("UNREGISTERED"),
    .AUTO_CARRY_CHAINS("ON"),
    .AUTO_CASCADE_BUFFERS("ON"),
    .INTENDED_DEVICE_FAMILY("Cyclone V")
) rom_start (
    .address(address),
    .inclock(clk),
    .q(color_start)
);

// --- 2. Game Over ROM ---
lpm_rom #(
    .LPM_WIDTH(1),
    .LPM_WIDTHAD(19),
    .LPM_NUMWORDS(307200),
    .LPM_FILE("RTL/game_state_mifs/gameOver.mif"),
    .LPM_TYPE("LPM_ROM"),
    .LPM_ADDRESS_CONTROL("REGISTERED"),
    .LPM_OUTDATA("UNREGISTERED"),
    .AUTO_CARRY_CHAINS("ON"),
    .AUTO_CASCADE_BUFFERS("ON"),
    .INTENDED_DEVICE_FAMILY("Cyclone V")
) rom_game_over (
    .address(address),
    .inclock(clk),
    .q(color_game_over)
);

// --- 3. Victory ROM ---
lpm_rom #(
    .LPM_WIDTH(1),
    .LPM_WIDTHAD(19),
    .LPM_NUMWORDS(307200),
    .LPM_FILE("RTL/game_state_mifs/victory.mif"),
    .LPM_TYPE("LPM_ROM"),
    .LPM_ADDRESS_CONTROL("REGISTERED"),
    .LPM_OUTDATA("UNREGISTERED"),
    .AUTO_CARRY_CHAINS("ON"),
    .AUTO_CASCADE_BUFFERS("ON"),
    .INTENDED_DEVICE_FAMILY("Cyclone V")
) rom_victory (
    .address(address),
    .inclock(clk),
    .q(color_victory)
);

	
	always_comb begin
		
		is_pixel_in_screen = (pixelX < WIDTH) && (pixelY < HIGHT); 
		
		case (game_state)
			start: 
				begin
					chosen_color = color_start;
					draw_somthing = 1'b1;
				end
			game_over:  
				begin
					chosen_color = color_game_over;
					draw_somthing = 1'b1;
				end
			victory:  
				begin
					chosen_color = color_victory;
					draw_somthing = 1'b1;
				end
			default:
				begin
					chosen_color = 1;
					draw_somthing = 1'b0;
				end
			
		endcase
	end// alwayscomb


always_ff@(posedge clk or negedge resetN)
begin
	if(!resetN) begin
		drawingRequest <=	1'b0;
		is_pixel_in_screen_d <= 1'b0;
	end
	
	else begin
	
		is_pixel_in_screen_d <= is_pixel_in_screen;
		 drawingRequest <= 0;
		 RGBout <= 0;
		 
	  	if (is_pixel_in_screen_d && draw_somthing) 
			begin
				drawingRequest <= chosen_color ? toggle_bg_color : 1; 
				RGBout <= chosen_color ? BG_color : drawing_color;
			end
 	end 
end



endmodule