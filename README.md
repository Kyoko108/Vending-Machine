# Vending Machine Controller (Verilog HDL)

A finite state machine (FSM) vending machine controller in Verilog. It accepts ₹5 and ₹10 coins, dispenses a ₹15 product, and signals ₹5 change on overpayment. Coin inputs are synchronized and edge-detected, so one physical coin counts exactly once. Verified with a self-checking testbench (Icarus Verilog + GTKWave).

---

## Specification

| Item | Value |
| --- | --- |
| Product price | ₹15 |
| Accepted coins | ₹5, ₹10 |
| Possible overpayment | ₹5 only (₹10 + ₹10 = ₹20) |
| FSM type | Moore (outputs depend only on current state) |
| Clock | Single clock, rising edge |
| Reset | Active-high, asynchronous |

### Ports

| Signal | Dir | Description |
| --- | --- | --- |
| `clk` | in | Clock |
| `rst` | in | Active-high asynchronous reset |
| `coin5` | in | ₹5 coin inserted |
| `coin10` | in | ₹10 coin inserted |
| `dispense` | out | High for one cycle when ₹15 or more has been paid |
| `change` | out | High together with `dispense` when ₹5 change is due |

---

## Design

### Input conditioning

Each coin input passes through a 2-flip-flop synchronizer followed by a rising-edge detector. The FSM sees a single one-cycle pulse per coin, no matter how long the coin line stays high. Without this, a coin line held for N cycles is counted N times (see [Bugs Found & Fixed](#bugs-found--fixed)).

```
coin5 ──► [FF]──►[FF]──┬──► coin5_pulse = sync & ~prev ──► FSM
                       └──► [FF] (prev)
```

### FSM states

| State | Amount stored | Output |
| --- | --- | --- |
| `S0` | ₹0 | none |
| `S5` | ₹5 | none |
| `S10` | ₹10 | none |
| `S15` | ₹15 | `dispense` |
| `S20` | ₹20 | `dispense` + `change` |

### State transitions

```
S0  --5--> S5     S0  --10--> S10     S0  --no coin--> S0
S5  --5--> S10    S5  --10--> S15     S5  --no coin--> S5
S10 --5--> S15    S10 --10--> S20     S10 --no coin--> S10
S15 ------------> S0   (unconditional)
S20 ------------> S0   (unconditional)
```

### State diagram

![State diagram](https://github.com/user-attachments/assets/52cc5e00-d39d-4668-9e06-899767b0c215)

### FSM architecture

![FSM architecture](https://github.com/user-attachments/assets/ed19b921-5349-41c9-b6da-0f74e79c0d9f)

### Design decisions and limitations

These are deliberate choices or known limits, not hidden behavior:

- **Latency:** a coin takes 3 clock cycles from the input pin to affect the FSM state, because of the synchronizer and edge detector.
- **Held coin = one coin.** A coin line held high for several cycles is counted once.
- **Minimum gap between identical coins:** two `coin5` insertions with no idle cycle between them look like one held coin and count once. Real coins arrive milliseconds apart, so this only matters in simulation.
- **Simultaneous coins:** if `coin5` and `coin10` pulse in the same cycle, `coin5` takes priority and `coin10` is dropped. This policy is implemented but **not covered by the testbench**.
- **Coin during dispense:** `S15` and `S20` return to `S0` unconditionally, so a coin pulse arriving in that single cycle is lost.
- **Asynchronous reset is not synchronized on release.** Fine for simulation; a real FPGA or ASIC flow would add a reset synchronizer.
- **No synthesis run.** This repo is simulation-verified only. No area or timing numbers are claimed.

---

## Verification

The testbench (`vending_machine_tb.v`) is self-checking. It counts rising edges of `dispense` and `change` for each transaction, compares them with expected values, and prints `PASS`/`FAIL` per test plus a final `RESULT` line.

| # | Test | Expected |
| --- | --- | --- |
| 1 | ₹5 + ₹10 | dispense, no change |
| 2 | ₹10 + ₹5 | dispense, no change |
| 3 | ₹5 + ₹5 + ₹5 | dispense, no change |
| 4 | ₹10 + ₹10 | dispense + change |
| 5 | ₹5 + ₹5 + ₹10 | dispense + change |
| 6 | ₹5 then ₹10, no idle cycle between | dispense, no change |
| 7 | ₹10, long idle gap, ₹5 | dispense (hold state works) |
| 8 | ₹10, long idle gap, ₹10 | dispense + change |
| 9 | ₹5 only | no dispense |
| 10 | Reset in the middle of a transaction | no dispense, clean restart |
| 11 | ₹5 held for 3 cycles (`-DHELD_COIN`) | counted once, no dispense |
| 12 | ₹10 held for 3 cycles (`-DHELD_COIN`) | counted once, no dispense |

**Not covered:** simultaneous `coin5` + `coin10`, and a coin arriving during the dispense cycle.

### Running the simulation

Basic tests (1-10):

```
iverilog -g2012 -Wall -o sim vending_machine.v vending_machine_tb.v
vvp sim
```

All tests including held-coin (1-12):

```
iverilog -g2012 -DHELD_COIN -o sim vending_machine.v vending_machine_tb.v
vvp sim
```

View waveforms:

```
gtkwave vending_machine.vcd
```

### Results

Basic tests (1-10):

<img width="727" height="221" alt="Screenshot 2026-11-10 132937" src="https://github.com/user-attachments/assets/95551369-3346-4f59-a30f-41797d22f493" />
<!-- DRAG screenshot 1 (10 tests pass) onto this line in the GitHub editor, then delete this comment -->

All tests including held-coin (1-12):

<img width="727" height="240" alt="Screenshot 2026-11-10 141234" src="https://github.com/user-attachments/assets/b0651f88-2460-4909-a27b-5da044effb3d" />
<!-- DRAG screenshot 2 (12 tests pass) onto this line in the GitHub editor, then delete this comment -->


---

## Bugs Found & Fixed

1. **State register width truncation.** `state` and `next_state` were 2 bits wide, but the design has 5 states. `S20` was silently truncated to `S0`. Fixed by widening both to `[2:0]`.
2. **Missing hold transition.** `S10` had no "no coin" branch and fell through to `S0`, discarding a ₹10 coin if there was any gap before the next coin. Fixed with an explicit self-loop.
3. **`change` driven by a live input.** The original output logic checked `coin10` directly, so the output depended on input timing. Fixed by deriving `change` purely from `state == S20`. FSM outputs should be a function of state, not transient inputs.
4. **Held coin counted every clock cycle.** The FSM sampled the raw coin lines, so a coin held for 3 cycles was counted 3 times: a single ₹5 held for 3 cycles dispensed a product. This was invisible to the original testbench because every pulse was exactly one cycle wide. It was found by a self-checking test and failed as shown below, then fixed with the synchronizer and edge detector.

   Before the fix:
   ```
   FAIL  held 5 x3 cycles = one coin: dispense=1 (exp 0)  change=0 (exp 0)
   FAIL  held 10 x3 cycles = one coin: dispense=1 (exp 0)  change=1 (exp 0)
   ---- 12 tests, 2 failed ----
   RESULT: FAIL
   ```

---

## Project Structure

```
Vending-Machine/
├── vending_machine.v        # RTL design
├── vending_machine_tb.v     # Self-checking testbench
├── README.md
├── .gitignore               # ignores simulation outputs
└── docs/                    # diagrams and waveform screenshots (optional)
```

Simulation outputs (`sim`, `*.vcd`, `*.exe`) are generated by the commands above and are not committed.

---

## Possible Extensions

- Multiple products and variable pricing
- Exact-change and coin-return mechanism
- Test for simultaneous coins and coin-during-dispense, then decide the policy
- Synthesis run (e.g. Yosys) to report state encoding and cell count
- Mealy vs. Moore comparison

---

## Tools

Verilog HDL, Icarus Verilog (`-g2012`), GTKWave, VS Code
