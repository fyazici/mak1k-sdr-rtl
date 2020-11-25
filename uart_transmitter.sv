`default_nettype none

module uart_transmitter(i_clk, i_stb, i_data, o_ack, o_uart_tx);

    parameter BAUD_CYCLES = 12; // 1Mbaud @ 12MHz
    localparam BAUD_COUNTER_WIDTH = $clog2(BAUD_CYCLES);

    parameter BITS_PER_FRAME = 8;
    localparam BIT_COUNTER_WIDTH = $clog2(BITS_PER_FRAME);

    input i_clk;
    input i_stb;
    input [(BITS_PER_FRAME-1):0] i_data;
    
    output logic o_ack;
    output logic o_uart_tx;

    localparam S_start = 2'd0, S_transmit = 2'd1, S_transmit_last = 2'd2;
    logic [1:0] state = S_start;

    logic [(BITS_PER_FRAME-1):0] data_reg = 0;
    logic [(BIT_COUNTER_WIDTH-1):0] bit_counter = 0;
    logic [(BAUD_COUNTER_WIDTH-1):0] baud_counter = 0;

    always_ff @(posedge i_clk) begin
        case (state)
            S_start: begin
                o_uart_tx <= 1'b1;
                o_ack <= 1'b0;

                if (baud_counter != 0)
                    baud_counter <= baud_counter - 1'b1;
                else if (i_stb) begin
                    o_uart_tx <= 1'b0;
                    data_reg <= i_data;
                    o_ack <= 1'b1;
                    bit_counter <= 0;
                    baud_counter <= BAUD_CYCLES - 1;
                    state <= S_transmit;
                end
            end

            S_transmit: begin
                o_ack <= 1'b0;
                if (baud_counter != 0)
                    baud_counter <= baud_counter - 1'b1;
                else begin
                    baud_counter <= BAUD_CYCLES - 1;
                    o_uart_tx <= data_reg[bit_counter];
                    if (bit_counter != (BITS_PER_FRAME-1))
                        bit_counter <= bit_counter + 1'b1;
                    else
                        state <= S_transmit_last;
                end
            end

            S_transmit_last: begin
                if (baud_counter != 0)
                    baud_counter <= baud_counter - 1'b1;
                else begin
                    baud_counter <= BAUD_CYCLES - 1;
                    o_uart_tx <= 1'b1;
                    state <= S_start;
                end
            end

            default:
                state <= S_start;
        endcase
    end

endmodule
