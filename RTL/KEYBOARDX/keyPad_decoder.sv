// (c) Technion IIT, Department of Electrical Engineering 2019 
// Written By David Bar-On  Apr 2023 
// used to detect if one of the keys 0-9 was pressed,  if so sends the last keycode with Valid 

module keyPad_decoder 	
 ( 
   input	   logic  clk,
	input	   logic  resetN, 
   input  logic [8:0]	keyCode,	
   input  logic 	make,	
   input  logic 	brakee,  // warning break is a reserved word 
	
   output  logic [9:0] 	NumberKey,	
   output  logic plus,Back,slash,del,enter,minus , star, num ,
	
	
		
	output  logic [3:0]	key,
   output  logic 	keyIsValid	// valid while key [0..A] is pressed
  	 
  ) ;
  
  localparam NUM_OF_KEYS  = 18 ;

 logic[0:(NUM_OF_KEYS-1)][8:0] KEYS_ENCODEING =  // table holding the encoding of each key 
//    0      1       2       3       4       5        6       7       8       9       +      BackApace    /     DEL    ENTER    -       *        NUM    
  
  {9'h070, 9'h069, 9'h072, 9'h07A, 9'h06B, 9'h073, 9'h074, 9'h06C, 9'h075, 9'h07D,  9'h079 , 9'h066, 9'h14A,  9'h071, 9'h15A,  9'h07B , 9'h07C,   9'h077 } ; 
	

	 logic [NUM_OF_KEYS:0] 	keyIsPressed ; // all keys 	
	
	
always_ff @(posedge clk or negedge resetN) begin
 	if (resetN == 1'b0) begin 
			key <= 4'b0000 ; 	
			keyIsValid	<= 0 ; 
		end 
		else begin 
		// this is an example of how to use a for loop and generate 9 parallel circuits, one per digit 
		
				for(logic [3:0] i = 0 ;i < 10 ; i++) begin // for loop creating one machine per key 
					if (keyCode  == KEYS_ENCODEING[i] ) begin 
							if (make == 1'b1) begin ;  // turn on when key is pressed 
							      keyIsPressed[i] <=1'b1;
									keyIsValid <= 1'b1 ;
									key <= i	; 
							end ; 
							if (brakee == 1'b1) begin // turn off after key is released 
								keyIsPressed[i] <=1'b0;
								keyIsValid <= 1'b0 ;  
							end 
					end 
					
					
					
				// code for the special keys 
				
				for(int i = 10 ;i < NUM_OF_KEYS ; i++) begin // for loop creating one machine per key 
					if (keyCode  == KEYS_ENCODEING[i] ) begin 
							if (make == 1'b1) begin ;  // turn on when key is pressed 
							   keyIsPressed[i] <=1'b1;
							end ; 
							if (brakee == 1'b1) begin // turn off after key is released 
								keyIsPressed[i] <=1'b0;
							end 
					end 

				end
		end 
    end 
end 

// assign special wires 

//    0      1       2       3       4       5        6       7       8       9       +      BackApace    /     DEL    ENTER    -       *        NUM    

assign   plus = keyIsPressed [10] ; 
assign   Back = keyIsPressed [11] ; 
assign   slash = keyIsPressed [12] ; 
assign   del = keyIsPressed [13] ; 
assign   enter = keyIsPressed [14] ; 
assign   minus = keyIsPressed [15] ; 
assign   star = keyIsPressed [16] ; 
assign   num = keyIsPressed [17] ; 
assign   NumberKey [9:0]= keyIsPressed [9:0] ; 



endmodule

 
