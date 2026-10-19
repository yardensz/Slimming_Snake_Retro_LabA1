set_global_assignment -entity "CLK_31P5" -library "lib_CLK_31P5" -name IP_TOOL_NAME "altera_pll"
set_global_assignment -entity "CLK_31P5" -library "lib_CLK_31P5" -name IP_TOOL_VERSION "20.1"
set_global_assignment -entity "CLK_31P5" -library "lib_CLK_31P5" -name IP_TOOL_ENV "mwpim"
set_global_assignment -library "lib_CLK_31P5" -name SPD_FILE [file join $::quartus(sip_path) "CLK_31P5.spd"]

set_global_assignment -library "lib_CLK_31P5" -name MISC_FILE [file join $::quartus(sip_path) "CLK_31P5_sim/CLK_31P5.vo"]
