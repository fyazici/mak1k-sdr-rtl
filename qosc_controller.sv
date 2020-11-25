`default_nettype none

module qosc_controller(i_clk, i_pll_clk, i_we, i_reload, o_quad_pulse);
	
	input logic i_clk;
	input logic i_pll_clk;
	input logic i_we;
	input logic [31:0] i_reload;
	
	output logic [3:0] o_quad_pulse;
	
	// reload signal clock domain crossing
	logic r_we, r_we_x;
	logic [31:0] r_reload = 32'd63;
	
	always_ff @(posedge i_pll_clk)
		{r_we, r_we_x} <= {r_we_x, i_we};
	
	always_ff @(posedge i_clk)
		if (r_we)
			r_reload <= i_reload;
		
	// pulse generator
	logic [31:0] counter = 32'h00010000;
	logic [3:0] pulse_ring = 4'b0001;
	
	always_ff @(posedge i_pll_clk)
		if (counter != 0)
			counter <= counter - 1'b1;
		else begin
			counter <= r_reload;
			pulse_ring <= {pulse_ring[2:0], pulse_ring[3]};
		end
	
	assign o_quad_pulse = pulse_ring;
	
endmodule
