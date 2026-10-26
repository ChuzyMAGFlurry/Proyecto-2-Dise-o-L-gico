// -----------------------------------------------------------------------------
// Modulo 2: Decodificador y Control de Display de 7 Segmentos (Corregido)
// -----------------------------------------------------------------------------
module DecodificadorDisplay #(
    parameter SEG_ACTIVE_LOW = 0,
    parameter DIG_ACTIVE_LOW = 0
)(
    input  logic        clk,
    input  logic        rst,
    input  logic        key_valid,
    input  logic [3:0]  key_code,
    output logic [6:0]  seg,
    output logic [3:0]  dig,
    output logic [9:0]  value
);
    // ---------------- captura, binario y BCD ----------------
    // CORRECCIÓN: Se usa 'wire' para que la lógica sea combinacional y se actualice con key_code
    wire is_digit = ~key_code[3] | ~(key_code[2] | key_code[1]);
    wire is_clear = (key_code == 4'd14);

    logic [1:0] count;
    logic [3:0] d2, d1, d0;   // centenas, decenas, unidades (BCD)

    always_ff @(posedge clk or posedge rst)
        if (rst) begin
            value <= 10'd0;
            count <= 2'd0;
            d2 <= 4'd0; d1 <= 4'd0; d0 <= 4'd0;
        end else if (key_valid) begin
            if (is_clear) begin
                value <= 10'd0;
                count <= 2'd0;
                d2 <= 4'd0; d1 <= 4'd0; d0 <= 4'd0;
            end else if (is_digit && count < 2'd3) begin
                value <= value * 10 + key_code;
                count <= count + 1'b1;
                d2 <= d1; d1 <= d0; d0 <= key_code;
            end
        end

    // ---------------- multiplexado del display ----------------
    logic [15:0] rcnt;
    always_ff @(posedge clk or posedge rst)
        if (rst) rcnt <= 16'd0;
        else     rcnt <= rcnt + 1'b1;
    logic [1:0] sel = rcnt[15:14];

    logic [3:0] nib;
    logic       blank;
    always_comb begin
        case (sel)
            2'd0: begin nib = d2; blank = (d2 == 4'd0);                 end // izquierda -> centenas
            2'd1: begin nib = d1; blank = (d2 == 4'd0) && (d1 == 4'd0); end // centro    -> decenas
            2'd2: begin nib = d0; blank = 1'b0;                         end // derecha   -> unidades
            default: begin nib = 4'd0; blank = 1'b1;                    end // extremo derecho apagado
        endcase
    end

    // g f e d c b a (1 = encendido)
    function automatic logic [6:0] decode(input logic [3:0] n);
        case (n)
            4'd0: decode = 7'b0111111;
            4'd1: decode = 7'b0000110;
            4'd2: decode = 7'b1011011;
            4'd3: decode = 7'b1001111;
            4'd4: decode = 7'b1100110;
            4'd5: decode = 7'b1101101;
            4'd6: decode = 7'b1111101;
            4'd7: decode = 7'b0000111;
            4'd8: decode = 7'b1111111;
            4'd9: decode = 7'b1101111;
            default: decode = 7'b0000000;
        endcase
    endfunction

    logic [6:0] seg_on = decode(nib);
    logic [3:0] dig_on = blank ? 4'b0000 : (4'b0001 << sel);

    always_ff @(posedge clk) begin
        seg <= SEG_ACTIVE_LOW ? ~seg_on : seg_on;
        dig <= DIG_ACTIVE_LOW ? ~dig_on : dig_on;
    end
endmodule
