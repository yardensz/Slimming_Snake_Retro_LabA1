//--------------------------------------
// (c) Technion IIT, Department of Electrical Engineering 2021 
//-- SystemVerilog version June 2018 Alex Grinshpun
// convert to 8 bits table - dudy march 2019 
// add volume level key 3  - eyallev Nov 2024
//--------------------------------------


module	sintable	 #( 
					COUNT_SIZE = 8  // size of the table (in bits) 
		)	
		(	
//		--////////////////////	Clock Input	 	////////////////////	

					input		logic							clk,
					input		logic							resetN,
					input		logic [COUNT_SIZE-1:0]	ADDR,
					input    logic 						volume,
					
					output	logic [15:0]	Q,						 // table function output 
					output 	logic [3:0] 	volume_display
					
			);

			
			
localparam int table_size = (2**COUNT_SIZE)-1;

logic [7:0] tmp8bit  ;
logic [1:0] volume_level;
logic volume_d;




assign volume_display [1:0] = volume_level;

assign volume_display [3:2] = 0;



const logic [0:table_size] [7:0] sin_table = {
8'h0,
8'h3,
8'h6,
8'h9,
8'hC,
8'hF,
8'h12,
8'h15,
8'h18,
8'h1C,
8'h1F,
8'h22,
8'h25,
8'h28,
8'h2B,
8'h2E,
8'h30,
8'h33,
8'h36,
8'h39,
8'h3C,
8'h3F,
8'h41,
8'h44,
8'h47,
8'h49,
8'h4C,
8'h4E,
8'h51,
8'h53,
8'h55,
8'h58,
8'h5A,
8'h5C,
8'h5E,
8'h60,
8'h62,
8'h64,
8'h66,
8'h68,
8'h6A,
8'h6C,
8'h6D,
8'h6F,
8'h70,
8'h72,
8'h73,
8'h75,
8'h76,
8'h77,
8'h78,
8'h79,
8'h7A,
8'h7B,
8'h7C,
8'h7C,
8'h7D,
8'h7E,
8'h7E,
8'h7F,
8'h7F,
8'h7F,
8'h7F,
8'h7F,
8'h7F,
8'h7F,
8'h7F,
8'h7F,
8'h7F,
8'h7F,
8'h7E,
8'h7E,
8'h7D,
8'h7C,
8'h7C,
8'h7B,
8'h7A,
8'h79,
8'h78,
8'h77,
8'h76,
8'h75,
8'h73,
8'h72,
8'h70,
8'h6F,
8'h6D,
8'h6C,
8'h6A,
8'h68,
8'h66,
8'h64,
8'h62,
8'h60,
8'h5E,
8'h5C,
8'h5A,
8'h58,
8'h55,
8'h53,
8'h51,
8'h4E,
8'h4C,
8'h49,
8'h47,
8'h44,
8'h41,
8'h3F,
8'h3C,
8'h39,
8'h36,
8'h33,
8'h30,
8'h2E,
8'h2B,
8'h28,
8'h25,
8'h22,
8'h1F,
8'h1C,
8'h18,
8'h15,
8'h12,
8'hF,
8'hC,
8'h9,
8'h6,
8'h3,
8'h0,
8'hFD,
8'hFA,
8'hF7,
8'hF3,
8'hF0,
8'hED,
8'hEA,
8'hE7,
8'hE4,
8'hE1,
8'hDE,
8'hDB,
8'hD8,
8'hD5,
8'hD2,
8'hCF,
8'hCC,
8'hC9,
8'hC6,
8'hC4,
8'hC1,
8'hBE,
8'hBC,
8'hB9,
8'hB6,
8'hB4,
8'hB1,
8'hAF,
8'hAC,
8'hAA,
8'hA8,
8'hA5,
8'hA3,
8'hA1,
8'h9F,
8'h9D,
8'h9B,
8'h99,
8'h97,
8'h96,
8'h94,
8'h92,
8'h91,
8'h8F,
8'h8E,
8'h8C,
8'h8B,
8'h8A,
8'h89,
8'h87,
8'h86,
8'h86,
8'h85,
8'h84,
8'h83,
8'h82,
8'h82,
8'h81,
8'h81,
8'h81,
8'h80,
8'h80,
8'h80,
8'h80,
8'h80,
8'h80,
8'h80,
8'h81,
8'h81,
8'h81,
8'h82,
8'h82,
8'h83,
8'h84,
8'h85,
8'h86,
8'h86,
8'h87,
8'h89,
8'h8A,
8'h8B,
8'h8C,
8'h8E,
8'h8F,
8'h91,
8'h92,
8'h94,
8'h96,
8'h97,
8'h99,
8'h9B,
8'h9D,
8'h9F,
8'hA1,
8'hA3,
8'hA5,
8'hA8,
8'hAA,
8'hAC,
8'hAF,
8'hB1,
8'hB4,
8'hB6,
8'hB9,
8'hBC,
8'hBE,
8'hC1,
8'hC4,
8'hC6,
8'hC9,
8'hCC,
8'hCF,
8'hD2,
8'hD5,
8'hD8,
8'hDB,
8'hDE,
8'hE1,
8'hE4,
8'hE7,
8'hEA,
8'hED,
8'hF0,
8'hF3,
8'hF7,
8'hFA,
8'hFD



 };

always_ff@(posedge clk or negedge resetN)
begin
	if(!resetN)
	begin
	  tmp8bit		<= 8'h00;
	  volume_level <= 2'h1;
	  volume_d 		<= 1'b1;

	  
	end
			
	else 
	begin
	volume_d <= volume;

	if ((!volume) && (volume_d) )	  //&&  (	 > 2'h0 )
	   volume_level <= volume_level - 2'h1;

		tmp8bit	<= sin_table[ADDR]; //  get sine (or other function) value from the table  
		
   end
end

 always_comb begin
        case (volume_level)

				2'h0: 	Q = 16'b00;
				2'h1:	 	Q = {{3{tmp8bit[7]}},tmp8bit[7:0], {5{tmp8bit[7]}} };
				2'h2: 	Q = {{2{tmp8bit[7]}},tmp8bit[7:0], {6{tmp8bit[7]}} };
				2'h3: 	Q = {tmp8bit[7],tmp8bit[7:0], {7{tmp8bit[7]}} };
            default: Q = {tmp8bit[7],tmp8bit[7:0], {7{tmp8bit[7]}} };
        endcase

end
endmodule

