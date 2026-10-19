// (c) Technion IIT, Department of Electrical Engineering 2025 
module random 	
 ( 
	input	logic  clk,
	input	logic  resetN, 
	input	logic	 rise,
	output logic unsigned [SIZE_BITS-1:0] dout	
  ) ;

// Generating a random number by latching a fast counter with the rising edge of an input ( e.g. key pressed )
  
parameter SIZE_BITS = 8;
parameter unsigned [SIZE_BITS-1:0] MIN_VAL = 0;  //set the min and max values 
parameter unsigned [SIZE_BITS-1:0] MAX_VAL = 255;

	logic unsigned  [SIZE_BITS-1:0] counter/* synthesis keep = 1 */;
	logic rise_d /* synthesis keep = 1 */;
	
	
always_ff @(posedge clk or negedge resetN) begin
		if (!resetN) begin
			dout <= (MAX_VAL+MIN_VAL)>>1;  //  divide by 2
			counter <= MIN_VAL;
			rise_d <= 1'b0;
		end
		
		else begin
			counter <= counter+SIZE_BITS'(1);
			if ( counter >= MAX_VAL ) // the +1 is done on the next clock 
				counter <=  MIN_VAL ; // set min and max mvalues 
			rise_d <= rise;
			if (rise && !rise_d) // rising edge 
				dout <= counter;
		end
	
	end
 
endmodule

