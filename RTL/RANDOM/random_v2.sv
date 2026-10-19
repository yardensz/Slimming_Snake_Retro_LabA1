// (c) Technion IIT, Department of Electrical Engineering 2025 
module random_v2 
	
 #(
	parameter SIZE_BITS = 8,
	parameter unsigned [SIZE_BITS-1:0] MIN_VAL = 0,  //set the min and max values 
	parameter unsigned [SIZE_BITS-1:0] MAX_VAL = 255
  )

 ( 
	input	logic  clk,
	input	logic  resetN, 
	input	logic	 rand_req,				// asking to generate, this arrives from food_controller.
	
	input	logic rand_collision, 		// collision happened and we need to pick a new random position.
	input logic random_effect,			// the human element that makes this module to be "turely random"
	
	output logic unsigned [SIZE_BITS-1:0] rand_pos	
  ) ;

// Generating a random number by latching a fast counter with the rising edge of an input ( e.g. key pressed )
  

	logic unsigned  [SIZE_BITS-1:0] counter; /* synthesis keep = 1 */
	logic rise_d; /* synthesis keep = 1 */
	logic rise_rand_req;
	
	assign rise_rand_req = (rand_collision || rand_req);
	
	
	
always_ff @(posedge clk or negedge resetN) begin
		if (!resetN) begin
			rand_pos <= (MAX_VAL+MIN_VAL)>>1;  //  divide by 2
			counter <= MIN_VAL;
			rise_d <= 1'b0;
		end
		
		else begin
			counter <= counter+SIZE_BITS'(1);
			if ( counter >= MAX_VAL ) counter <=  MIN_VAL ; // set min and max mvalues 
			
			rise_d <= random_effect;
			
			if (rise_rand_req && rise_d) rand_pos <= counter;// rising edge // 
				
		end
	
	end
 
endmodule

