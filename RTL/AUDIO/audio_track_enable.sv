


module audio_track_enable
	
 (  
	input logic 			clk,
	input logic 			resetN,
	input logic				soft_reset,
	input logic	[13:0]	time_counter,		// in tenth of a second			
	input logic [3:0]		audio_selector,

	
   output logic 			enable_track,		// decides to enable or disable a track
	output logic 			zero_counter		// 0 - don't zero, 1 - zero the counter
	
  ) ;
  
 
 
 
 logic [13:0] 	time_limit; 	// the amount of time (in 0.1 sec incraments) for enable to be ON
	
 logic 			enable_track_d;
	
	
	
	
	
	always_ff @(posedge clk or negedge resetN) begin

       if (!resetN) begin
            
				enable_track 	<= 0;
				zero_counter	<= 0;
       end
		 
		 
		 
		 
		else begin
		
				/*
					Order of selection:
						Game-over 						- 0
						Start menu 						- 1
						next level 						- 2
						Mushroom eaten 				- 3
						Food was eaten 				- 4
						background music 				- 5
						
						death 							- 14
						default/reset/soft reset 	- 15
				*/
				
				
				
				// ---- Default values ---- 
				time_limit <= 0;
				
				
			// ---- selecting the amount of time enable will be ON ----
			
				if 		(soft_reset) 															time_limit <= 0;		// 
				
				else if 	( (audio_selector == 4'd0) || (audio_selector == 4'd1) )	time_limit <= 300;	// count to 30 sec
				
				else if 	(audio_selector 	== 4'd2)											time_limit <= 5;		// count to 0.5 sec
				
				else if 	(audio_selector 	== 4'd3)											time_limit <= 50;		// count to 0.5 sec
				
				else if 	(audio_selector 	== 4'd4)											time_limit <= 5;		// count to 0.5 sec
				
				else if 	(audio_selector 	== 4'd14)										time_limit <= 10;		// count to 1 sec

				else if 	(audio_selector	== 4'd15)										time_limit <= 0;		// count to 00000
				
				
				
				
				
				
				
			// ---- selecting according to the timer state of ENABLE ---- 
				
				if 		(time_limit == 0) 				enable_track <= 1;	// when reset or when default 
				
				else if 	(time_counter <= time_limit) 	enable_track <= 1;	// when timer is still going			
					
				else 												enable_track <= 0;	// when time is up
		
		
				
				
				
				
			// ---- reseting the timer ----
				
				enable_track_d <= enable_track;
				
				
				if (enable_track_d && !enable_track) 	zero_counter <= 0;	// if enable has fallen to 0, then zero the counter
				else 												zero_counter <= 1;
				
				
				
				
		end // end of "else resetN"
		
	end // end always_ff
 
 
 



endmodule


















