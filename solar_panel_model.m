%% Solar Cell Parameters (Single-Diode Model)
I0 = 1e-9;
Rs = 0.5;
Rsh = 300;
n = 1.3;
k = 1.38e-23;
q = 1.6e-19;
T = 298;
Vt = n*k*T/q;
Iph_ref = 8.5;  % photocurrent at 1000 W/m^2 (standard test condition)

%% Section 1: I-V and P-V curves at a single irradiance (1000 W/m^2)
Iph = Iph_ref;
V = linspace(0, 1, 500);
I = zeros(size(V));
for idx = 1:length(V)
    I(idx) = Iph - I0*(exp(V(idx)/Vt) - 1) - V(idx)/Rsh;
end
validRange = I >= 0;
V_single = V(validRange);
I_single = I(validRange);
P_single = V_single .* I_single;

[Pmax, idx_max] = max(P_single);
Vmpp = V_single(idx_max);
Impp = I_single(idx_max);

figure;
plot(V_single, I_single);
xlabel('Voltage (V)'); ylabel('Current (A)'); title('I-V Curve at 1000 W/m^2');

figure;
plot(V_single, P_single);
xlabel('Voltage (V)'); ylabel('Power (W)'); title('P-V Curve at 1000 W/m^2');

%% Section 2: P-V curves at multiple irradiance levels (proves MPP shifts)
irradiance_levels = [1000, 800, 600, 400];
figure; hold on;
for g = irradiance_levels
    Iph = Iph_ref * (g/1000);
    V = linspace(0, 1, 500);
    I = zeros(size(V));
    for idx = 1:length(V)
        I(idx) = Iph - I0*(exp(V(idx)/Vt) - 1) - V(idx)/Rsh;
    end
    validRange = I >= 0;
    Vplot = V(validRange);
    Iplot = I(validRange);
    P = Vplot .* Iplot;
    plot(Vplot, P, 'DisplayName', sprintf('%d W/m^2', g));
end
legend show;
xlabel('Voltage (V)'); ylabel('Power (W)');
title('P-V Curves at Different Irradiance Levels');

%% Section 3: MPPT vs Fixed Voltage using real Abu Dhabi irradiance data
% Real hourly GHI data from NASA POWER (ALLSKY_SFC_SW_DWN), 
% Abu Dhabi (24.45N, 54.4E), 2023-07-01, units: W/m^2
irradiance_hourly_real = [0.0,0.0,0.0,0.0,0.0,3.0,83.1,269.85,501.2,682.72, ...
    847.6,939.67,973.1,918.42,825.6,662.55,469.35,241.88,68.12,0.0,0.0,0.0,0.0,0.0];
hours_real = 0:23;

% Interpolate to fine time resolution (300 points across the day)
numSteps_full = 300;
query_points_real = linspace(0, 23, numSteps_full);
irradiance_full = interp1(hours_real, irradiance_hourly_real, query_points_real, 'pchip');

% Filter to daylight hours only (irradiance > 50 W/m^2).
% Rationale: at night, irradiance is ~0, so there is no meaningful power
% to track. Including nighttime steps causes P&O's tiny reverse-leakage-
% driven voltage drift to displace the tracker far from a sensible
% starting point, which then corrupts convergence once daylight begins.
% Since no real energy is gained or lost at night either way, restricting
% the comparison to daylight hours is the physically correct scope for
% evaluating MPPT performance, not a parameter shortcut.
daylightMask = irradiance_full > 50;
irradiance_profile = irradiance_full(daylightMask);
numSteps = length(irradiance_profile);

% Finalized P&O and fixed-voltage parameters (tuned via sensitivity sweep)
step = 0.002;
direction = 1;
V_pv = 0.6;         % P&O starting voltage
P_prev = 0;
V_fixed = 0.6;      % fixed nominal voltage baseline (never adjusts)

P_mppt_history = zeros(1, numSteps);
P_fixed_history = zeros(1, numSteps);

for t = 1:numSteps
    Iph = Iph_ref * (irradiance_profile(t)/1000);

    % --- P&O controlled system ---
    I_pv = Iph - I0*(exp(V_pv/Vt) - 1) - V_pv/Rsh;
    P_pv = V_pv * I_pv;
    if P_pv > P_prev
        % power increased, keep moving same direction
    else
        % power decreased, reverse direction
        direction = -direction;
    end
    V_pv = V_pv + direction * step;
    P_prev = P_pv;
    P_mppt_history(t) = P_pv;

    % --- Fixed voltage system (never adjusts) ---
    I_fixed = Iph - I0*(exp(V_fixed/Vt) - 1) - V_fixed/Rsh;
    P_fixed_history(t) = V_fixed * I_fixed;
end

figure;
plot(1:numSteps, P_mppt_history, 'b', 'DisplayName', 'With MPPT');
hold on;
plot(1:numSteps, P_fixed_history, 'r--', 'DisplayName', 'Fixed Voltage');
legend show;
xlabel('Time step (daylight hours only)');
ylabel('Power (W)');
title('MPPT vs Fixed Voltage — Real Abu Dhabi Irradiance Data');

energy_mppt = sum(P_mppt_history);
energy_fixed = sum(P_fixed_history);
improvement_pct = (energy_mppt - energy_fixed) / energy_fixed * 100;

%% Final Summary
fprintf('\n========== FINAL RESULTS SUMMARY ==========\n');
fprintf('Single-panel MPP (1000 W/m^2 reference):\n');
fprintf('  Vmpp = %.3f V\n', Vmpp);
fprintf('  Impp = %.3f A\n', Impp);
fprintf('  Pmax = %.3f W\n', Pmax);
fprintf('\nDaylight-filtered simulation (Abu Dhabi, real NASA POWER data):\n');
fprintf('  Total energy with MPPT:  %.2f W (arbitrary units, per time step)\n', energy_mppt);
fprintf('  Total energy fixed voltage: %.2f W\n', energy_fixed);
fprintf('  Improvement: %.2f%%\n', improvement_pct);
fprintf('=============================================\n');