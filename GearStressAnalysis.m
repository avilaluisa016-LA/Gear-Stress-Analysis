%% ============================================================
%  Spur Gear Stress Analysis — 6:1 Reduction (Phase 1)
%  Lewis Bending Stress & Hertzian Contact Stress
%
%  Assembly:  SimpleGearRatio (Fusion 360)
%  Pinion:    6T  driver  (critical / high-stress component)
%  Gear:      36T driven
%  Module:    m  = 2 mm
%  Material:  ABS thermoplastic (both gears)
%  Author:    Luis Avila
% =============================================================

clear; clc; close all;

%% ── 1. GEAR GEOMETRY ─────────────────────────────────────────
m   = 2;          % module (mm)
Z1  = 6;          % pinion tooth count (driver)
Z2  = 36;         % gear tooth count  (driven)
GR  = Z2 / Z1;    % gear ratio = 6

phi = 20;         % pressure angle (degrees) — standard for spur gears
phi_r = deg2rad(phi);

% Pitch diameters
d1 = m * Z1;      % pinion  pitch diameter (mm) = 12 mm
d2 = m * Z2;      % gear    pitch diameter (mm) = 72 mm

% Face width — rule of thumb: 8–12 × module
b = 10;           % face width (mm)

% Addendum & dedendum
a   = m;              % addendum (mm)
ded = 1.25 * m;       % dedendum (mm)

fprintf('=== Gear Geometry ===\n');
fprintf('Module:           %g mm\n',  m);
fprintf('Gear ratio:       %g : 1\n', GR);
fprintf('Pinion pitch dia: %g mm\n',  d1);
fprintf('Gear  pitch dia:  %g mm\n',  d2);
fprintf('Face width:       %g mm\n',  b);
fprintf('Centre distance:  %g mm\n\n', (d1+d2)/2);

%% ── 2. MATERIAL PROPERTIES (ABS) ────────────────────────────
% Source: Typical ABS injection-moulded properties
E_ABS    = 2000;    % Young's modulus (MPa)
nu_ABS   = 0.35;    % Poisson's ratio
Sy_ABS   = 40;      % Yield strength (MPa)
Su_ABS   = 45;      % Ultimate tensile strength (MPa)

% Allowable bending stress (conservative: Sy / SF, SF = 2)
SF_bend  = 2.0;
sigma_all = Sy_ABS / SF_bend;   % 20 MPa

fprintf('=== Material: ABS ===\n');
fprintf('E  = %g MPa\n',   E_ABS);
fprintf('Sy = %g MPa\n',   Sy_ABS);
fprintf('Allowable bending stress = %g MPa (SF = %.1f)\n\n', sigma_all, SF_bend);

%% ── 3. LOADING ───────────────────────────────────────────────
% Define a range of input torques on the pinion shaft
T1_range = linspace(0.01, 0.5, 200);   % N·m  (0.01 -> 0.5 N·m)

% Tangential force on pinion pitch circle
% Wt = T1 / (d1/2)  [units: N·m / m -> N]
r1_m   = (d1 / 2) / 1000;              % pitch radius in metres
Wt     = T1_range ./ r1_m;             % tangential load (N)

