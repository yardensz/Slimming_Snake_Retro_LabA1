//
// (c) Technion IIT, The Faculty of Electrical and Computer Engineering, 2025
//
//
//  PRELIMINARY VERSION  -  06 April 2025
//


module JukeBox1

    (
    // Declare wires and regs :
 
 input logic [3:0] melodySelect ,     // selector of one melody  
 input logic [4:0] noteIndex,         // serial number of current note. ( maximum 31 ). noteIndex determines freqIndex and note_length, via JueBox
 
 output logic [3:0] tone,        // index to toneDecoder
 output logic [3:0] note_length,      // length of notes, in beats
 output logic silenceOutN ) ;         //  a silence note: disable sound
 

 localparam MaxMelodyLength = 6'h32;  // maximum melody length, in notes. 
	

// ************** frequencies: *************************************************************************************************
    typedef enum logic [3:0] {do_, doD, re, reD, mi, fa, faD, sol, solD, la, laD, si, do_H, doDH, re_H, silence } musicNote ;//*
//              Hex value:     0    1    2   3   4    5   6    7     8    9   A   B    C      D    E      F                  //*
// *****************************************************************************************************************************
      
   // type of frequency is musicNote   (enum)  
   // Frequency index is 0....15   
   // length is in beats ( 1 to 15 )
   // length = 0 means end of melody		

