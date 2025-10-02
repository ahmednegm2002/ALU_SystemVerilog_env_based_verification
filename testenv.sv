// write testenv.sv
import env_pkg::*;
class testenv;
    virtual alu_if vif;
    mailbox #(transaction) mb_seq_driv, mb_mon_score ,mb_mon_sub;
    sequencer seqr;
    driver drv;
    monitor mon;
    scoreboard scb;
    subscriber sub;
//constructor of testenv
    function new(virtual alu_if vif);  // pass virtual interface from top module
        this.vif = vif;
        mb_seq_driv = new();
        mb_mon_score = new();
        mb_mon_sub = new();
        seqr = new(this.mb_seq_driv);
        drv = new(this.vif, this.mb_seq_driv);
        mon = new(this.vif, this.mb_mon_score , this.mb_mon_sub);
        scb = new(this.mb_mon_score);
        sub = new(this.mb_mon_sub);
    endfunction

    task run_env(int num);
        fork
            begin
                seqr.generate_tr(num);
            end
            begin
                drv.run_driver(num);
            end
            begin
                mon.run_monitor();
            end
            begin
                scb.run_scoreboard();
            end
            begin
                sub.run_subscriber(num);
            end
            // begin
            //     #100000000;
            //     $finish;
            // end
        join
    endtask
endclass