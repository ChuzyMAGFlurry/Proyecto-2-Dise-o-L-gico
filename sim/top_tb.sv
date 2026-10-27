`timescale 1ns / 1ps

module top_tb;

    // Parámetros sobrescritos para simulación rápida
    parameter DWELL_BITS = 4;
    parameter DB_N       = 2;
    parameter SEG_ACTIVE_LOW = 0;
    parameter DIG_ACTIVE_LOW = 0;

    // Señales de entrada
    logic clk;
    logic [3:0] row;
    logic s1;
    logic s2;

    // Señales de salida
    logic [3:0] col;
    logic [6:0] seg;
    logic [3:0] dig;

    // Instancia del módulo UUT (Unit Under Test)
    top #(
        .DWELL_BITS(DWELL_BITS),
        .DB_N(DB_N),
        .SEG_ACTIVE_LOW(SEG_ACTIVE_LOW),
        .DIG_ACTIVE_LOW(DIG_ACTIVE_LOW)
    ) uut (
        .clk(clk),
        .row(row),
        .s1(s1),
        .s2(s2),
        .col(col),
        .seg(seg),
        .dig(dig)
    );

    // Generador de reloj (50 MHz -> período de 20 ns)
    always #10 clk = ~clk;

    // Procedimiento de estímulos
    initial begin
        // Inicializar señales
        clk = 0;
        row = 4'b1111; // Sin teclas presionadas en la matriz
        s1  = 1'b1;    // Botones activos en bajo (1 = liberado)
        s2  = 1'b1;

        // Configurar generación de archivo VCD para GTKWave
        $dumpfile("top_tb.vcd");
        $dumpvars(0, top_tb);

        // Esperar a que termine el reset inicial por power-on reset (por)
        // Con por de 4 bits, toma 16 ciclos de reloj. Esperamos un poco más.
        #500;

        // ---------------------------------------------------------
        // Prueba 1: Presionar botón S1 (Operando A)
        // ---------------------------------------------------------
        $display("[%0t ns] Presionando boton S1...", $time);
        s1 = 1'b0; // Presionado (activo bajo)
        #2000;
        s1 = 1'b1; // Liberado
        #1000;

        // ---------------------------------------------------------
        // Prueba 2: Presionar botón S2 (Operando B)
        // ---------------------------------------------------------
        $display("[%0t ns] Presionando boton S2...", $time);
        s2 = 1'b0;
        #2000;
        s2 = 1'b1;
        #1000;

        // Finalizar simulación
        #5000;
        $display("[%0t ns] Simulación finalizada.", $time);
        $finish;
    end

endmodule
