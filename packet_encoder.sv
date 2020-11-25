`default_nettype none

module packet_encoder(i_clk, i_we, i_wdata, o_stb, i_raddr, o_rdata);
	
	input logic i_clk;
	input logic i_we;
	input logic [23:0] i_wdata;
	input logic [7:0] i_raddr;
	
	output logic o_stb;
	output logic [7:0] o_rdata;
	
	// double buffering logic
	logic buffer_index = 1'b0;
	logic rbuffer_index = 1'b0;
	
	always @(posedge i_clk)
		buffer_index <= rbuffer_index;
	
	// buffer 0
	logic [7:0] buf0_data;
	logic [7:0] buf0_addr;
	logic buf0_we;
	logic [7:0] buf0_q;
	packet_buffer #(.DATA_WIDTH(8), .ADDR_WIDTH(8)) buffer0(
		.clk(i_clk), 
		.we(buf0_we),
		.data(buf0_data),
		.addr(buf0_addr),
		.q(buf0_q)
	);
	
	// buffer 1
	logic [7:0] buf1_data;
	logic [7:0] buf1_addr;
	logic buf1_we;
	logic [7:0] buf1_q;
	packet_buffer #(.DATA_WIDTH(8), .ADDR_WIDTH(8)) buffer1(
		.clk(i_clk), 
		.we(buf1_we),
		.data(buf1_data),
		.addr(buf1_addr),
		.q(buf1_q)
	);
	
	// buffer muxing
	logic buf_we;
	logic [7:0] buf_addr;
	logic [7:0] buf_data;
	
	assign buf0_we = buffer_index ? 1'b0 : buf_we;
	assign buf1_we = buffer_index ? buf_we : 1'b0;
	
	assign buf0_addr = buffer_index ? i_raddr : buf_addr;
	assign buf1_addr = buffer_index ? buf_addr : i_raddr;
	
	assign buf0_data = buf_data;
	assign buf1_data = buf_data;
	
	assign o_rdata = buffer_index ? buf0_q : buf1_q;
	
	// register written samples
	logic [7:0] inbyte0;
	logic [7:0] inbyte1;
	logic [7:0] inbyte2;
	
	// register all but the first byte
	// this is required to achieve 1-byte-per-clock encoding
	assign inbyte0 = i_wdata[23:16];
	always_ff @(posedge i_clk)
		if (i_we)
			{inbyte1, inbyte2} <= i_wdata[15:0];
	
	// constant-cobs encode sample bytes
	localparam S_enc_b0 = 3'd0, S_enc_b1 = 3'd1, S_enc_b2 = 3'd2, S_enc_finalize = 3'd3;
	logic [2:0] state = S_enc_b0;
	
	logic [7:0] z_index = 8'd0;
	logic [7:0] p_index = 8'd1;
	
	always_ff @(posedge i_clk) begin
		// default outputs
		o_stb <= 1'b0;
		buf_we <= 1'b0;
		
		case (state)
			S_enc_b0: begin
				// start encoding immediately for 1b per clock
				if (i_we) begin
					if (inbyte0 != 0) begin
						buf_addr <= p_index;
						buf_data <= inbyte0;
						buf_we <= 1'b1;
					end else begin
						buf_addr <= z_index;
						buf_data <= p_index;
						buf_we <= 1'b1;
						z_index <= p_index;
					end
					
					p_index <= p_index + 1'b1;
					state <= S_enc_b1;
				end
			end
			
			S_enc_b1: begin
				if (inbyte1 != 0) begin
					buf_addr <= p_index;
					buf_data <= inbyte1;
					buf_we <= 1'b1;
				end else begin
					buf_addr <= z_index;
					buf_data <= p_index;
					buf_we <= 1'b1;
					z_index <= p_index;
				end
				
				p_index <= p_index + 1'b1;
				state <= S_enc_b2;
			end
			
			S_enc_b2: begin
				if (inbyte2 != 0) begin
					buf_addr <= p_index;
					buf_data <= inbyte2;
					buf_we <= 1'b1;
				end else begin
					buf_addr <= z_index;
					buf_data <= p_index;
					buf_we <= 1'b1;
					z_index <= p_index;
				end
				
				if (p_index != 8'd252) begin
					p_index <= p_index + 1'b1;
					state <= S_enc_b0;
				end else begin
					state <= S_enc_finalize;
				end
			end
			
			S_enc_finalize: begin
				buf_addr <= z_index;
				buf_data <= 8'd255;
				buf_we <= 1'b1;
				
				z_index <= 8'd0;
				p_index <= 8'd1;
				rbuffer_index <= ~rbuffer_index;
				o_stb <= 1'b1;
				
				state <= S_enc_b0;
			end
			
			default:
				state <= S_enc_b0;
		endcase
	end
	
endmodule
