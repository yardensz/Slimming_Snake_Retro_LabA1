import custom_types::*;

module snake_tail #(
	parameter logic [5:0] INIT_TAIL_X = 6'd5,
	parameter logic [4:0] INIT_TAIL_Y = 5'd6
) (
	input logic clk,
	input logic resetN,
	input logic man_reset,
	
	input logic move_pulse,
	input logic moving,
	input logic head_is_moving,
	input logic ate_fat,
	
	// Tile read from snake_matrix (4-bit logic so no enum typecast is needed)
	input logic [3:0] next_tile,
	
	// Outputs to snake_management_unit to index snake_matrix[moved_tail_y][moved_tail_x]
	output logic [4:0] moved_tail_y,
	output logic [5:0] moved_tail_x,
	
	// Outputs to the DRAW module
	output logic [4:0] draw_tail_y,
	output logic [5:0] draw_tail_x,
	output logic [4:0] delete_prev_tail_y,
	output logic [5:0] delete_prev_tail_x,
	output snakepart   draw_tail
);

	// Calculate moved_tail_x/y based on current tail direction
	always_comb begin
		moved_tail_x = draw_tail_x;
		moved_tail_y = draw_tail_y;
		
		case (draw_tail)
			tail_up:   moved_tail_y = draw_tail_y - 5'd1;
			tail_down: moved_tail_y = draw_tail_y + 5'd1;
			tail_left: moved_tail_x = draw_tail_x - 6'd1;
			default:   moved_tail_x = draw_tail_x + 6'd1; // tail_right
		endcase
	end

	always_ff @(posedge clk or negedge resetN) begin
		if (!resetN) begin
			draw_tail          <= tail_right;
			draw_tail_x        <= INIT_TAIL_X;
			draw_tail_y        <= INIT_TAIL_Y;
			delete_prev_tail_x <= INIT_TAIL_X - 6'd1;
			delete_prev_tail_y <= INIT_TAIL_Y;
		end 
		else if (man_reset) begin
			draw_tail          <= tail_right;
			draw_tail_x        <= INIT_TAIL_X;
			draw_tail_y        <= INIT_TAIL_Y;
			delete_prev_tail_x <= INIT_TAIL_X - 6'd1;
			delete_prev_tail_y <= INIT_TAIL_Y;
		end 
		else if (move_pulse && (moving || head_is_moving)) begin
			if (!ate_fat) begin
				case ({draw_tail, next_tile})
					{tail_right, turn2}, {tail_left, turn1}: draw_tail <= tail_up;
					{tail_right, turn3}, {tail_left, turn4}: draw_tail <= tail_down;
					{tail_up,    turn3}, {tail_down, turn2}: draw_tail <= tail_left;
					{tail_up,    turn4}, {tail_down, turn1}: draw_tail <= tail_right;
					default: ;
				endcase

				draw_tail_x        <= moved_tail_x;
				draw_tail_y        <= moved_tail_y;

				delete_prev_tail_y <= draw_tail_y;
				delete_prev_tail_x <= draw_tail_x;
			end
		end
	end

endmodule