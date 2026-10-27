# Proyecto corto 2: Diseño digital sincrónico en HDL
Segundo proyecto de Diseño Lógico enfocado en el análisis de circuitos secuenciales, la construcción de contadores y cerrojos, y el diseño de un sistema digital sincrónico en HDL implementado en la FPGA Tang Nano 9K.
## 1. Abreviaturas y definiciones
- FPGA: Field Programmable Gate Array.
- HDL: Hardware Description Language.
- FSM: Finite State Machine (máquina de estados finitos).
- BCD: Binary-Coded Decimal.
- RTL: Register Transfer Level.

## 2. Referencias
[1] Pong P. Chu. FPGA Prototyping by SystemVerilog Examples. Xilinx MicroBlaze MCS SoC Edition. Wiley, 2018.

[2] Andrew House. Hex Keypad Explanation. 2009.

[3] David Medina. Video tutorial para principiantes. Flujo abierto para Tang Nano 9K. 2024.

[4] David Medina. Wiki tutorial sobre el uso de la Tang Nano 9K y el flujo abierto de herramientas. 2024.

[5] William James Dally y R. Curtis Harting. Digital Design: A Systems Approach. Cambridge University Press, 2012.
## 3. Desarrollo
### 3.0 Descripción general del proyecto
El proyecto consiste en el diseño e implementación de un sistema digital sincrónico mediante el uso de SystemVerilog y la FPGA Tang Nano 9K. El objetivo principal es desarrollar un sistema capaz de recibir dos números enteros positivos de hasta tres dígitos decimales mediante un teclado hexadecimal, realizar la resta aritmética entre ambos y mostrar el resultado, incluyendo su signo, en cuatro displays de siete segmentos.

Para llevar a cabo este proceso, el sistema se divide en diferentes subsistemas funcionales. El primero se encarga de detectar las teclas presionadas, sincronizar las señales de entrada y eliminar el rebote mecánico para permitir el ingreso correcto de los operandos. Posteriormente, el subsistema aritmético procesa los números almacenados y calcula la diferencia mediante el procedimiento de suma en complemento a la base, sin utilizar directamente el operador de resta. 
Finalmente, el subsistema de despliegue convierte el resultado a su representación decimal y controla la multiplexación de los cuatro displays de siete segmentos para mostrar los números ingresados o el resultado de la operación. Todos los bloques se integran mediante un módulo superior y funcionan utilizando el reloj de 27 MHz de la FPGA, con bases de tiempo adicionales para controlar los procesos que requieren una frecuencia menor. Además, el proyecto incluye la construcción y evaluación de circuitos digitales secuenciales, como contadores sincrónicos y asincrónicos, así como cerrojos SR y D, cuyo comportamiento se analiza mediante mediciones con un osciloscopio o analizador lógico.

### 3.1 Lectura del teclado hexadecimal
Se desarrolla un subsistema encargado de detectar las teclas presionadas en el teclado hexadecimal y convertirlas en códigos que puedan ser procesados por el sistema. La lectura se basa en el barrido de filas o columnas para identificar la posición de la tecla activada.
Las señales provenientes del teclado se sincronizan con el reloj de la FPGA y pasan por un proceso de eliminación de rebote para evitar que una sola pulsación sea interpretada como varias. También se incorpora una lógica de control que permite seleccionar el operando que se está ingresando, almacenar sus dígitos en orden decimal y determinar cuándo se debe mostrar el resultado de la operación.

### 3.2 Subsistema de resta aritmética
Se implementa un bloque aritmético que recibe los dos operandos almacenados y calcula su diferencia de forma sincrónica. De acuerdo con los requisitos del proyecto, la resta se realiza mediante el procedimiento de suma en complemento a la base, sin utilizar directamente el operador -.
El subsistema produce el valor del resultado y una señal que indica si este es negativo. Estas salidas se conectan al bloque de despliegue para representar correctamente tanto la magnitud del resultado como su signo.

### 3.3 Subsistema de despliegue en displays de siete segmentos
Se desarrolla un sistema de visualización que permite mostrar los números ingresados y el resultado de la resta en cuatro displays de siete segmentos. Los datos se convierten a dígitos decimales y se selecciona de forma periódica cada display mediante un proceso de multiplexación.

La lógica de control determina si se muestran los dígitos del primer operando, los del segundo operando o el resultado. Cuando corresponde, también se representa el signo negativo. El refresco de los displays se controla mediante una base de tiempo derivada del reloj principal de 27 MHz.

