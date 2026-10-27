`timescale 1ns/1ps

module resta_aritmetica_tb;
    logic clk;
    logic rst;
    logic valid_i;
    logic [9:0] operando_a_i;
    logic [9:0] operando_b_i;
    
    wire [9:0] resultado_o;
    wire       negativo_o;
    wire       listo_o;

    // Instancia de la Unidad Bajo Prueba (UUT)
    resta_aritmetica uut (
        .clk(clk),
        .rst(rst),
        .valid_i(valid_i),
        .operando_a_i(operando_a_i),
        .operando_b_i(operando_b_i),
        .resultado_o(resultado_o),
        .negativo_o(negativo_o),
        .listo_o(listo_o)
    );

    // Generación de reloj: 27 MHz -> Período de ~37.04 ns
    always #18.52 clk = ~clk;

    // Task sincronizada para aplicar las restas de forma ordenada
    task aplicar_resta(input [9:0] a, input [9:0] b);
        begin
            @(posedge clk);
            #1; // Retardo mínimo para evitar condiciones de carrera
            operando_a_i = a;
            operando_b_i = b;
            valid_i      = 1'b1;
            @(posedge clk);
            #1;
            valid_i      = 1'b0;
        end
    endtask

    initial begin
        // Archivo VCD para GTKWave
        $dumpfile("resta.vcd");
        $dumpvars(0, resta_aritmetica_tb);

        // Inicialización
        clk = 0;
        rst = 1;
        valid_i = 0;
        operando_a_i = 10'd0;
        operando_b_i = 10'd0;

        // Liberar reset
        #100;
        rst = 0;
        #50;

        // 1. Caso A > B (100 - 30 = 70, positivo)
        aplicar_resta(10'd100, 10'd30);

        // 2. Caso A < B (30 - 100 = 70, negativo)
        aplicar_resta(10'd30, 10'd100);

        // 3. Caso A == B (255 - 255 = 0)
        aplicar_resta(10'd255, 10'd255);

        // 4. Caso con valores grandes (800 - 200 = 600)
        aplicar_resta(10'd800, 10'd200);

        #100;
        $finish;
    end

    // Monitor limpio que imprime cuando la salida ya está lista y registrada
    always @(posedge clk) begin
        if (!rst && listo_o) begin
            $display("Time = %0t ns | A = %0d | B = %0d | resultado = %0d | negativo = %b", 
                     $time, operando_a_i, operando_b_i, resultado_o, negativo_o);
        end
    end

endmodule
