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
1. Lewis Bending Stress = Wt/(b*m*Y)​

Wt​ is the tangential load
b is the face width
m is the module
Y is the Lewis form factor (Barth equation, ϕ=20°)

2. Hertzian Contact Stress = ( (Wt/b) * ((1/rho1) + (1/rho2)/ pi * Ze))^(1/2)

ρ1 and ρ2​ are the radii of curvature at the pitch point
Ze​ is the elastic coefficient for the ABS material pair.
Material Properties — ABS
    Young's Modulus = 2,000MPa
    Poisson's Ratio = 0.35
    Yield Strength = 40 MPa
    Allowable Bending Stress = 20 MPa (SF = 2.0)

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
