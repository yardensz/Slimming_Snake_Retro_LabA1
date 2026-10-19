


import custom_types::*;



module audio_controller
	
 (  
	input logic 			clk,
	input logic 			resetN,
	input logic				soft_reset,
	
	input logic 			mushroom_eaten, 	
	input logic 			apple_eaten,
	input logic				hamburder_eaten,
	input logic 			melody_ended,
	input logic				shroom_mode,		// is 1 for the duration of shroom mode
	input gamestate 		game_state,			// the state of the game

	
   output logic 			enable,				// decides to enable or disable a track
	output logic [3:0]	audio_selector,
	output logic			restart_melody
	
  ) ;
  
 
 
 
 logic 		regular_food_eaten;		// include hamburder and apple
 
 logic 		new_req;						// request for playing sound, it can be once the last one was over or it can be to override current sound
 
 gamestate	game_state_d;
 
 logic 		victory_pulse;
 
 logic 		game_over_pulse;
 
 logic		shroom_mode_d;
 
 
 
 
 assign regular_food_eaten 	= (hamburder_eaten || apple_eaten);
 
 assign new_req				 	= (		 hamburder_eaten || apple_eaten || mushroom_eaten 
														|| melody_ended || game_over_pulse || victory_pulse			); // MUST contain only pulses of clk (sure?)
 
 
 assign victory_pulse	 = (game_state == victory) 	&& (game_state_d != victory);			// turn victory signal to a pulse

 assign game_over_pulse	 = (game_state == game_over) 	&& (game_state_d != game_over);		// turn game_over signal to a pulse
	
	
	
	
	
	always_ff @(posedge clk or negedge resetN) begin

       if (!resetN) begin
            
				enable 				<= 0;
				audio_selector		<= 4'd5;
				game_state_d 		<= start;
				restart_melody 	<= 0;
			   shroom_mode_d 		<= 0;
       end
		 
		 
		 
		 
		else begin
		
				/*
					Order of selection:
						no sound 						- 5
						eaten ham or apple 			- 2
						Mushroom eaten 				- 1
						Death				 				- 3
						
						
				*/
				
			// ---- Default values ----
				restart_melody 	<= 0;
				game_state_d 		<= game_state;
				shroom_mode_d 		<= shroom_mode;
	
	
				
				
				
			// ----- soft reset -----
				if	(soft_reset) begin 
					
					enable 			<= 0;
					audio_selector	<= 4'd5;
				
				end 
			
			
				
				
			// ----- selecting track (until end of melody) -----	
				else if (new_req) begin 										// IF  (there is a req for new sound) 
				
					// ---- Default values ---- 
					enable 				<= 1;
					game_state_d		<= game_state;
					restart_melody 	<= 1;
				
				
					
					if 		(victory_pulse)						audio_selector <= 4'd8;
					
					else if 	(game_over_pulse)						audio_selector <= 4'd13;
												
					else if 	(mushroom_eaten)						audio_selector <= 4'd1;
					
					else if 	(regular_food_eaten)					audio_selector <= 4'd2;		
					
					

					
					
					else begin 					// else, turn the sound OFF
						enable 			<= 0;
						audio_selector	<= 4'd5;
					end
					
					
					
					
				end // end of "new_req"
				
				
				
			
			// ----- turning OFF mushroom sound once shroom_mode is over -----	
				else if ( 	(shroom_mode_d) && (!shroom_mode) && (audio_selector == 4'd1)		) begin 		// is mushroom sound is ON and the mushroom signal has turned OFF, turn the mushroom audio OFF.
					
					enable 			<= 0;
					audio_selector	<= 4'd5;
					
				end // end of "!shroom_mode"
		
		
		
		
			
		
				
				
				
				
		end // end of "else resetN"
		
		
	end // end always_ff
 
 
 



endmodule


















