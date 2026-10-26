module top #(
    parameter DWELL_BITS = 14,
    parameter DB_N       = 19,
    parameter SEG_ACTIVE_LOW = 0,
    parameter DIG_ACTIVE_LOW = 0
)(
    input  logic       clk,
    input  logic [3:0] row,

    // Botones fisicos de la Tang Nano 9K
    input  logic       s1,
    input  logic       s2,

    output logic [3:0] col,
    output logic [6:0] seg,
    output logic [3:0] dig
);

    // ---------------------------------------------------------
    // Reinicio inicial
    // ---------------------------------------------------------
    logic [3:0] por = 4'd0;

    always_ff @(posedge clk) begin
        if (!(&por))
            por <= por + 1'b1;
    end

    logic rst;
    assign rst = ~(&por);


    // ---------------------------------------------------------
    // Teclado y antirrebote
    // ---------------------------------------------------------
    logic key_down;
    logic db_level;
    logic db_tick;
    logic [3:0] key_code;

    EscanearTeclado #(
        .DWELL_BITS(DWELL_BITS)
    ) u_scan (
        .clk(clk),
        .rst(rst),
        .row_n(row),
        .col_n(col),
        .key_down(key_down),
        .key_code(key_code)
    );

    debounce #(
        .N(DB_N)
    ) u_db (
        .clk(clk),
        .reset(rst),
        .sw(key_down),
        .db_level(db_level),
        .db_tick(db_tick)
    );


    // ---------------------------------------------------------
    // Antirrebote de los botones fisicos S1 y S2
    //
    // Los botones son activos en nivel bajo:
    // presionado = 0
    // liberado   = 1
    // ---------------------------------------------------------
    logic s1_level;
    logic s1_tick;

    logic s2_level;
    logic s2_tick;

    debounce #(
        .N(DB_N)
    ) u_db_s1 (
        .clk(clk),
        .reset(rst),
        .sw(~s1),
        .db_level(s1_level),
        .db_tick(s1_tick)
    );

    debounce #(
        .N(DB_N)
    ) u_db_s2 (
        .clk(clk),
        .reset(rst),
        .sw(~s2),
        .db_level(s2_level),
        .db_tick(s2_tick)
    );


    // ---------------------------------------------------------
    // Deteccion de la tecla *
    // Codigo hexadecimal de * = 14
    // ---------------------------------------------------------
    logic star_tick;

    assign star_tick = db_tick && (key_code == 4'd14);


    // ---------------------------------------------------------
    // Operandos y control
    // ---------------------------------------------------------
    logic [9:0] operando_a;
    logic [9:0] operando_b;

    logic [1:0] cantidad_a;
    logic [1:0] cantidad_b;

    logic seleccion;
    logic [1:0] modo_display;

    logic [9:0] resultado;
    logic negativo;
    logic listo;

    // Indica si ya se calculo la resta actual
    logic resultado_calculado;


    // ---------------------------------------------------------
    // Registro de operandos y control de visualizacion
    // ---------------------------------------------------------
    always_ff @(posedge clk or posedge rst) begin
        if (rst) begin
            operando_a <= 10'd0;
            operando_b <= 10'd0;

            cantidad_a <= 2'd0;
            cantidad_b <= 2'd0;

            seleccion <= 1'b0;
            modo_display <= 2'd0;

            resultado_calculado <= 1'b0;
        end else begin

            // -------------------------------------------------
            // S1: seleccionar y limpiar el operando A
            // -------------------------------------------------
            if (s1_tick) begin
                seleccion <= 1'b0;

                operando_a <= 10'd0;
                cantidad_a <= 2'd0;

                modo_display <= 2'd0;
                resultado_calculado <= 1'b0;
            end

            // -------------------------------------------------
            // S2: seleccionar y limpiar el operando B
            // -------------------------------------------------
            else if (s2_tick) begin
                seleccion <= 1'b1;

                operando_b <= 10'd0;
                cantidad_b <= 2'd0;

                modo_display <= 2'd1;
                resultado_calculado <= 1'b0;
            end

            // -------------------------------------------------
            // Tecla *: calcular la resta y cambiar la pantalla
            //
            // Primera pulsacion:
            //     calcula A - B y muestra el resultado.
            //
            // Pulsaciones siguientes:
            //     resultado -> A -> B -> resultado
            // -------------------------------------------------
            else if (star_tick) begin

                if (!resultado_calculado) begin
                    modo_display <= 2'd2;
                    resultado_calculado <= 1'b1;
                end else begin

                    case (modo_display)

                        // Resultado -> A
                        2'd2: begin
                            modo_display <= 2'd0;
                        end

                        // A -> B
                        2'd0: begin
                            modo_display <= 2'd1;
                        end

                        // B -> resultado
                        2'd1: begin
                            modo_display <= 2'd2;
                        end

                        default: begin
                            modo_display <= 2'd2;
                        end

                    endcase
                end
            end

            // -------------------------------------------------
            // Procesamiento del teclado
            // -------------------------------------------------
            else if (db_tick) begin

                // Tecla A: seleccionar y limpiar operando A
                // Se conserva como alternativa al boton S1.
                if (key_code == 4'd10) begin
                    seleccion <= 1'b0;

                    operando_a <= 10'd0;
                    cantidad_a <= 2'd0;

                    modo_display <= 2'd0;
                    resultado_calculado <= 1'b0;
                end

                // Tecla B: seleccionar y limpiar operando B
                // Se conserva como alternativa al boton S2.
                else if (key_code == 4'd11) begin
                    seleccion <= 1'b1;

                    operando_b <= 10'd0;
                    cantidad_b <= 2'd0;

                    modo_display <= 2'd1;
                    resultado_calculado <= 1'b0;
                end

                // Tecla D: cambiar modo de visualizacion
                else if (key_code == 4'd13) begin
                    if (modo_display == 2'd2)
                        modo_display <= 2'd0;
                    else
                        modo_display <= modo_display + 1'b1;
                end

                // Manejo explícito de la tecla 9
                else if (key_code == 4'd9) begin
                    if (!seleccion && cantidad_a < 2'd3) begin
                        operando_a <= operando_a * 10'd10 + 10'd9;
                        cantidad_a <= cantidad_a + 1'b1;
                    end else if (seleccion && cantidad_b < 2'd3) begin
                        operando_b <= operando_b * 10'd10 + 10'd9;
                        cantidad_b <= cantidad_b + 1'b1;
                    end
                end

                // Manejo de las teclas del 0 al 8
                else if (key_code <= 4'd8) begin
                    if (!seleccion && cantidad_a < 2'd3) begin
                        operando_a <= operando_a * 10'd10 + key_code;
                        cantidad_a <= cantidad_a + 1'b1;
                    end else if (seleccion && cantidad_b < 2'd3) begin
                        operando_b <= operando_b * 10'd10 + key_code;
                        cantidad_b <= cantidad_b + 1'b1;
                    end
                end

                // Tecla C: mostrar el resultado si ya se calculo
                else if (key_code == 4'd12) begin
                    if (resultado_calculado)
                        modo_display <= 2'd2;
                end

                // La tecla * se procesa mediante star_tick.
                // No se utiliza aqui para evitar duplicar acciones.
            end
        end
    end


    // ---------------------------------------------------------
    // Modulo de resta
    // La operacion se inicia con la tecla *
    // ---------------------------------------------------------
    resta_aritmetica u_resta (
        .clk(clk),
        .rst(rst),
        .valid_i(star_tick && !resultado_calculado),
        .operando_a_i(operando_a),
        .operando_b_i(operando_b),
        .resultado_o(resultado),
        .negativo_o(negativo),
        .listo_o(listo)
    );


    // ---------------------------------------------------------
    // Seleccion del numero que se mostrara
    // ---------------------------------------------------------
    logic [3:0] centenas;
    logic [3:0] decenas;
    logic [3:0] unidades;
    logic [9:0] numero_mostrado;

    always_comb begin
        case (modo_display)
            2'd0: numero_mostrado = operando_a;
            2'd1: numero_mostrado = operando_b;
            default: numero_mostrado = resultado;
        endcase

        centenas = numero_mostrado / 10'd100;
        decenas  = (numero_mostrado / 10'd10) % 10'd10;
        unidades = numero_mostrado % 10'd10;
    end


    // ---------------------------------------------------------
    // Multiplexacion del display
    // ---------------------------------------------------------
    logic [15:0] scan_counter;
    logic [1:0] scan_sel;
    logic [3:0] digito_actual;
    logic [6:0] seg_on;
    logic [3:0] dig_on;

    always_ff @(posedge clk or posedge rst) begin
        if (rst)
            scan_counter <= 16'd0;
        else
            scan_counter <= scan_counter + 1'b1;
    end

    assign scan_sel = scan_counter[15:14];

    always_comb begin
        digito_actual = 4'd0;
        seg_on = 7'b0000000;
        dig_on = 4'b0000;

        case (scan_sel)

            // Digito de signo
            2'd0: begin
                if ((modo_display == 2'd2) && negativo)
                    seg_on = 7'b1000000;
                else
                    seg_on = 7'b0000000;

                dig_on = 4'b0001;
            end

            // Centenas
            2'd1: begin
                digito_actual = centenas;
                seg_on = decodificar_7seg(digito_actual);
                dig_on = 4'b0010;
            end

            // Decenas
            2'd2: begin
                digito_actual = decenas;
                seg_on = decodificar_7seg(digito_actual);
                dig_on = 4'b0100;
            end

            // Unidades
            default: begin
                digito_actual = unidades;
                seg_on = decodificar_7seg(digito_actual);
                dig_on = 4'b1000;
            end

        endcase
    end


    // ---------------------------------------------------------
    // Decodificador de siete segmentos
    // ---------------------------------------------------------
    function automatic logic [6:0] decodificar_7seg(
        input logic [3:0] n
    );
        case (n)
            4'd0: decodificar_7seg = 7'b0111111;
            4'd1: decodificar_7seg = 7'b0000110;
            4'd2: decodificar_7seg = 7'b1011011;
            4'd3: decodificar_7seg = 7'b1001111;
            4'd4: decodificar_7seg = 7'b1100110;
            4'd5: decodificar_7seg = 7'b1101101;
            4'd6: decodificar_7seg = 7'b1111101;
            4'd7: decodificar_7seg = 7'b0000111;
            4'd8: decodificar_7seg = 7'b1111111;
            4'd9: decodificar_7seg = 7'b1101111;
            default: decodificar_7seg = 7'b0000000;
        endcase
    endfunction


    // ---------------------------------------------------------
    // Salidas fisicas del display
    // ---------------------------------------------------------
    always_ff @(posedge clk or posedge rst) begin
        if (rst) begin
            seg <= SEG_ACTIVE_LOW ? 7'b1111111 : 7'b0000000;
            dig <= DIG_ACTIVE_LOW ? 4'b1111 : 4'b0000;
        end else begin
            seg <= SEG_ACTIVE_LOW ? ~seg_on : seg_on;
            dig <= DIG_ACTIVE_LOW ? ~dig_on : dig_on;
        end
    end

endmodule
