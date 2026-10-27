`timescale 1ns/1ps

module EscanearTeclado_tb;
    // Parámetro reducido para simulación rápida (2^2 = 4 ciclos por columna)
    parameter int SIM_DWELL = 2;

    // Señales de prueba
    logic clk;
    logic rst;
    logic [3:0] row_n;
    wire  [3:0] col_n;
    logic       key_down;
    logic [3:0] key_code;

    // Variables de control para simular la pulsación de teclas
    logic [1:0] target_row;
    logic [1:0] target_col;
    logic       simulate_press;

    // Instancia de la Unidad Bajo Prueba (UUT)
    EscanearTeclado #(.DWELL_BITS(SIM_DWELL)) uut (
        .clk(clk),
        .rst(rst),
        .row_n(row_n),
        .col_n(col_n),
        .key_down(key_down),
        .key_code(key_code)
    );

    // Modelo eléctrico del teclado matricial y resistencias pull-up (3.3V -> '1')
    // Las filas tienen pull-up por defecto (4'hF). Si la columna activa (en 0) 
    // coincide con la tecla presionada, la fila respectiva baja a 0.
    logic [3:0] row_model;
    always_comb begin
        row_model = 4'hF; // Pull-up pasivo (todas en 1)
        if (simulate_press) begin
            // Si el escáner pone en 0 la columna objetivo de la tecla presionada
            if (col_n[target_col] === 1'b0) begin
                row_model[target_row] = 1'b0;
            end
        end
    end
    assign row_n = row_model;

    // Generación de reloj: 27 MHz -> Período de ~37.04 ns
    always #18.52 clk = ~clk;

    // Procedimiento de estímulos
    initial begin
        // Archivo VCD para GTKWave
        $dumpfile("keypad.vcd");
        $dumpvars(0, EscanearTeclado_tb);

        // Inicialización
        clk = 0;
        rst = 1;
        simulate_press = 0;
        target_row = 0;
        target_col = 0;

        // Reset
        #100;
        rst = 0;
        #100;

        // 1. Simular la pulsación de la tecla '5' 
        // Según el keymap: Fila 1, Columna 1 -> key_code = 5
        $display("Simulando pulsacion de la tecla '5'...");
        target_row = 2'd1;
        target_col = 2'd1;
        simulate_press = 1;
        
        // Esperar a que el módulo detecte la tecla y aplique 'hold'
        #600;

        // 2. Liberar la tecla '5'
        $display("Liberando la tecla '5'...");
        simulate_press = 0;
        #400;

        // 3. Simular la pulsación de la tecla 'A' (código 10)
        // Según el keymap: Fila 0, Columna 3 -> key_code = 10 (A)
        $display("Simulando pulsacion de la tecla 'A'...");
        target_row = 2'd0;
        target_col = 2'd3;
        simulate_press = 1;
        #600;

        // 4. Liberar la tecla 'A'
        $display("Liberando la tecla 'A'...");
        simulate_press = 0;
        #400;

        // Fin de simulación
        $finish;
    end

    // Monitor en consola
    initial begin
        $monitor("Time = %0t ns | rst = %b | col_n = %b | row_n = %b | key_down = %b | key_code = %0d | col_sel = %0d | hold = %b", 
                 $time, rst, col_n, row_n, key_down, key_code, uut.col_sel, uut.hold);
    end

endmodule