musicNote frq[(MaxMelodyLength-1'b1):0]  ;     // frq is the array of frequency indices of the melody. it includes up to 32 notes.  
logic [3:0] len[(MaxMelodyLength-1'b1):0] ;   // len is the array of note lengths , in terms of beats. it includes up to 32 notes.		

assign silenceOutN = !( tone == silence ) ; // disable sound if note is "silence"	 
	 
	 
	 
always_comb begin	 
    frq = '{default: 0};
	 len = '{default: 0}; 
  case (melodySelect)  
      0:   begin
	
			//********************************************************************** 
			// Sheet Music of song:  YONATAN HAKATAN  ( up to 32 notes )          *
			//**********************************************************************

				 frq[0] = sol ;           len[0] = 2 ;    // YO  ( e.g.: sol, length = 2 beats )
				 frq[1] =  mi ;           len[1] = 2 ;    // NA
				 frq[2] =  mi ;           len[2] = 4 ;    // TAN ( e.g.: mi, length = 6 beats)

				 frq[3] =  fa ;           len[3] = 2 ;    // Ha   
				 frq[4] =  re ;           len[4] = 2 ;    // KA
				 frq[5] =  re ;           len[5] = 4 ;    // TAN

				 
				 frq[6] =  do_ ;           len[6] = 2 ;   // RATZ
				 frq[7] =  re  ;           len[7] = 2 ;   // BA
				 frq[8] =  mi  ;           len[8] = 2 ;   // BO
				 frq[9] =  fa  ;           len[9] = 2 ;   // KER
				 frq[10]=  sol ;           len[10]= 2 ;   // EL
				 frq[11]=  sol ;           len[11]= 2 ;   // HA
				 frq[12]=  sol ;           len[12]= 4 ;   // GAN
				 
				 frq[13] = sol ;           len[13] = 2 ;   // HU  
				 frq[14] =  mi ;           len[14] = 2 ;   // TI
				 frq[15] =  mi ;           len[15] = 4 ;   // PES 

				 frq[16] =  fa ;           len[16] = 2 ;   // AL   
				 frq[17] =  re ;           len[17] = 2 ;   // HA
				 frq[18] =  re ;           len[18] = 4 ;   // ETZ
				 
				 frq[19] =  do_;           len[19] = 2 ;   // EF   
				 frq[20] =  mi ;           len[20] = 2 ;   // RO
				 frq[21] =  sol;           len[21] = 2 ;   // CHIM   
	    		
				 frq[22] =  sol;           len[22] = 2 ;   // CHI
				 frq[23] =  do_;           len[23] = 7 ;   // PES   			 
				 frq[24] = do_ ;           len[24] = 0 ;    // length = 0 means end of melody
	
	
       end // case 0 

      1:   begin
  
			
			//************************************************************************************************** 
			// Sheet Music of melody: "Ode to Joy" from Bethoven's 9th symphony   ( up to 32 notes )          *
			//**************************************************************************************************
				 // First phrase
				  frq[0]  =  mi  ;      len[0]  = 2  ;   
				  frq[1]  =  mi  ;      len[1]  = 2  ;   
				  frq[2]  =  fa  ;      len[2]  = 2  ;   
				  frq[3]  =  sol ;      len[3]  = 2  ;  
				  frq[4]  =  sol ;      len[4]  = 2  ;  
				  frq[5]  =  fa  ;      len[5]  = 2  ;   
				  frq[6]  =  mi  ;      len[6]  = 2  ;   
				  frq[7]  =  re  ;      len[7]  = 2  ;   
				  frq[8]  =  do_ ;      len[8]  = 2  ;   
				  frq[9]  =  do_ ;      len[9]  = 2  ;   
				  frq[10] =  re  ;      len[10] = 2  ;  
				  frq[11] =  mi  ;      len[11] = 2  ;  
				  frq[12] =  mi  ;      len[12] = 4  ;   
				  frq[13] =  re  ;      len[13] = 1  ;  
				  frq[14] =  re  ;      len[14] = 5  ;   
				  
				  // Second phrase (repeat of first with different ending)
				  frq[15] =  mi  ;      len[15] = 2  ;  
				  frq[16] =  mi  ;      len[16] = 2  ;  
				  frq[17] =  fa  ;      len[17] = 2  ;  
				  frq[18] =  sol ;      len[18] = 2  ; 
				  frq[19] =  sol ;      len[19] = 2  ; 
				  frq[20] =  fa  ;      len[20] = 2  ;  
				  frq[21] =  mi  ;      len[21] = 2  ;  
				  frq[22] =  re  ;      len[22] = 2  ;  
				  frq[23] =  do_ ;      len[23] = 2  ; 
				  frq[24] =  do_ ;      len[24] = 2  ; 
				  frq[25] =  re  ;      len[25] = 2  ;  
				  frq[26] =  mi  ;      len[26] = 2  ;  
				  frq[27] =  re  ;      len[27] = 4  ;  
				  frq[28] =  do_ ;      len[28] = 1  ; 
				  frq[29] =  do_ ;      len[29] = 5  ; 
				  
   				 frq[30] = do_ ;     len[30] = 0 ;    // length = 0 means end of melody
				
      end // case 1
	
      2:   begin
			
			//************************************************************************************************** 
			// Sheet Music of melody:  do re mi fa sol la si do                                                *
			//**************************************************************************************************
			 
				  frq[0]  =  do_ ;      len[0]  = 2  ;   
				  frq[1]  =  re  ;      len[1]  = 2  ;   
				  frq[2]  =  mi  ;      len[2]  = 2  ;   
				  frq[3]  =  fa  ;      len[3]  = 2  ;  
				  frq[4]  =  sol ;      len[4]  = 2  ;  
				  frq[5]  =  la  ;      len[5]  = 2  ;   
				  frq[6]  =  si  ;      len[6]  = 2  ;   
				  frq[7]  =  do_H ;     len[7]  = 2  ;   
				  frq[8]  =  re_H ;     len[8]  = 6  ;   

	 			  frq[9] = do_ ;     len[9] = 0 ;    // length = 0 means end of melody
				 
      end // case 2 

      3:   begin
			
			//************************************************************************************************** 
			// Sheet Music of melody:  REVERSE ORDER OF: do re mi fa sol la si do                                                *
			//**************************************************************************************************
			 
				  frq[8]  =  do_ ;      len[8]  = 6  ;   
				  frq[7]  =  re  ;      len[7]  = 2  ;   
				  frq[6]  =  mi  ;      len[6]  = 2  ;   
				  frq[5]  =  fa  ;      len[5]  = 2  ;  
				  frq[4]  =  sol ;      len[4]  = 2  ;  
				  frq[3]  =  la  ;      len[3]  = 2  ;   
				  frq[2]  =  si  ;      len[2]  = 2  ;   
				  frq[1]  =  do_H ;     len[1]  = 2  ;   
				  frq[0]  =  re_H ;     len[0]  = 2  ;   

	 			  frq[9] = do_ ;     len[9] = 0 ;    // length = 0 means end of melody
  
      end // case 3 


      4:   begin		
			//************************************************************************************************** 
			// Sheet Music of melody:  Single Note do_                                                *
			//**************************************************************************************************			 
				  frq[0]  =  do_ ;       len[0]  = 2  ;   
	 			  frq[1] =   do_ ;       len[1]  = 0 ;    // length = 0 means end of melody
      end // case 4

      5:   begin		
			//************************************************************************************************** 
			// Sheet Music of melody:  Single Note re                                                *
			//**************************************************************************************************			 
				  frq[0]  =  re  ;       len[0]  = 2  ;   
	 			  frq[1] =   do_ ;       len[1]  = 0 ;    // length = 0 means end of melody
      end // case 5


      6:   begin		
			//************************************************************************************************** 
			// Sheet Music of melody:  Single Note mi                                                *
			//**************************************************************************************************			 
				  frq[0]  =  mi  ;       len[0]  = 2  ;   
	 			  frq[1] =   do_ ;       len[1]  = 0 ;    // length = 0 means end of melody
      end // case 6


      7:   begin		
			//************************************************************************************************** 
			// Sheet Music of melody:  Single Note fa                                                *
			//**************************************************************************************************			 
				  frq[0]  =  fa  ;       len[0]  = 2  ;   
	 			  frq[1] =   do_ ;       len[1]  = 0 ;    // length = 0 means end of melody
      end // case 7


      8:   begin		
			//************************************************************************************************** 
			// Sheet Music of melody:  Single Note sol                                                *
			//**************************************************************************************************			 
				  frq[0]  =  sol ;       len[0]  = 2  ;   
	 			  frq[1] =   do_ ;       len[1]  = 0 ;    // length = 0 means end of melody
      end // case 8


      9:   begin		
			//************************************************************************************************** 
			// Sheet Music of melody:  Single Note la                                                *
			//**************************************************************************************************			 
				  frq[0]  =  la  ;       len[0]  = 2  ;   
	 			  frq[1] =   do_ ;       len[1]  = 0 ;    // length = 0 means end of melody
      end // case 9


      10:   begin		
			//************************************************************************************************** 
			// Sheet Music of melody:  Single Note si                                                *
			//**************************************************************************************************			 
				  frq[0]  =  si  ;       len[0]  = 2  ;   
	 			  frq[1] =   do_ ;       len[1]  = 0 ;    // length = 0 means end of melody
      end // case 10


      11:   begin		
			//************************************************************************************************** 
			// Sheet Music of melody:  Single Note do_H                                                *
			//**************************************************************************************************			 
				  frq[0]  =  do_H ;      len[0]  = 2  ;   
	 			  frq[1] =   do_ ;       len[1]  = 0 ;    // length = 0 means end of melody
      end // case 11


      12:   begin		
			//************************************************************************************************** 
			// Sheet Music of melody:  Single Note re_H                                                *
			//**************************************************************************************************			 
				  frq[0]  =  re_H ;       len[0]  = 2  ;   
	 			  frq[1] =   do_  ;       len[1]  = 0 ;    // length = 0 means end of melody
      end // case 12

		
		default: begin
				
			//************************************************************************************************** 
			// Sheet Music     S O S                                                                           *
			//**************************************************************************************************
				 // First phrase
				  frq[0]  =  do_H ;      len[0]  = 2  ;   
				  frq[1]  =  do_H ;      len[1]  = 2  ;   
				  frq[2]  =  do_H ;      len[2]  = 2  ; 
				  
				  frq[3]  =  silence ;   len[3]  = 3  ;
				  
				  frq[4]  =  do_H ;      len[4]  = 4  ;  
              frq[5]  =  silence ;   len[5]  = 1  ;
				  frq[6]  =  do_H ;      len[6]  = 4  ;  
              frq[7]  =  silence ;   len[7]  = 1  ;
				  frq[8]  =  do_H ;      len[8]  = 4  ;   
				  
				  frq[9]  =  silence ;   len[9]  = 3  ;
				  
				  frq[10]  =  do_H ;     len[10]  = 2  ;   
				  frq[11]  =  do_H ;     len[11]  = 2  ;   
				  frq[12] =  do_H ;      len[12]  = 2  ;   

	 			  frq[13] = do_H ;       len[13] = 0 ;    // length = 0 means end of melod
	
      end
   endcase
  end // always 
 
//***********************************************************************
//     Extract outputs of specific note from sheet music :                                                        *
//***********************************************************************

assign tone   = frq[noteIndex] ;
assign note_length = len[noteIndex] ; 

 
 
endmodule

