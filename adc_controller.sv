`default_nettype none

module adc_controller(i_clk, i_pll_clk, i_pll_locked, o_sample_stb, o_sample_i, o_sample_q);

	parameter CHANNEL_I = 5'd3;
	parameter CHANNEL_Q = 5'd4;

	input logic i_clk;
	input logic i_pll_clk;
	input logic i_pll_locked;
	
	output logic o_sample_stb;
	output logic [11:0] o_sample_i;
	output logic [11:0] o_sample_q;
	
	// adc controller ip core instance
	logic adc_controller_reset_n;
	logic adc_command_valid;
	logic [4:0] adc_command_channel;
	logic adc_command_sop;
	logic adc_command_eop;
	logic adc_command_ready;
	logic adc_response_valid;
	logic [11:0] adc_response_data;

	system_adc1 adc1_inst(
		.adc_pll_clock_clk(i_pll_clk),
		.adc_pll_locked_export(i_pll_locked),
		.clock_clk(i_clk),
		.reset_sink_reset_n(adc_controller_reset_n),
		.command_valid(adc_command_valid),
		.command_channel(adc_command_channel),
		.command_startofpacket(adc_command_sop),
		.command_endofpacket(adc_command_eop),
		.command_ready(adc_command_ready),
		.response_valid(adc_response_valid),
		.response_data(adc_response_data)
	);
	
	assign adc_controller_reset_n = 1'b1;	// reset not used
	assign adc_command_eop = 1'b0;			// continuous reading

	localparam S_start = 2'b00, S_read_i = 2'b01, S_read_q = 2'b11;
	logic [1:0] state = S_start;
	
	always_ff @(posedge i_clk) begin
		o_sample_stb <= 1'b0;
		
		case (state)
			S_start: begin
				adc_command_valid <= 1'b1;
				adc_command_channel <= CHANNEL_I;
				adc_command_sop <= 1'b1;
				
				if (adc_command_ready) begin
					adc_command_sop <= 1'b0;
					adc_command_channel <= CHANNEL_Q;
					state <= S_read_i;
				end
			end
			
			S_read_i: begin
				if (adc_response_valid) begin
					o_sample_i <= adc_response_data;
					adc_command_channel <= CHANNEL_I;
					state <= S_read_q;
				end
			end
			
			S_read_q: begin
				if (adc_response_valid) begin	
					o_sample_q <= adc_response_data;
					o_sample_stb <= 1'b1;
					adc_command_channel <= CHANNEL_Q;
					state <= S_read_i;
				end
			end
			
			default:
				state <= S_start;
		endcase
	end
		
endmodule
