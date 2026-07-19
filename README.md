# Solar PV MPPT Simulation

A MATLAB-based simulation of a single solar panel with Maximum Power Point Tracking (MPPT) control, demonstrating efficiency gains under real Abu Dhabi irradiance conditions.

## Overview

This project models the electrical characteristics of a photovoltaic (PV) panel and compares two operating strategies:
- **MPPT control**: Dynamically tracks the voltage that maximizes power output
- **Fixed voltage**: Operates at a constant voltage regardless of irradiance changes

The simulation reveals that MPPT improves energy extraction by **1.92%** compared to fixed voltage operation under real Abu Dhabi solar irradiance data.

## Motivation

Abu Dhabi receives high and variable solar irradiance throughout the day. Fixed-voltage PV systems waste potential energy when irradiance changes. This simulation quantifies the real-world benefit of MPPT algorithms in the Gulf region's climate.

## Files

- `solar_panel_model.m` – Main MATLAB script
- `01_IV_Curve_1000Wm2.png` – Current-voltage characteristics at peak irradiance
- `02_PV_Curve_1000Wm2.png` – Power-voltage curve at peak irradiance
- `03_PV_Curves_Multiple_Irradiance.png` – P-V curves across four irradiance levels
- `04_MPPT_vs_Fixed_Voltage_AbuDhabi.png` – MPPT vs fixed voltage performance over a day

## How to Run

1. Have MATLAB installed (R2020a or later recommended)
2. Download `solar_panel_model.m`
3. Open MATLAB and navigate to the directory containing the script
4. Run: `solar_panel_model`
5. The script generates four plots showing PV characteristics and MPPT performance

## Results

- **Peak power at 1000 W/m²**: ~5.2 W (see `02_PV_Curve_1000Wm2.png`)
- **MPPT advantage**: +1.92% daily energy vs fixed voltage
- **Real data**: Abu Dhabi irradiance profile (daylight hours only)

## Contact

Questions? Reach out via GitHub or email: anlon9564@gmail.com
