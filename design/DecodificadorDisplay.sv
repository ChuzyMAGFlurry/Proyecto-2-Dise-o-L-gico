// -----------------------------------------------------------------------------
// Modulo 2: Lectura de teclado matricial 4x4 por barrido de columnas
//
// Conexion electrica (hoja de datos Grayhill serie 96, matriz 4x4, sin resistencias):
//   terminales 1..4 = FILAS    (tecla n conecta terminal fila + terminal columna)
//   terminales 5..8 = COLUMNAS
// Las FILAS son entradas de la FPGA con pull-up (3.3 V). Las COLUMNAS se barren:
// una columna a la vez se lleva a 0 y las demas quedan en alta impedancia (Z).
// Si una tecla esta presionada, su fila se lee en 0 mientras su columna esta activa.
// Nunca se aplican mas de 3.3 V al teclado.
//
// Al encontrar una tecla el barrido se DETIENE (hold) y key_down=1 mientras siga
// presionada; esa senal es la que entra al antirrebote. key_code queda estable.
//
// Mapa de teclas (leyenda): 1 2 3 A / 4 5 6 B / 7 8 9 C / * 0 # D
// key_code: 0-9 = digitos, 10=A, 11=B, 12=C, 13=D, 14='*', 15='#'
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
    logic is_digit = ~key_code[3] | ~(key_code[2] | key_code[1]);
    logic is_clear = (key_code == 4'd14);

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