### 3.4 Integración y verificación del sistema
Los subsistemas se conectan mediante un módulo superior que coordina la lectura de las teclas, el almacenamiento de los operandos, la operación aritmética y la visualización. Durante el desarrollo se utilizan simulaciones RTL y pruebas de banco para comprobar el comportamiento de los módulos antes de su implementación en la FPGA.
También se revisan la síntesis, el temporizado y la implementación física para detectar posibles problemas de funcionamiento o de cumplimiento de la frecuencia de reloj. Los resultados, las capturas de simulación y las observaciones obtenidas se documentan en los apartados correspondientes de la bitácora.

## 4. Ejercicios de laboratorio
En los siguientes apartados se documentan los ejercicios del proyecto. Se dejan las preguntas planteadas en el enunciado para completar posteriormente con las mediciones, observaciones y explicaciones correspondientes.

### 1. Contadores sincrónicos integrados: 74LS163
Se conectan dos contadores sincrónicos de 4 bits 74LS163 (o 75HC163) en cascada. La señal de reloj se genera desde la FPGA y se utiliza un osciloscopio o analizador lógico para observar y verificar el funcionamiento de los contadores.
 
#### Preguntas:
##### a. ¿Qué hace la salida RCO en un 74LS163?
La salida RCO en un 74LS163 permite indicar cuando el contador llega a su valor máximo, por lo que cuenta desde 0000 hasta 1111, es decir, de 0 a 15. Funcionando así como una señal de acarreo, facilitando la expansión del contador. La salida se ve como una señal digital cuadrada, que permanece en LOW (0 V) casi todo el tiempo y pasa a HIGH (aproximadamente 5 V) cuando el contador llega a 1111, siempre que ENT = 1.

##### b Explique por qué RCO y T están conectadas entre los dos contadores y explique cómo trabaja esta conexión.
Están conectadas para que ambos trabajen en cascada y aumenten la capacidad del conteo. Esta conexión trabaja haciendo que el primer contador avance con cada pulso de reloj, mientras que el segundo contador solo aumenta cuando el primero completa su conteo de 0 a 15, cuando el primer contador llega a 1111, la salida RCO se activa y habilita la entrada T del segundo contador. En el siguiente flanco activo del reloj, el segundo contador incrementa su valor en una unidad y el primero vuelve a iniciar su conteo desde cero, repitiendo el mismo proceso de forma continua, permitiendo que ambos contadores trabajen coordinadamente y cuenten valores desde 0 hasta 255. 


##### c ¿Cuál es la diferencia entre las entradas T y P del 74LS163? (En la hoja de datos de este chip comercial, puede que estas señales se llamen ENT y ENP).
La diferencia entre las entradas es que ambas deben estar en nivel lógico alto (1) para que el contador avance con cada flanco de subida del reloj, donde la ENT también participa en la generación de la salida RCO. Por su parte, ENP únicamente habilita el conteo y no interviene directamente en la generación de RCO. Por eso, al conectar varios contadores en cascada, se suele mantener ENP en alto y conectar la salida RCO del primer contador a la entrada ENT del siguiente, permitiendo que el segundo avance cuando el primero complete su ciclo. 
<img width="800" height="503" alt="ej_1_pin11_c1" src="https://github.com/user-attachments/assets/34a04185-c6d3-43ac-a986-43d45ac85c71" />
<img width="800" height="503" alt="ej_1_pin11_c2" src="https://github.com/user-attachments/assets/3e9264c6-65ba-40ff-aea7-9c3156baf2af" />
<img width="800" height="503" alt="ej_1_pin14_c1" src="https://github.com/user-attachments/assets/8b4b4a38-6602-413a-aa43-77834d8d5ac7" />


##### d ¿Cúanto toma, luego del flanco positivo de reloj, para que uno de los flip-flops cambie de estado? Usted debe disparar el osciloscopio en el bit adecuado. ¿Importa cuál bit de salida escoja? 
En el 74LS163, este tiempo es del orden de nanosegundos y depende de las condiciones de operación y de la carga conectada a la salida. Para medirlo, se debe disparar el osciloscopio con el flanco positivo de la señal de reloj y observar el cambio en una de las salidas Q, midiendo el tiempo entre el flanco del reloj y el cambio de la salida. 
De igual manera es importante cuál bit es escogido, porque no todos los bits cambian en cada pulso: el bit menos significativo QA cambia en cada conteo, mientras que los demás cambian con menor frecuencia, por ello suele ser la opción más conveniente paar observar y medir el tiempo de propagación 
<img width="800" height="503" alt="ej_1_parte_d_qa" src="https://github.com/user-attachments/assets/26babf4e-e5f8-42c2-a41e-e04934c5debf" />
<img width="800" height="503" alt="ej_1_parte_d_qd" src="https://github.com/user-attachments/assets/74ea3e1f-01f2-4905-8a4a-a2cb1098d561" />


