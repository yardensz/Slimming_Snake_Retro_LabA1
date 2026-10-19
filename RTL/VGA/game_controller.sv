import custom_types::*;

module game_controller (
    input logic clk, resetN,
    input logic [15:0] length,
    input logic death_condition, // Added to trigger game_over
    input logic action_btn,      // Added to transition out of start/victory/game_over
	 input logic next_lvl_cheat_button,
	 
	 input logic start_of_frame,
	 
	 input logic shroom_eaten,
	 
    output gamestate game_fsm,
	
	 output logic game_active_flag, //1 iff in level 1,2,3 aka the actual game is active and not some screen
	 output logic [3:0] end_of_lvl,
	 output logic a_lvl_has_started_d,
	 
	 output logic soft_reset,
	 
	 output logic shroom_mode
	 
);

	localparam logic [7:0] shroom_time_seconds = 6; 		// Yarden changed from 5 to 6 (you can delete it now)
	
	localparam logic [7:0] fps = 60; 
	logic [15:0] shroom_counter;
	
	assign shroom_mode = (shroom_counter != 0);
	logic  a_lvl_has_started;
	assign a_lvl_has_started = |end_of_lvl[2:0];
	assign soft_reset = (game_fsm == start);
			
			
	 logic delayed_next_lvl_cheat_button, delayed_action_btn;
	 
	 
	 assign skip_lvl_cond = delayed_next_lvl_cheat_button && !next_lvl_cheat_button  //activate on button release
									|| ((length == 16'd2) && !(|end_of_lvl)) ;													//OR when length is 2
									
	 assign action_button_cond = delayed_action_btn && !action_btn;
    
	 assign game_active_flag = (game_fsm == lvl1) || ( game_fsm == lvl2) || ( game_fsm == lvl3);
	 
	 always_ff @(posedge clk or negedge resetN) begin
        if (!resetN) begin
				shroom_counter <= 0;
				a_lvl_has_started_d <= 0;//only here to solve vierd bug
            game_fsm <= start;
				delayed_next_lvl_cheat_button <= 1'b0;
				delayed_action_btn <= 1'b0;
				end_of_lvl <= 4'h0;
			
        end
        else begin
		  
				end_of_lvl <= 4'h0;
				a_lvl_has_started_d <= a_lvl_has_started;
				delayed_next_lvl_cheat_button <= next_lvl_cheat_button;
				delayed_action_btn <= action_btn ;
		  
            case (game_fsm)
                start: begin
                    // Wait for a user input to begin the game
                    if (action_button_cond)
								begin
									game_fsm <= lvl1;
									end_of_lvl[0] <= 1'b1;
								end
                end

                lvl1: begin
                    if (death_condition)
                        game_fsm <= game_over;
                    else if (skip_lvl_cond)
								begin
									game_fsm <= lvl2;
									end_of_lvl[1] <= 1'b1;
								end
                end

                lvl2: begin
                    if (death_condition)
                        game_fsm <= game_over;
                    else if (skip_lvl_cond)
                        begin
									game_fsm <= lvl3;
									end_of_lvl[2] <= 1'b1;
								end
                end

                lvl3: begin
                    if (death_condition)
                        game_fsm <= game_over;
                    else if (skip_lvl_cond)
							begin
								game_fsm <= victory;
								end_of_lvl[3] <= 1'b1;
							end
                    
                end

                victory: begin
                    // Wait for user input to return to the start screen
                    if (action_button_cond)
                        game_fsm <= start;
                end

                game_over: begin
                    // Wait for user input to restart after dying
                    if (action_button_cond)
                        game_fsm <= start;
                end

                default: game_fsm <= start;
            endcase
				
				
				//-----shroom logic---------
				
				if (game_fsm == start || game_fsm == game_over || game_fsm == victory) begin
                shroom_counter <= 16'd0;
            end
					else
				if (start_of_frame)
					begin
						if(shroom_eaten)
							shroom_counter <= fps * shroom_time_seconds;
						else if
							(shroom_counter != 0)
								shroom_counter <= shroom_counter -1;
							
					
					
					end
				
        end
    end

endmodule


