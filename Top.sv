// Top: teclado 4x4 -> antirrebote -> captura -> display. Tang Nano 9K (reloj 27 MHz)
module top #(
    parameter DWELL_BITS = 14,   // barrido: 2^14 ciclos por columna
    parameter DB_N       = 19    // antirrebote: 2^19 ciclos ~ 19.4 ms
)(
    input  logic       clk,
    input  logic [3:0] row,
    output wire  [3:0] col,
    output logic [6:0] seg,
    output logic [3:0] dig
);
    // reset de encendido (sin boton externo)
    logic [3:0] por = 4'd0;
    always_ff @(posedge clk) if (!(&por)) por <= por + 1'b1;
    logic rst;
    assign rst = ~(&por);

    logic       key_down, db_level, db_tick;
    logic [3:0] key_code;
    logic [9:0] valor_bin;   // numero en binario, para la resta de la siguiente parte

    EscanearTeclado #(.DWELL_BITS(DWELL_BITS)) u_scan (
        .clk(clk), .rst(rst), .row_n(row), .col_n(col),
        .key_down(key_down), .key_code(key_code)
    );

    debounce #(.N(DB_N)) u_db (
        .clk(clk), .reset(rst), .sw(key_down),
        .db_level(db_level), .db_tick(db_tick)
    );

    DecodificadorDisplay #(.SEG_ACTIVE_LOW(0), .DIG_ACTIVE_LOW(0)) u_disp (
        .clk(clk), .rst(rst), .key_valid(db_tick), .key_code(key_code),
        .seg(seg), .dig(dig), .value(valor_bin)
    );
endmodule
