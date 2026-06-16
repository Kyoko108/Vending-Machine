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

| State | Amount Stored          |
| ----- | ---------------------- |
| S0    | ₹0                     |
| S5    | ₹5                     |
| S10   | ₹10                    |
| S15   | ₹15 (Dispense Product) |

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
S0  --₹5-->  S5
S0  --₹10--> S10

S5  --₹5-->  S10
S5  --₹10--> S15

S10 --₹5-->  S15
S10 --₹10--> S15

S15 --------> S0
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

### Test Case 1

```text
Insert ₹5
Insert ₹10
```

Expected Result:

```text
Product Dispensed
```

---

### Test Case 2

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
<img width="883" height="438" alt="image" src="https://github.com/user-attachments/assets/7bdee3d6-cbc0-4422-8201-43ca08a66438" />


[ Add image here ]
