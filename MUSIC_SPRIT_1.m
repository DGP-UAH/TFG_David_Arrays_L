
%  Estimación por rama con MUSIC y ESPRIT (toolbox)
%  Reutiliza Xy, Xz, Frequency, c, d, M1, M2, P, u, v

%% ULA auxiliares por rama
arrayY = phased.ULA('NumElements', M1, 'ElementSpacing', d);
arrayZ = phased.ULA('NumElements', M2, 'ElementSpacing', d);

%%MUSIC
musicY = phased.MUSICEstimator('SensorArray', arrayY, ...
    'OperatingFrequency', Frequency, 'PropagationSpeed', c, ...
    'ScanAngles', -90:0.01:90, ...
    'DOAOutputPort', true, 'NumSignalsSource', 'Property', 'NumSignals', P);

musicZ = phased.MUSICEstimator('SensorArray', arrayZ, ...
    'OperatingFrequency', Frequency, 'PropagationSpeed', c, ...
    'ScanAngles', -90:0.01:90, ...
    'DOAOutputPort', true, 'NumSignalsSource', 'Property', 'NumSignals', P);

% Los estimadores esperan los datos como (snapshots x sensores)
[~, ang_y_music] = musicY(Xy.');
[~, ang_z_music] = musicZ(Xz.');

u_hat_music = sind(ang_y_music);
v_hat_music = sind(ang_z_music);

% Figuras de pseudo-espectro (equivalente a P_MUSIC,y(u) y P_MUSIC,z(v))
figure;
plotSpectrum(musicY);
title('Pseudo-espectro MUSIC — rama y');

figure;
plotSpectrum(musicZ);
title('Pseudo-espectro MUSIC — rama z');

%% ESPRIT 
espritY = phased.ESPRITEstimator('SensorArray', arrayY, ...
    'OperatingFrequency', Frequency, 'PropagationSpeed', c, ...
    'NumSignalsSource', 'Property', 'NumSignals', P);

espritZ = phased.ESPRITEstimator('SensorArray', arrayZ, ...
    'OperatingFrequency', Frequency, 'PropagationSpeed', c, ...
    'NumSignalsSource', 'Property', 'NumSignals', P);

ang_y_esprit = espritY(Xy.');
ang_z_esprit = espritZ(Xz.');

u_hat_esprit = sind(ang_y_esprit);
v_hat_esprit = sind(ang_z_esprit);

%% Comparación con los valores verdaderos
fprintf('--- Valores verdaderos ---\n');
fprintf('u = '); disp(sort(u));
fprintf('v = '); disp(sort(v));

fprintf('--- MUSIC ---\n');
fprintf('u_hat = '); disp(sort(u_hat_music.'));
fprintf('v_hat = '); disp(sort(v_hat_music.'));

fprintf('--- ESPRIT ---\n');
fprintf('u_hat = '); disp(sort(u_hat_esprit.'));
fprintf('v_hat = '); disp(sort(v_hat_esprit.'));




%  Emparejamiento mediante covarianza cruzada Ryz
% Elegimos qué estimaciones emparejar (MUSIC o ESPRIT); aquí MUSIC
u_est = u_hat_music(:).';   % 1 x P
v_est = v_hat_music(:).';   % 1 x P

Pe = length(u_est); % número de estimaciones por rama

%% Construcción de los vectores de dirección para cada estimación
ay_est = exp(1j*2*pi/lambda*d*m*u_est);   % M1 x Pe
az_est = exp(1j*2*pi/lambda*d*n*v_est);   % M2 x Pe

%% Matriz de compatibilidad rho(i,k)
rho = abs(ay_est' * Ryz_hat * az_est);    % Pe x Pe

figure;
imagesc(rho);
colorbar;
xlabel('Índice k (estimación en v)');
ylabel('Índice i (estimación en u)');
title('Magnitud de compatibilidad \rho_{i,k}');

%% Resolución del emparejamiento óptimo 
[M_asig, ~] = matchpairs(-rho, max(rho(:)));  

fprintf('--- Emparejamiento obtenido (i -> k) ---\n');
disp(M_asig);

%% Reconstrucción de los pares finales
u_pareado = u_est(M_asig(:,1));
v_pareado = v_est(M_asig(:,2));

fprintf('--- Pares finales (u,v) tras emparejamiento ---\n');
for idx = 1:size(M_asig,1)
    fprintf('Fuente asignada %d: u=%.4f, v=%.4f\n', idx, u_pareado(idx), v_pareado(idx));
end

fprintf('--- Verdad terreno (referencia) ---\n');
disp([u(:), v(:)]);