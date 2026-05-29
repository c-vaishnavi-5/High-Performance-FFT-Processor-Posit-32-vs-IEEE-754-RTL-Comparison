# High-Performance FFT Processor — Posit-32 vs IEEE-754 RTL Comparison

8-point Radix-2 DIT FFT cores implemented in Verilog HDL using Posit-32 and IEEE-754 arithmetic on a 90nm CMOS standard cell library. Evaluated for numerical accuracy, power, performance, and area using Cadence Genus synthesis.

## Overview

Two fully pipelined FFT processors sharing an identical 3-stage, 12-butterfly architecture. The only difference between the two implementations is the arithmetic format within the butterfly units, ensuring all observed differences in results are attributable solely to the numerical representation.

## Tools & Technologies

- HDL: Verilog HDL
- Simulation: ModelSim / Cadence Xcelium
- Synthesis: Cadence Genus
- Technology: 90nm CMOS Standard Cell Library
- Reference: MATLAB (double-precision FFT outputs)

## Key Features

- 3-stage, 12-butterfly Radix-2 DIT architecture with 12-cycle pipeline latency
- Pipelined Posit-32 multiplier (4-stage) and adder/subtractor (5-stage) with regime extraction
- 4-cycle butterfly unit: 4 multipliers + 6 adder/subtractors per instance
- Irrational twiddle factors W1 and W3 isolated to Stage 3; Stages 1 and 2 use exact factors only
- Stage-wise SQNR probing to trace error propagation across butterfly stages

## Results

**Hardware Synthesis (50 MHz target)**

| Metric | IEEE-754 FFT | Posit-32 FFT | Difference |
|---|---|---|---|
| Cell Area | 406,235.7 um2 | 809,909.5 um2 | +99.3% |
| Gate Count | 50,225 | 141,986 | +182.7% |
| Dynamic Power | 25.21 mW | 35.21 mW | +39.7% |
| Total Power | 27.27 mW | 39.06 mW | +43.2% |
| Critical Path Delay | 19.235 ns | 19.760 ns | +2.7% |

**Numerical Accuracy (vs MATLAB double-precision reference)**

| Test | Posit SQNR (dB) | FP32 SQNR (dB) | Advantage |
|---|---|---|---|
| T1–T4 (exact twiddles) | inf | inf | Tie |
| T5: Cosine f=1 | 160.93 | 142.83 | +18.10 dB |
| T6: Random | 160.01 | 143.01 | +17.00 dB |
| T7: Multi-tone | 160.03 | 160.00 | +0.03 dB |
| T8: Wide Range | 32.40 | 32.40 | Tie |
| Average (T5–T8) | 128.34 | 119.56 | +8.78 dB |

## Repository Structure

- `Floating/` — Verilog HDL source files of IEEE-754 core)
- `posit/` — Verilog HDL source files of posit<32,2> core)

## Academic Context

B.Tech Final Year Project — VIT Chennai, November 2025
