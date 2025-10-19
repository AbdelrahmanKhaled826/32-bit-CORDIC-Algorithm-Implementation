# 🚀 CORDIC Fixed-Point Hardware Implementation

This project implements a **13-stage pipelined CORDIC (Coordinate Rotation Digital Computer)** algorithm in **Verilog HDL**, verified using **MATLAB fixed-point modeling**. The design supports multiple operation modes (rotation, vectoring, sine/cosine, and hyperbolic functions) and achieves excellent numerical precision with less than **0.001% error**.

---

## 📘 Table of Contents
1. [Overview](#overview)
2. [Project Structure](#Project_Structure)
3. [Design Objectives](#design-objectives)
4. [System Architecture](#system-architecture)
6. [Implementation Details](#implementation-details)
7. [Verification Setup](#verification_Setup)
10. [Tools Used](#tools-used)
11. [Author](#Author)

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

## 📁 Project Structure

| File | Description |
|------|--------------|
| `cordic.m` | Core MATLAB model for CORDIC computation |
| `chooes_good_iteration.m` | Script to determine optimal iteration count (tolerance-based) |
| `chooes_good_wordlength.m` | Script to choose best fixed-point word length |
| `prepare_data_to_rtl.m` | Generates fixed-point data for RTL simulation |
| `cordic.v` | Top-level CORDIC module |
| `cordic_stage.v` | Individual pipeline stage implementation |
| `cordic_fixed_multiplier.v` | Fixed-point multiplier module |
| `cordic_tb.v` | Main testbench comparing RTL vs. MATLAB outputs |
| `cordic_fixed_multiplier_tb.v` | Unit test for multiplier block |

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
> ### CORDIC Core Equations
> The iterative updates are defined as:
>
> $$
> x_{i+1} = x_i + d_i \, y_i \, 2^{-i}
> $$
> $$
> y_{i+1} = y_i - d_i \, x_i \, 2^{-i}
> $$
> $$
> z_{i+1} = z_i + d_i \, \tan^{-1}(2^{-i})
> $$
>
> where:
> - $d_i = \text{sign}(z_i)$  
> - $(x_0, y_0)$ is the initial vector  
> - $z_0$ is the input angle

The scaling factor $K_n$ after $n$ iterations is given by:

$$
K_n = \prod_{i=0}^{n-1} \frac{1}{\sqrt{1 + 2^{-2i}}}
$$

For large $n$, $K_n \approx 0.6073$.



💡 *These equations allow CORDIC to compute trigonometric, vectoring, and rotation operations efficiently using only shift and add operations — no multipliers required.*
---

## 💻 Implementation Details

### 🔹 MATLAB Fixed-Point Modeling
- MATLAB scripts were used to analyze **quantization error** and determine the optimal word and fraction lengths.
- Fixed-point testbench compared expected vs. simulated values for all modes.
- To achieve the desired precision in CORDIC computations, a MATLAB simulation was performed with up to 30 iterations. The error at each step was compared against a tolerance level of 1e-4.
The results showed that increasing the number of iterations reduces the residual error; however, beyond a certain point, improvements become negligible due to fixed-point resolution limits.

<p align="center">

<img width="487" height="443" alt="image" src="https://github.com/user-attachments/assets/12d62a26-3fa0-4600-a331-4a969d0b0dc9" />

<img width="504" height="443" alt="image" src="https://github.com/user-attachments/assets/7b44645b-f143-48a1-ba73-bbb62e30de3f" />

<img width="534" height="484" alt="image" src="https://github.com/user-attachments/assets/9f5ff850-8f80-4979-b708-f772cb6d8f44" />

</p>
✅ Result: Optimal iteration count = 13

-Through MATLAB simulation and systematic testing, the fixed-point parameters for the CORDIC design were optimized to balance accuracy and hardware efficiency.
After evaluating multiple Word Length (WL) and Fraction Length (FL) combinations, the configuration of WL = 32 and FL = 22 was identified as the best trade-off, ensuring the maximum quantization error remained below 1×10⁻⁷.
<p align="center">

<img width="624" height="568" alt="image" src="https://github.com/user-attachments/assets/e3a53cd4-8203-4c65-a9af-33dfd5260b62" />

</p>

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
  input                                 i_cordic_clk,
  input                                 i_cordic_rst_n,
  input               [1:0]             i_cordic_mode,
  input      signed   [WORD_LENGTH-1:0] i_cordic_x,
  input      signed   [WORD_LENGTH-1:0] i_cordic_y,
  input      signed   [WORD_LENGTH-1:0] i_cordic_theta,
  output reg signed   [WORD_LENGTH-1:0] o_codic_out1,
  output reg signed   [WORD_LENGTH-1:0] o_codic_out2
);
```
---

## 🔹 Verification Setup
- MATLAB was used to generate **golden reference data** for all test cases (magnitude, angle, sine, cosine, and rotation).
- The RTL implementation was tested using a dedicated **testbench** (`cordic_tb.v`), which automatically compares RTL outputs with MATLAB reference results.
- All tests were performed using:
  - **13 pipeline stages** (iterations)
  - **Word Length (WL) = 32 bits**
  - **Fraction Length (FL) = 22 bits**

###  ✅Simulation Results
<p align="center">

<img width="918" height="239" alt="image" src="https://github.com/user-attachments/assets/9ef35442-4060-4433-866e-c9092ea57621" />
</p>

All test cases demonstrated **excellent agreement** between MATLAB and RTL outputs.  
The **maximum relative error** across all tests remained **below 0.001%**, confirming the numerical precision of the design.

Example results:

- **Magnitude and angle computation:** Error ≤ 0.0001%
<p align="center">
<img width="508" height="218" alt="image" src="https://github.com/user-attachments/assets/5739ce17-5626-4d96-9e1a-f9268557c495" />
<img width="303" height="223" alt="image" src="https://github.com/user-attachments/assets/2ca11f14-45e2-4fa0-a22b-5190553ff153" />

<img width="498" height="213" alt="image" src="https://github.com/user-attachments/assets/6c1a79c2-b2f7-4f72-8e49-9b87865ee331" />
<img width="302" height="222" alt="image" src="https://github.com/user-attachments/assets/eca412ad-1963-4303-86de-7445948dadd2" />
</p>

- **Sine and cosine generation:** Error ≤ 0.0001%
<p align="center">
<img width="538" height="239" alt="image" src="https://github.com/user-attachments/assets/429c3b26-1bdb-4f77-ad0c-a076952393dc" />
<img width="319" height="238" alt="image" src="https://github.com/user-attachments/assets/4518a2c9-b475-4bcf-9297-40c1505e3b22" />

<img width="543" height="236" alt="image" src="https://github.com/user-attachments/assets/5cd0fd55-a2d7-4197-a480-6ae4841bc99f" />
<img width="321" height="239" alt="image" src="https://github.com/user-attachments/assets/2a18b986-6db0-4183-a74d-a1bd475f2d55" />


</p>

- **Vector rotations (X, Y):** Error ≤ 0.0003% 
<p align="center">
<img width="633" height="272" alt="image" src="https://github.com/user-attachments/assets/d9fb578f-ff80-4edf-82f8-4740a8fe5b57" />
<img width="226" height="304" alt="image" src="https://github.com/user-attachments/assets/35527cf1-a027-46f7-850a-29aff94a7be8" />

</p>

---

### 📜Elaborated Design
<p align="center">
  <img width="908" height="404" alt="image" src="https://github.com/user-attachments/assets/e369b76b-9ec5-45a1-a09f-e5ff026c9f65" />

</p>

---

## 📈 Performance Metrics
<p align="center">
  
| Metric | Value | Tool |
|--------|--------|------|
| Maximum Frequency | 250 MHz | Vivado |
| Total Power | 0.6 W | Vivado Power Report |
| Timing Slack | +0.564 ns | Post-Route Timing Summary |
| LUT Utilization | 1.83% | Synthesis Report |

</p>
### 📜 Timing summary on 250 MHZ
<p align="center">
  <img width="1030" height="212" alt="image" src="https://github.com/user-attachments/assets/056db41a-47bf-4520-9c65-054b12bb5d7e" />

</p>

---

## 🛠️ Tools Used

| Tool                  | Purpose                                    |
| ---------------------- | ------------------------------------------ |
| **MATLAB R2023b**      | Fixed-point modeling and data verification |
| **Vivado**  | RTL simulation, synthesis, and waveform analysis |
| **Git & GitHub**       | Version control and project sharing        |

---
## 👤 Author

**Abdelragman Khaled Elsayed**  
*Digital Design Engineer · FPGA Enthusiast*  

📧 [abdokhaled1712002@gmail.com](abdokhaled1712002@gmail.com)  


