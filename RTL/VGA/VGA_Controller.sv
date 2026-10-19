// (c) Technion IIT, Department of Electrical Engineering 2021 
//-- Alex Grinshpun Apr 2017
// SystemVerilog version Alex Grinshpun May 2018
// coding convention dudy December 2018


//-- Eyal Lev January 2021 change VGA clock to  25MHz Input clocK
//-- dudy clock 32.5. fixed colors bug                    


module	VGA_Controller	(	//	Host Side
				
					input		logic	[7:0]		RGBIn,
					output	logic	[10:0]	PixelX,
					output	logic	[10:0]	PixelY,
					output	logic			startOfFrame,
						//	VGA Side
						output logic [28:0] oVGA,
						output logic [18:0] address ,
					
						//	Control Signal
					input		logic	clk,
					input		logic	resetN	);

//	Internal Registers
logic			[10:0]	H_Cont;
logic			[10:0]	V_Cont;
logic      oVGA_HS;
logic      oVGA_HS_d;
logic      oVGA_VS;


////////////////////////////////////////////////////////////
//	Horizontal	Parameter
const logic [10:0]	H_FRONT	=	24;
const logic [10:0]	H_SYNC	=	40;
const logic [10:0]	H_BACK	=	128;
const logic [10:0]	H_ACT	=	640;
const logic [10:0]	H_BLANK	=	H_FRONT + H_SYNC + H_BACK;
const logic [10:0]	H_TOTAL	=	H_FRONT + H_SYNC + H_BACK + H_ACT;
////////////////////////////////////////////////////////////
//	Vertical Parameter
const logic [10:0]	V_FRONT	=	9;
const logic [10:0]	V_SYNC	=	3;
const logic [10:0]	V_BACK	=	28;
const logic [10:0]	V_ACT	=	480;
const logic [10:0]	V_BLANK	=	V_FRONT+V_SYNC+V_BACK;
const logic [10:0]	V_TOTAL	=	V_FRONT+V_SYNC+V_BACK+V_ACT;

logic VGA_VS_pulse;
logic VGA_VS_d;
int VGA_VS_pulse_cnt;
logic			timer_done;

// // 28 bits VGA OUTPUT [CLOCK,      BLANK                           , SYNC ,     VS   , HS
assign	oVGA		=   	{{~clk},{~((H_Cont < H_BLANK)||(V_Cont < V_BLANK))},{oVGA_VS},{oVGA_VS},{oVGA_HS},

//                          8 bits RED color     ,       8 bits Green color         ,      8 bits Blue color
							 {RGBIn[1:0], {6{RGBIn[1]}}},     {RGBIn[4:2], {5{RGBIn[4]}}},      {RGBIn[7:5], {5{RGBIn[7]}}}}; // extend with MSB 

assign	PixelX	=	(H_Cont >= H_BLANK)	?	H_Cont - H_BLANK	:	11'h0	;
assign	PixelY	=	(V_Cont >= V_BLANK)	?	V_Cont - V_BLANK	:	11'h0	;

assign   address =(({{8{1'b0}},{PixelY}} * (19'd640)) + {{{8{1'b0}},{PixelX}}});


//	Horizontal Generator: Refer to the pixel clock
always_ff@(posedge clk or negedge resetN)
begin
	if(!resetN)
	begin
		H_Cont		<=	11'b0;
		oVGA_HS		<=	1'b1;
		oVGA_HS_d	<=	1'b1;

	end
	else
	begin
		if(H_Cont<H_TOTAL) 			
					H_Cont	<=	H_Cont+1'b1;
		
		else
		H_Cont	<=	11'b0;
		
		//	Horizontal Sync
		if(H_Cont == H_FRONT-1'b1)			//	Front porch end
			oVGA_HS	<=	1'b0;
		if(H_Cont == H_FRONT + H_SYNC-1'b1)	//	Sync pulse end
			oVGA_HS	<=	1'b1;
		
		
		oVGA_HS_d <= oVGA_HS;
				
	end
end

//	Vertical Generator: Refer to the pixel clock

always_ff@(posedge clk or negedge resetN)
begin
	if(!resetN)
	begin
		  V_Cont		<=	11'b0;
		  oVGA_VS	<=	1'b1;
		  VGA_VS_d	<= 1'b0;
	end
	else begin

		
		if (!oVGA_HS_d && oVGA_HS)    // positive edge of OVGA_HS
	   begin
			if(V_Cont < V_TOTAL)
				V_Cont	<=	V_Cont + 1'b1;
			else
				V_Cont	<=	11'b0;

			//	Vertical Sync
			if(V_Cont == V_FRONT - 1'b1)			//	Front porch end
				oVGA_VS	<=	1'b0;
			if(V_Cont == V_FRONT + V_SYNC-1'b1)	//	Sync pulse end
				oVGA_VS	<=	1'b1;
	   end
		
		
	//---- delayed signal -------
		VGA_VS_d	<= oVGA_VS;
		
	end
end




assign startOfFrame	= !oVGA_VS && VGA_VS_d;// generating a short pulse ;

endmodule