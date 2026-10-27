import custom_types::*;

module snake_management_unit (
	input  logic               clk,
	input  logic               resetN,
	input  logic               game_tick, 
	input  logic               up_key,
	input  logic               down_key,
	input  logic               left_key,
	input  logic               right_key,
	input  logic               ate_fat,
	input  logic               ate_diet,
	input  logic               deadly_collision, 
	input  logic [987:0]       flat_snake_matrix,
	input  logic [3:0]         lvl_end,
	input  logic               soft_reset,
	
	output logic [15:0]        points,
	output logic               dead,
	
	output logic [4:0]         draw_head_y, 
	output logic [5:0]         draw_head_x,
	output snakepart           draw_head,
	
	output logic [4:0]         draw_neck_y, 
	output logic [5:0]         draw_neck_x,
	output snakepart           draw_neck,
	
	output logic [4:0]         draw_tail_y, 
	output logic [5:0]         draw_tail_x,
	output snakepart           draw_tail,
	
	output logic [4:0]         delete_prev_tail_y, 
	output logic [5:0]         delete_prev_tail_x
);

// -------------------- board limits & start positions ------------------:

localparam logic [5:0] lim_x       = 6'd19;
localparam logic [4:0] lim_y       = 5'd13;

localparam logic [5:0] init_head_x = 6'd10;
localparam logic [4:0] init_head_y = 5'd6;

localparam logic [5:0] init_tail_x = 6'd5;
localparam logic [4:0] init_tail_y = 5'd6;

// -------------------- internal signals --------------------------------:

// head & motion signals
logic [4:0] moved_head_y; 
logic [5:0] moved_head_x; 
logic       moving;
logic       head_is_moving;
logic       has_moved;

// tail movement signals (used to index snake_matrix for next_tile)
logic [4:0] moved_tail_y;
logic [5:0] moved_tail_x;

// grid unpacking
logic [0:12][0:18][3:0] snake_matrix;

// collision flags
logic out_of_bounds;
logic self_collision;
logic snake_snake_collision;
logic eaten_wall;

// -------------------- submodules --------------------------------------:

// computes next head coordinates and neck orientation from key inputs
snake_move dmshlk (
	.clk              (clk),
	.resetN           (resetN),
	.move_pulse       (game_tick),
	.stall            (ate_diet),
	.up_key           (up_key),
	.down_key         (down_key),
	.left_key         (left_key),
	.right_key        (right_key),
	.current_y        (draw_head_y),
	.current_x        (draw_head_x),
	.man_reset        (|lvl_end[2:0] || soft_reset),
	.move_to_y        (moved_head_y),
	.move_to_x        (moved_head_x),
	.head_replacement (draw_neck),
	.head_orientation (draw_head),
	.moving           (moving)
);

// computes tail movement, orientation, and previous tail deletion
snake_tail #(
	.INIT_TAIL_X      (init_tail_x),
	.INIT_TAIL_Y      (init_tail_y)
) tail_inst (
	.clk                (clk),
	.resetN             (resetN),
	.man_reset          (|lvl_end[2:0] || soft_reset || dead),
	.move_pulse         (game_tick),
	.moving             (moving),
	.head_is_moving     (head_is_moving),
	.ate_fat            (ate_fat),
	.next_tile          (snake_matrix[moved_tail_y][moved_tail_x]),
	.moved_tail_y       (moved_tail_y),
	.moved_tail_x       (moved_tail_x),
	.draw_tail_y        (draw_tail_y),
	.draw_tail_x        (draw_tail_x),
	.delete_prev_tail_y (delete_prev_tail_y),
	.delete_prev_tail_x (delete_prev_tail_x),
	.draw_tail          (draw_tail)
);

// -------------------- continuous logic assignments --------------------:

// unpack the flat matrix to 2D grid coordinates
assign snake_matrix = flat_snake_matrix;

// flag when head position changes
assign head_is_moving = (moved_head_x != draw_head_x) || (moved_head_y != draw_head_y);

// boundary check
assign out_of_bounds = (draw_head_y == 5'b1_1111 || draw_head_y == lim_y ||
                        draw_head_x == 6'b11_1111 || draw_head_x == lim_x);

// self collision check (ignore tail square since tail moves away on regular advance)
assign self_collision = head_is_moving && 
                        (snake_matrix[moved_head_y][moved_head_x] != nothing) && 
                        !((moved_head_x == draw_tail_x) && (moved_head_y == draw_tail_y)) && 
                        !ate_fat && !ate_diet;

// combined death condition
assign dead = snake_snake_collision || out_of_bounds || eaten_wall;

// -------------------- state update with always flip-flop --------------:

always_ff @(posedge clk or negedge resetN) begin
	if (!resetN) begin
		eaten_wall            <= 1'b0;
		snake_snake_collision <= 1'b0;
		has_moved             <= 1'b0;
		points                <= 16'd6;
		
		draw_head_y           <= init_head_y; 
		draw_head_x           <= init_head_x;
		
		draw_neck_x           <= init_head_x - 1;
		draw_neck_y           <= init_head_y;
	end
	else if (soft_reset) begin 
		eaten_wall            <= 1'b0;
		snake_snake_collision <= 1'b0;
		has_moved             <= 1'b0;
		points                <= 16'd6;

		draw_head_y           <= init_head_y; 
		draw_head_x           <= init_head_x;

		draw_neck_x           <= init_head_x - 1;
		draw_neck_y           <= init_head_y;
	end
	else begin
		// instantaneous wall collision on system clk, guarded against stale reset/idle pulses
		if (has_moved && moving && !dead && deadly_collision) begin
			eaten_wall <= 1'b1;
		end

		// reset snake body on level clear or death
		if (|lvl_end[2:0] || dead) begin
			points             <= 16'd6;
			has_moved          <= 1'b0;

			draw_head_y        <= init_head_y; 
			draw_head_x        <= init_head_x;
			
			draw_neck_x        <= init_head_x - 1;
			draw_neck_y        <= init_head_y;
		end
		// step advance on game tick
		else if (game_tick) begin
			// enable collision checks once the snake has made its first valid move
			if (moving) begin
				has_moved <= 1'b1;
			end

			// out-of-bounds border clamp
			if (out_of_bounds) begin
				draw_head_y <= draw_head_y; 
				draw_head_x <= draw_head_x;
			end 
			else begin 
				if (!ate_diet) begin 
					draw_head_y           <= moved_head_y; 
					draw_head_x           <= moved_head_x;
					snake_snake_collision <= 1'b0;
					if (self_collision)
						snake_snake_collision <= 1'b1;
				end
				else begin
					// length increment when eating diet food
					points <= points - 1;
				end
			end

			draw_neck_y <= draw_head_y; 
			draw_neck_x <= draw_head_x;
			
			// length increment when eating fat food
			if ((moving || head_is_moving) && ate_fat) begin
				points <= points + 1;
			end
		end
	end
end

endmodule