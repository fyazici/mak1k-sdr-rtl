set_global_assignment -entity "system_adc1" -library "lib_system_adc1" -name IP_TOOL_NAME "Qsys"
set_global_assignment -entity "system_adc1" -library "lib_system_adc1" -name IP_TOOL_VERSION "19.1"
set_global_assignment -entity "system_adc1" -library "lib_system_adc1" -name IP_TOOL_ENV "Qsys"
set_global_assignment -library "lib_system_adc1" -name SPD_FILE [file join $::quartus(sip_path) "../system_adc1.spd"]
set_global_assignment -library "lib_system_adc1" -name MISC_FILE [file join $::quartus(sip_path) "../../system_adc1.qsys"]

set_global_assignment -library "lib_system_adc1" -name MISC_FILE [file join $::quartus(sip_path) "system_adc1.v"]
set_global_assignment -library "lib_system_adc1" -name MISC_FILE [file join $::quartus(sip_path) "submodules/system_adc1_modular_adc_0.v"]
set_global_assignment -library "lib_system_adc1" -name MISC_FILE [file join $::quartus(sip_path) "submodules/altera_modular_adc_control.v"]
set_global_assignment -library "lib_system_adc1" -name MISC_FILE [file join $::quartus(sip_path) "submodules/altera_modular_adc_control_avrg_fifo.v"]
set_global_assignment -library "lib_system_adc1" -name MISC_FILE [file join $::quartus(sip_path) "submodules/altera_modular_adc_control_fsm.v"]
set_global_assignment -library "lib_system_adc1" -name MISC_FILE [file join $::quartus(sip_path) "submodules/chsel_code_converter_sw_to_hw.v"]
set_global_assignment -library "lib_system_adc1" -name MISC_FILE [file join $::quartus(sip_path) "submodules/fiftyfivenm_adcblock_primitive_wrapper.v"]
set_global_assignment -library "lib_system_adc1" -name MISC_FILE [file join $::quartus(sip_path) "submodules/fiftyfivenm_adcblock_top_wrapper.v"]
