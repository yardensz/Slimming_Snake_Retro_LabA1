// (c) Technion IIT, Department of Electrical Engineering 2021
// SystemVerilog version Alex Grinshpun May 2018
// up counter 
module	addr_counter	 #(
					COUNT_SIZE = 8
		)
	
		(	
//		--////////////////////	Clock Input	 	////////////////////	
					input		logic	clk,
					input		logic	resetN,
					input		logic	en, 		//two enables one for a "slow clock" 
					input		logic	en1, 		// one for external disable 
					input		logic	en2,		// mute switch
					
					output	logic [COUNT_SIZE-1:0]	addr // sin table index 

		);



logic [COUNT_SIZE-1:0] count_limit = {COUNT_SIZE{1'b1}};
//
always_ff@(posedge clk or negedge resetN)
begin
	if(!resetN)
	begin
		addr	<= 0;
	end
	else if (en == 1'b1 && en1 == 1'b1 && en2 == 1'b1 ) begin
				if (addr >= count_limit)  // overflow 
					addr <= COUNT_SIZE'(0);
				else 
					addr <= addr + COUNT_SIZE'(1);
			end

end
endmodule

