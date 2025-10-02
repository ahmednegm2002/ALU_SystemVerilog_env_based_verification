class subscriber;
    mailbox #(transaction) mb_sub;
    transaction tr;

    // Covergroup defined inside the class
    covergroup cg_sub;
        cp_a       : coverpoint tr.a{
            bins a_max ={15}; // example: cover when a is at its max value (15 for 4-bit)
            bins a_min ={0};  // example: cover when a is at its min value (0 for 4-bit)
            bins a_other ={[1:14]};       // example: cover when a is at its average value (7 for 4-bit)
        }
        
        cp_b       : coverpoint tr.b{
            bins b_max ={15}; // example: cover when b is at its max value (15 for 4-bit)
            bins b_min ={0};  // example: cover when b is at its min value (0 for 4-bit)
            bins b_other ={[1:14]};       // example: cover when b is at its average value (7 for 4-bit)
        }
        cp_cin     : coverpoint tr.cin;
        cp_ctl     : coverpoint tr.ctl {
            bins add_no_carry = {3}; // example: cover when ctl is at its max value (15 for 4-bit)
            bins add_with_carry = {4};  // example: cover when ctl is at its min value (0 for 4-bit)
            bins sub_no_borrow = {5};       // example: cover when ctl is at its average value (7 for 4-bit)
            bins sub_with_borrow = {6};       // example: cover when ctl is at
            bins ctl_other1 = {[0:2]};
            bins ctl_other2 = {[7:13]};
            ignore_bins ctl_invalid = {[14:$]}; // example: ignore ctl values 1111 and 0000
        }
        // cross coverage
    cross_specific: cross cp_a, cp_b, cp_ctl {
    bins a_b_max_add_no_carry = binsof(cp_a.a_max) && binsof(cp_b.b_max) && binsof(cp_ctl.add_no_carry);
    bins a_b_min_sub_no_borrow = binsof(cp_a.a_min) && binsof(cp_b.b_min) && binsof(cp_ctl.sub_no_borrow);
    bins a_b_max_add_with_carry = binsof(cp_a.a_max) && binsof(cp_b.b_max) && binsof(cp_ctl.add_with_carry);
    bins a_b_min_sub_with_borrow = binsof(cp_a.a_min) && binsof(cp_b.b_min) && binsof(cp_ctl.sub_with_borrow);
    ignore_bins a_b_other_any_ctl = (binsof(cp_a.a_other) || binsof(cp_b.b_other));
    ignore_bins any_other_ctl= (binsof(cp_ctl.ctl_other1) || binsof(cp_ctl.ctl_other2));
  }

    endgroup

    // Constructor
    function new(mailbox #(transaction) mb);
        this.mb_sub = mb;
        this.cg_sub = new();  // instantiate covergroup here
    endfunction

    // Run subscriber
    task run_subscriber(int num);
        repeat (num+2) begin
            mb_sub.get(tr);
            cg_sub.sample();   // sample coverage here
        end
        $display("All transactions are received by subscriber, ending simulation");
        $finish;
    endtask
endclass
