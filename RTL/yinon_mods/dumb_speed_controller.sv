module dumb_speed_controller
#(parameter  logic [7:0] speed_value= 8'h0f)
	(			
	input	logic	clk,
	input logic resetN,
	input logic start_of_frame,

	output logic divided_pulse // return a pulse every 16 times
	);


	
	logic sof_d;
	logic sof_posedge;
	logic [7: 0] count;
	
	assign sof_posedge = start_of_frame && !sof_d;
	assign divided_pulse = ((count == speed_value) && sof_posedge) ;
	
	always_ff@(posedge clk or negedge resetN)
		begin	
			if(!resetN) begin
				count <=	0;
				sof_d <= 0;
				end
				
			else begin
			
			if(sof_posedge)
				count <= (count >= speed_value) ? 1 : count + 1;				
			sof_d <= start_of_frame;
			
			
				
			end // resetN else
		end// alwaysff
endmodule	