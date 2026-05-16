%% Shaft Analysis
% Purpose of this file is to test the stress that my shaft will experience
% while driving a spur gear.
clc, clear;
% Importing model and setting grids
shaftModel = createpde('structural', 'static-solid');
importGeometry(shaftModel, 'Test Shaft.stl'); % Model from Fusion 360
pdegplot(shaftModel, 'FaceLabels','on', 'FaceAlpha', ...
    0.5);
title('Shaft Geometry - Face labels');

msh = generateMesh(shaftModel, 'Hmax', 0.0008, 'GeometricOrder', 'linear');
pdeplot3D(shaftModel);
title('Shaft Mesh');

% Define material properties and dimensions
shaftDiameter = 0.01; % meters
shaftLength = 0.0254; % meters
pressureAngle = 20; % Degrees
E = 2.3e9; % Pa; Using weakest version
nu = 0.35; % Dimensionless
structuralProperties(shaftModel, 'YoungsModulus', E, ...
    'PoissonsRatio', nu);
structuralBC(shaftModel, 'Face', 30, 'Constraint', ...
    'fixed');

Ft = (2 * torque) / shaftDiameter; % Tangential Force in N
Fr = (Ft * tand(pressureAngle)); % Radial Force in N

% Apply loads to the shaft
structuralBoundaryLoad(shaftModel, 'Face', 29, ...
    'SurfaceTraction', [0; -Fr; Ft]); % Adjusted for geometry

% Solve the structural analysis problem
results = solve(shaftModel);
% Von Mises Stress Distribution
figure;
pdeplot3D(shaftModel, 'ColorMapData', results.VonMisesStress);
title('Von Mises Stress Distribution (Pa)');
colorbar;
peakStress = max(results.VonMisesStress);

tensileStrength = 40e6;  % Pa - ABS typical tensile strength
SF = tensileStrength/peakStress;

fprintf('\n--- Results Summary ---\n');
fprintf('Peak Von Mises Stress : %.2f MPa\n', peakStress / 1e6);
fprintf('Safety Factor         : %.2f\n', SF);
if SF >= 2
    fprintf('Status: PASS (SF >= 2)\n');
else
    fprintf('Status: FAIL (SF < 2) - Consider redesign\n');
end