import custom_types::*;

module all_numbers_display (
    input  logic               clk,
    input  logic               resetN,
    
    input  logic signed [10:0] pixelX,
    input  logic signed [10:0] pixelY,
    
    // Values to display

    input  logic [15:0]        score, 
    input  logic [15:0]        length_val, 
    
    input gamestate            game_state,
    
    // VGA Outputs
    output logic               drawingRequest,
    output logic [7:0]         RGBout
);

    // ==========================================
    // Position Parameters 
    // ==========================================
    parameter logic [10:0] HIGHSCORE_X = 11'd200;
    parameter logic [10:0] HIGHSCORE_Y = 11'd200;
    
    parameter logic [10:0] SCORE_X     = 11'd300;
    parameter logic [10:0] SCORE_Y     = 11'd432;
    
    parameter logic [10:0] LENGTH_X    = 11'd64;
    parameter logic [10:0] LENGTH_Y    = 11'd432;
    
    parameter logic [10:0] LVL_X       = 11'd500;
    parameter logic [10:0] LVL_Y       = 11'd432;

    // ==========================================
    // Zeros to Keep Parameters
    // ==========================================
    parameter int HIGHSCORE_ZEROS = 5;
    parameter int SCORE_ZEROS     = 5;
    parameter int LENGTH_ZEROS    = 3;
    parameter int LVL_ZEROS       = 1;

    // ==========================================
    // Internal Signals
    // ==========================================
    logic [19:0] score_bcd, length_bcd; 
    
    logic dr_highScore, dr_score, dr_length, dr_lvl;
    logic [7:0] rgb_highScore, rgb_score, rgb_length, rgb_lvl;

    logic mask_highScore, mask_inGame; 

    // ==========================================
    // BCD Converters 
    // ==========================================
    binary_to_BCD bcd_score (
        .clk(clk), .resetN(resetN),
        .in_num(score),
        .out_num(score_bcd)
    );

    binary_to_BCD bcd_length (
        .clk(clk), .resetN(resetN),
        .in_num(length_val),
        .out_num(length_bcd)
    );

    // ==========================================
    // Display Instances
    // ==========================================
    TripleDigitNumber #(
        .top_left_x(HIGHSCORE_X), 
        .top_left_y(HIGHSCORE_Y),
        .number_of_zeros_to_keep(HIGHSCORE_ZEROS),
		  .color(8'b111_000_11)
    ) disp_highScore (
        .clk(clk), .resetN(resetN),
        .pixelX(pixelX), .pixelY(pixelY),
        .number(score_bcd), 
        .drawingRequest(dr_highScore),
        .RGBout(rgb_highScore)
    );

    TripleDigitNumber #(
        .top_left_x(SCORE_X), 
        .top_left_y(SCORE_Y),
        .number_of_zeros_to_keep(SCORE_ZEROS)
    ) disp_score (
        .clk(clk), .resetN(resetN),
        .pixelX(pixelX), .pixelY(pixelY),
        .number(score_bcd), 
        .drawingRequest(dr_score),
        .RGBout(rgb_score)
    );

    TripleDigitNumber #(
        .top_left_x(LENGTH_X), 
        .top_left_y(LENGTH_Y),
        .number_of_zeros_to_keep(LENGTH_ZEROS)
    ) disp_length (
        .clk(clk), .resetN(resetN),
        .pixelX(pixelX), .pixelY(pixelY),
        .number(length_bcd),
        .drawingRequest(dr_length),
        .RGBout(rgb_length)
    );

    TripleDigitNumber #(
        .top_left_x(LVL_X - 11'd80), 
        .top_left_y(LVL_Y),
        .number_of_zeros_to_keep(LVL_ZEROS)
    ) disp_lvl (
        .clk(clk), .resetN(resetN),
        .pixelX(pixelX), .pixelY(pixelY),
        .number({17'b0000_0000_0000_0000_0, game_state}), 
        .drawingRequest(dr_lvl),
        .RGBout(rgb_lvl)
    );

    // ==========================================
    // Output Multiplexing
    // ==========================================
    assign mask_highScore = (game_state == start) | 
                            (game_state == victory) | 
                            (game_state == game_over);
                                    
    assign mask_inGame =    (game_state == lvl1) | 
                            (game_state == lvl2) | 
                            (game_state == lvl3);
                                    
    assign drawingRequest = (dr_highScore & mask_highScore) | 
                            (dr_score     & mask_inGame)    | 
                            (dr_length    & mask_inGame)    | 
                            (dr_lvl       & mask_inGame);
    
    always_comb begin
        // Applied masks here as well to prevent overlaps
        if      (dr_highScore & mask_highScore) RGBout = rgb_highScore;
        else if (dr_score     & mask_inGame)    RGBout = rgb_score;
        else if (dr_length    & mask_inGame)    RGBout = rgb_length;
        else if (dr_lvl       & mask_inGame)    RGBout = rgb_lvl;
        else                                    RGBout = 8'h00;
    end

endmodule