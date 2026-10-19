package custom_types;

    typedef enum logic [3:0] {
	 
		nothing,
		
		head_up, head_down, head_left, head_right,
		
		tail_up, tail_down, tail_left, tail_right,
		
		turn1, turn2, turn3, turn4, 		// turns are like graph quadrants: 	2 | 1
													//												--+--
		body_horizontal, body_vertical	//												3 | 4
		
    } snakepart;
	 
	 
	 
	 typedef enum logic [2:0] {
	 start = 3'd0, lvl1 = 3'd1, lvl2 = 3'd2, lvl3 = 3'd3, victory = 3'd5,
	 game_over = 3'd7
	 } gamestate;
	 
	 
endpackage