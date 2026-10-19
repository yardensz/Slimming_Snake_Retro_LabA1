

localparam int NOTES_IN_A_SONG 	= 256;
localparam int SOUND_MEM_SIZE 	= 4096;
localparam int SOUND_ADDR_W 		= $clog2(SOUND_MEM_SIZE);

typedef logic [SOUND_ADDR_W-1:0] song_addr_t; 

module melody_player_1
    (
    // Declare wires and regs :
 input logic 				resetN,
 input logic 				CLOCK_31p5,
 input logic 				startMelody,
 input logic 	[3:0] 	melodySelect, 			// selector of one melody  
// input logic [15:0] songs_mem,					// input from songs.mif
 input logic 				restartMelody,
 
 output logic 	[3:0] 	tone,
 output logic 	[2:0] 	octave,
 output logic 				EnableSoundOut,		// controls AUDIO module on/off 
 output logic 				melodyEnded       	// indicates end of melody.  Also outputs to LED3      
 //output logic [11:0] 	note_address 			// output to audio MIF address 
 
  );   
 

 // Maestro state machine declaration 
enum logic [2:0] {s_idle, s_playNote, s_gap, s_ended, s_waitRelease, s_restart } SM_Maestro;

	// parameters declarations
	logic [11:0] 	note_address;
	logic [15:0]	songs_mem;
	logic [4:0] 	noteTimeCounter; 		// count down timer ( maximum 1024 )
   logic [4:0] 	noteDuration;    
   logic [4:0] 	gapDuration;     		// time of gap between notes in msec
   logic 			hundredthSecPulse; 	// A short pulse, once every 1/100 second. 

	
	
	
	// interface signals to the list of songs
	logic [7:0] noteIndex;
	lpm_rom #(
    .LPM_WIDTH(16),
    .LPM_WIDTHAD(12),
	 .LPM_NUMWORDS(4096),
    .LPM_FILE("RTL/AUDIO/songs.mif"),
	   .LPM_TYPE               ("LPM_ROM"),
      .LPM_ADDRESS_CONTROL    ("REGISTERED"), 
		.LPM_OUTDATA            ("UNREGISTERED"), 
		.AUTO_CARRY_CHAINS      ("ON"),
		.AUTO_CASCADE_BUFFERS   ("ON"),
	   .INTENDED_DEVICE_FAMILY ("Cyclone V")  
) rom_inst (
    .address(note_address),
	 .inclock(CLOCK_31p5),
	// .outclock(clk),
    .q(songs_mem)
);

  //----------------------------------------------------------------------------------------------------------
  // Instances of slow counter.  pulse every 10 mSec
  //----------------------------------------------------------------------------------------------------------									  									  								 
   Mili_sec_counter #(.SIMULATION_MODE(1'h0), .mSecPerTick(30), .PLLClock(315)) mili_sec_counter_inst 
	                     (.clk(CLOCK_31p5),   
								 .resetN(resetN),
								 .turbo(1'h0),   
								 .hundredth_sec(hundredthSecPulse) );
								 

								 
								 
	//----------------------------------------------------------------------------------------------------------								 					 	 
	//   syncronous code,  executed once every clock to update the current state and outputs 
	//----------------------------------------------------------------------------------------------------------


	
	always_ff @(posedge CLOCK_31p5 or negedge resetN) // State machine logic 
		begin   
		if ( !resetN ) begin // Asynchronic reset, initialize the state machine 
		
			SM_Maestro 			<= s_idle;
			noteIndex 			<= 8'b0 ;
			noteTimeCounter  	<= noteDuration ;
			EnableSoundOut 	<= 1'b0 ;
			melodyEnded 		<= 1'b0 ;
			
		end // asynch
		
		
		
		else begin 	// Synchronic logic of the state machine; once every clock 
//--------------------------------------------------------------------------------------------------------------------
			// state machine 
			// default outputs 
			EnableSoundOut <= 1'b0 ;
			melodyEnded 	<= 1'b0 ;
			
			
			if (!startMelody) begin
				 SM_Maestro <= s_idle;
				 noteIndex 	<= 8'd0;
			end
			
			
			else if (restartMelody) begin
				 SM_Maestro <= s_restart;
				 noteIndex 	<= 8'd0;
			end
		
			
			
			else begin
		
				case ( SM_Maestro )			
					// ================================================				
					s_idle: begin
					
						noteIndex <= 8'b0;
						
						if (startMelody) begin   						// start melody pressed 
						
							noteTimeCounter 	<= noteDuration ;		// preset noteTimecounter
							SM_Maestro 			<= s_playNote ;	
						end // if
						
					end // s_idle	
					// ================================================

					
					s_playNote: begin	
					
						EnableSoundOut <= 1'b1 ; 								// enable sound 
						
						if ((noteDuration != 4'b0)) begin   				// if song is still playing 
						
							if ( hundredthSecPulse ) begin
							
								noteTimeCounter <= noteTimeCounter - 5'b1; // decremnt counter
							end
							
							
							if (noteTimeCounter == 5'b0) begin 				// timer finished 
							
								noteIndex 			<= noteIndex + 1'b1 ;   // increment note Index 
								SM_Maestro 			<= s_gap ;   				// next state 
								noteTimeCounter 	<= gapDuration ;			// preset counter for gap between notes 
							end // if timer ended
							
						end // if not end of song	
						
						else begin
							// reached end of song
							SM_Maestro <= s_ended;
						end
						
					end // s_playNote
					// ================================================	
		
		
					s_gap : begin	
					
						if ( hundredthSecPulse ) begin
						
							noteTimeCounter <= noteTimeCounter - 5'b1; // decremnt counter  
						end
						
						
						if (noteTimeCounter == 5'b0) begin // timer finished
						
							SM_Maestro <= s_playNote ;   // back to playnote state    
							noteTimeCounter <= noteDuration ;     // preset counter 
						end // if 
						
					end // s_gap
					// ================================================		
			
			
					s_ended: begin
					
						melodyEnded <= 1'b1;
						SM_Maestro <= s_waitRelease;
					end //s_end
					
					//	================================================
					
					
					s_waitRelease: begin
						if (!startMelody) begin
							SM_Maestro <= s_idle;
						end
					end // s_waitRelease
					
					//	================================================
					
					
					
					s_restart: begin
						 SM_Maestro <= s_idle;
					end
					
					//	================================================

					default: begin
						SM_Maestro <= s_idle ;
					end // default
					
				endcase
				
			end // end else 
			
			
		end // if reset else
		
	end // always_ff state machine 

	//assign song_index  = base_offset + noteIndex;
	//assign note_address[11:8] = melodySelect;
	//assign note_address[7:0] = noteIndex;
	assign note_address = {{melodySelect},{noteIndex}};
//	assign tone        	= all_songs[song_index].note;
//	assign octave      	= all_songs[song_index].octave;
//	assign noteDuration  = all_songs[song_index].duration;	// in units of ? msec
//	assign gapDuration  	= all_songs[song_index].gap;		   // in units of ? msec

	assign tone        	= songs_mem[15:12];  
	assign octave   		= {{1'b0},{songs_mem[11:10]}} + 3'd3; 
	assign noteDuration  = songs_mem[9:5];
	assign gapDuration  	= songs_mem[4:0];
	
	
endmodule

