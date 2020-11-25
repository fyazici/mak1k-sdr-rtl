`default_nettype none

module top(
	// CLOCKS
	input CLK12M,
	input CLK_X,
	
	// LEDS
	output [7:0] LED,
	
	// BUTTONS
	input USER_BTN,
	
	// ACCELEROMETER
	input SEN_INT1,
	input SEN_INT2,
	output SEN_SDI,
	input SEN_SDO,
	output SEN_SPC,
	output SEN_CS,
	
	// SDRAM
	output [13:0] SDRAM_A,
	output [1:0] SDRAM_BA,
	output SDRAM_CLK,
	output SDRAM_CKE,
	output SDRAM_RAS,
	output SDRAM_CAS,
	output SDRAM_WE,
	output SDRAM_CS,
	inout [15:0] SDRAM_DQ,
	output [1:0] SDRAM_DQM,
	
	// EXT FLASH
	output FLASH_CS,
	output FLASH_CLK,
	inout FLASH_DI,
	input FLASH_DO,
	
	// DUAL FUNCTION ADC INPUTS (NOT AVAILABLE IF BANK 1A USED FOR ADC)
	// ADC_AIN,
	
	// DIGITAL USER IO
	inout [14:0] USER_DIO,
	
	// PMOD IO
	inout [7:0] PIO,
	
	// FT2232H UART
	input FT2232H_TX,
	output FT2232H_RX
);
	
	logic input_clk;
	logic adc0_clk;
	logic qosc_clk;
	logic core_clk;
	logic pll1_locked;
	system_pll1 pll1_inst(
		.inclk0(input_clk), 
		.locked(pll1_locked), 
		.c0(adc0_clk), 
		.c1(qosc_clk), 
		.c2(core_clk)
	);
	
	logic adc_sample_stb;
	logic [11:0] adc_sample_i;
	logic [11:0] adc_sample_q;
	adc_controller adc_controller_inst(
		.i_clk(core_clk), 
		.i_pll_clk(adc0_clk), 
		.i_pll_locked(pll1_locked), 
		.o_sample_stb(adc_sample_stb),
		.o_sample_i(adc_sample_i),
		.o_sample_q(adc_sample_q)
	);
	
	logic qosc_we;
	logic [31:0] qosc_reload;
	logic [3:0] qosc_pulse_outputs;
	qosc_controller qosc_controller_inst(
		.i_clk(core_clk),
		.i_pll_clk(qosc_clk),
		.i_we(qosc_we),
		.i_reload(qosc_reload),
		.o_quad_pulse(qosc_pulse_outputs)
	);
	
	localparam UART_BAUD_CYCLES = 6;
	
	logic uart_rx;
	logic config_state_led;
	config_controller #(.BAUD_CYCLES(UART_BAUD_CYCLES)) config_controller_inst(
		.i_clk(core_clk),
		.i_uart_rx(uart_rx),
		.o_qosc_we(qosc_we),
		.o_qosc_reload(qosc_reload),
		.o_state_led(config_state_led)
	);
	
	logic uart_tx;
	sample_controller #(.BAUD_CYCLES(UART_BAUD_CYCLES)) sample_controller_inst(
		.i_clk(core_clk),
		.i_sample_stb(adc_sample_stb),
		.i_sample_i(adc_sample_i),
		.i_sample_q(adc_sample_q),
		.o_uart_tx(uart_tx)
	);
	
	assign input_clk = CLK12M;
	assign USER_DIO[9:6] = qosc_pulse_outputs;
	assign uart_rx = FT2232H_TX;
	assign FT2232H_RX = uart_tx;
	assign LED[0] = config_state_led;
	
	assign PIO[4] = uart_rx;
	assign PIO[5] = uart_tx;
	
endmodule	
