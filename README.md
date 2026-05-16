# Gear-Stress-Analysis
## Overview
This project documents the CAD modeling and analytical stress validation of a 6:1 spur gear reduction assembly designed in Autodesk Fusion 360. Stress analysis is performed in MATLAB using classical gear theory — Lewis bending stress and Hertzian contact stress — with the 6-tooth pinion identified as the critical (highest-stress) component.
This is Phase 1 of a larger mechanism design project. Future phases will extend the design toward a functional robotic joint actuator, incorporating dynamic simulation, material optimization, and multi-stage reduction.

Assembly Specifications
ParameterValueGear TypeSpur gearModule (m)2 mmPinion Tooth Count6T (driver)Gear Tooth Count36T (driven)Gear Ratio6 : 1Pressure Angle20°Face Width10 mmMaterialABS thermoplasticCentre Distance42 mmCAD SoftwareAutodesk Fusion 360

## Repository Structure
SimpleGearRatio/
├── CAD/
│   └── SimpleGearRatio.f3z       # Fusion 360 assembly (all components)
├── MATLAB/
│   └── GearStressAnalysis.m      # Stress analysis script
├── Output/
│   └── GearStressAnalysis_Plots.png  # 4-panel results figure
└── README.md

## Stress Analysis — MATLAB
Theory
Two classical failure modes are evaluated across a range of input torques (0.01 – 0.5 N·m):
1. Lewis Bending Stress
σb=Wtb⋅m⋅Y\sigma_b = \frac{W_t}{b \cdot m \cdot Y}σb​=b⋅m⋅YWt​​
Where WtW_t
Wt​ is the tangential load, bb
b is the face width, mm
m is the module, and YY
Y is the Lewis form factor (Barth equation, ϕ=20°\phi = 20°
ϕ=20°). The 6-tooth pinion has the lowest YY
Y value and therefore the highest bending stress — making it the critical component.
2. Hertzian Contact Stress
σH=Wtb⋅1/ρ1+1/ρ2π⋅ZE\sigma_H = \sqrt{\frac{W_t}{b} \cdot \frac{1/\rho_1 + 1/\rho_2}{\pi \cdot Z_E}}σH​=bWt​​⋅π⋅ZE​1/ρ1​+1/ρ2​​​
Where ρ1\rho_1
ρ1​, ρ2\rho_2
ρ2​ are the radii of curvature at the pitch point and ZEZ_E
ZE​ is the elastic coefficient for the ABS material pair.
Material Properties — ABS
PropertyValueYoung's Modulus2,000 MPaPoisson's Ratio0.35Yield Strength40 MPaAllowable Bending Stress20 MPa (SF = 2.0)

## How to Run the Analysis
1. Clone the repo or download GearStressAnalysis.m
2. Open in MATLAB (R2020b or later recommended)
3. Run the script — no additional toolboxes required
4. The script will:
    Print a results summary to the command window
    Generate and save the 4-panel plot as GearStressAnalysis_Plots.png

Author
Luis Avila
[GrabCAD](https://grabcad.com/luis.avila-73/models) · [LinkedIn](https://www.linkedin.com/in/avilaluis4/)
