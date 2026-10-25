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
module EscanearTeclado #(parameter DWELL_BITS = 14)(   // 2^14/27MHz ~ 0.6 ms por columna
    input  logic       clk,
    input  logic       rst,
    input  logic [3:0] row_n,     // filas, activo en bajo (asincronas)
    output wire  [3:0] col_n,     // columnas, activo en bajo (0 o Z)
    output logic       key_down,
    output logic [3:0] key_code
);
    // sincronizador de 2 FF para las filas
    logic [3:0] row_s1, row_s2;
    always_ff @(posedge clk or posedge rst)
        if (rst) begin row_s1 <= 4'hF; row_s2 <= 4'hF; end
        else     begin row_s1 <= row_n; row_s2 <= row_s1; end

    // temporizador de permanencia por columna (tiempo para que la linea se asiente)
    logic [DWELL_BITS-1:0] dwell;
    always_ff @(posedge clk or posedge rst)
        if (rst) dwell <= {DWELL_BITS{1'b0}};
        else     dwell <= dwell + 1'b1;
    logic dwell_tick;
    assign dwell_tick = &dwell;

    // fila activa (la primera que se lea en 0)
    logic [1:0] row_idx;
    always_comb begin
        if      (!row_s2[0]) row_idx = 2'd0;
        else if (!row_s2[1]) row_idx = 2'd1;
        else if (!row_s2[2]) row_idx = 2'd2;
        else                 row_idx = 2'd3;
    end

    function automatic logic [3:0] keymap(input logic [1:0] r, input logic [1:0] c);
        case ({r, c})
            4'b00_00: keymap = 4'd1;   4'b00_01: keymap = 4'd2;
            4'b00_10: keymap = 4'd3;   4'b00_11: keymap = 4'd10; // A
            4'b01_00: keymap = 4'd4;   4'b01_01: keymap = 4'd5;
            4'b01_10: keymap = 4'd6;   4'b01_11: keymap = 4'd11; // B
            4'b10_00: keymap = 4'd7;   4'b10_01: keymap = 4'd8;
            4'b10_10: keymap = 4'd9;   4'b10_11: keymap = 4'd12; // C
            4'b11_00: keymap = 4'd14;  4'b11_01: keymap = 4'd0;  // '*', 0
            4'b11_10: keymap = 4'd15;  4'b11_11: keymap = 4'd13; // '#', D
        endcase
    endfunction

    logic       hold;
    logic [1:0] col_sel;
    logic [3:0] code_r;

    always_ff @(posedge clk or posedge rst)
        if (rst) begin
            hold    <= 1'b0;
            col_sel <= 2'd0;
            code_r  <= 4'd0;
        end else if (dwell_tick) begin
            if (!hold) begin
                if (row_s2 != 4'hF) begin          // hay una tecla en esta columna
                    hold   <= 1'b1;
                    code_r <= keymap(row_idx, col_sel);
                end else
                    col_sel <= col_sel + 1'b1;     // siguiente columna
            end else begin
                if (row_s2 == 4'hF) hold <= 1'b0;  // soltaron la tecla
            end
        end

    assign col_n[0] = (col_sel == 2'd0) ? 1'b0 : 1'bz;
    assign col_n[1] = (col_sel == 2'd1) ? 1'b0 : 1'bz;
    assign col_n[2] = (col_sel == 2'd2) ? 1'b0 : 1'bz;
    assign col_n[3] = (col_sel == 2'd3) ? 1'b0 : 1'bz;

    assign key_down = hold;
    assign key_code = code_r;
endmodule
