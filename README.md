# Vending Machine Controller using Verilog HDL

## Overview

This project implements a Finite State Machine (FSM) based Vending Machine Controller in Verilog HDL.

The vending machine dispenses a product costing **₹15** and accepts the following coin denominations:

* ₹5 Coin
* ₹10 Coin

The controller tracks the accumulated amount using FSM states and dispenses the product when the required amount is reached.

---

## Features

* FSM-based design
* Accepts ₹5 and ₹10 coins
* Dispenses product when ₹15 is accumulated
* Returns change on overpayment (₹20 case)
* Includes simulation testbench
* Generates waveform output for verification using GTKWave

---

## Functional Specification

### Product Cost

```text
₹15
```

### Accepted Coins

```text
₹5
₹10
```

### Outputs

| Signal   | Description                                  |
| -------- | -------------------------------------------- |
| dispense | Product is dispensed                         |
| change   | Indicates change is returned (if applicable) |

---

## FSM States

| State | Amount Stored                     |
| ----- | --------------------------------- |
| S0    | ₹0                                |
| S5    | ₹5                                |
| S10   | ₹10                               |
| S15   | ₹15 (Dispense Product ,no change) |
| S20   | ₹20 (Dispense + Change)           |

---

## State Diagram
<img width="1254" height="1254" alt="image" src="https://github.com/user-attachments/assets/52cc5e00-d39d-4668-9e06-899767b0c215" />



---

## FSM Architecture
<img width="1536" height="1024" alt="image" src="https://github.com/user-attachments/assets/ed19b921-5349-41c9-b6da-0f74e79c0d9f" />


---

## Project Structure

```text
Vending_Machine_Controller/
│
├── vending_machine.v
├── vending_machine_tb.v
├── vending_machine.vcd
├── README.md
```

---

## State Transitions

```text
S0 --₹5--> S5
S0 --₹10--> S10

S5 --₹5--> S10
S5 --₹10--> S15

S10 --₹5--> S15
S10 --₹10--> S20

S15 --------> S0
S20 --------> S0
```

---

## Simulation Setup

### Compilation

```cmd
iverilog -g2012 -Wall -s vending_machine_tb -o vending_machine.exe vending_machine.v vending_machine_tb.v
```

### Run Simulation

```cmd
vvp vending_machine.exe
```

### View Waveforms

```cmd
gtkwave vending_machine.vcd
```

---

## Test Scenario

### Test Case 1 — Exact Payment

```text
Insert ₹5
Insert ₹10
```

Expected Result:

```text
Product Dispensed
```

---

### Test Case 2 — Overpayment

```text
Insert ₹10
Insert ₹10
```

Expected Result:

```text
Product Dispensed
Change Returned
```

---

## Bugs Found & Fixed

While verifying the design against Test Case 2 (₹10 + ₹10), a few issues surfaced during debugging:

1. **State register width truncation** — `state`/`next_state` were declared as `[1:0]` (2 bits), which could only represent 4 states. Adding a 5th state (`S20`) silently truncated it to `S0` at the register level, even though the parameter itself was defined correctly. Fixed by widening both to `[2:0]`.
2. **Missing hold-state transition** — the `S10` state had no explicit "no coin inserted" branch holding at `S10`; it defaulted to `S0`, silently discarding the first ₹10 coin if there was any gap before the second coin arrived. Fixed by adding an explicit self-loop.
3. **Change output tied to a live input signal instead of state** — the original output logic checked `if (coin10)` to decide whether to assert `change`, rather than deriving it purely from the current state. This made the output timing-dependent and could misfire depending on how long the coin signal stayed asserted. Fixed by deriving `change` purely from `state == S20`.

This was a good reminder that FSM outputs should always be a pure function of state, not of transient input timing.

---

## Concepts Demonstrated

* Finite State Machines (FSM)
* Sequential Logic Design
* Combinational Logic Design
* State Transition Design
* Verilog HDL
* Functional Verification
* Testbench Development

---

## Tools Used

* Verilog HDL
* Icarus Verilog
* GTKWave
* Visual Studio Code

---

## Future Enhancements

* Support for multiple products
* Variable product pricing
* Exact change calculation
* Coin return mechanism
* LCD/Display interface
* Mealy and Moore FSM comparison

---

## Below is the Output 
<img width="968" height="431" alt="image" src="https://github.com/user-attachments/assets/798ce625-675e-43e4-96c0-65f43cb17707" />



