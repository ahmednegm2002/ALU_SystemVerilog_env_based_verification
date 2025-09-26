
class monitor; // get stimulus and response from DUT through virtual interface and print them
virtual alu_if vif;
mailbox #(transaction) mb_mon;
    function new(virtual alu_if vif , mailbox #(transaction) mb);
        this.mb_mon = mb;
        this.vif = vif;
    endfunction
    task run_monitor();
        transaction tr;
       forever begin
            tr= new() ;
            fork:watchdog
               begin
                @(posedge vif.valid_out); // wait until DUT respond
               end
               begin
                   repeat(2) begin
                    @(posedge vif.clk); // wait until DUT finish respond
                   end
               end
            join_any
            disable watchdog;
            if (vif.valid_out) begin
                tr.a = vif.a;
                tr.b = vif.b;
                tr.cin = vif.cin;
                tr.ctl = vif.ctl;
                tr.pkt_num = vif.pkt_num;
                tr.valid_in = vif.valid_in;
                tr.valid_out = vif.valid_out;
                tr.alu = vif.alu;
                tr.carry = vif.carry;
                tr.zero = vif.zero;
                mb_mon.put(tr); // send for scoreboard
                $display("---------------------------------------------------");
                $display("Monitoring from DUT: a=%0d, b=%0d, cin=%0b, ctl=%0b, pkt_num=%0d", vif.a, vif.b, vif.cin, vif.ctl, vif.pkt_num);
                $display("Monitoring from DUT: valid_out=%0b, alu=%0d, carry=%0b, zero=%0b", vif.valid_out, vif.alu, vif.carry, vif.zero);
                $display("---------------------------------------------------");
            end
            else begin // disaple fork
            $display("monitor time out!!: No response from DUT");
            $finish;
            end           
       end
    endtask
endclass
