class transaction;
    randc logic [3:0] a, b;
    randc logic cin;
    randc logic valid_in;
    randc logic [3:0] ctl;
    logic [3:0] alu;
    logic carry, zero;
    logic valid_out;
    int pkt_num;
    static int correct_count = 0;
    static int error_count = 0;



    constraint c_valid_in {valid_in == 1'b1;} // always valid input

    constraint c_ctl { ctl inside {[0:8], [10:13]}; } // ctl in 0-8 and 10-13, exclude 9


    function void tr_display();
        $display("---------------------------------------------------");
        $display("pkt_num=%0d", pkt_num);
        $display("a=%0d, b=%0d, cin=%0b, ctl=%0b", a, b, cin, ctl);
        $display("valid_in=%0b, valid_out=%0b, alu=%0d, carry=%0b, zero=%0b", valid_in, valid_out, alu, carry, zero);
        $display("---------------------------------------------------");       
    endfunction
endclass