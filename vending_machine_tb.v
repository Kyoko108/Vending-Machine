`timescale 1ns/1ps

module vending_machine_tb;

reg clk = 0, rst = 1, coin5 = 0, coin10 = 0;
wire dispense, change;

vending_machine uut (
    .clk(clk), .rst(rst),
    .coin5(coin5), .coin10(coin10),
    .dispense(dispense), .change(change)
);

always #5 clk = ~clk;

// ---------- scoreboard: count rising edges of each output ----------
integer disp_cnt = 0, chg_cnt = 0;
integer errors = 0, tests = 0;
reg dispense_q = 0, change_q = 0;

always @(posedge clk) begin
    dispense_q <= dispense;
    change_q   <= change;
    if (dispense && !dispense_q) disp_cnt = disp_cnt + 1;
    if (change   && !change_q)   chg_cnt  = chg_cnt  + 1;
end

// ---------- helpers (all assume we are sitting on a negedge) ----------
task do_reset;
begin
    coin5 = 0; coin10 = 0; rst = 1;
    repeat (2) @(negedge clk);
    rst = 0;
    @(negedge clk);
    disp_cnt = 0; chg_cnt = 0;
end
endtask

// hold = cycles the coin line stays high, gap = idle cycles afterwards
task ins5(input integer hold, input integer gap);
begin
    coin5 = 1; repeat (hold) @(negedge clk);
    coin5 = 0; repeat (gap)  @(negedge clk);
end
endtask

task ins10(input integer hold, input integer gap);
begin
    coin10 = 1; repeat (hold) @(negedge clk);
    coin10 = 0; repeat (gap)  @(negedge clk);
end
endtask

task check(input integer exp_d, input integer exp_c, input [8*32-1:0] name);
begin
    repeat (8) @(negedge clk);   // let outputs settle
    tests = tests + 1;
    if (disp_cnt !== exp_d || chg_cnt !== exp_c) begin
        errors = errors + 1;
        $display("FAIL  %0s: dispense=%0d (exp %0d)  change=%0d (exp %0d)",
                 name, disp_cnt, exp_d, chg_cnt, exp_c);
    end else
        $display("PASS  %0s", name);
end
endtask

// ---------- tests ----------
initial begin
    @(negedge clk);

    do_reset; ins5(1,1); ins10(1,1);               check(1,0,"5+10");
    do_reset; ins10(1,1); ins5(1,1);               check(1,0,"10+5");
    do_reset; ins5(1,1); ins5(1,1); ins5(1,1);     check(1,0,"5+5+5");
    do_reset; ins10(1,1); ins10(1,1);              check(1,1,"10+10 (change)");
    do_reset; ins5(1,1); ins5(1,1); ins10(1,1);    check(1,1,"5+5+10 (change)");
    do_reset; ins5(1,0); ins10(1,1);               check(1,0,"5 then 10 back-to-back");
    do_reset; ins10(1,8); ins5(1,1);               check(1,0,"10, long gap, 5 (hold state)");
    do_reset; ins10(1,8); ins10(1,1);              check(1,1,"10, long gap, 10 (hold state)");
    do_reset; ins5(1,8);                           check(0,0,"5 only, no dispense");
    do_reset; ins10(1,2); do_reset; ins5(1,1);     check(0,0,"mid-transaction reset");

`ifdef HELD_COIN
    // Spec decision: a coin line held high for several cycles is ONE coin.
    // Expected to FAIL unless the DUT has input edge detection.
    do_reset; ins5(3,1);                           check(0,0,"held 5 x3 cycles = one coin");
    do_reset; ins10(3,1);                          check(0,0,"held 10 x3 cycles = one coin");
`endif

    $display("---- %0d tests, %0d failed ----", tests, errors);
    if (errors == 0) $display("RESULT: PASS");
    else             $display("RESULT: FAIL");
    $finish;
end

// watchdog
initial begin
    #100000;
    $display("RESULT: FAIL (timeout)");
    $finish;
end

initial begin
    $dumpfile("vending_machine.vcd");
    $dumpvars(0, vending_machine_tb);
end

endmodule
