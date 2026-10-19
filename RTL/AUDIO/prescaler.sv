/// (c) Technion IIT, Department of Electrical Engineering 2021 
//-- This module is dividing the 50MHz CLOCK OSC, and sends clock
//-- enable it to the appropriate outputs in order to achieve
//-- operation at slower rate of individual modules (this is done
//-- to keep the whole system globally synchronous).
//-- All DACs output are set to 100 KHz. 

//-- Alex Grinshpun Apr 2017
//-- Dudy Nov 13 2017
// SystemVerilog version Alex Grinshpun May 2018

module	prescaler	(	
//		--////////////////////	Clock Input	 	////////////////////	
					input		logic	clk,
					input		logic	resetN,
					input		logic [11:0]	preScaleValue,
					output	logic	slowEnPulse, 
					output	logic	slowEnPulse_d // a delayed enalbe to avoid read and write DPRAM at the same time 

		);

int	counter;


always_ff@(posedge clk or negedge resetN)
begin
	if(!resetN)
	begin
			counter	<= 12'b0;
			slowEnPulse			<= 1'b0;
			slowEnPulse_d		<= 1'b0;
	end
	else
	begin
		slowEnPulse_d	<=	slowEnPulse; // 1 clk delay
		if (counter >= preScaleValue) begin
				counter        <= 12'b0;
				slowEnPulse		<= 1'b1;
		end
		else begin
				counter <= counter + 1'b1;
				slowEnPulse			<= 1'b0;
		end
				
	end
end
endmodule
