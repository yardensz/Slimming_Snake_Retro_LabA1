module mushroom_filter (
    input  logic       clk,
    input  logic       resetN,
    input  logic       start_of_frame,
    input  logic       enable,
    
    input  logic [7:0] RGBin,
    output logic [7:0] RGBout
);
//this modules increases every color value by 1 every 4 frames... black is not touched

    logic [7:0] color_offset;
		logic [2:0] slow_count; //to make the color change every 4 frames
		
    always_ff @(posedge clk or negedge resetN) begin
        if (!resetN) begin
            color_offset <= 8'd0;
				slow_count<= 2'b00;
        end
        else begin
            if (enable) begin
                if (start_of_frame) begin
							slow_count <= 2'b001 + slow_count;
							if  (slow_count == 2'b000)
								color_offset <= color_offset + 8'd1; 
                end
            end
            else begin
                color_offset <= 8'd0;
            end
        end
    end

    always_comb begin
        if (enable && RGBin != 8'h00) begin
            RGBout = RGBin + color_offset;
        end
        else begin
            RGBout = RGBin;
        end
    end

endmodule