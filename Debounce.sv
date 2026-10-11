// -----------------------------------------------------------------------------
// Modulo 1: Eliminador de rebote (FSMD explicito, estilo Pong Chu, fig. 5.9/ASMD v2)
// Estados: zero -> wait1 -> one -> wait0 -> zero
//  - sw debe permanecer en 1 durante 2^N ciclos para aceptar el flanco 0->1
//  - sw debe permanecer en 0 durante 2^N ciclos para aceptar el flanco 1->0
// db_tick: pulso de 1 ciclo al confirmar una pulsacion
// N = 19 con reloj de 27 MHz -> (2^19)/27e6 ~ 19.4 ms
// Si el curso entrega su propio HDL, puede reemplazar este archivo (mismos puertos).
// -----------------------------------------------------------------------------
module debounce #(parameter N = 19)(
    input  logic clk,
    input  logic reset,
    input  logic sw,
    output logic  db_level,
    output logic  db_tick
);
    localparam [1:0] ZERO  = 2'b00,
                     WAIT0 = 2'b01,
                     ONE   = 2'b10,
                     WAIT1 = 2'b11;

    logic  [1:0]   state_reg, state_next;
    logic  [N-1:0] q_reg;
    logic [N-1:0] q_next;
    logic         q_zero;
    logic q_load, q_dec;

    // registros de estado y de datos
    always_ff @(posedge clk or posedge reset)
        if (reset) begin
            state_reg <= ZERO;
            q_reg     <= {N{1'b0}};
        end else begin
            state_reg <= state_next;
            q_reg     <= q_next;
        end

    // data path (contador): cargar 1...1, decrementar o mantener
    assign q_next = q_load ? {N{1'b1}} :
                    q_dec  ? q_reg - 1'b1 :
                             q_reg;
    assign q_zero = (q_next == {N{1'b0}});

    // control path (FSM): genera las senales de control del data path
    always_comb begin
        state_next = state_reg;
        q_load     = 1'b0;
        q_dec      = 1'b0;
        db_tick    = 1'b0;
        db_level   = 1'b0;
        case (state_reg)
            ZERO: begin
                if (sw) begin
                    state_next = WAIT1;
                    q_load     = 1'b1;
                end
            end
            WAIT1: begin
                if (sw) begin
                    q_dec = 1'b1;
                    if (q_zero) begin
                        state_next = ONE;
                        db_tick    = 1'b1;
                    end
                end else
                    state_next = ZERO;
            end
            ONE: begin
                db_level = 1'b1;
                if (!sw) begin
                    state_next = WAIT0;
                    q_load     = 1'b1;
                end
            end
            WAIT0: begin
                db_level = 1'b1;
                if (!sw) begin
                    q_dec = 1'b1;
                    if (q_zero)
                        state_next = ZERO;
                end else
                    state_next = ONE;
            end
            default: state_next = ZERO;
        endcase
    end
endmodule
