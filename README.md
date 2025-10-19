# 🚀 CORDIC Fixed-Point Hardware Implementation

This project implements a **13-stage pipelined CORDIC (Coordinate Rotation Digital Computer)** algorithm in **Verilog HDL**, verified using **MATLAB fixed-point modeling**. The design supports multiple operation modes (rotation, vectoring, sine/cosine, and hyperbolic functions) and achieves excellent numerical precision with less than **0.001% error**.

---

## 📘 Table of Contents
1.[Repository Structure](#Repository-Structure)
1. [Overview](#overview)
2. [Design Objectives](#design-objectives)
3. [System Architecture](#system-architecture)
4. [Implementation Details](#implementation-details)
5. [Simulation & Verification](#simulation--verification)
6. [Results Summary](#results-summary)
7. [Repository Structure](#repository-structure)
8. [Tools Used](#tools-used)
9. [Future Improvements](#future-improvements)
10. [License](#license)

---

## 🗂️ Repository Structure

32_bit_CORDIC_Algorithm_Implementation/
│
├── Matlab/
│   ├── cordic.m
│   ├── chooes_good_iteration.m
│   ├── chooes_good_wordlength.m
│   ├── prepare_data_to_rtl.m
│
├── RTL/
│   ├── cordic.v
│   ├── cordic_stage.v
│   ├── cordic_fixed_multiplier.v
│   ├── cordic_fixed_multiplier_tb.v
│   ├── cordic_tb.v
│
├── results/
│   ├── constrains_cordic.xdc
│   ├── cordic_clock_utilization_routed.rpt
│   ├── cordic_power_routed.rpt
│   ├── cordic_route_status.rpt
│   ├── cordic_timing_summary_routed.rpt
│
├── documentation/
│   ├── cordic.pdf
│
└── README.md


---

## 🧠 Overview

The **CORDIC algorithm** is widely used for computing trigonometric, hyperbolic, and vector functions using only **shift-add operations**, eliminating the need for multipliers.  
This makes it ideal for FPGA and ASIC implementations where area and power efficiency are critical.

This project demonstrates:
- Fixed-point arithmetic modeling in MATLAB  
- RTL design in Verilog HDL  
- Co-simulation and accuracy comparison  
- Pipelined architecture for high throughput  
<p align="center">
  <img width="894" height="318" alt="image" src="https://github.com/user-attachments/assets/9b709ade-25c4-472e-87ab-73f419372439" />
</p>

---

## 🎯 Design Objectives
- Implement a **parameterized, iterative CORDIC architecture**.
- Support multiple operating **modes**:
  
| Mode | Description |
|------|--------------|
| 0 | Selects **vectoring mode** to calculate the **magnitude** and **angle** of the vector. |
| 1 | Selects **rotation mode** to calculate **sine** and **cosine** of θ. |
| 2 | Selects **rotation mode** to calculate the **new point (x, y)** after **counterclockwise rotation**. |
| 3 | Selects **rotation mode** to calculate the **new point (x, y)** after **clockwise rotation**. |

- Optimize word length and fractional length for accuracy and resource utilization.
- Achieve < **0.001% error** compared to MATLAB reference.

---

## ⚙️ System Architecture

The CORDIC algorithm iteratively rotates a vector in 2D space using the following equations:

$$
x_{i+1} = x_i + y_i \cdot d_i \cdot 2^{-i}
$$

$$
y_{i+1} = y_i - x_i \cdot d_i \cdot 2^{-i}
$$

$$
z_{i+1} = z_i + d_i \cdot \arctan(2^{-i})
$$

where  

$$
d_i = \text{sign}(z_i)
$$

💡 *These equations allow CORDIC to compute trigonometric, vectoring, and rotation operations efficiently using only shift and add operations — no multipliers required.*
---

## 💻 Implementation Details

### 🔹 MATLAB Fixed-Point Modeling
- MATLAB scripts were used to analyze **quantization error** and determine the optimal word and fraction lengths.
- Fixed-point testbench compared expected vs. simulated values for all modes.

### 🔹 Verilog HDL Design
- RTL implemented with **parameterized generics** for iteration and word length.
- Fully **pipelined architecture** for maximum throughput.
- Testbench reads MATLAB-generated inputs and compares RTL outputs in real-time.

Example top-level module:
```verilog
module cordic #(
  parameter ITERATION = 13,
  parameter WORD_LENGTH = 32,
  parameter FRACTION_LENGTH = 22,
  parameter MUL_LENGTH = 64
)(
  input                          i_cordic_clk,
  input                          i_cordic_rst_n,
  input           [1:0]          i_cordic_mode,
  input signed   [WORD_LENGTH-1:0] i_cordic_x,
  input signed   [WORD_LENGTH-1:0] i_cordic_y,
  input signed   [WORD_LENGTH-1:0] i_cordic_theta,
  output reg signed [MUL_LENGTH-1:0] o_codic_out1,
  output reg signed [MUL_LENGTH-1:0] o_codic_out2
);
