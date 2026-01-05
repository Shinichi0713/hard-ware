interface simple_bus_if (input logic clk);
    logic [7:0] data;
    logic       valid;
    logic       ready;

    // Master側（送り手）の入出力定義
    modport master (
        output data, valid,
        input  ready
    );

    // Slave側（受け手）の入出力定義
    modport slave (
        input  data, valid,
        output ready
    );
endinterface