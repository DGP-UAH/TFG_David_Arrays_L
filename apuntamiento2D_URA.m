
clear; clc; close all;

%%Definición del array

Array = phased.URA('Size',[4 4],...
    'Lattice','Rectangular','ArrayNormal','x');

Array.ElementSpacing = [0.5 0.5]*0.6;

rwind = ones(1,4).';
cwind = ones(1,4).';
taper = rwind*cwind.';
Array.Taper = taper.';

Elem = phased.IsotropicAntennaElement;
Elem.FrequencyRange = [0 500000000];
Array.Element = Elem;

Frequency = 500000000;
PropagationSpeed = 300000000;

% Ángulo de apuntamiento a verificar [Azimut; Elevación]
SteeringAngles = [30; 0];

%  Verificación de separabilidad del steering 

% Steering vector IDEAL 
SteerVector_ideal = phased.SteeringVector('SensorArray', Array, ...
    'PropagationSpeed', PropagationSpeed);

w_ideal = step(SteerVector_ideal, Frequency, SteeringAngles);

% Posiciones reales de los elementos (ArrayNormal='x' -> array en plano y-z)
pos = getElementPosition(Array);   % 3xN [x;y;z]

y_pos = pos(2,:);
z_pos = pos(3,:);

y_unique = unique(y_pos);
z_unique = unique(z_pos);

M1 = numel(y_unique);
M2 = numel(z_unique);

% Reorganizar el vector de pesos en una matriz M1 x M2
W = zeros(M1, M2);
for n = 1:length(w_ideal)
    i = find(y_unique == y_pos(n));
    j = find(z_unique == z_pos(n));
    W(i,j) = w_ideal(n);
end

%% Test de separabilidad: descomposición en valores singulares

s = svd(W);

fprintf('=== Steering IDEAL (sin cuantizacion de fase) ===\n');
fprintf('Valores singulares de la matriz de pesos W:\n');
disp(s);
fprintf('Razon (2do valor singular / 1er valor singular): %.2e\n', s(2)/s(1));

if s(2)/s(1) < 1e-10
    fprintf('--> La matriz W es de RANGO 1: el steering es separable.\n\n');
else
    fprintf('--> La matriz W NO es de rango 1: el steering NO es separable.\n\n');
end

%% Reconstrucción producto de dos steering vectors 1D
[U,S,V] = svd(W);
wx_reconstruido = U(:,1) * sqrt(S(1,1));
wy_reconstruido = conj(V(:,1)) * sqrt(S(1,1));

W_reconstruida = wx_reconstruido * wy_reconstruido.';

error_reconstruccion = max(abs(W(:) - W_reconstruida(:)));
fprintf('Error maximo de reconstruccion (rango 1): %.2e\n\n', error_reconstruccion);

PhaseShiftBits = 3;

SteerVector_quant = phased.SteeringVector('SensorArray', Array, ...
    'PropagationSpeed', PropagationSpeed, 'NumPhaseShifterBits', PhaseShiftBits);

w_quant = step(SteerVector_quant, Frequency, SteeringAngles);

W_quant = zeros(M1, M2);
for n = 1:length(w_quant)
    i = find(y_unique == y_pos(n));
    j = find(z_unique == z_pos(n));
    W_quant(i,j) = w_quant(n);
end

s_quant = svd(W_quant);

fprintf('=== Steering CUANTIZADO (%d bits) ===\n', PhaseShiftBits);
fprintf('Valores singulares de la matriz de pesos W (cuantizada):\n');
disp(s_quant);
fprintf('Razon (2do valor singular / 1er valor singular): %.2e\n', s_quant(2)/s_quant(1));
fprintf('--> Con cuantizacion de fase, la separabilidad se degrada ligeramente\n');
fprintf('    debido al redondeo de fase introducido por los desfasadores reales.\n\n');

%  Representación gráfica

figure('Name','Geometria del array');
scatter(y_pos, z_pos, 100, 'filled');
axis equal; grid on;
xlabel('y (m)'); ylabel('z (m)');
title('Array Planar Uniforme 4\times4 (plano y-z, ArrayNormal=x)');

figure('Name','Diagrama apuntado (steering ideal)');
az_range = -90:0.2:90;
pat = pattern(Array, Frequency, az_range, SteeringAngles(2), ...
    'PropagationSpeed', PropagationSpeed, 'Type','Directivity', ...
    'CoordinateSystem','rectangular', 'Weights', w_ideal);
plot(az_range, pat, 'LineWidth',1.5);
grid on; xlabel('Azimut (deg)'); ylabel('Directividad (dBi)');
title(sprintf('Diagrama apuntado a Az_0=%d°, El_0=%d°', SteeringAngles(1), SteeringAngles(2)));