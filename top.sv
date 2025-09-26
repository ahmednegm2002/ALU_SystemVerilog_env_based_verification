//`include "alu_if.sv"    // bring in interface
`include "env_pkg.sv"   // bring in package with classes
`include "testenv.sv"   // bring in environment
`timescale 1ns/1ps
module top;

logic clk, reset;
testenv env;

initial begin
    clk = 0;
    forever #5 clk = ~clk;
end
initial begin
    reset = 0;
    // reset all inputs
    alu_if_inst.valid_in = 0;
    alu_if_inst.a = 0;
    alu_if_inst.b = 0;
    alu_if_inst.cin = 0;
    alu_if_inst.ctl = 0;
    alu_if_inst.pkt_num = 0;
    #15;
    reset = 1;


    env = new(vif);
    env.run_env(1000); // generate 10 transactions

    $finish;
end

alu_if alu_if_inst(clk, reset);
// DUT instantiation
alu DUT (
    .clk(alu_if_inst.clk),
    .reset(alu_if_inst.reset),
    .a(alu_if_inst.a),
    .b(alu_if_inst.b),
    .cin(alu_if_inst.cin),
    .ctl(alu_if_inst.ctl),
    .alu(alu_if_inst.alu),
    .carry(alu_if_inst.carry),
    .zero(alu_if_inst.zero),
    .valid_in(alu_if_inst.valid_in),
    .valid_out(alu_if_inst.valid_out)   
);

virtual alu_if vif;
initial begin
    vif = alu_if_inst;
end


endmodule