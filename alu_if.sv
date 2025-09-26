interface alu_if (input logic clk, input logic reset);
    logic valid_in;
    logic [3:0] a, b;
    logic  cin;
    logic [3:0] ctl;
    logic valid_out;
    logic [3:0] alu;
    logic carry , zero;
    int pkt_num;
endinterface 

