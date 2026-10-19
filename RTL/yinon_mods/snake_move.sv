//yinon was here 1
import custom_types::*;
module snake_move (

	input logic clk,
	input logic resetN,
	
	input logic move_pulse,
	
	input logic stall, //TENTATIVE, for shrinking the snake if eat healthy.
	
	input logic up_key,
	input logic down_key,
	input logic left_key,
	input logic right_key,
	
	input logic man_reset,
	
	//currunt head position from controller
	//x goes form 1 to 19, left to right. y goes form 1 to 14, up to down... like in a matrix
	input logic [4:0] current_y,
	input logic [5:0] current_x,
	
	//next head position
	output logic [4:0] move_to_y,
	output logic [5:0] move_to_x,
	output snakepart  head_replacement, head_orientation,
	output logic moving
	
	
);	
	

	//enum for keeping track of last key pressed
	enum  logic [2:0] {none, up, down, left, right} last_key;

//states

	enum  logic [2:0] {idle_st, dead_st, up_st, down_st, left_st, right_st} fsm_move , fsm_move_prev;
	
	
	always_comb begin
		
	//moving output
			moving = (fsm_move != idle_st);
			
	//output logic head_dirction:::::::::::::::::::::;
		case (fsm_move)
			up_st:   head_orientation = head_up; 		//up
			down_st: head_orientation = head_down;		//down
			left_st: head_orientation = head_left;		//left
			default: head_orientation = head_right;	//right
		endcase
		
	//otuput logic for head replacement::::::::::::::::::
	case ({fsm_move_prev,fsm_move})
		{up_st,up_st}, {down_st,down_st}: 
			head_replacement = body_vertical;
			
		{right_st, right_st}, {left_st,left_st}, {idle_st,right_st}, {idle_st, idle_st}:
			head_replacement = body_horizontal;
		 
		{down_st, right_st}, {left_st, up_st}:
			head_replacement = turn1;
			
		{right_st, up_st}, {down_st, left_st}, {idle_st, up_st}:
			head_replacement = turn2;
			
		{right_st, down_st}, {up_st,left_st}, {idle_st, down_st}:
			head_replacement = turn3;
			
		{up_st,right_st}, {left_st, down_st}:
			head_replacement = turn4;
			
		default: 	//just to shut up the compiler:
			head_replacement = nothing; 
			
		
		 
		 
	 endcase
	end //alwayscomb
	
	//incorperating move and stall
	logic move, pulse;
	assign pulse = move_pulse && !stall;
	
	always_ff@(posedge clk or negedge resetN)
		begin
		
		if (!resetN) begin 
			fsm_move <= idle_st;
			last_key <= none;
			fsm_move_prev <= idle_st;
		end else begin
		
		if (man_reset) begin 
			fsm_move <= idle_st;
			last_key <= none;
			fsm_move_prev <= idle_st;
		end 
		else
		last_key <= up_key ? up : down_key ? down: left_key ? left : right_key ? right : last_key;
		
		//fsm defaults: (not moving)
		move_to_x <= current_x;
		move_to_y <= current_y;
		
		if(pulse)
			fsm_move_prev <= fsm_move;
		
		
		case (fsm_move)
			
			
			//----------idle---------- 
			///////////////assuming snake is facing right on idle
			idle_st: begin
				//move predition
				
				if(pulse) begin
					case(last_key)
						up: fsm_move <= up_st; 
						down: fsm_move <= down_st; 
						default: fsm_move <= right_st;
					endcase
					
				end 
				else begin
					case(last_key)
						up: move_to_y <= current_y - 1;
						down: move_to_y <= current_y + 1;
						right: move_to_x <= current_x + 1;
						//no default: if no keypressed on position update.
					endcase	
					
				end
			end // idle
			
			
			//-------------up---------------
			//design policy if key is pressed in miving direction do nothing, 
			//if key is pressed on OPOSITE direction do NOTHING
			
			up_st: begin
				
			if (pulse) begin
			
				case(last_key)
					left: fsm_move <= left_st;
					right: fsm_move <= right_st;
				endcase 
				
			end 
			else begin
				case(last_key)
						left: move_to_x <= current_x - 1;
						right: move_to_x <= current_x + 1;
						default : move_to_y <= current_y - 1;
				endcase
			end
			
			
			end //up_st
			
			//-------------down--------------
			
			down_st: begin
			
			if (pulse) begin
			
				case(last_key)
					left: fsm_move <= left_st;
					right: fsm_move <= right_st;
				endcase 
				
			end 
			else begin
			
				case(last_key)
						left: move_to_x <= current_x - 1;
						right: move_to_x <= current_x + 1;
						default: move_to_y <= current_y  + 1;
				endcase
				
			end
			
			end //down
			
			//-----------left--------------
			
			left_st: begin
			
			if (pulse) begin
			
				case(last_key)
					up: fsm_move <= up_st;
					down: fsm_move <= down_st;
				endcase 
				
			end 
			else begin
			
				case(last_key)
						up: move_to_y <= current_y - 1;
						down: move_to_y <= current_y + 1;
						default: move_to_x <= current_x  - 1;
				endcase
				
			end
				
			end//left
				
				
			
			//---------------right------------
			
			right_st: begin
			
			if (pulse) begin
			
				case(last_key)
					up: fsm_move <= up_st;
					down: fsm_move <= down_st;
				endcase 
				
			end 
			else begin
			
				case(last_key)
						up: move_to_y <= current_y - 1;
						down: move_to_y <= current_y + 1;
						default: move_to_x <= current_x  + 1;
				endcase
				
			end
				end//ritght
			
			
		endcase
		
		
		
		
		
		end// resetN else
		
		
		
		
		
		
		end //alwaysff
		
		
		
		
		
		
		
		
		
		
		
endmodule 







