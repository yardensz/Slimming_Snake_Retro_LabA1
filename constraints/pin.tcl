#============================================================
# DEFINE PROJECT NAME !!!!!!!!!!!!!
# set proj_name Lab1Demo
# file for VGA lab containg also VGA and audio pins  
#============================================================


#============================================================
# Device's details
#============================================================
set_global_assignment -name FAMILY "Cyclone V"
set_global_assignment -name DEVICE 5CSXFC6D6F31C6
set_global_assignment -name NUM_PARALLEL_PROCESSORS ALL
#set_global_assignment -name SMART_COMPILE ON
#set_global_assignment -name OPTIMIZATION_MODE "FAST FIT"
#set_global_assignment -name FITTER_EFFORT "LOW"
#set_global_assignment -name TIMEQUEST_FLOW OFF
#set_global_assignment -name POWER_ANALYSIS OFF
#set_global_assignment -name ECO_OPTIMIZATION OFF
set_global_assignment  -name PHYSICAL_SYNTHESIS_EFFORT  FAST
set_global_assignment  -name FITTER_EFFORT         "FAST_FIT"
#execute_flow -implement
set_global_assignment -name PHYSICAL_SYNTHESIS_COMBO_LOGIC OFF
set_global_assignment -name PHYSICAL_SYNTHESIS_REGISTER_DUPLICATION OFF

set_global_assignment -name PHYSICAL_SYNTHESIS_ASYNCHRONOUS_SIGNAL_PIPELINING OFF
set_global_assignment -name OPTIMIZE_HOLD_TIMING OFF
set_global_assignment -name INCREMENTAL_COMPILATION ON


#============================================================
# CLOCK
#============================================================
set_location_assignment PIN_AF14 -to CLOCK_50


#============================================================
# KEY
#============================================================
set_location_assignment PIN_AJ4 -to resetN_pin  ; # KEY[0]
set_location_assignment PIN_AK4 -to KEY[1]
set_location_assignment PIN_AA14 -to KEY[2]
set_location_assignment PIN_AA15 -to KEY[3]

#============================================================
# SW
#============================================================
set_location_assignment PIN_AB30 -to SW[0] ; #SW[0]
set_location_assignment PIN_Y27 -to SW[1] ; #SW[1]
set_location_assignment PIN_AB28 -to SW[2] ; #SW[2]
set_location_assignment PIN_AC30 -to SW[3] ; #SW[3]
set_location_assignment PIN_W25 -to SW[4] ; #SW[4]
set_location_assignment PIN_V25 -to SW[5] ; #SW[5]
set_location_assignment PIN_AC28 -to SW[6] ;# SW[6]
set_location_assignment PIN_AD30 -to SW[7] ;#SW[7]
set_location_assignment PIN_AC29 -to SW[8] ;#SW[8]
set_location_assignment PIN_AA30 -to SW[9] ;#ENABLE_SOF --if want to stop smiley move with sw9


#============================================================
# LED
#============================================================ 
set_location_assignment PIN_AA24 -to ball_toggle ;#LEDR[0]
set_location_assignment PIN_AB23 -to ir_write
set_location_assignment PIN_AC23 -to sound_on
set_location_assignment PIN_AD24 -to LEDR[3]
set_location_assignment PIN_AG25 -to LEDR[4]
set_location_assignment PIN_AF25 -to numKey[0]
set_location_assignment PIN_AE24 -to numKey[1]
set_location_assignment PIN_AF24 -to numKey[2]
set_location_assignment PIN_AB22 -to numKey[3]
set_location_assignment PIN_AC22 -to AUDOUT[0] ;#MICROPHON_LED ; #LEDR[9]
set_location_assignment PIN_AF9 -to redLight
set_location_assignment PIN_AE7 -to yellowLight
set_location_assignment PIN_AE11 -to greenLight



#============================================================
# Seg7
#============================================================
set_location_assignment PIN_W17 -to HEX0[0]
set_location_assignment PIN_V18 -to HEX0[1]
set_location_assignment PIN_AG17 -to HEX0[2]
set_location_assignment PIN_AG16 -to HEX0[3]
set_location_assignment PIN_AH17 -to HEX0[4]
set_location_assignment PIN_AG18 -to HEX0[5]
set_location_assignment PIN_AH18 -to HEX0[6]
set_location_assignment PIN_AF16 -to HEX1[0]
set_location_assignment PIN_V16 -to HEX1[1]
set_location_assignment PIN_AE16 -to HEX1[2]
set_location_assignment PIN_AD17 -to HEX1[3]
set_location_assignment PIN_AE18 -to HEX1[4]
set_location_assignment PIN_AE17 -to HEX1[5]
set_location_assignment PIN_V17 -to HEX1[6]
set_location_assignment PIN_AA21 -to HEX2[0]
set_location_assignment PIN_AB17 -to HEX2[1]
set_location_assignment PIN_AA18 -to HEX2[2]
set_location_assignment PIN_Y17 -to HEX2[3]
set_location_assignment PIN_Y18 -to HEX2[4]
set_location_assignment PIN_AF18 -to HEX2[5]
set_location_assignment PIN_W16 -to HEX2[6]
set_location_assignment PIN_Y19 -to HEX3[0]
set_location_assignment PIN_W19 -to HEX3[1]
set_location_assignment PIN_AD19 -to HEX3[2]
set_location_assignment PIN_AA20 -to HEX3[3]
set_location_assignment PIN_AC20 -to HEX3[4]
set_location_assignment PIN_AA19 -to HEX3[5]
set_location_assignment PIN_AD20 -to HEX3[6]
set_location_assignment PIN_AD21 -to HEX4[0]
set_location_assignment PIN_AG22 -to HEX4[1]
set_location_assignment PIN_AE22 -to HEX4[2]
set_location_assignment PIN_AE23 -to HEX4[3]
set_location_assignment PIN_AG23 -to HEX4[4]
set_location_assignment PIN_AF23 -to HEX4[5]
set_location_assignment PIN_AH22 -to HEX4[6]
set_location_assignment PIN_AF21 -to HEX5[0]
set_location_assignment PIN_AG21 -to HEX5[1]
set_location_assignment PIN_AF20 -to HEX5[2]
set_location_assignment PIN_AG20 -to HEX5[3]
set_location_assignment PIN_AE19 -to HEX5[4]
set_location_assignment PIN_AF19 -to HEX5[5]
set_location_assignment PIN_AB21 -to HEX5[6]