%% ── 4. LEWIS BENDING STRESS ──────────────────────────────────
% sigma_b = Wt / (b * m * Y)
% Y = Lewis form factor — approximation for full-depth teeth:
%   Y ≈ 0.154 - 0.912/Z   (Barth equation, phi = 14.5°)
%   For phi = 20°: Y ≈ 0.175 - 0.841/Z  (Shigley's Table 14-2 curve fit)

Y1 = 0.175 - 0.841 / Z1;   % pinion  (Z=6,  lowest Y -> highest stress)
Y2 = 0.175 - 0.841 / Z2;   % gear    (Z=36)

b_m  = b  / 1000;           % face width  in metres
m_m  = m  / 1000;           % module      in metres

sigma_b1 = Wt ./ (b_m * m_m * Y1) / 1e6;   % MPa — pinion
sigma_b2 = Wt ./ (b_m * m_m * Y2) / 1e6;   % MPa — gear

%% ── 5. HERTZIAN CONTACT STRESS ───────────────────────────────
% sigma_H = sqrt( Wt * (1/R1 + 1/R2) / (pi * b * Z_E) )
%
% Z_E = elastic coefficient for same-material pair:
%   Z_E = sqrt( E / (2*(1-nu^2)*pi) )  [simplified for identical materials]
%
% Contact radii of curvature at pitch point:
%   rho1 = r1 * sin(phi)
%   rho2 = r2 * sin(phi)

r2_m   = (d2 / 2) / 1000;
rho1   = r1_m * sin(phi_r);
rho2   = r2_m * sin(phi_r);

Z_E    = sqrt( E_ABS*1e6 / (2 * pi * (1 - nu_ABS^2)) );   % Pa^0.5

sigma_H = sqrt( (Wt ./ (b_m)) .* (1/rho1 + 1/rho2) / (pi * Z_E) ) / 1e3; % MPa
% Note: dividing by 1e3 converts Pa^0.5 result to MPa

%% ── 6. SAFETY FACTORS vs TORQUE ─────────────────────────────
SF_lewis   = sigma_all ./ sigma_b1;    % Lewis  safety factor (pinion)
SF_hertz   = (Sy_ABS   ./ sigma_H);   % Hertz  safety factor (yield proxy)

% Find max safe torque (SF_lewis >= 1 and SF_hertz >= 1)
safe_idx = find(SF_lewis >= 1 & SF_hertz >= 1, 1, 'last');
if ~isempty(safe_idx)
    T_max_safe = T1_range(safe_idx);
else
    T_max_safe = 0;
end

fprintf('=== Stress Results at T1 = 0.1 N·m ===\n');
idx_ref = find(T1_range >= 0.1, 1);
fprintf('Tangential force Wt:        %.2f N\n',   Wt(idx_ref));
fprintf('Lewis bending stress (6T):  %.2f MPa\n', sigma_b1(idx_ref));
fprintf('Lewis bending stress (36T): %.2f MPa\n', sigma_b2(idx_ref));
fprintf('Hertzian contact stress:    %.2f MPa\n', sigma_H(idx_ref));
fprintf('Bending SF (pinion):        %.2f\n',     SF_lewis(idx_ref));
fprintf('\nMax safe input torque (SF ≥ 1): %.3f N·m\n\n', T_max_safe);

%% ── 7. PLOTS ─────────────────────────────────────────────────
fig = figure('Name','Gear Stress Analysis','Color','w','Position',[100 100 1100 750]);

% --- Plot 1: Bending Stress vs Torque ---
subplot(2,2,1);
plot(T1_range, sigma_b1, 'b-',  'LineWidth', 2); hold on;
plot(T1_range, sigma_b2, 'g--', 'LineWidth', 2);
yline(sigma_all, 'r-', 'Allowable (20 MPa)', 'LineWidth',1.5,'LabelHorizontalAlignment','left');
xlabel('Input Torque T_1 (N·m)');
ylabel('Lewis Bending Stress \sigma_b (MPa)');
title('Lewis Bending Stress vs Input Torque');
legend('Pinion (6T) — critical','Gear (36T)','Location','northwest');
grid on; xlim([0 0.5]); ylim([0 max(sigma_b1)*1.15]);

% --- Plot 2: Hertzian Contact Stress vs Torque ---
subplot(2,2,2);
plot(T1_range, sigma_H, 'm-', 'LineWidth', 2); hold on;
yline(Sy_ABS, 'r-', sprintf('Yield = %g MPa',Sy_ABS), ...
      'LineWidth',1.5,'LabelHorizontalAlignment','left');
xlabel('Input Torque T_1 (N·m)');
ylabel('Contact Stress \sigma_H (MPa)');
title('Hertzian Contact Stress vs Input Torque');
legend('Contact stress','Location','northwest');
grid on; xlim([0 0.5]);

% --- Plot 3: Safety Factors vs Torque ---
subplot(2,2,3);
plot(T1_range, SF_lewis, 'b-', 'LineWidth', 2); hold on;
plot(T1_range, SF_hertz, 'm--','LineWidth', 2);
yline(1, 'r-', 'SF = 1  (failure)', 'LineWidth',1.5);
yline(2, 'k:', 'SF = 2  (design target)', 'LineWidth',1.2);
xlabel('Input Torque T_1 (N·m)');
ylabel('Safety Factor');
title('Safety Factors vs Input Torque');
legend('Bending SF (pinion)','Hertz SF','Location','northeast');
grid on; xlim([0 0.5]); ylim([0 10]);

% --- Plot 4: Tooth geometry summary (bar chart) ---
subplot(2,2,4);
params     = {'Pitch dia (mm)','Addendum (mm)','Dedendum (mm)','Y (Lewis)'};
pinion_vals= [d1, a, ded, Y1];
gear_vals  = [d2, a, ded, Y2];
X = categorical(params);
X = reordercats(X, params);
b_grp = bar(X, [pinion_vals; gear_vals]');
b_grp(1).FaceColor = [0.2 0.4 0.8];
b_grp(2).FaceColor = [0.2 0.7 0.4];
legend('Pinion (6T)','Gear (36T)','Location','northwest');
title('Gear Parameter Comparison');
ylabel('Value');
grid on;

sgtitle(sprintf('Spur Gear Stress Analysis  |  Module m=%g, GR=%g:1, ABS, b=%g mm', m, GR, b), ...
        'FontSize', 13, 'FontWeight','bold');

% Save figure
saveas(fig, '/mnt/user-data/outputs/GearStressAnalysis_Plots.png');
fprintf('Plots saved to GearStressAnalysis_Plots.png\n');