`timescale 1ns/1ps

module debounce_tb;
    // Parámetro reducido para simulación rápida (2^3 = 8 ciclos en lugar de 2^19)
    parameter int SIM_N = 3;

    // Señales de prueba
    logic clk;
    logic reset;
    logic sw;
    logic db_level;
    logic db_tick;

    // Instancia de la Unidad Bajo Prueba (UUT), sobrescribiendo N
    debounce #(.N(SIM_N)) uut (
        .clk(clk),
        .reset(reset),
        .sw(sw),
        .db_level(db_level),
        .db_tick(db_tick)
    );

    // Generación de reloj: 27 MHz -> Período de ~37.04 ns (mitad = 18.52 ns)
    always #18.52 clk = ~clk;

    // Procedimiento de estímulos
    initial begin
        // Archivo de ondas para visualización (ej. GTKWave)
        $dumpfile("debounce.vcd");
        $dumpvars(0, debounce_tb);

        // Inicialización de señales
        clk = 0;
        reset = 1;
        sw = 0;

        // Aplicar reset durante unos nanosegundos
        #100;
        reset = 0;
        #100;

        // 1. Simular rebotes al presionar el botón (0 -> 1 con ruido)
        #40  sw = 1;
        #20  sw = 0;
        #30  sw = 1;
        #15  sw = 0;
        #50  sw = 1; // Presión estable definitiva

        // Esperar a que el contador expire (con N=3 se requieren 8 ciclos * 37.04 ns ≈ 300 ns)
        #400;

        // 2. Simular rebotes al soltar el botón (1 -> 0 con ruido)
        #40  sw = 0;
        #25  sw = 1;
        #15  sw = 0; // Liberación estable definitiva

        // Esperar a que el contador expire para volver a estado ZERO
        #400;

        // Finalizar la simulación
        $finish;
    end

    // Monitor en consola para rastrear cambios
    initial begin
        $monitor("Time = %0t ns | reset = %b | sw = %b | db_level = %b | db_tick = %b | state = %0d", 
                 $time, reset, sw, db_level, db_tick, uut.state_reg);
    end

endmodule
