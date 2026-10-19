//made by yinon

module clock_divider (
	input	logic	clk,
	input logic resetN,
	
	input logic start_of_frame_pulse,
	output logic divided_pulse
	);

	
	logic sof_d;
	logic [1: 0] count;
	
	assign divided_pulse = ((count == 2'd3) && start_of_frame_pulse && !sof_d) ;
	
	always_ff@(posedge clk or negedge resetN)
		begin	
			if(!resetN) begin
				count <=	0;
				sof_d <= 0;
				end
			else 
			begin if (!sof_d && start_of_frame_pulse) begin
				if (count < 2'd3) 
						count <= count + 1;
					else 
						count <= 0;
				end
				
				sof_d <= start_of_frame_pulse;
			end // else
			
		end// alwaysff
endmodule	