##### e. Eche un vistazo a la salida RCO del contador menos significativo. Use la opción de captura de fallas enel osciloscopio a ver si puede localizar alguna falla en la salidas de acarreo (revisar página 162 del manual del DSOX2002A). ¿Observa alguna? Este tipo de fallas es muy difícil de capturar pues son muy cortas y, a veces, algunos acarreos no generan fallas. Trate de usar el osciloscopio primero en modo analizador lógico y luego en modo analógico para buscar estas fallas. Explique en qué casos es esperable hallar esta falla
En la imagen obtenida mediante el osciloscopio en modo analógico, se pueden observar transitorios y oscilaciones en las señales durante los cambios de estado. Estos comportamientos pueden estar relacionados con los retardos de propagación de los flip-flops y las compuertas lógicas del circuito.
La falla en la salida de acarreo RCO del contador menos significativo se puede presentar cuando varios bits cambian de estado y las señales no se actualizan exactamente al mismo tiempo. Esto puede generar un pulso muy corto o glitch que no debería aparecer en el funcionamiento ideal del circuito.
<img width="800" height="503" alt="WhatsApp Imag 2026-10-26 at 11 31 44 AM" src="https://github.com/user-attachments/assets/232bc55e-1d3a-4f12-ac14-e07e4b70221b" />
<img width="800" height="503" alt="WhatsApp Image 2026-10-26 at 11 31 44 AM" src="https://github.com/user-attachments/assets/5149d226-f396-40be-a403-fca5da3013de" />
Este tipo de falla es esperable principalmente cuando el contador pasa de un estado en el que todos sus bits están en nivel alto al siguiente estado, provocando que varios bits cambien simultáneamente. Debido a los diferentes retardos de propagación, la señal RCO puede presentar transitorios antes de estabilizarse.
En la captura del osciloscopio se aprecian oscilaciones y transitorios en los flancos de las señales, pero no es posible confirmar únicamente con esta imagen que se haya producido una falla en RCO. Para comprobarlo, sería necesario observar directamente la salida RCO y verificar si aparecen pulsos breves no deseados durante las transiciones.


### 2. Construcción de contadores con compuertas integradas
Se construye un contador de 4 bits en dos modalidades: asincrónica y sincrónica. Para ello se utilizan flip-flops 74HC74 y el sumador 74HC283. En ambos circuitos se debe generar una señal lógica que indique cuándo se ha pasado por el máximo de cuenta disponible. Se comparan las salidas mediante un analizador lógico.

#### Preguntas:
##### a. ¿Qué diferencias se observan en las salidas de las cuentas de ambas estructuras al medirlas con un analizador lógico?
El contador asíncrono y el contador síncrono presentan diferencias principalmente en la forma en que cambian sus salidas. En el contador asíncrono, los flip-flops no reciben directamente la misma señal de reloj, sino que cada etapa utiliza la salida de la etapa anterior como señal de reloj. Por esta razón, los cambios de estado se producen de manera progresiva, generando pequeños retardos entre los bits de salida. En cambio, en el contador síncrono, todos los flip-flops reciben la misma señal de reloj, por lo que sus salidas cambian en respuesta al mismo flanco de reloj. Aunque también existen retardos de propagación propios de los componentes, las transiciones son más coordinadas y se reduce la diferencia temporal entre los cambios de los bits.

Al observar ambas configuraciones con el analizador lógico, se puede comprobar que los dos contadores recorren la secuencia de estados correspondiente a una cuenta binaria de 4 bits, desde 0000 hasta 1111, antes de regresar a 0000. Sin embargo, en el contador asíncrono pueden observarse pequeños desfases entre las transiciones de los bits, mientras que en el síncrono estas se encuentran mejor sincronizadas con la señal de reloj. Además, ambos circuitos deben generar una señal lógica que indique cuándo se alcanza el final de la cuenta y se produce el desbordamiento. En un contador de 4 bits, esto sucede cuando se pasa de 1111 a 0000. La señal debe diseñarse de acuerdo con la lógica de detección utilizada en cada circuito.:
<img width="800" height="503" alt="ej_2_sincrono2" src="https://github.com/user-attachments/assets/f07823d9-b85b-41c1-b999-0731cdade21a" />

