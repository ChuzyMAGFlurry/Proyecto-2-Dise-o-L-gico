// Modulo 2: Decodificador y Control de Display de 7 Segmentos (Corregido)

module DecodificadorDisplay #(              //esto era por si se necesitaba lógica invertida, entonces si era cato_do comun o anodo comun hacían la transición 
    parameter SEG_ACTIVE_LOW = 0,       
    parameter DIG_ACTIVE_LOW = 0
)(
    input  logic        clk,        
    input  logic        rst,
    input  logic        key_valid,          //Viene desde el escaner, solo la recibe si es estable (antirebote)
    input  logic [3:0]  key_code,           //si tiene la identificación del keymap del escaner
    output logic [6:0]  seg,                //las 7 lineas que controlan los segmentos físicos del display
    output logic [3:0]  dig,                //las lineas de selección de dígito
    output logic [9:0]  value               //el valor que se va acumulando de 0 a 999
);

    wire is_digit = ~key_code[3] | ~(key_code[2] | key_code[1]);    //evalúa si el dato que se guardo (key_code) es válido (osea 0 al 9)
    wire is_clear = (key_code == 4'd14);    //detecta si la tecla es reiniciado(reset con *)

    logic [1:0] count;
    logic [3:0] d2, d1, d0;   // centenas, decenas, unidades (BCD)

    always_ff @(posedge clk or posedge rst) 
        if (rst) begin                               
            value <= 10'd0;
            count <= 2'd0;
            d2 <= 4'd0; d1 <= 4'd0; d0 <= 4'd0;
        end else if (key_valid) begin                   
            if (is_clear) begin                 //si se resetea con * limpia los displays
                value <= 10'd0;
                count <= 2'd0;
                d2 <= 4'd0; d1 <= 4'd0; d0 <= 4'd0;
            end else if (is_digit && count < 2'd3) begin        //en caso de que sea digito y no se haya superado el límite de 3 dígitos 
                value <= value * 10 + key_code;
                count <= count + 1'b1;
                d2 <= d1; d1 <= d0; d0 <= key_code;
            end
        end

    // multiplexado del display 
    logic [15:0] rcnt;                  //contador de 16 bits para cada ciclo de reloj
    always_ff @(posedge clk or posedge rst)
        if (rst) rcnt <= 16'd0;                 //toma los dos bits más significativos del contador para generar una señal de cambio rápido 
        else     rcnt <= rcnt + 1'b1;
    logic [1:0] sel = rcnt[15:14];
                                        
    logic [3:0] nib;                            
    logic       blank;                         //solo mostrara el número sin los ceros, si tengo 5, no mostrara 005
    always_comb begin                       //dependiendo del estado del sel
        case (sel)          
            2'd0: begin nib = d2; blank = (d2 == 4'd0);                 end // izquierda son centenas
            2'd1: begin nib = d1; blank = (d2 == 4'd0) && (d1 == 4'd0); end // centro    son decenas
            2'd2: begin nib = d0; blank = 1'b0;                         end // derecha   son unidades
            default: begin nib = 4'd0; blank = 1'b1;                    end // extremo derecho siempre debería estar apagado
        endcase
    end

    function automatic logic [6:0] decode(input logic [3:0] n); //traduce el número binario de 4 bits al 7 segmentos para encender los displays
        case (n)
            4'd0: decode = 7'b0111111;          //g f e d c b a
            4'd1: decode = 7'b0000110;
            4'd2: decode = 7'b1011011;
            4'd3: decode = 7'b1001111;
            4'd4: decode = 7'b1100110;
            4'd5: decode = 7'b1101101;
            4'd6: decode = 7'b1111101;
            4'd7: decode = 7'b0000111;
            4'd8: decode = 7'b1111111;
            4'd9: decode = 7'b1101111;
            default: decode = 7'b0000000;           //esta apagado en cualquier caso   
        endcase
    endfunction

    logic [6:0] seg_on = decode(nib);           //seg_on y dig_on calculan los valores en formato en alto 
    logic [3:0] dig_on = blank ? 4'b0000 : (4'b0001 << sel);   //Si la supresión de ceros está activa, apaga el dígito mandando ceros 
                                                                //sino corre los bits para encender únicamente el led del dígito que toca recargar
    always_ff @(posedge clk) begin                              //se aplica una inversión lógica si los parametros externos están invertidos en caso de que lo estuvieran
        seg <= SEG_ACTIVE_LOW ? ~seg_on : seg_on;
        dig <= DIG_ACTIVE_LOW ? ~dig_on : dig_on;
    end
endmodule
