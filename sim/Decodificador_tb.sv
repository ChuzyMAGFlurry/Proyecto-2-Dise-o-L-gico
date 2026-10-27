`timescale 1ns/1ps

module DecodificadorDisplay_tb;
    // Señales de prueba
    logic clk;
    logic rst;
    logic key_valid;
    logic [3:0] key_code;
    wire  [6:0] seg;
    wire  [3:0] dig;
    wire  [9:0] value;

    // Instancia de la Unidad Bajo Prueba (UUT)
    DecodificadorDisplay #(
        .SEG_ACTIVE_LOW(0),
        .DIG_ACTIVE_LOW(0)
    ) uut (
        .clk(clk),
        .rst(rst),
        .key_valid(key_valid),
        .key_code(key_code),
        .seg(seg),
        .dig(dig),
        .value(value)
    );

    // Generación de reloj: 27 MHz -> Período de ~37.04 ns
    always #18.52 clk = ~clk;

    // Procedimiento de estímulos
    initial begin
        // Archivo VCD para GTKWave
        $dumpfile("display.vcd");
        $dumpvars(0, DecodificadorDisplay_tb);

        // Inicialización
        clk = 0;
        rst = 1;
        key_valid = 0;
        key_code = 4'd0;

        // Aplicar reset
        #100;
        rst = 0;
        #100;

        // 1. Ingresar dígito '3'
        @(posedge clk);
        key_code  = 4'd3;
        key_valid = 1;
        @(posedge clk);
        key_valid = 0;
        #300;

        // 2. Ingresar dígito '5'
        @(posedge clk);
        key_code  = 4'd5;
        key_valid = 1;
        @(posedge clk);
        key_valid = 0;
        #300;

        // 3. Ingresar dígito '7' -> El valor acumulado debe ser 357
        @(posedge clk);
        key_code  = 4'd7;
        key_valid = 1;
        @(posedge clk);
        key_valid = 0;
        
        // Esperar tiempo suficiente para observar el multiplexado de los displays.
        // Como rcnt utiliza rcnt[15:14], cada cambio de display toma 2^14 ciclos (~606 us).
        // Damos un margen de 2 ms para visualizar el barrido completo de los 3 dígitos.
        #2000000; 

        // 4. Probar la tecla CLEAR ('*' -> código 14) para limpiar el valor
        @(posedge clk);
        key_code  = 4'd14;
        key_valid = 1;
        @(posedge clk);
        key_valid = 0;
        
        // Esperar un momento para verificar el reseteo
        #500000;

        // Fin de la simulación
        $finish;
    end

    // Monitor en consola para rastrear valores en tiempo real
    initial begin
        $monitor("Time = %0t ns | rst = %b | key_valid = %b | key_code = %0d | value = %0d | d2=%0d d1=%0d d0=%0d | dig = %b | seg = %b", 
                 $time, rst, key_valid, key_code, value, uut.d2, uut.d1, uut.d0, dig, seg);
    end

endmodule
