`default_nettype none

module fifo(i_clk, i_write, i_wdata, i_read, o_rdata, o_empty, o_full, o_count);

    parameter FIFO_DEPTH = 64;
    parameter FIFO_WIDTH = 8;

    localparam PTR_WIDTH = $clog2(FIFO_DEPTH);

    input i_clk;
    input i_write;
    input [(FIFO_WIDTH-1):0] i_wdata;
    input i_read;
    output logic [(FIFO_WIDTH-1):0] o_rdata;
    output o_empty;
    output o_full;
    output [PTR_WIDTH:0] o_count;

    logic wrap_w = 1'b0;
    logic wrap_r = 1'b0;

    logic [(PTR_WIDTH-1):0] ptr_w = 0;
    logic [(PTR_WIDTH-1):0] ptr_r = 0;

    logic [(FIFO_WIDTH-1):0] mem [(FIFO_DEPTH-1):0];

    assign o_empty = (ptr_w == ptr_r) && (wrap_w == wrap_r);
    assign o_full = (ptr_w == ptr_r) && (wrap_w != wrap_r);
    assign o_count = ((wrap_w == wrap_r) ? 0 : FIFO_DEPTH) + ptr_w - ptr_r;

    always_ff @(posedge i_clk)
        if (i_write)
            if (!o_full) begin
                mem[ptr_w] <= i_wdata;
                if (ptr_w != (FIFO_DEPTH-1))
                    ptr_w <= ptr_w + 1'b1;
                else begin
                    ptr_w <= 0;
                    wrap_w <= ~wrap_w;
                end
            end
    
    always_ff @(posedge i_clk)
        if (i_read)
            if (!o_empty) begin
                o_rdata <= mem[ptr_r];
                if (ptr_r != (FIFO_DEPTH-1))
                    ptr_r <= ptr_r + 1'b1;
                else begin
                    ptr_r <= 0;
                    wrap_r <= ~wrap_r;
                end
            end

endmodule
