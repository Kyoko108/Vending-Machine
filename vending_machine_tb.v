`timescale 1ns/1ps

module vending_machine_tb;

reg clk;
reg rst;
reg coin5;
reg coin10;

wire dispense;
wire change;

vending_machine uut (
    .clk(clk),
    .rst(rst),
    .coin5(coin5),
    .coin10(coin10),
    .dispense(dispense),
    .change(change)
);

// Clock Generation
always #5 clk = ~clk;

initial
begin
    clk = 0;
    rst = 1;
    coin5 = 0;
    coin10 = 0;

    #20;
    rst = 0;

    // Insert Rs.5
    #10 coin5 = 1;
    #10 coin5 = 0;

    // Insert Rs.10
    #10 coin10 = 1;
    #10 coin10 = 0;

    // Wait
    #30;

    // Insert Rs.10
    #10 coin10 = 1;
    #10 coin10 = 0;

    // Insert another Rs.10
    #10 coin10 = 1;
    #10 coin10 = 0;

    #50;
    $finish;
end

initial
begin
    $monitor(
        "Time=%0t coin5=%b coin10=%b dispense=%b change=%b",
        $time, coin5, coin10, dispense, change
    );
end

initial
begin
    $dumpfile("vending_machine.vcd");
    $dumpvars(0, vending_machine_tb);
end

endmodule