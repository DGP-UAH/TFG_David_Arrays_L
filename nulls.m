%% Null steering: nulo en theta_int, apuntamiento en theta_T 
N = getNumElements(Array);
d = Array.ElementSpacing;
lambda = PropagationSpeed / Frequency;

theta_T   = 70;   % dirección de apuntamiento (broadside)
theta_int = 90;   % dirección de la interferencia

% Direcciones muestreadas: theta_T, theta_int, y N-2 direcciones
theta_libres = linspace(-90, 90, N);
theta_libres(abs(theta_libres - theta_T) < 1e-6) = [];
theta_libres(abs(theta_libres - theta_int) < 1e-6) = [];
theta_libres = theta_libres(1:(N-2));

theta_muestreo = [theta_T, theta_int, theta_libres];
B_deseado = [1, 0, zeros(1, N-2)];   % 1 en apuntamiento, 0 en el resto

% Matriz de steering vectors V(psi) para las N direcciones muestreadas
sv = phased.SteeringVector('SensorArray', Array, 'PropagationSpeed', PropagationSpeed);
V = zeros(N, N);
for i = 1:N
    V(:, i) = sv(Frequency, [0; theta_muestreo(i)]);
end

% Resolución del sistema: w = [V^H]^-1 * B^H
w_null = (V') \ B_deseado(:);

%% Verificación: patrón resultante con el nulo impuesto 
[pat_null, ~] = pattern(Array, Frequency, 0, -90:0.01:90, ...
    'PropagationSpeed', Propaga'tionSpeed, 'CoordinateSystem', 'polar', ...
    'weights', w_null, 'Type', 'Directivity');

figure;
plot(-90:0.01:90, pat_null - max(pat_null));
grid on; xlabel('Elevación (grados)'); ylabel('dB normalizado');
xline(theta_int, '--r', sprintf('Interferencia (%.0f°)', theta_int));
xline(theta_T, '--g', sprintf('Apuntamiento (%.0f°)', theta_T));
title(sprintf('Null steering: nulo en %.0f°, apuntamiento en %.0f°', theta_int, theta_T));

% Comprobación numérica del nulo
idx_int = find(abs((-90:0.01:90) - theta_int) < 0.01, 1);
fprintf('Nivel en la dirección de interferencia: %.2f dB\n', pat_null(idx_int) - max(pat_null));