##### b. ¿Qué problemas puede presentar la configuración asincrónica?
El principal problema del contador asíncrono es el retardo de propagación acumulado entre los flip-flops. Como cada etapa depende del cambio de estado de la anterior, las salidas no cambian simultáneamente y se producen estados intermedios durante las transiciones de la cuenta. Por ejemplo, cuando el contador pasa de 0111 a 1000, los cuatro bits deben cambiar de estado. Sin embargo, debido a los retardos de propagación, el analizador lógico puede mostrar temporalmente combinaciones distintas del valor final esperado. Estas transiciones pueden generar pulsos no deseados, conocidos como glitches, que podrían afectar a otros componentes del circuito. 
<img width="800" height="503" alt="eje_2_asincrono" src="https://github.com/user-attachments/assets/1f3c66ce-524d-4071-926f-1e2575a20c9b" />

Otro problema se presenta al utilizar las salidas para generar señales de control. Si la lógica de detección del máximo de cuenta responde a uno de esos estados transitorios, puede activarse momentáneamente cuando no corresponde. Además, conforme se agregan más flip-flops, aumenta el retardo total y se limita la frecuencia máxima de funcionamiento del contador. Por estas razones, aunque el contador asíncrono es relativamente sencillo de implementar, puede presentar problemas de temporización y confiabilidad. El contador síncrono resulta más adecuado cuando se necesita que las salidas cambien de manera coordinada y que las señales de control sean más estables.


### 3. Construcción de un cerrojo Set-Reset con compuertas NAND y transformación en un cerrojo D
Se construye un cerrojo SR con compuertas NAND 74HC00. La señal de reloj se genera desde la FPGA. Se verifica su comportamiento con la tabla de verdad y posteriormente se añade la lógica necesaria para convertirlo en un cerrojo D.

#### Preguntas:
##### a. ¿Cómo funciona el cerrojo SR? Demuestre su funcionamiento usando el circuito construido y su tabla de verdad. ¿Cuál podría ser su utilidad? ¿Es necesario utilizar la señal de reloj para que funcione?
El cerrojo SR sincronizado por reloj se construye utilizando compuertas NAND 74HC00 y permite almacenar un bit de información. Sus entradas principales son Set (S), Reset (R) y la señal de reloj (CLK), mientras que sus salidas son Q y su complemento Q̅, esto permite que el circuito funciona de manera que las entradas S y R solo pueden modificar el estado almacenado cuando la señal de reloj se encuentra en nivel alto. Cuando CLK está en nivel bajo, el cerrojo conserva su estado anterior, independientemente de los cambios que se produzcan en las entradas.
Cuando el reloj está en alto, la entrada Set permite establecer Q en alto y Q̅ en bajo. Por otro lado, la entrada Reset permite establecer Q en bajo y Q̅ en alto. Si ninguna de estas entradas está activada, el circuito conserva el último estado almacenado, Ppra demostrar su funcionamiento experimentalmente, se pueden probar las combinaciones de entradas y observar las salidas Q y Q̅ con el analizador lógico. Primero se activa Set para comprobar que Q pasa a nivel alto; después se activa Reset para comprobar que Q pasa a nivel bajo. Finalmente, se coloca CLK en nivel bajo y se modifican las entradas para verificar que las salidas mantienen el estado almacenado, el cerrojo puede utilizarse para almacenar temporalmente información, conservar el estado de una señal de control o servir como elemento básico en circuitos secuenciales. 
En el circuito sincronizado por reloj, sí es necesario utilizar CLK para controlar cuándo se permite modificar el estado almacenado. Sin embargo, el principio de almacenamiento de un cerrojo SR básico no requiere necesariamente un reloj: puede construirse un cerrojo asíncrono utilizando únicamente compuertas NAND cruzadas. En ese caso, las entradas pueden modificar el estado en cualquier momento.
<img width="800" height="503" alt="ej3_s0r0_p11" src="https://github.com/user-attachments/assets/0ccc76af-cf46-401d-b3f0-84387d9aab22" />
<img width="800" height="503" alt="ej3_s0r1_p11" src="https://github.com/user-attachments/assets/e7e4df55-1ce7-4e0a-ad8d-308345e53b45" />
<img width="800" height="503" alt="ej3_s1r0_p11" src="https://github.com/user-attachments/assets/149bc397-9137-42a2-b295-b3c3de040e34" />
<img width="800" height="503" alt="ej3_s1r1_p11" src="https://github.com/user-attachments/assets/4690d65d-8702-47f3-859f-1264c469001b" />

