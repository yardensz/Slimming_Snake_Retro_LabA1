module speed_controller(
	input	logic	clk,
	input logic resetN,
	input logic start_of_frame,
	input logic slowmo_sw, // switch to slow motion
	input logic [15:0] snake_length,
	input logic enable,
	input logic [2:0] lvl_start,
	
	output logic [15:0] speed_value, // connect to any seven seg display
	output logic divided_pulse // return a pulse every *speed_value* time
);
	parameter logic [15:0] SLOWMO_SPEED = 60;
	parameter logic [7:0]  START_DELAY_FRAMES = 60; // 1 second delay

	logic sof_d, sof_posedge;
	logic [15: 0] count;
	logic [7:0] starting_delay_count;
	
	
	assign sof_posedge = start_of_frame && !sof_d;
	
	assign divided_pulse = enable && ((count >= speed_value) && sof_posedge && (starting_delay_count == 0)) ;
	
	assign speed_value = slowmo_sw ? SLOWMO_SPEED : 16'd12 + (snake_length >> 2);   
	
	//assign divided_pulse = button_posedge;
	
	always_ff@(posedge clk or negedge resetN)
		begin	
			if(!resetN) begin
				count <=	0;
				sof_d <= 0;
				starting_delay_count <= 0;
			end
			else begin
				
				sof_d <= start_of_frame;
				
				if(|lvl_start) begin
						count <= 0;
						starting_delay_count <= START_DELAY_FRAMES;
					end
			
				else if(sof_posedge) begin
				
						if (starting_delay_count > 0) begin
							starting_delay_count <= starting_delay_count - 1;
							
							// Pre-load the count so the pulse fires immediately on the next frame
							if (starting_delay_count == 8'd1) begin
								count <= speed_value;
							end else begin
								count <= 0;
							end
						end 
					else begin
						// Standard counting operation when no delay is active
						count <= (count >= speed_value) ? 1 : count + 1;
					end
				end//sof else
				
			end // resetN else
			
			
			
			
		end// alwaysff
		
endmodule	























