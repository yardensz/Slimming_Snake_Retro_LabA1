//
// coding convention dudy December 2018
// (c) Technion IIT, Department of Electrical Engineering 2025
// generating a number bitmap 



module NumbersBitMap	(	
					input		logic				clk,
					input		logic				resetN,
					input 	logic	[10:0] 	offsetX,				// offset from top left position 
					input 	logic	[10:0] 	offsetY,
					input		logic				InsideRectangle, 	//input that the pixel is within a bracket 
					input 	logic	[3:0] 	digit, 				// digit to display
					

					
					
					output	logic				drawingRequest, 	//output that the pixel should be dispalyed 
					output	logic	[7:0]		RGBout
);


localparam logic [12:0] OBJECT_WIDTH_X = 6'd16;
localparam logic [12:0] OBJECT_WIDTH_Y = 6'd32;
localparam logic [12:0] digit_location_MIF = OBJECT_WIDTH_X * OBJECT_WIDTH_Y;

// generating a number bitmap from a MIF file




logic [12:0] address  ;

 assign RGBout = digit_color;
 
 //here:::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::--------------------------------------->
assign address = ((digit_location_MIF*digit)+((offsetY)*OBJECT_WIDTH_X + (offsetX))); //***no more Double size (offsetX>>1)
//assign address = ((digit_location_MIF*digit)+((offsetY)*OBJECT_WIDTH_X + (offsetX))); //Origimal size of digit
	//***comment the previous line and adjust the square object to double size as the size of a double bitmap

parameter logic	[7:0] digit_color = 8'b11100000 ; //set the color of the digit 

lpm_rom #(
    .LPM_WIDTH(1),
    .LPM_WIDTHAD(13),
	 .LPM_NUMWORDS(8192),
    .LPM_FILE("RTL/numbers.mif"),
	   .LPM_TYPE               ("LPM_ROM"),
      .LPM_ADDRESS_CONTROL    ("REGISTERED"), 
		.LPM_OUTDATA            ("UNREGISTERED"), 
		.AUTO_CARRY_CHAINS      ("ON"),
		.AUTO_CASCADE_BUFFERS   ("ON"),
	   .INTENDED_DEVICE_FAMILY ("Cyclone V")  
) rom_inst (
    .address(address),
	 .inclock(clk),
	// .outclock(clk),
    .q(color)
);

// pipeline (ff) to get the pixel color from the array 	 

always_ff@(posedge clk or negedge resetN)
begin
	if(!resetN) begin
		drawingRequest <=	1'b0;
		
	end
	
	else begin
	
		drawingRequest <=	1'b0;
	  	if (InsideRectangle) drawingRequest <= (color == 1'b1) ? 1'b1 : 1'b0;
		
 	end 
end

  // this is a fixed color 


endmodule