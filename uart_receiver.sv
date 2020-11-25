`default_nettype none

module uart_receiver(i_clk, i_uart_rx, o_stb, o_data);

    parameter BAUD_CYCLES = 12; // 1Mbaud @ 12MHz
    parameter BAUD_HALF_CYCLES = BAUD_CYCLES / 2;
    localparam BAUD_COUNTER_WIDTH = $clog2(BAUD_CYCLES);

    parameter BITS_PER_FRAME = 8;
    localparam BIT_COUNTER_WIDTH = $clog2(BITS_PER_FRAME);

    input i_clk;
    input i_uart_rx;
    
    output logic o_stb;
    output logic [(BITS_PER_FRAME-1):0] o_data;

    logic r_uart_rx, r_uart_rx_x;
    always_ff @(posedge i_clk)
        {r_uart_rx, r_uart_rx_x} <= {r_uart_rx_x, i_uart_rx};
    
    localparam S_wait = 2'd0, S_start = 2'd1, S_receive = 2'd2, S_receive_last = 2'd3;
    logic [1:0] state = S_wait;

    logic [(BITS_PER_FRAME-1):0] data_reg = 0;
    logic [(BIT_COUNTER_WIDTH-1):0] bit_counter = 0;
    logic [(BAUD_COUNTER_WIDTH-1):0] baud_counter = 0;

    always_ff @(posedge i_clk) begin
        case(state)
            S_wait: begin
                o_stb <= 1'b0;
                
                if (!r_uart_rx) begin
                    bit_counter <= 0;
                    if (BAUD_HALF_CYCLES > 0) begin
                        baud_counter <= BAUD_HALF_CYCLES - 1;
                        state <= S_start;
                    end else begin
                        // clock too slow for midpoint sampling
                        baud_counter <= BAUD_CYCLES - 1;
                        state <= S_receive;
                    end
                end
            end

            S_start: begin
                if (baud_counter != 0)
                    baud_counter <= baud_counter - 1'b1;
                else begin
                    if (r_uart_rx)  // false positive
                        state <= S_wait;
                    else begin
                        baud_counter <= BAUD_CYCLES - 1'b1;
                        state <= S_receive;
                    end
                end
            end

            S_receive: begin
                if (baud_counter != 0)
                    baud_counter <= baud_counter - 1'b1;
                else begin
                    baud_counter <= BAUD_CYCLES - 1'b1;
                    data_reg[bit_counter] <= r_uart_rx;
                    if (bit_counter != (BITS_PER_FRAME-1))
                        bit_counter <= bit_counter + 1'b1;
                    else
                        state <= S_receive_last;
                end
            end

            S_receive_last: begin
                if (baud_counter != 0)
                    baud_counter <= baud_counter - 1'b1;
                else begin
                    state <= S_wait;
                    if (r_uart_rx) begin // stop bit check
                        o_data <= data_reg;
                        o_stb <= 1'b1;
                    end
                end
            end

            default:
                state <= S_wait;
        endcase
    end

endmodule
