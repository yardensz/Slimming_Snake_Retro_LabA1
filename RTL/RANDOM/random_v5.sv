module random_v5
	
 #(
	parameter SIZE_BITS = 8,
	parameter unsigned 							HASH_SHIFT	= 5,		// in the hash function, set a constand number to be used
	parameter unsigned 							HASH_MOD		= 19		// set % value for each hash functoin 
  )

  
 ( 
	input	logic  									 clk,
	input	logic  									 resetN, 
	input logic 									 random_effect,		// the human element that makes this module to be "turely random"
	input logic					[SIZE_BITS-1:0] min_count,
	input logic					[SIZE_BITS-1:0] max_count,
	input logic 				[SIZE_BITS-1:0] last_rand,
	input logic										 enable_hashing,		// when there isn't user input, hash function will start working.
	
	output logic 				[SIZE_BITS-1:0] new_rand,
	output logic unsigned 	[SIZE_BITS-1:0] rand_pos
  ) ;

// Generating a random number by latching a fast counter with the rising edge of an input ( e.g. key pressed )
  

	logic unsigned  	[SIZE_BITS-1:0] 	counter;
	logic 										rise_d;
	logic											enable_hashing_d;
	logic					[10:0] 				num_cycle;
	
	
	
	
	
always_ff @(posedge clk or negedge resetN) begin
		if (!resetN) begin
			rand_pos 		<= 1; 				// instead of deviding by 2
			counter 			<= min_count;
			rise_d			<= 1'b0;
			num_cycle		<= 0;
		end
		
		
		else begin
		
			new_rand <= last_rand;										// unless there was an update, keep the old one
			
			
			// --- Quick counter ---
			if (counter < max_count) 	counter <= counter + 1; 
			else 								counter <= min_count;			
			
			
			//
			rise_d 				<= random_effect;
			
			
			
			// --- Taking "random" value from counter ---
			if (random_effect && !rise_d) begin
				 rand_pos	<= counter;
				 new_rand	<= counter;				// updats new_rand
				 num_cycle	<= 11'd2;				// first run with user input (changed from 1->2 for testing)
			end
			
			
			
			else if (enable_hashing) begin 	// deleted part: "&& !enable_hashing_d"
				
				rand_pos 	<= (last_rand + (num_cycle * HASH_SHIFT) ) % HASH_MOD; // Hash function: Xn = (X0 + n*SHIFT) % MOD
				num_cycle	<= num_cycle + 1;
				
			end
				

		end
	
	end
 
endmodule





















