
class driver; // get stimulus from sequencer through mailbox and drive to DUT through virtual interface
mailbox #(transaction) mb_drv;
virtual alu_if vif;
    function new(virtual alu_if vif , mailbox #(transaction) mb);
        this.mb_drv = mb;
        this.vif = vif;
    endfunction
    task run_driver(int num);
        transaction tr;
       repeat (num+2) begin
           tr = new();
           mb_drv.get(tr);
           //tr.tr_display();
           vif.a = tr.a;
           vif.b = tr.b;
           vif.cin = tr.cin;
           vif.ctl = tr.ctl;
           vif.valid_in = tr.valid_in;
           vif.pkt_num = tr.pkt_num;
           $display("---------------------------------------------------");
           $display("Driving to DUT pkt_num=%0d: a=%0d, b=%0d, cin=%0b, ctl=%0b, valid_in=%0b",vif.pkt_num, vif.a, vif.b, vif.cin, vif.ctl, tr.valid_in);
           $display("---------------------------------------------------"); 

           fork: watchdog_driver
              begin
               @(posedge vif.valid_out); // wait until DUT finish respond
              end
              begin
                  repeat(2) begin
                   @(posedge vif.clk); // wait until DUT finish respond
                   
                  end
              end
              join_any
              disable watchdog_driver;
              if(! vif.valid_out) begin
                    $display("driver time out!!: valid_out is not asserted from DUT");
                    $finish;
                end
       end
           #10;
           // create event and toggle it here to notify end of simulation
           
           $display("All transactions are sent to DUT, ending simulation");
           $display("correct responses: %0d, errors: %0d", transaction::correct_count, transaction::error_count);
           $display("passing rate: %0f %%", (transaction::correct_count*100.0)/(transaction::correct_count+transaction::error_count));
           $finish;

    endtask
endclass