##### b. ¿Qué ocurre si las señales S y R se mantienen ambas en alto, de acuerdo con la tabla de verdad del circuito?
Cuando S y R se mantienen simultáneamente en alto mientras CLK también está en alto, ambas entradas de control quedan activadas al mismo tiempo. En el circuito descrito, esto provoca que las dos salidas Q y Q̅ pasen a nivel bajo, por esto, esta condición es considerada prohibida porque las salidas dejan de ser complementarias, incumpliendo la relación esperada entre Q y Q̅. Además, cuando S y R regresan simultáneamente a cero, el estado final puede ser impredecible debido a las diferencias en los retardos de propagación de las compuertas, lo que se debe evitar activar Set y Reset simultáneamente. El circuito debe utilizarse con combinaciones de entradas que permitan almacenar un estado válido y mantener la relación complementaria entre sus salidas.

##### c. ¿Qué lógica se debe añadir para transformar el cerrojo SR en un cerrojo D y cómo se demuestra su funcionamiento?
Para transformar el cerrojo SR en un cerrojo D, se añade una compuerta inversora para generar la señal complementaria de la entrada D y se conectan las entradas de control de la siguiente manera:
S = D
R = D̅
En una implementación con habilitación de reloj, estas señales deben pasar por la lógica de habilitación correspondiente. Así, cuando CLK está en alto, el valor de D determina el estado de la salida Q. Cuando CLK está en bajo, el circuito conserva el valor almacenado. Con esta modificación se evita la condición prohibida del cerrojo SR, ya que D y D̅ nunca pueden tener el mismo valor lógico en condiciones ideales y para comprobar el funcionamiento, se cambia la entrada D mientras CLK está en alto y se observa que Q sigue su valor. Luego se coloca CLK en bajo y se modifica D nuevamente; en este caso, Q debe conservar el último valor almacenado. De esta manera, se demuestra que el cerrojo D permite almacenar un bit de información de forma controlada mediante la señal de reloj.
<img width="800" height="503" alt="ej3_s0r0_p33" src="https://github.com/user-attachments/assets/5d47b8df-bfb4-4b5b-bb0d-9732807afd90" />
<img width="800" height="503" alt="ej3_s1r0_p33" src="https://github.com/user-attachments/assets/b7e467e0-9d1d-4d28-9431-c1d2e6d06309" />
<img width="800" height="503" alt="ej3_s1r0_p334" src="https://github.com/user-attachments/assets/2d83e402-b93c-4b37-b510-2e1671921774" />
<img width="800" height="503" alt="ej3_s1r1_p33" src="https://github.com/user-attachments/assets/e9a574b6-e338-4959-98a1-787e6866502d" />

### 4.2 Módulo 
#### 1. Encabezado del módulo

##### Encabezado del módulo de Debounce
module debounce #(parameter N = 19)(
    input  logic clk,
    input  logic reset,
    input  logic sw,
    output logic  db_level,
    output logic  db_tick
);

##### Encabezado del módulo de EscanearTeclado
module EscanearTeclado #(parameter DWELL_BITS = 14)(   // 2^14/27MHz ~ 0.6 ms por columna
    input  logic       clk,
    input  logic       rst,
    input  logic [3:0] row_n,     // filas, activo en bajo (asincronas)
    output wire  [3:0] col_n,     // columnas, activo en bajo (0 o Z)
    output logic       key_down,
    output logic [3:0] key_code
);

##### Encabezado del módulo de DecodificadorDisplay
module DecodificadorDisplay #(
    parameter SEG_ACTIVE_LOW = 0,
    parameter DIG_ACTIVE_LOW = 0
)(
    input  logic        clk,
    input  logic        rst,
    input  logic        key_valid,
    input  logic [3:0]  key_code,
    output logic [6:0]  seg,
    output logic [3:0]  dig,
    output logic [9:0]  value
);

##### Encabezado del módulo de resta_aritmetica
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

