import custom_types::*;

module score_keeper (
    input logic clk,
    input logic resetN,
    input logic soft_reset,
    input logic game_tick, 
    
    input logic ate_apple,
    input logic ate_burger,
    input logic ate_mushroom, 
    
    input gamestate game_state,
    
    output logic [15:0] score
);

    // ==========================================
    // Parameters
    // ==========================================
    parameter logic [15:0] APPLE_WEIGHT    = 16'd10;
    parameter logic [15:0] BURGER_WEIGHT   = 16'd15;
    parameter logic [15:0] MUSHROOM_WEIGHT = 16'd100;
   // parameter logic [15:0] LVL_WEIGHT    = 16'd1000; 

    // ==========================================
    // Internal Registers
    // ==========================================
    logic [15:0] current_score;
    logic [15:0] high_score;
    
    gamestate game_state_d;
    logic game_just_ended, game_just_ended_d;

    assign game_just_ended = ((game_state == game_over) || (game_state == victory)) && 
                             !((game_state_d == game_over) || (game_state_d == victory));

    always_ff @(posedge clk or negedge resetN) begin
        if (!resetN) begin
            current_score <= 16'd0;
            game_state_d  <= start;
				game_just_ended_d <= 0;
        end
        else begin
            game_state_d <= game_state;
            // -----------------------------------------------------
            // 1. High Score Update 
            // -----------------------------------------------------
            if (game_just_ended) begin
                if (current_score > high_score) begin
                    high_score <=  current_score ;
                end
            end
            
            // -----------------------------------------------------
            // 2. Score Management 
            // -----------------------------------------------------
            if (soft_reset) begin
                current_score <= 16'd0;
            end
            else if (game_tick) begin
           
					 if (ate_apple) begin
                    current_score <= current_score + APPLE_WEIGHT;
                end
                else if (ate_burger) begin
                    current_score <= current_score + BURGER_WEIGHT;
                end
                else if (ate_mushroom) begin
                    current_score <= current_score + MUSHROOM_WEIGHT;
                end
            end
        end
    end

    // ==========================================
    // Output Multiplexer
    // ==========================================
    always_comb begin
        if (game_state == start) begin
            score = high_score;
        end
        else begin
            score = current_score;
        end
    end

endmodule