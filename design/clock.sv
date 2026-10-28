module top (
    input  wire clk27,
    output reg  clk_out
);
    reg [23:0] accumulator = 24'd0;
    localparam [23:0] INCREMENT = 24'd1145325; // 1.8432006 MHz (error ~0.6 Hz)

    always @(posedge clk27) begin
        accumulator <= accumulator + INCREMENT;
        clk_out     <= accumulator[23];
    end
endmodule
