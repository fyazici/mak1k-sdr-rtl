`default_nettype none

module sample_controller(i_clk, i_sample_stb, i_sample_i, i_sample_q, o_uart_tx);
	
	parameter BAUD_CYCLES;
	
	input logic i_clk;
	input logic i_sample_stb;
	input logic [11:0] i_sample_i;
	input logic [11:0] i_sample_q;
	
	output logic o_uart_tx;
	
	logic uart_stb;
	logic [7:0] uart_data;
	logic uart_ack;
	uart_transmitter #(.BAUD_CYCLES(BAUD_CYCLES)) uart_tx_inst(
		.i_clk(i_clk), 
		.i_stb(uart_stb), 
		.i_data(uart_data), 
		.o_ack(uart_ack),
		.o_uart_tx(o_uart_tx)
	);
	
	logic [23:0] sample_packet;
	assign sample_packet = {i_sample_i, i_sample_q};
	
	logic penc_we;
	logic [23:0] penc_wdata;
	logic penc_packet_stb;
	logic [7:0] penc_raddr;
	logic [7:0] penc_rdata;
	packet_encoder packet_encoder_inst(
		.i_clk(i_clk),
		.i_we(penc_we),
		.i_wdata(penc_wdata),
		.o_stb(penc_packet_stb),
		.i_raddr(penc_raddr),
		.o_rdata(penc_rdata)
	);
	
	assign penc_we = i_sample_stb;
	assign penc_wdata = sample_packet;
	assign uart_data = penc_rdata;
	
	localparam S_wait = 2'd0, S_begin = 2'd1, S_transmit = 2'd2, S_finish = 2'd3;
	logic [1:0] state = S_wait;
	
	always_ff @(posedge i_clk) begin
		case (state)
			S_wait: begin
				uart_stb <= 1'b0;
				
				if (penc_packet_stb) begin
					penc_raddr <= 8'd0;
					state <= S_begin;
				end
			end
			
			S_begin: begin
				uart_stb <= 1'b1;
				state <= S_transmit;
			end
			
			S_transmit: begin
				if (uart_ack) begin
					uart_stb <= 1'b1;
					
					if (penc_raddr != 8'd255)
						penc_raddr <= penc_raddr + 1'b1;
					else begin
						uart_stb <= 1'b0;
						state <= S_wait;
					end
				end
			end
			
			default:
				state <= S_wait;
		endcase
	end
	
endmodule
