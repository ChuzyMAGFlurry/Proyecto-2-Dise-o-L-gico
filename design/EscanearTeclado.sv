// Modulo 2: Lectura de teclado matricial 4x4 por barrido de columnas
// Conexion electrica (hoja de datos Grayhill serie 96, matriz 4x4, sin resistencias):

module EscanearTeclado #(parameter DWELL_BITS = 14)(   // 2^14/27MHz ~ 0.6 ms por columna, tarda como 0,6ms en cambiar de columna 
    input  logic       clk,
    input  logic       rst,
    input  logic [3:0] row_n,     // filas del teclado, activo en bajo (asincronas)
    output wire  [3:0] col_n,     // columnas del teclado, activo en bajo (0 o Z)
    output logic       key_down, //si hay una tecla presionada (1 si hay tecla, o si no)
    output logic [3:0] key_code  //se supone que cuenta de 0 al 15 porque va desde la fila 0 hasta la 3 (osea la cuarta)
);
    // sincronizador de 2 FF para las filas
    logic [3:0] row_s1, row_s2;                 //dos registros en cascada              
    always_ff @(posedge clk or posedge rst)     //al reiniciarse todas empiezan en alto, sin presionar
        if (rst) begin row_s1 <= 4'hF; row_s2 <= 4'hF; end
        else     begin row_s1 <= row_n; row_s2 <= row_s1; end

    // tiempo por columna
    logic [DWELL_BITS-1:0] dwell;                   //contador que incrementa su valor en cada ciclo de reloj
    always_ff @(posedge clk or posedge rst)            //se activa en 1 cuando la to_dos los bits del contador dwell llegan a 1 avanzando en la siguiente columna
        if (rst) dwell <= {DWELL_BITS{1'b0}};           
        else     dwell <= dwell + 1'b1;
    logic dwell_tick;
    assign dwell_tick = &dwell;

    // fila activa (la primera que se lea en 0)
    logic [1:0] row_idx;                            //es un codificador de prioridad Revisa las 4 lineas de fila sincronizadas y ve cual está en bajo asignando un indice (0 a 3) a la variable
    always_comb begin
        if      (!row_s2[0]) row_idx = 2'd0;
        else if (!row_s2[1]) row_idx = 2'd1;
        else if (!row_s2[2]) row_idx = 2'd2;
        else                 row_idx = 2'd3;
    end

    function automatic logic [3:0] keymap(input logic [1:0] r, input logic [1:0] c);       //toma las coordenadas, fila r, columna c y las hace un punto(r,c) y devuelve el código de tecla estandar 
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
            hold    <= 1'b0;                        //indica si el escaner se congeló porque encontró una tecla
            col_sel <= 2'd0;                        //selecicona cual columna se está barriendo 
            code_r  <= 4'd0;                        //almacena el dato en la tecla detectada
        end else if (dwell_tick) begin
            if (!hold) begin                        //si no hay tecla retenida
                if (row_s2 != 4'hF) begin          // si una fila se leyo en bajo revisa su columna y hace el keymap
                    hold   <= 1'b1;         
                    code_r <= keymap(row_idx, col_sel);
                end else
                    col_sel <= col_sel + 1'b1;     //en otro caso pasa a la siguiente columna
            end else begin
                if (row_s2 == 4'hF) hold <= 1'b0;  // si sigue presionada la tecla esperará a que todas las filas vuelvan a estar en alto (osea se suelte la tecla)
            end
        end

    assign col_n[0] = (col_sel == 2'd0) ? 1'b0 : 1'bz;      //la columna que se selecciona se pone en nivel bajo al ser comparada y las demás se ponen en alta impedancia ( 1'bz)
    assign col_n[1] = (col_sel == 2'd1) ? 1'b0 : 1'bz;
    assign col_n[2] = (col_sel == 2'd2) ? 1'b0 : 1'bz;
    assign col_n[3] = (col_sel == 2'd3) ? 1'b0 : 1'bz;

    assign key_down = hold;                     //esta es la primera salida que es directamente el estado de "sostener"
    assign key_code = code_r;                      //expone el código de la tecla presionada (su identificación del mapa de arriba )
endmodule