##### Encabezado del módulo de top 
module top #(
    parameter DWELL_BITS = 14,
    parameter DB_N       = 19,
    parameter SEG_ACTIVE_LOW = 0,
    parameter DIG_ACTIVE_LOW = 0
)(
    input  logic       clk,
    input  logic [3:0] row,
    output logic [3:0] col,
    output logic [6:0] seg,
    output logic [3:0] dig
);
#### Testbenchs:
Pruebas para el Antirebote:
<img width="1600" height="579" alt="WhatsApp Image 2026-10-26 at 4 09 18 PM" src="https://github.com/user-attachments/assets/31a3abf5-ee45-418a-bf27-ba3d926ea572" />
<img width="1374" height="714" alt="WhatsApp Image 2026-10-26 at 4 05 27 PM" src="https://github.com/user-attachments/assets/33ebc64a-8eae-4910-8ae1-a069a744b483" />
Pruebas para el escaneo del teclado:
<img width="1600" height="664" alt="WhatsApp Image 2026-10-26 at 4 16 32 PM (1)" src="https://github.com/user-attachments/assets/a24f56eb-9034-4189-81b6-eff208845ffa" />
<img width="1312" height="538" alt="WhatsApp Image 2026-10-26 at 4 16 13 PM (1)" src="https://github.com/user-attachments/assets/86fb481b-330f-4413-8d96-72bc88d2eaf2" />
Pruebas para el decodificador:
<img width="1600" height="536" alt="WhatsApp Image 2026-10-26 at 4 34 52 PM (1)" src="https://github.com/user-attachments/assets/0f19f64f-e160-4f28-827d-03fbde1f0337" />
<img width="1357" height="393" alt="WhatsApp Image 2026-10-26 at 4 34 52 PM" src="https://github.com/user-attachments/assets/2010d381-ed25-4185-a05d-689ec3e04fa6" />
Prueba de la resta:
<img width="1600" height="551" alt="WhatsApp Image 2026-10-26 at 5 05 11 PM" src="https://github.com/user-attachments/assets/9f7b78c1-d8b2-4af4-a64e-aedd09310195" />
<img width="1159" height="223" alt="WhatsApp Image 2026-10-26 at 5 05 40 PM" src="https://github.com/user-attachments/assets/ac07e127-8118-40d5-ac08-5c0ea102ce68" />
Prueba del top (de todo):
<img width="1159" height="223" alt="WhatsApp Image 2026-10-26 at 5 05 40 PM" src="https://github.com/user-attachments/assets/23d63a04-e0d6-4dfb-a081-fc08e486edf5" />
<img width="1600" height="551" alt="WhatsApp Image 2026-10-26 at 5 05 11 PM" src="https://github.com/user-attachments/assets/9dc33008-a9e6-471c-82f2-2086fe668418" />


## 5. Consumo de Recursos
=== top ===

   Number of wires:               3305
   Number of wire bits:           7203
   Number of public wires:        3305
   Number of public wire bits:    7203
   Number of memories:               0
   Number of memory bits:            0
   Number of processes:              0
   Number of cells:               4903
     ALU                          1110
     DFFC                           98
     DFFCE                          52
     DFFE                            4
     DFFP                            8
     GND                             1
     IBUF                            7
     LUT1                         1401
     LUT2                          264
     LUT3                          338
     LUT4                          180
     MUX2_LUT5                     789
     MUX2_LUT6                     372
     MUX2_LUT7                     176
     MUX2_LUT8                      87
     OBUF                           11
     TBUF                            4
     VCC                             1

## 6. Problemas encontrados durante el proyecto
Primero, tuvimos problemas con el teclado, una vez teníamos todo realizado, surgió un problema con el teclado mecánico, ya que el pin asociado de la 4ta columna se debió haber herrumbrado, y realizando diversas pruebas como cambio de pines, etc. ninguna de las letras respondió al input. De igual manera, por alguna razón la 3ra fila y 3ra columna (tecla 9) no funcionaba de forma correcta, al inicio durante la creación del debounce estaba dando problemas ya que tenia mal configurada la frecuencia, y para el caso del Top, este número no estaba siendo recibido por el display, provocando que se cambiara gran parte del código solamente para el funcionamiento de este.
En cuanto a los ejercicios, la dificultad radico en el uso del equipo, como fue las puntas atenuadoras, 10:1, y el analizador lógico, ya que, este equipo al tener diferencias a un osciloscopio, se tardó más de lo esperado para los resultados.

## 7. Apéndices: 
### Apéndice 1:
Con esta fórmula se puede obtener el total de la resta aritmética 
Para números de tres dígitos:
   A-B=A+(1000-B)
o bien: 
   A-B=A+(B negado)+1
### Apéndice 2:
BITACORA JORGE CHAVARRIA MATA



BITACORA DEREK ROJAS CAMACHO
