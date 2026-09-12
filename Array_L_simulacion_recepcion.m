
%  Generación de señal recibida y matrices de covarianza
%  Array en L: dos ULA ortogonales (ramas y, z)
%% Parámetros del array (reutilizando la geometría ya construida)
c = 3e8;
Frequency = 500e6;      % banda UHF
lambda = c/Frequency;
d = lambda/2;

M1 = 8;   % elementos rama y (incluye vértice)
M2 = 8;   % elementos rama z (incluye vértice)

%% Parámetros de las fuentes
P = 4;                          % número de fuentes
theta = [20, 50, 15, 90];
phi   = [30, -40, -89, 23];               % acimut (grados)

% Cosenos directores, criterio u,v del texto: u=cos(theta)sin(phi), v=sin(theta)
u = cosd(theta).*sind(phi);
v = sind(theta);

%% Parámetros de simulación
N0 = 1;                 % potencia de ruido de referencia 
SNR_dB = 10;            % relación señal a ruido por fuente
SNR_lin = 10^(SNR_dB/10);
Amplitud = sqrt(SNR_lin*N0);   % amplitud de cada fuente (misma potencia para todas)

N_snapshots = 200;      % número de muestras temporales

%% Construcción de los vectores de dirección de cada rama
m = (0:M1-1).';
n = (0:M2-1).';   % n=0 corresponde al vértice 

ay = exp(1j*2*pi/lambda*d*m*u);   % M1 x P
az = exp(1j*2*pi/lambda*d*n*v);   % M2 x P

%% Generación de las señales de las P fuentes 
% Fase aleatoria por fuente y por snapshot, amplitud común por SNR
s = (Amplitud/sqrt(2)) * (randn(P,N_snapshots) + 1j*randn(P,N_snapshots));

%% Generación del ruido en cada rama (AWGN, N0=1)
ruido_y = sqrt(N0/2)*(randn(M1,N_snapshots) + 1j*randn(M1,N_snapshots));
ruido_z = sqrt(N0/2)*(randn(M2,N_snapshots) + 1j*randn(M2,N_snapshots));

%% Señal recibida por cada rama: x = A*s + n
Xy = ay*s + ruido_y;   % M1 x N_snapshots
Xz = az*s + ruido_z;   % M2 x N_snapshots

%% Matrices de covarianza muestrales
Ry_hat  = (Xy*Xy')/N_snapshots;
Rz_hat  = (Xz*Xz')/N_snapshots;
Ryz_hat = (Xy*Xz')/N_snapshots;

%% Verificación: autovalores de cada rama 
[~, Dy] = eig(Ry_hat);
[~, Dz] = eig(Rz_hat);
autovalores_y = sort(diag(Dy), 'descend');
autovalores_z = sort(diag(Dz), 'descend');

figure;
subplot(1,2,1);
stem(autovalores_y, 'filled');
title('Autovalores de R_y'); xlabel('Índice'); ylabel('\lambda_i');
grid on;

subplot(1,2,2);
stem(autovalores_z, 'filled');
title('Autovalores de R_z'); xlabel('Índice'); ylabel('\lambda_i');
grid on;

fprintf('SNR = %d dB, P = %d fuentes, N = %d snapshots\n', SNR_dB, P, N_snapshots);
fprintf('Autovalores rama y: '); disp(autovalores_y.');
fprintf('Autovalores rama z: '); disp(autovalores_z.');


%% Verificación de Ryz: valores singulares 
sv_yz = svd(Ryz_hat);

figure;
stem(sv_yz, 'filled');
title('Valores singulares de R_{yz}');
xlabel('Índice'); ylabel('\sigma_i');
grid on;

fprintf('Valores singulares de Ryz: '); disp(sv_yz.');



