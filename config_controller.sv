`default_nettype none

module config_controller(i_clk, i_uart_rx, o_qosc_we, o_qosc_reload, o_state_led);

	parameter BAUD_CYCLES;
	
	input logic i_clk;
	input logic i_uart_rx;
	
	output logic o_qosc_we;
	output logic [31:0] o_qosc_reload;
	output logic o_state_led = 0;
	
	logic uart_stb;
	logic [7:0] uart_data;
	logic [23:0] counter_temp;
	logic [1:0] counter_shifts = 0;
	uart_receiver #(.BAUD_CYCLES(BAUD_CYCLES)) uart_rx_ctrl(
		.i_clk(i_clk), 
		.i_uart_rx(i_uart_rx), 
		.o_stb(uart_stb), 
		.o_data(uart_data)
	);
	
	// shift in new reload value
	always_ff @(posedge i_clk) begin
		o_qosc_we <= 1'b0;
		if (uart_stb) begin
			if (counter_shifts != 2'd3) begin
				counter_temp <= {counter_temp[15:0], uart_data};
				counter_shifts <= counter_shifts + 1'b1;
			end else begin
				o_qosc_reload <= {counter_temp, uart_data};
				o_qosc_we <= 1'b1;
				counter_shifts <= 2'd0;
				o_state_led <= ~o_state_led;
			end
		end
	end

endmodule
