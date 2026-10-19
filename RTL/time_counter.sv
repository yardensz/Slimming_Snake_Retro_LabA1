module time_counter
	
#(
	parameter unsigned SIZE_BITS = 8	;								// the number of bits needed to count
	parameter unsigned [SIZE_BITS-1:0] MAX_SEC_COUNT = 5  ;	//	how many seconds to count
	parameter unsigned BOARD_FREQ  = 50//000000   				// frequncy of D6 (50 Mhz) // set to 50 for sim 

  )

 ( 
	input	logic clk,
	input	logic resetN, 
	input logic	zero_count,
	

	output logic 						time_pulse, 	// reached the wanted amount of time
	output logic [SIZE_BITS-1:0] 	time_counter 	
	
  ) ;
  
  
  logic [25:0] 				clk_counter; 		// can count to 60M
  logic [SIZE_BITS-1:0] 	sec_counter; 		// can count upto 255 "seconds" with 8 bit ("" for sim, when it is not seconds really)
  
  assign time_counter = sec_counter;
  
  
  

	always_ff @(posedge clk or negedge resetN) begin
	
		if (!resetN) begin
			time_pulse 	<= 0;
			sec_counter <= 0;
			clk_counter <= 0;
		end															// end if reset
		
		
		
		else if (zero_count) begin								// soft reset of time counting (=syncrenized reset)
			
			time_pulse 	<= 0;
			sec_counter <= 0;
			clk_counter <= 0;
			
		end 															// end else if 
		
		
		
		else begin
		
			if (clk_counter < BOARD_FREQ - 1) begin				// converts clock to a second (only with 6D6, not in sim)
				clk_counter <= clk_counter + 1;
				time_pulse 	<= 0;
			end 
			
			
			else begin												// if we reached 1 sec, keep on counting or send a pulse
				clk_counter <= 0;

				if (sec_counter < MAX_SEC_COUNT) begin		// count seconds 
					sec_counter <= sec_counter + 1;
				end 
				
				
				else begin
					sec_counter <= 0;
					time_pulse 	<= 1;
				end

			end
			
			
			
		end															// end else reset 

	end 																// end alwaysff
  
 
 
endmodule

