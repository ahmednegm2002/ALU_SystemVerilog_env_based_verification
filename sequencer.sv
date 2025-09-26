
class sequencer; // generate stimulus that will passed to driver through mailbox later on
mailbox #(transaction) mb_seq;
    function new(mailbox #(transaction) mb);
        this.mb_seq = mb;
    endfunction

    task generate_tr(int num);
    transaction tr;
    // directed testing 
    tr= new();
    tr.a = 4'b0011; tr.b = 4'b0001; tr.cin = 1'b0; tr.ctl = 4'b0000; tr.valid_in=1'b1; tr.pkt_num=0;
    mb_seq.put(tr);
    tr= new();
    tr.a = 4'b0100; tr.b = 4'b0010; tr.cin = 1'b0; tr.ctl = 4'b0001; tr.valid_in=1'b1; tr.pkt_num=1;
    mb_seq.put(tr);

        for (int i=0; i<num; i++) begin
            tr = new();
            assert(tr.randomize());
            tr.pkt_num = i+2; // since 2 directed tests are already sent
            tr.tr_display();
            mb_seq.put(tr);
        end
    endtask
endclass