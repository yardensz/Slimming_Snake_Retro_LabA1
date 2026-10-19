module random_v4
	
 #(
	parameter SIZE_BITS = 8,
	parameter unsigned [SIZE_BITS-1:0] 	MIN_VAL	= 0,  //set the min and max values 
	parameter unsigned [SIZE_BITS-1:0] 	MAX_VAL	= 255,
	parameter unsigned [1:0]				MODE		= 1	// the mode that the rand inst will work in (making Random less predictable) 

  )

 ( 
	input	logic  									clk,
	input	logic  									resetN, 
	input logic 									random_effect,			// the human element that makes this module to be "turely random"
	input logic 									rand_enable,			// allows the user to choose when to activate the module (or the rand function)

	
	
	output logic unsigned [SIZE_BITS-1:0] 	rand_pos,
	output logic 									rand_valid	
  ) ;

// Generating a random number by latching a fast counter with the rising edge of an input ( e.g. key pressed )
  

	logic unsigned  [SIZE_BITS-1:0] counter; /* synthesis keep = 1 */
	logic rise_d; /* synthesis keep = 1 */
	logic [3:0] mode_calc;	// the calculation we do in order to make Rand inst different from each other (so they are unsyncronized)
	logic time_rand_req_d;	// flag for time passed, taking a pulse as a 
	
	assign mode_calc = ( ( (2 + MODE) ^ MODE ) - MODE ); // complicated enough to make it "random", max value is: (2+3)^2 - 3 = 22    => 4 bits
	
	/* 
	2+0)^2 - 0 = 4
	2+1)^2 - 1 = 8
	2+2)^2 - 2 = 14
	2+3)^2 - 3 = 22
	*/
	
always_ff @(posedge clk or negedge resetN) begin
		if (!resetN) begin
			rand_pos 		<= (MAX_VAL+MIN_VAL)>>1;  //  divide by 2
			counter 			<= MIN_VAL;
			rise_d			<= 1'b0;
			rand_valid 		<= 1'b0;
		end
		
		else begin
		
			if ( counter < MAX_VAL ) counter <= counter + 1; // count quickly up to the top number
			else counter <= MIN_VAL;			
			
			
			rise_d 			<= random_effect;
			rand_valid 		<= 1'b0;

			
			if (rand_enable && random_effect && !rise_d) begin
				 rand_pos   	<= counter;
				 rand_valid	 	<= 1'b1;
			end
				

		end
	
	end
 
endmodule