#============================================================
# VGA
#============================================================
set_location_assignment PIN_AK22 -to OVGA[27]  ;# VGA_BLANK_N
set_location_assignment PIN_AJ21 -to  OVGA[16] ;#VGA_B[0]
set_location_assignment PIN_AJ20 -to  OVGA[17] ;#VGA_B[1]
set_location_assignment PIN_AH20 -to  OVGA[18] ;#VGA_B[2]
set_location_assignment PIN_AJ19 -to  OVGA[19] ;#VGA_B[3]
set_location_assignment PIN_AH19 -to  OVGA[20] ;#VGA_B[4]
set_location_assignment PIN_AJ17 -to  OVGA[21] ;#VGA_B[5]
set_location_assignment PIN_AJ16 -to  OVGA[22] ;#VGA_B[6]
set_location_assignment PIN_AK16 -to  OVGA[23]  ;#VGA_B[7]
set_location_assignment PIN_AK21 -to OVGA[28] ;#VGA_CLK
set_location_assignment PIN_AK26 -to OVGA[8] ;#VGA_G[0]
set_location_assignment PIN_AJ25 -to OVGA[9] ;#VGA_G[1]
set_location_assignment PIN_AH25 -to OVGA[10] ;#VGA_G[2]
set_location_assignment PIN_AK24 -to OVGA[11] ;#VGA_G[3]
set_location_assignment PIN_AJ24 -to OVGA[12] ;#VGA_G[4]
set_location_assignment PIN_AH24 -to OVGA[13] ;#VGA_G[5]
set_location_assignment PIN_AK23 -to OVGA[14] ;#VGA_G[6]
set_location_assignment PIN_AH23 -to OVGA[15] ;#VGA_G[7]
set_location_assignment PIN_AK19 -to OVGA[24] ;#VGA_HS
set_location_assignment PIN_AK29 -to OVGA[0] ;#VGA_R[0]
set_location_assignment PIN_AK28 -to OVGA[1] ;#VGA_R[1]
set_location_assignment PIN_AK27 -to OVGA[2] ;#VGA_R[2]
set_location_assignment PIN_AJ27 -to OVGA[3] ;#VGA_R[3]
set_location_assignment PIN_AH27 -to OVGA[4] ;#VGA_R[4]
set_location_assignment PIN_AF26 -to OVGA[5] ;#VGA_R[5]
set_location_assignment PIN_AG26 -to OVGA[6] ;#VGA_R[6]
set_location_assignment PIN_AJ26 -to OVGA[7] ;#VGA_R[7]
set_location_assignment PIN_AJ22 -to OVGA[26] ;#VGA_SYNC_N
set_location_assignment PIN_AK18 -to OVGA[25] ;#VGA_VS

#============================================================
# Audio
#============================================================
set_location_assignment PIN_AJ29 -to AUD_ADCDAT
set_location_assignment PIN_AH29 -to AUDIN[1] ;#AUD_ADCLRCK
set_location_assignment PIN_AF30 -to AUDIN[2] ;#AUD_BCLK
set_location_assignment PIN_AF29 -to AUDOUT[4] ;#AUD_DACDAT  
set_location_assignment PIN_AG30 -to AUDIN[3] ;#AUD_DACLRCK
set_location_assignment PIN_AH30 -to AUDOUT[5] ;#AUD_XCK

#============================================================
# PS2
#============================================================
set_location_assignment PIN_AB25 -to PS2_CLK
set_location_assignment PIN_AA25 -to PS2_DAT

#============================================================
# ADC
#============================================================
set_location_assignment PIN_Y21 -to ADC_CONVST
set_location_assignment PIN_W22 -to ADC_DIN
set_location_assignment PIN_V23 -to ADC_DOUT
set_location_assignment PIN_W24 -to ADC_SCLK

#============================================================
# I2C for Audio and Video-In
#============================================================
set_location_assignment PIN_Y24 -to AUDOUT[6] ;#AUD_I2C_SCLK
set_location_assignment PIN_Y23 -to AUDOUT[7] ;#AUD_I2C_SDAT

#============================================================
# Assigning 3.3 V to all pins
#============================================================
		  
set name_ids [get_names -filter * -node_type pin]

    foreach_in_collection name_id $name_ids {
        set pin_name [get_name_info -info full_path $name_id]
        post_message "Assigning 3.3-V LVTTL to $pin_name"
		set_instance_assignment -name IO_STANDARD "3.3-V LVTTL" -to $pin_name
          }
		  
export_assignments
