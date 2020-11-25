`default_nettype none

module clock_divider(
    i_clk,
    i_stb,
    o_stb
);
    
    // parameters
    parameter DIVIDER_WIDTH = 1;
    parameter DIVIDER_STEP = 1;

    // input ports
    input logic i_clk;
    input logic i_stb;

    // output ports
    output logic o_stb;

    // module
    logic [(DIVIDER_WIDTH-1):0] counter;

    initial begin
        counter <= 0;
		  o_stb <= 0;
    end

    always_ff @(posedge i_clk) begin
        if (i_stb) begin
            {o_stb, counter} <= counter + DIVIDER_STEP;
        end else begin
            o_stb <= 0;
        end
    end

endmodule
