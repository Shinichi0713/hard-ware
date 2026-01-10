interface score_if #(parameter int WIDTH = 16) (input logic clk);
    logic [WIDTH-1:0] add_points;
    logic             valid;
    logic             full; // 集計機が忙しい時のバックプレッシャー

    modport agent (
        output add_points, valid,
        input  full
    );

    modport collector (
        input  add_points, valid,
        output full
    );
endinterface