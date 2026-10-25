
module resta_aritmetica (
    input  logic       clk,
    input  logic       rst,
    input  logic       valid_i,
    input  logic [9:0] operando_a_i,
    input  logic [9:0] operando_b_i,
    output logic [9:0] resultado_o,
    output logic       negativo_o,
    output logic       listo_o
);

    logic [10:0] resta_complemento;
    logic [10:0] magnitud;

    // A - B = A + complemento a 2 de B.
    // No se utiliza el operador de resta.
    always_comb begin
        resta_complemento =
            {1'b0, operando_a_i}
            + (~{1'b0, operando_b_i})
            + 11'd1;

        if (resta_complemento[10])
            magnitud = ~resta_complemento + 11'd1;
        else
            magnitud = resta_complemento;
    end

    // Registrar resultado y signo
    always_ff @(posedge clk or posedge rst) begin
        if (rst) begin
            resultado_o <= 10'd0;
            negativo_o  <= 1'b0;
            listo_o     <= 1'b0;
        end
        else begin
            listo_o <= valid_i;

            if (valid_i) begin
                resultado_o <= magnitud[9:0];
                negativo_o  <= resta_complemento[10];
            end
        end
    end

endmodule
