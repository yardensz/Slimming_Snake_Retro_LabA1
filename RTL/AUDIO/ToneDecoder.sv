/// (c) Technion IIT, Department of Electrical Engineering 2021 
//-- This module  generate the correet prescaler tones for a single ocatave 

//-- Dudy Feb 12 2019 
//-- Eyal Lev --change values to 31.5 MHz   Apr 2023
//-- Eyal Lev --change values to OCTAVA  6   Nov 2024
module	ToneDecoder	(	
					input	logic [3:0] tone, 
					input	logic [2:0] octave, 
					output	logic [11:0]	preScaleValue
		);

// The original design
/*
logic [0:15] [9:0]	preScaleValueTable = { 

//---------------VALUES for 31.5MHz   ocatave   6------------------------

10'h75,   // decimal =117.58      Hz =1046.5  do    31_500_000/256/<FREQ_Hz>
10'h6E,   // decimal =110.98      Hz =1108.73  doD
10'h68,   // decimal =104.75      Hz =1174.66  re
10'h62,   // decimal =98.87       Hz =1244.51  reD
10'h5D,   // decimal =93.32       Hz =1318.51  mi
10'h58,   // decimal =~~88        Hz =1696.91  fa    <----- **** CORRECTED:  changed from h48 to h58 *****
10'h53,   // decimal =83.14       Hz =1479.98 faD
10'h4E,   // decimal =78.47       Hz =1567.98 sol
10'h4A,   // decimal =74.07       Hz =1661.22 solD
10'h45,   // decimal =69.91       Hz =1760 La
10'h41,   // decimal =65.99       Hz =1864.66  laD
10'h3E,   // decimal =62.29       Hz =1975.53  si
10'h3A,   // decimal =58.79       Hz =2093  do   Next OCTAV - 7
10'h37,   // decimal =55.49       Hz =2217.46  doD  Next OCTAV - 7
10'h34,   // decimal =52.38       Hz =2349.02  reD  Next OCTAV - 7
10'h31} ; // decimal =49.44       Hz =2489.02  reD  Next OCTAV - 7 

assign 	preScaleValue = preScaleValueTable [tone] ; 
*/
/**/
// The new design

//---------------VALUES for 31.5MHz clock, Base Octava (1) ------------------------
	logic [0:11] [11:0] preScaleValueTable = '{
		12'heb3, // C	(2093.0 Hz) (2090 Hz = 31,500,000 / 256 / 3763 (i.e. 0xeb))
		12'hddf, // C#	(2217.5 Hz)
		12'hd18, // D	(2349.3 Hz)
		12'hc5c, // D#	(2489.0 Hz)
		12'hbaa, // E	(2637.0 Hz)
		12'hb03, // F	(2793.8 Hz)
		12'ha65, // F#	(2960.0 Hz)
		12'h9cf, // G	(3136.0 Hz)
		12'h942, // G#	(3322.4 Hz)
		12'h8bd, // A	(3520.0 Hz)
		12'h840, // A#	(3729.3 Hz)
		12'h7c9  // B	(3951.1 Hz)

	};

// tone select the specific song from the table to be played 
assign 	preScaleValue = preScaleValueTable[tone] >> octave; 
/**/

endmodule





















































