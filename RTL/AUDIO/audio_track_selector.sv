


import custom_types::*; 



module audio_track_selector
	
 (  
	input logic 			clk,
	input logic 			resetN,
	input logic 			mushroom_eaten, 	// this is a FLAG from game_controller named "mushroom_mode", notice that this is not a pulse like all the rest maybe
	input logic 			apple_eaten,
	input logic				hamburder_eaten,
   input gamestate		game_state,			// which game stage we are on (start, lvl, end)
	input logic 			melody_ended,		// confirms that the latest melody was ended
	input logic 			start_of_lvl,		// pulse for the beginning of a level
	input logic				Soft_reset,
	input logic 			death,
	
   output logic [3:0]	audio_selector
	
  ) ;
  
 
 
	
	
	
	always_ff @(posedge clk or negedge resetN) begin
	
       if (!resetN) begin
            
				audio_selector <= 4'd9; 	// Default value
				
       end
		 
		 
		 
		 
		else begin
		
				/*
					Order of selection:
						Game-over - 0
						Start menu - 1
						next level - 2
						Mushroom eaten - 3
						Food was eaten - 4
						background music - 5
						death - 14
						default/reset/soft reset - 15
				*/
				
				
				
				// ---- Default values ---- 
				
				audio_selector <= 4'd15; 	// no sound (enable will be OFF)
				
				
				
				if 		(Soft_reset)															audio_selector <= 4'd15;	// soft reset of the system --> no sound
				
				else if 	(death)																	audio_selector	<= 4'd14;	// dead snake
				
				else if 	(game_state	== game_over)											audio_selector	<= 4'd0;		// start game
				
				else if 	(game_state	== start)												audio_selector	<= 4'd1;		// start menu
				
				else if 	(start_of_lvl)															audio_selector	<= 4'd2;	
							
				else if 	(mushroom_eaten && melody_ended)									audio_selector	<= 4'd3;		// mushroom was eaten and higher priority are finished.		
				
				else if 	( (apple_eaten || hamburder_eaten) && melody_ended )		audio_selector	<= 4'd4;		// apple or hamburger were eaten
					
				else if 	(melody_ended)															audio_selector	<= 4'd5;		// BG music or keep it empty (for now it will be empty sound)
				
				
				
				
		end // end of "else resetN"
		
	end // end always_ff
 
 
 



endmodule


















