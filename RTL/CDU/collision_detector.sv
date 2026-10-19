

// Collision Detection Unit (CDU) - 16.7.26




import packaged_food ::* ; // import all types of foods 



module	collision_detector	(	
					input	logic					clk,
					input	logic					resetN,	
					
					input logic 				food_draw_req,			// for food that already has been on screen
					input logic 				snake_draw_req,		// for the snake itself (body and tail, without head)
					input logic 				rand_draw_req,			// for random food placment
					input logic 				head_draw_req,			// for snake's head (snake_draw is not including the head)

					
					input logic 				[987:0] flat_food_matrix,		// NEW 1D Flat Bus Output (13 * 19 * 4 = 988)
					input logic 				[5:0] snake_head_x ,
					input logic 				[4:0] snake_head_y,

					
					
					output logic				food_collision,		// the snake eat something
					output logic				snake_collision,		// the snake hit himself
					output logic				rand_collision,		// the request of drawing random food item - has denied!
					
					output food_option		eaten_food				// the food the snake just eat
					
 );
 

 
 
 logic food_collision_cond ;
 logic snake_collision_cond;
 logic rand_collision_cond ;
 
 assign food_collision_cond 	= (food_draw_req && head_draw_req); 								// 1 for there is a collision.
 assign snake_collision_cond 	= (head_draw_req && snake_draw_req);								// collision of snake body with its head.
 assign rand_collision_cond 	= ( (food_draw_req || snake_draw_req) && rand_draw_req );	// random food is in a collision with snake's body or with another food
 
 logic [0:12][0:18][3:0]  food_matrix;
 assign food_matrix = flat_food_matrix;
 
 
 
 always_ff@(posedge clk or negedge resetN) begin

	if(!resetN) begin
		
		rand_collision 	<= 0;
		food_collision 	<= 0;
		snake_collision 	<= 0;
		eaten_food			<= air;

	end
	
	
	else begin
		
		rand_collision 	<= (rand_collision_cond); 	// if there were a collision, output 1 (BTW the bracets are on purpose) 
		food_collision 	<= (food_collision_cond); 
		snake_collision 	<= (snake_collision_cond); 
		
		
		eaten_food <= air;

		if (food_collision_cond && !food_collision)
			 eaten_food <= food_option'(food_matrix[snake_head_y][snake_head_x]); // return the eaten food type, food_option is to turn the matrix value into a food type by name.
				
		
	end
 
 end
 
 
 
 
 endmodule 
 
 
 
 
 
 
 
 
 
 
 