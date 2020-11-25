`default_nettype none

// Quartus Prime Verilog Template
// Single port RAM with single read/write address 

module packet_buffer 
#(parameter DATA_WIDTH=8, parameter ADDR_WIDTH=6)
(
	input [(DATA_WIDTH-1):0] data,
	input [(ADDR_WIDTH-1):0] addr,
	input we, clk,
	output reg [(DATA_WIDTH-1):0] q
);

	// Declare the RAM variable
	reg [DATA_WIDTH-1:0] mem [(1<<ADDR_WIDTH)-1:0];

	// Variable to hold the registered read address
	reg [ADDR_WIDTH-1:0] addr_reg;
	
	always @ (posedge clk)
	begin
		// Write
		if (we)
			mem[addr] <= data;

		addr_reg <= addr;
	end

	// Continuous assignment implies read returns NEW data.
	// This is the natural behavior of the TriMatrix memory
	// blocks in Single Port mode.  
	
	always_comb begin
		if (addr_reg == 8'd253 || addr_reg == 8'd254)
			q = 8'hFF;
		else if (addr_reg == 8'd255)
			q = 8'h00;
		else
			q = mem[addr_reg];
	end	

endmodule
