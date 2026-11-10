`timescale 1ns/1ps

module vending_machine(
    input clk,
    input rst,          // active-high, asynchronous
    input coin5,
    input coin10,
    output reg dispense,
    output reg change   // asserted together with dispense: Rs.5 returned
);

localparam S0  = 3'b000;
localparam S5  = 3'b001;
localparam S10 = 3'b010;
localparam S15 = 3'b011;
localparam S20 = 3'b100;

reg [2:0] state;
reg [2:0] next_state;

// ---------------- Input conditioning ----------------
// 2-FF synchronizer, then rising-edge detect: one coin = one pulse,
// no matter how many cycles the coin line stays high.
reg [1:0] c5_sync, c10_sync;
reg       c5_prev, c10_prev;

always @(posedge clk or posedge rst)
begin
    if (rst) begin
        c5_sync  <= 2'b00;
        c10_sync <= 2'b00;
        c5_prev  <= 1'b0;
        c10_prev <= 1'b0;
    end else begin
        c5_sync  <= {c5_sync[0],  coin5};
        c10_sync <= {c10_sync[0], coin10};
        c5_prev  <= c5_sync[1];
        c10_prev <= c10_sync[1];
    end
end

wire coin5_pulse  = c5_sync[1]  & ~c5_prev;
wire coin10_pulse = c10_sync[1] & ~c10_prev;

// ---------------- State register ----------------
always @(posedge clk or posedge rst)
begin
    if (rst)
        state <= S0;
    else
        state <= next_state;
end

// ---------------- Next-state logic ----------------
// If both coin pulses arrive in the same cycle, coin5 wins and coin10 is
// ignored (documented policy).
always @(*)
begin
    case (state)

        S0:
        begin
            if (coin5_pulse)
                next_state = S5;
            else if (coin10_pulse)
                next_state = S10;
            else
                next_state = S0;
        end

        S5:
        begin
            if (coin5_pulse)
                next_state = S10;
            else if (coin10_pulse)
                next_state = S15;
            else
                next_state = S5;
        end

        S10:
        begin
            if (coin5_pulse)
                next_state = S15;
            else if (coin10_pulse)
                next_state = S20;
            else
                next_state = S10;
        end

        S15:     next_state = S0;
        S20:     next_state = S0;
        default: next_state = S0;

    endcase
end

// ---------------- Output logic (Moore) ----------------
always @(*)
begin
    dispense = 1'b0;
    change   = 1'b0;

    case (state)
        S15: dispense = 1'b1;
        S20: begin
            dispense = 1'b1;
            change   = 1'b1;
        end
        default: ;
    endcase
end

endmodule
