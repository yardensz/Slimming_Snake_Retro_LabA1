// (c) Technion IIT, Department of Electrical Engineering 2020 

// Implements a slow clock as an 1/100 second counter
// Turbo input sets output 10 times faster
// Updated by Mor Dahan - January 2022
// Updated by Dudy BarOn - march  2025
 
 module Mili_sec_counter      	
	(
   // Input, Output Ports
	input  logic clk, 
	input  logic resetN, 
	input  logic turbo,
	
	output logic hundredth_sec
   );
	
	int hundredthSecCount ;
	int hundredthSec ;		 // gets either hundredth seccond or Turbo top value

parameter logic SIMULATION_MODE  = 1'b1 ;  
parameter  mSecPerTick 				= 10 ;  
parameter  PLLClock  				= 315 ;  
	
//       ----------------------------------------------	counter limit setting
	localparam hundredthSecVal_REAL = 32'd100 * PLLClock * mSecPerTick; // for DE10 board 
	localparam hundredthSecVal_SIM = 32'd20; // for quartus simulation 
	localparam hundredthSecVal = SIMULATION_MODE ? hundredthSecVal_SIM : hundredthSecVal_REAL ; //select what to use 
//       ----------------------------------------------	
	
	assign  hundredthSec = turbo ? hundredthSecVal/10 : hundredthSecVal;  // it is valid to devide by 10, as it is done by the complier not by logic (actual transistors) 

	
   always_ff @( posedge clk or negedge resetN )
   begin
	
		// asynchronous reset
		if ( !resetN ) begin
			hundredth_sec 		<= 1'b0;
			hundredthSecCount <= 32'd0;
		end // if reset
		
		// executed once every clock 	
		else begin
			if (hundredthSecCount >= hundredthSec) begin
				hundredth_sec 		<= 1'b1;
				hundredthSecCount <= 0;
			end
			else begin
				hundredthSecCount <= hundredthSecCount + 1;
				hundredth_sec		<= 1'b0;
			end
		end // else clk
		
	end // always
	
endmodule