module input_flipper (
    input  logic enable,
    
    input  logic up_in,
    input  logic down_in,
    input  logic left_in,
    input  logic right_in,
	 
	 input alternative_down,// connect to 5
    
    output logic up_out,
    output logic down_out,
    output logic left_out,
    output logic right_out
);
		assign combined_down = down_in || alternative_down;
    assign up_out    = enable ? combined_down  : up_in;
    assign down_out  = enable ? up_in    : combined_down;
    assign left_out  = enable ? right_in : left_in;
    assign right_out = enable ? left_in  : right_in;

endmodule