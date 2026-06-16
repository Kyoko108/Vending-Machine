`timescale 1ns/1ps

module vending_machine(
    input clk,
    input rst,
    input coin5,
    input coin10,
    output reg dispense,
    output reg change
);

parameter S0  = 2'b00;
parameter S5  = 2'b01;
parameter S10 = 2'b10;
parameter S15 = 2'b11;

reg [1:0] state;
reg [1:0] next_state;

// State Register
always @(posedge clk or posedge rst)
begin
    if (rst)
        state <= S0;
    else
        state <= next_state;
end

// Next-State Logic
always @(*)
begin
    case(state)

        S0:
        begin
            if (coin5)
                next_state = S5;
            else if (coin10)
                next_state = S10;
            else
                next_state = S0;
        end

        S5:
        begin
            if (coin5)
                next_state = S10;
            else if (coin10)
                next_state = S15;
            else
                next_state = S5;
        end

        S10:
        begin
            if (coin5 || coin10)
                next_state = S15;
            else
                next_state = S10;
        end

        S15:
            next_state = S0;

        default:
            next_state = S0;

    endcase
end

// Output Logic
always @(*)
begin
    dispense = 0;
    change   = 0;

    case(state)

        S15:
        begin
            dispense = 1;

            if (coin10)
                change = 1;
        end

    endcase
end

endmodule