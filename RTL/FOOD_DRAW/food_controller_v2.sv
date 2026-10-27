

import packaged_food ::* ; // import all types of foods 
import custom_types::*;


module	food_controller_v2	(	
					input logic				clk,
					input logic				resetN,	
					input logic 			[2:0] game_state, 					// from game_controller
																							
					input food_option 	eaten_food, 							// which food eaten last time around? 
					input logic 			[7:0] time_counter, 					// timer (in sec), setting it for 8 bits for 256 sec overall.
					input logic 			[15:0] [7:0] food_count_in,	 	// [# of food types] [so we can count upto 256 of each food type]
					input logic 			gen_mushroom_req,						// input from user to generate a mushroom
					input logic 			[7:0] mushroom_time_counter,
					input logic 			soft_board_reset,						// reset when switching between levels (1->2->3)
					input logic				food_gen_done,							// confirm that a food was darwn on screen, and other request can happend afterwareds

					
					output food_option 	gen_food,								// which food we want to generate
					output logic			time_soft_reset, 						// to reset the timer	
					output logic 			mushroom_time_reset,
					output logic			[15:0] [7:0] food_count_out, 		// [# of food types] [so we can count upto 256 of each food type]
					output logic 			food_gen_flag
		
			);		
 
 

 
 logic start_cooldown;
 
 enum logic [5:0] { idel_state ,apple_state , ham_state , full_state , mushroom_state} fsm; 		// FSM 
 
 logic game_active;
 
 logic game_active_1_sec ;
 
 logic game_active_2_sec ;
 
 logic mushroom_cond;

 
 
 
 
 
 assign game_active				= 	( (game_state == lvl1) || (game_state == lvl2) || (game_state == lvl3) );
  
 assign game_active_1_sec		= 	( (game_active) && (time_counter >= 8'd1) );
 
 assign game_active_2_sec		= 	( (game_active) && (time_counter >= 8'd2) );

 assign mushroom_cond			=	(	( (mushroom_time_counter >= 8'd10) && (game_state == lvl2) ) || (mushroom_time_counter >= 8'd3) && (game_state == lvl3)	);				// in lvl2 mushroom can be generated only mid game, in lvl3 it like anyother food
 

 
  
	 always_ff@(posedge clk or negedge resetN) begin

		if(!resetN) begin
			
			fsm 						<= idel_state;
			time_soft_reset 		<= 1; 				// reset timer always unless told otherwise
			mushroom_time_reset	<= 1;
			food_count_out			<= 0;
			gen_food					<= air;
			food_gen_flag			<= 0;
			
		end
		
		
		
		
		else begin	// else resetN
		
			// default for timer reset --> DO NOT! reset timer always unless told otherwise
			time_soft_reset       <= 0;
			mushroom_time_reset   <= 0;			
			
						
			
			
			// ---- reset the state machine when switching levels ---- 
			if (soft_board_reset) begin
			
				time_soft_reset 				<= 1; 
				mushroom_time_reset			<= 1;	
				food_count_out					<= 0;
				fsm 								<= idel_state;
				food_gen_flag					<= 0;
				gen_food							<= air;

					
			end
		
		
			// ---- making sure food was drawn on the bitmap ----
			else if (food_gen_flag) begin		// if the flag for generating is till on, check if you can turn it off, if so, turn it off and add 1 to the food counter.

				if (food_gen_done) begin

					food_count_out[gen_food] <= food_count_in[gen_food] + 1;
					food_gen_flag 				 <= 0;
					gen_food     				 <= air;
				end

			end
		
		
		
			// ---- takes care of reducing the amount when food was eaten only once it was drawn on screen ----
			
			else if ( (eaten_food != air) ) begin
			
				food_count_out[eaten_food] <= food_count_in[eaten_food] - 1;
				time_soft_reset 				<= 1; 										// make sure that all generation are generated at a consistant time frame
				
			end

		
		
		
		
			else begin
				
				// ------ setting up priorities for generation first ------
				
						// ---- menual mushroom - first ----
					if ( (game_active) && (food_count_in [mushroom] == 8'd0) && (gen_mushroom_req) ) begin									
						
									gen_food							<= mushroom;
									food_gen_flag					<= 1;
									time_soft_reset 				<= 1; 																		
									fsm								<= mushroom_state;
					end
					
					
						// ---- automatic apple - second ----
					else if ( (game_active_1_sec) && (food_count_in [red_apple] == 8'd0) ) begin		// game active=3'd2, 2 sec, 000 apple, 000 ham
					
									gen_food							<= red_apple;
									food_gen_flag					<= 1;
									time_soft_reset 				<= 1; 												// reset timer befor hopping
									fsm								<= apple_state;
					end
				
				
				
				
				
				// ------ choose what to generate if non of the priorities were needed ------	
				
					else begin
					
						case (fsm) 	
									
								// -------------------------------------------------------------------------------------------------------------
								default: begin 
								
											time_soft_reset 		<= 0; 				// don't reset the timer when not in a state
											mushroom_time_reset	<= 0;
											food_count_out			<= 0;
											gen_food					<= air;
											food_gen_flag			<= 0;
											fsm 						<= idel_state;
								end // ------------------------- END OF DEFUALT -------------------------------------------------------------
					
					
					
					
							  /* --------------------------------------------------------------------------------------------------------------							
								▄▄ ▄▄▄▄  ▄▄▄▄▄ ▄▄    
								██ ██▀██ ██▄▄  ██    
								██ ████▀ ██▄▄▄ ██▄▄▄ 
																 
								------------------------------------------------------------------------------------------------------------- */
								idel_state: begin
											
											if (game_state == start) begin 																					// if game is NOT active (= start)
															gen_food 				<= air;
															food_gen_flag			<= 0;
															time_soft_reset 		<= 1; 																		// reset timer befor hopping 
															fsm 						<= idel_state;
											end

								end // ------------------------- END OF IDEL -------------------------------------------------------------
								
									
									
									
									
									
								/* -------------------------------------------------------------------------------------------------------------					                                                                                              
								 ▄▄▄  ▄▄▄▄  ▄▄▄▄  ▄▄    ▄▄▄▄▄        ▄▄▄▄ ▄▄▄▄▄▄ ▄▄▄ ▄▄▄▄▄▄ ▄▄▄▄▄ 
								██▀██ ██▄█▀ ██▄█▀ ██    ██▄▄        ███▄▄   ██  ██▀██  ██   ██▄▄  
								██▀██ ██    ██    ██▄▄▄ ██▄▄▄ ▄▄▄▄▄ ▄▄██▀   ██  ██▀██  ██   ██▄▄▄                                               
								------------------------------------------------------------------------------------------------------------- */	
								// Guiding order of generation: Apple --> Mushroom --> Hamburger
								
								apple_state: begin
										
										
											// ---- add a mushroom ---- 
										if ( (game_active) && (mushroom_cond) && (food_count_in [mushroom] == 8'd0) ) begin									
											
														gen_food							<= mushroom;
														food_gen_flag					<= 1;
														time_soft_reset 				<= 1;
														mushroom_time_reset			<= 1;
														fsm								<= mushroom_state;
										end
										
										
											// ---- add a hamburger ----	
										else if ( (game_active_1_sec) && (food_count_in [hamburger] < 8'd5) ) begin			
												
												gen_food							<= hamburger;
												food_gen_flag					<= 1;
												time_soft_reset 				<= 1; 															// reset timer befor hopping 
												fsm								<= ham_state;
												
										end 
										
										
										
										// ---- add nothing, you are full! ----
										else if ( (game_active_1_sec) && (food_count_in [hamburger] == 8'd5) ) begin			
												
												gen_food							<= air;
												time_soft_reset 				<= 1; 															// reset timer befor hopping 
												fsm								<= full_state;
												
										end 
									
										
										
											// ---- do again this state without generating anything ---- 
										else if (game_active_2_sec) begin																	
										
											time_soft_reset 	<= 1;
											fsm					<= mushroom_state;
										
										end 


											
								end // ------------------------- END OF RED_APPLE -------------------------------------------------------------
				
				
				
				
				
				
				
								/* -------------------------------------------------------------------------------------------------------------					                                                  
								▄▄ ▄▄  ▄▄▄  ▄▄   ▄▄        ▄▄▄▄ ▄▄▄▄▄▄ ▄▄▄ ▄▄▄▄▄▄ ▄▄▄▄▄ 
								██▄██ ██▀██ ██▀▄▀██       ███▄▄   ██  ██▀██  ██   ██▄▄  
								██ ██ ██▀██ ██   ██ ▄▄▄▄▄ ▄▄██▀   ██  ██▀██  ██   ██▄▄▄                                     
								------------------------------------------------------------------------------------------------------------- */
								// Guiding order of generation: Apple --> Mushroom --> Hamburger
								
								ham_state: begin
										
										
											// ---- same as in apple state ----
										if ( (game_active) && (mushroom_cond) && (food_count_in [mushroom] == 8'd0) ) begin									
											
														gen_food							<= mushroom;
														food_gen_flag					<= 1;
														time_soft_reset 				<= 1;
														mushroom_time_reset			<= 1;
														fsm								<= mushroom_state;
										end
										
									
									
											// ---- need to make sure all the conditions are necessery, maybe can be the same like in apple ----
										else if ( 	(game_active) && (time_counter >= 8'd2) && (!time_soft_reset) &&
														(food_count_in [hamburger] <= 8'd4) && (food_count_in [hamburger] >= 8'd0) 	) begin	
													
														gen_food							<= hamburger;
														food_gen_flag					<= 1;
														time_soft_reset 				<= 1; 																				// reset timer befor hopping 
														fsm								<= ham_state;	
										end
										
										
										
										
											// ---- same as in apple state ----
										else if ( (game_active_1_sec) && (food_count_in [hamburger] == 8'd5) ) begin			
												
												gen_food							<= air;
												time_soft_reset 				<= 1; 																						// reset timer befor hopping 
												fsm								<= full_state;
												
										end 
							
				

										
											
								end // ------------------------- END OF HAMBURGER -------------------------------------------------------------
				
				
				
				
				
				
				
								/* ------------------------------------------------------------------------------------------------------------																				
								▄▄▄▄▄ ▄▄ ▄▄ ▄▄    ▄▄           ▄▄▄▄ ▄▄▄▄▄▄ ▄▄▄ ▄▄▄▄▄▄ ▄▄▄▄▄ 
								██▄▄  ██ ██ ██    ██          ███▄▄   ██  ██▀██  ██   ██▄▄  
								██    ▀███▀ ██▄▄▄ ██▄▄▄ ▄▄▄▄▄ ▄▄██▀   ██  ██▀██  ██   ██▄▄▄ 																														 
								------------------------------------------------------------------------------------------------------------- */
								// Guiding order of generation: Apple --> Mushroom --> Hamburger
								

								full_state: begin
									
										
											// ---- same as in apple state ----
										if ( (game_active) && (mushroom_cond) && (food_count_in [mushroom] == 8'd0) ) begin									
											
														gen_food							<= mushroom;
														food_gen_flag					<= 1;
														time_soft_reset 				<= 1;
														mushroom_time_reset			<= 1;
														fsm								<= mushroom_state;
											
										end
										
										
										
										
											// ---- same as in apple state ----	
										else if ( (game_active_1_sec) && (food_count_in [hamburger] < 8'd5) ) begin			
												
														gen_food							<= hamburger;
														food_gen_flag					<= 1;
														time_soft_reset 				<= 1; 													// reset timer befor hopping 
														fsm								<= ham_state;
												
										end 
										
										
										
										
											// ---- same as in apple state ----
										else if ( (game_active_1_sec) && (food_count_in [hamburger] == 8'd5) ) begin			
												
												gen_food							<= air;
												time_soft_reset 				<= 1; 															// reset timer befor hopping 
												fsm								<= full_state;
												
										end
										
										
										
										
											// ---- reset time to not get stuck here ----
										else if (game_active_2_sec) begin 
											
											time_soft_reset <= 1; 
											
										end
										
										
												
								end // ------------------------- END OF FULL -------------------------------------------------------------
									
							
								
								
								
								
						
								/* -------------------------------------------------------------------------------------------------------------					                                                                                                          
								▄▄   ▄▄ ▄▄ ▄▄  ▄▄▄▄ ▄▄ ▄▄ ▄▄▄▄   ▄▄▄   ▄▄▄  ▄▄   ▄▄        ▄▄▄▄ ▄▄▄▄▄▄ ▄▄▄ ▄▄▄▄▄▄ ▄▄▄▄▄ 
								██▀▄▀██ ██ ██ ███▄▄ ██▄██ ██▄█▄ ██▀██ ██▀██ ██▀▄▀██       ███▄▄   ██  ██▀██  ██   ██▄▄  
								██   ██ ▀███▀ ▄▄██▀ ██ ██ ██ ██ ▀███▀ ▀███▀ ██   ██ ▄▄▄▄▄ ▄▄██▀   ██  ██▀██  ██   ██▄▄▄                                                                                                      
								------------------------------------------------------------------------------------------------------------- */
								mushroom_state: begin
										
										
											// ---- same as in apple state ----
										if ( (game_active) && (mushroom_cond) && (food_count_in [mushroom] == 8'd0) ) begin									
											
														gen_food							<= mushroom;
														food_gen_flag					<= 1;
														time_soft_reset 				<= 1;
														mushroom_time_reset			<= 1;
														fsm								<= mushroom_state;
											
										end
										
										
										
																			
											// ---- same as in apple state ----	
										else if ( (game_active_1_sec) && (food_count_in [hamburger] < 8'd5) ) begin			
												
														gen_food							<= hamburger;
														food_gen_flag					<= 1;
														time_soft_reset 				<= 1; 													// reset timer befor hopping 
														fsm								<= ham_state;
												
										end 
										
										
										
										
											// ---- same as in apple state ----
										else if ( (game_active_1_sec) && (food_count_in [hamburger] == 8'd5) ) begin			
												
												gen_food							<= air;
												time_soft_reset 				<= 1; 															// reset timer befor hopping 
												fsm								<= full_state;
												
										end
										
										
										
											
								end // ------------------------- END OF MUSHROOM -------------------------------------------------------------
				




						endcase // end the case
						
				end 	// end else of case
			
			end	// end else - eaten air
			
		end	// end else - syncrenized
	 
	 end
 
 
 
 
 
 
 endmodule
 
 

                                                                             