
clear; clc; close all;

%% Definición del array 

Array = phased.URA('Size',[4 4],...
    'Lattice','Rectangular','ArrayNormal','z');

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

lambda = PropagationSpeed / Frequency;
k = 2*pi/lambda;

pos = getElementPosition(Array);
x_pos = unique(pos(1,:));
y_pos = unique(pos(2,:));
M1 = numel(x_pos);
M2 = numel(y_pos);

to_dB = @(AF) max(20*log10(abs(AF)/max(abs(AF(:)))), -40);

%%Malla angular completa (todo el hemisferio visible

theta = linspace(0.001, pi/2, 300);   % elevación: 0 a 90°
phi   = linspace(-pi, pi, 300);       % azimut: -180 a 180°
[Theta, Phi] = meshgrid(theta, phi);

U = k*sin(Theta).*cos(Phi);
V = k*sin(Theta).*sin(Phi);

%%  Cálculo de AF_x, AF_y, AF_2D, producto

AF_2D = zeros(size(U));
for n = 1:size(pos,2)
    AF_2D = AF_2D + exp(-1j*(U*pos(1,n) + V*pos(2,n)));
end
AF_2D = AF_2D/(M1*M2);

AF_x = zeros(size(U));
for m1 = 1:M1
    AF_x = AF_x + exp(-1j*U*x_pos(m1));
end
AF_x = AF_x/M1;

AF_y = zeros(size(V));
for m2 = 1:M2
    AF_y = AF_y + exp(-1j*V*y_pos(m2));
end
AF_y = AF_y/M2;

AF_prod = AF_x .* AF_y;

err = abs(AF_2D - AF_prod);
fprintf('Error máximo |AF_2D - AF_x*AF_y|: %.2e\n', max(err(:)));

%  FIGURA 1 

AF_x_dB    = to_dB(AF_x);
AF_y_dB    = to_dB(AF_y);
AF_prod_dB = to_dB(AF_prod);
AF_2D_dB   = to_dB(AF_2D);

figure('Name','Separabilidad — Mapas 2D','Position',[100 100 1100 850]);

subplot(2,2,1);
imagesc(rad2deg(phi), rad2deg(theta), AF_x_dB.');
axis xy; colorbar; clim([-40 0]);
xlabel('\phi (deg)'); ylabel('\theta (deg)');
title('AF_x — ULA equivalente eje x');

subplot(2,2,2);
imagesc(rad2deg(phi), rad2deg(theta), AF_y_dB.');
axis xy; colorbar; clim([-40 0]);
xlabel('\phi (deg)'); ylabel('\theta (deg)');
title('AF_y — ULA equivalente eje y');

subplot(2,2,3);
imagesc(rad2deg(phi), rad2deg(theta), AF_prod_dB.');
axis xy; colorbar; clim([-40 0]);
xlabel('\phi (deg)'); ylabel('\theta (deg)');
title('Producto AF_x \times AF_y');

subplot(2,2,4);
imagesc(rad2deg(phi), rad2deg(theta), AF_2D_dB.');
axis xy; colorbar; clim([-40 0]);
xlabel('\phi (deg)'); ylabel('\theta (deg)');
title('AF_{2D} completo (referencia, suma directa)');

sgtitle('Verificación de separabilidad del URA — |AF| en dB');

%  FIGURA 2 
% Corte de azimut en theta = 60° (fuera de broadside)
theta_cut_deg = 60;
[~, idx] = min(abs(rad2deg(theta) - theta_cut_deg));

phi_deg = rad2deg(phi);
AF_2D_cut   = AF_2D_dB(:, idx);
AF_prod_cut = AF_prod_dB(:, idx);

figure('Name','Overlay corte 1D','Position',[100 100 900 500]);
plot(phi_deg, AF_2D_cut, '-', 'LineWidth', 2.2, 'Color', [0 0.45 0.74]); hold on;
plot(phi_deg(1:6:end), AF_prod_cut(1:6:end), 'o', ...
    'MarkerSize', 6, 'MarkerFaceColor', [0.85 0.33 0.10], ...
    'MarkerEdgeColor','k', 'LineStyle','none');
grid on;
xlabel('\phi (deg)'); ylabel('|AF| (dB)');
ylim([-40 0]);
legend('AF_{2D} completo (suma directa)', 'AF_x \times AF_y (muestreado)', ...
    'Location','southoutside');
title(sprintf('Corte a \\theta = %d° — Coincidencia producto vs. AF completo', theta_cut_deg));

%  FIGURA 3 — Mapa de error absoluto 
figure('Name','Error absoluto');
imagesc(rad2deg(phi), rad2deg(theta), err.');
axis xy; colorbar;
xlabel('\phi (deg)'); ylabel('\theta (deg)');
title(sprintf('Error absoluto |AF_{2D} - AF_x \\cdot AF_y| (máx = %.1e)', max(err(:))));