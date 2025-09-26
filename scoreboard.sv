class scoreboard; // get stimulus and response from monitor through mailbox and check them
mailbox #(transaction) mb_scb;
    function new(mailbox #(transaction) mb);
        this.mb_scb = mb;
    endfunction

task automatic alu_ref_model (
    input  logic [3:0] a,
    input  logic [3:0] b,
    input  logic       cin,
    input  logic [3:0] ctl,
    output logic [3:0] alu_ref,
    output logic       carry_ref,
    output logic       zero_ref
);
    logic [4:0] temp; // extra bit for carry/borrow
    alu_ref   = '0;
    carry_ref = 0;
    zero_ref  = 0;

    case (ctl)
        4'b0000: alu_ref = b;                       // Select data on port B
        4'b0001: begin                              // Increment B
                  temp      = b + 1;
                  alu_ref   = temp[3:0];
                  carry_ref = temp[4];
              end
        4'b0010: begin                              // Decrement B
                  temp      = b - 1;
                  alu_ref   = temp[3:0];
                  carry_ref = temp[4];
              end
        4'b0011: begin                              // ADD without carry
                      temp      = a + b;
                      alu_ref   = temp[3:0];
                      carry_ref = temp[4];
                  end
        4'b0100: begin                              // ADD with carry
                      temp      = a + b + cin;
                      alu_ref   = temp[3:0];
                      carry_ref = temp[4];
                  end
        4'b0101: begin                              // SUB without borrow
                      temp      = a - b;
                      alu_ref   = temp[3:0];
                      carry_ref = temp[4]; // can also define borrow separately
                  end
        4'b0110: begin                              // SUB with borrow
                      temp      = a - b - cin;
                      alu_ref   = temp[3:0];
                      carry_ref = temp[4];
                  end
        4'b0111: alu_ref = a & b;                   // AND
        4'b1000: alu_ref = a | b;                   // OR
        4'b1001: alu_ref = a ^ b;                   // XOR
        4'b1010: alu_ref = b << 1;                  // Shift left
        4'b1011: alu_ref = b >> 1;                  // Shift right
        4'b1100: alu_ref = {b[2:0], b[3]};          // Rotate left
        4'b1101: alu_ref = {b[0], b[3:1]};          // Rotate right
        default: alu_ref = 4'hX;
    endcase

    // Zero flag
    zero_ref = (alu_ref == 4'b0000);

endtask




    task run_scoreboard();

           logic [3:0] alu_ref;
           logic       carry_ref;
           logic       zero_ref;
       forever begin
           transaction tr ;
           mb_scb.get(tr);

           alu_ref_model(tr.a, tr.b, tr.cin, tr.ctl, alu_ref, carry_ref, zero_ref);

           if (tr.alu != alu_ref || tr.carry != carry_ref || tr.zero != zero_ref) begin
                $display("Mismatch detected in Scoreboard for pkt_num=%0d", tr.pkt_num);
                $display("Expected: alu=%0b, carry=%0b, zero=%0b", alu_ref, carry_ref, zero_ref);
                $display("Received: alu=%0b, carry=%0b, zero=%0b", tr.alu, tr.carry, tr.zero);
                tr.tr_display();
                tr.error_count++;
                $fatal; // stop simulation on error
              end
              else
              begin
                tr.correct_count++;
                $display("Match confirmed in Scoreboard for pkt_num=%0d", tr.pkt_num);
                tr.tr_display();
              end
            
       end
    endtask
endclass
