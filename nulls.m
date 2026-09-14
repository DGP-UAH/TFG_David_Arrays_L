%% NULL STEERING EN UPA Y ULA
%
% UPA:
%   - 4x4 elementos
%   - Apuntamiento: azimut 20 grados, elevacion 0 grados
%   - Nulo: azimut -30 grados, elevacion 0 grados
%
% ULA:
%   - 10 elementos dispuestos sobre el eje z
%   - Apuntamiento: elevacion 20 grados
%   - Nulo: elevacion -30 grados

clear;
close all;
clc;

%% PARAMETROS COMUNES

c = 3e8;                  % Velocidad de propagacion [m/s]
fc = 500e6;               % Frecuencia de trabajo [Hz]
lambda = c/fc;            % Longitud de onda [m]
d = lambda/2;             % Separacion entre sensores [m]

fprintf('Longitud de onda: %.3f m\n',lambda);
fprintf('Separacion entre sensores: %.3f m\n\n',d);

%% ELEMENTO ISOTROPO

elemento = phased.IsotropicAntennaElement( ...
    'FrequencyRange',[400e6 800e6], ...
    'BackBaffled',true);

%  PARTE 1: NULL STEERING EN UN UPA DE 4x4 ELEMENTOS
M1 = 4;
M2 = 4;

UPA = phased.URA( ...
    'Size',[M1 M2], ...
    'ElementSpacing',[d d], ...
    'Lattice','Rectangular', ...
    'ArrayNormal','x', ...
    'Element',elemento);

%% Direcciones para el UPA
% Formato: [azimut; elevacion]

az_des_UPA = 20;
el_des_UPA = 0;

az_null_UPA = -30;
el_null_UPA = 0;

dir_des_UPA = [az_des_UPA; el_des_UPA];
dir_null_UPA = [az_null_UPA; el_null_UPA];

%% Steering vectors del UPA

SV_UPA = phased.SteeringVector( ...
    'SensorArray',UPA, ...
    'PropagationSpeed',c);

a_des_UPA = SV_UPA(fc,dir_des_UPA);
a_null_UPA = SV_UPA(fc,dir_null_UPA);

%% Pesos de apuntamiento convencional del UPA
%
% Se normalizan para que:
%
%   w_steering_UPA' * a_des_UPA = 1

w_steering_UPA = a_des_UPA/(a_des_UPA' * a_des_UPA);

%% Pesos del UPA con un nulo
%
% Restricciones:
%
%   w_null_UPA' * a_des_UPA  = 1
%   w_null_UPA' * a_null_UPA = 0

C_UPA = [a_des_UPA a_null_UPA];
f_UPA = [1; 0];

w_null_UPA = C_UPA * ((C_UPA' * C_UPA) \ f_UPA);

%% Comprobacion numerica del UPA

resp_des_UPA_original = abs(w_steering_UPA' * a_des_UPA);
resp_int_UPA_original = abs(w_steering_UPA' * a_null_UPA);

resp_des_UPA_null = abs(w_null_UPA' * a_des_UPA);
resp_int_UPA_null = abs(w_null_UPA' * a_null_UPA);

fprintf('UPA 4x4\n');

fprintf('\nPatron sin null steering:\n');
fprintf('Respuesta en la direccion deseada:      %.6f\n', ...
    resp_des_UPA_original);
fprintf('Respuesta en la direccion interferente: %.6f\n', ...
    resp_int_UPA_original);

fprintf('\nPatron con null steering:\n');
fprintf('Respuesta en la direccion deseada:      %.6f\n', ...
    resp_des_UPA_null);
fprintf('Respuesta en la direccion interferente: %.6e\n\n', ...
    resp_int_UPA_null);

%% Rango angular para los cortes del UPA

az_UPA = -90:0.1:90;
el_corte_UPA = 0;

%% FIGURA 1: UPA, comparacion rectangular superpuesta

figure;

pattern(UPA,fc,az_UPA,el_corte_UPA, ...
    'PropagationSpeed',c, ...
    'Weights',[w_steering_UPA w_null_UPA], ...
    'CoordinateSystem','rectangular', ...
    'Type','powerdb', ...
    'Normalize',true, ...
    'PlotStyle','Overlay');

hold on;

xline(az_des_UPA,'k--', ...
    'Direccion deseada', ...
    'LineWidth',1.2);

xline(az_null_UPA,'r--', ...
    'Interferencia', ...
    'LineWidth',1.2);

hold off;

grid on;
ylim([-60 0]);

xlabel('Acimut (grados)');
ylabel('Potencia normalizada (dB)');
title('Null steering en un UPA de 4x4 elementos');

legend( ...
    'Patron sin nulo', ...
    'Patron con nulo', ...
    'Direccion deseada', ...
    'Interferencia', ...
    'Location','southwest');

%% FIGURA 2: UPA, representaciones rectangulares separadas

figure;

subplot(1,2,1);

pattern(UPA,fc,az_UPA,el_corte_UPA, ...
    'PropagationSpeed',c, ...
    'Weights',w_steering_UPA, ...
    'CoordinateSystem','rectangular', ...
    'Type','powerdb', ...
    'Normalize',true);

hold on;
xline(az_des_UPA,'k--','Direccion deseada');
xline(az_null_UPA,'r--','Interferencia');
hold off;

grid on;
ylim([-60 0]);

xlabel('Acimut (grados)');
ylabel('Potencia normalizada (dB)');
title('UPA sin null steering');

subplot(1,2,2);

pattern(UPA,fc,az_UPA,el_corte_UPA, ...
    'PropagationSpeed',c, ...
    'Weights',w_null_UPA, ...
    'CoordinateSystem','rectangular', ...
    'Type','powerdb', ...
    'Normalize',true);

hold on;
xline(az_des_UPA,'k--','Direccion deseada');
xline(az_null_UPA,'r--','Interferencia');
hold off;

grid on;
ylim([-60 0]);

xlabel('Acimut (grados)');
ylabel('Potencia normalizada (dB)');
title('UPA con nulo en -30 grados');

%% FIGURA 3: UPA, diagrama polar superpuesto

figure;

pattern(UPA,fc,az_UPA,el_corte_UPA, ...
    'PropagationSpeed',c, ...
    'Weights',[w_steering_UPA w_null_UPA], ...
    'CoordinateSystem','polar', ...
    'Type','powerdb', ...
    'Normalize',true, ...
    'PlotStyle','Overlay');

title(sprintf(['UPA 4x4: apuntamiento a %d grados y ', ...
    'nulo en %d grados'],az_des_UPA,az_null_UPA));

% No llamar manualmente a legend.
% pattern gestiona internamente la leyenda.

%% FIGURA 4: UPA, diagramas polares separados

figure;

subplot(1,2,1);

pattern(UPA,fc,az_UPA,el_corte_UPA, ...
    'PropagationSpeed',c, ...
    'Weights',w_steering_UPA, ...
    'CoordinateSystem','polar', ...
    'Type','powerdb', ...
    'Normalize',true);

title('UPA sin null steering');

subplot(1,2,2);

pattern(UPA,fc,az_UPA,el_corte_UPA, ...
    'PropagationSpeed',c, ...
    'Weights',w_null_UPA, ...
    'CoordinateSystem','polar', ...
    'Type','powerdb', ...
    'Normalize',true);

title('UPA con nulo en -30 grados');


%  PARTE 2: NULL STEERING EN UN ULA HORIZONTAL DE 10 ELEMENTOS

%
% El ULA se dispone sobre el eje y.
% Por tanto, el patron se estudia mediante un corte de acimut,
% manteniendo la elevacion fija en 0 grados.
%
% Condiciones:
%   - Apuntamiento: acimut 20 grados, elevacion 0 grados
%   - Nulo: acimut -30 grados, elevacion 0 grados

N = 10;

%% Creacion del ULA horizontal

ULA = phased.ULA( ...
    'NumElements',N, ...
    'ElementSpacing',d, ...
    'ArrayAxis','y', ...
    'Element',elemento);

%% Direcciones para el ULA
%
% phased.SteeringVector utiliza el formato:
%
%   [acimut; elevacion]

az_des_ULA = 20;
el_des_ULA = 0;

az_null_ULA = -30;
el_null_ULA = 0;

dir_des_ULA = [az_des_ULA; el_des_ULA];
dir_null_ULA = [az_null_ULA; el_null_ULA];

%% Steering vectors del ULA

SV_ULA = phased.SteeringVector( ...
    'SensorArray',ULA, ...
    'PropagationSpeed',c);

a_des_ULA = SV_ULA(fc,dir_des_ULA);
a_null_ULA = SV_ULA(fc,dir_null_ULA);

%% Pesos de apuntamiento convencional
%
% Estos pesos apuntan el lóbulo principal hacia azimut 20 grados,
% pero no imponen ningun nulo adicional.

w_steering_ULA = a_des_ULA/(a_des_ULA' * a_des_ULA);

%% Pesos con un unico nulo
%
% Se imponen las condiciones:
%
%   w_null_ULA' * a_des_ULA  = 1
%   w_null_ULA' * a_null_ULA = 0

C_ULA = [a_des_ULA a_null_ULA];
f_ULA = [1; 0];

% Solucion de minima norma del sistema C_ULA^H*w = f_ULA

w_null_ULA = C_ULA * ((C_ULA' * C_ULA) \ f_ULA);

% Normalizacion adicional para garantizar respuesta unitaria
% en la direccion deseada frente a posibles errores numericos.

w_null_ULA = w_null_ULA/(a_des_ULA' * w_null_ULA);

%% Comprobacion numerica del ULA

resp_des_ULA_original = abs(w_steering_ULA' * a_des_ULA);
resp_int_ULA_original = abs(w_steering_ULA' * a_null_ULA);

resp_des_ULA_null = abs(w_null_ULA' * a_des_ULA);
resp_int_ULA_null = abs(w_null_ULA' * a_null_ULA);

fprintf('ULA HORIZONTAL DE 10 ELEMENTOS\n');

fprintf('\nPatron sin null steering:\n');
fprintf('Respuesta en la direccion deseada:      %.6f\n', ...
    resp_des_ULA_original);
fprintf('Respuesta en la direccion interferente: %.6f\n', ...
    resp_int_ULA_original);

fprintf('\nPatron con null steering:\n');
fprintf('Respuesta en la direccion deseada:      %.6f\n', ...
    resp_des_ULA_null);
fprintf('Respuesta en la direccion interferente: %.6e\n\n', ...
    resp_int_ULA_null);

%% Rango angular del corte de acimut
%
% Se varia el acimut entre -90 y 90 grados.
% La elevacion se mantiene fija en 0 grados.

az_ULA = -90:0.1:90;
el_corte_ULA = 0;

%% FIGURA 5: ULA, comparacion rectangular superpuesta

figure;

pattern(ULA,fc,az_ULA,el_corte_ULA, ...
    'PropagationSpeed',c, ...
    'Weights',[w_steering_ULA w_null_ULA], ...
    'CoordinateSystem','rectangular', ...
    'Type','powerdb', ...
    'Normalize',true, ...
    'PlotStyle','Overlay');

hold on;

xline(az_des_ULA,'k--', ...
    'Direccion deseada', ...
    'LineWidth',1.2);

xline(az_null_ULA,'r--', ...
    'Interferencia', ...
    'LineWidth',1.2);

hold off;

grid on;
ylim([-60 0]);

xlabel('Acimut (grados)');
ylabel('Potencia normalizada (dB)');
title('Null steering en un ULA horizontal de 10 elementos');

legend( ...
    'Patron sin nulo', ...
    'Patron con nulo', ...
    'Direccion deseada', ...
    'Interferencia', ...
    'Location','southwest');

%% FIGURA 6: ULA, representaciones rectangulares separadas

figure;

subplot(1,2,1);

pattern(ULA,fc,az_ULA,el_corte_ULA, ...
    'PropagationSpeed',c, ...
    'Weights',w_steering_ULA, ...
    'CoordinateSystem','rectangular', ...
    'Type','powerdb', ...
    'Normalize',true);

hold on;
xline(az_des_ULA,'k--','Direccion deseada');
xline(az_null_ULA,'r--','Interferencia');
hold off;

grid on;
ylim([-60 0]);

xlabel('Acimut (grados)');
ylabel('Potencia normalizada (dB)');
title('ULA sin null steering');

subplot(1,2,2);

pattern(ULA,fc,az_ULA,el_corte_ULA, ...
    'PropagationSpeed',c, ...
    'Weights',w_null_ULA, ...
    'CoordinateSystem','rectangular', ...
    'Type','powerdb', ...
    'Normalize',true);

hold on;
xline(az_des_ULA,'k--','Direccion deseada');
xline(az_null_ULA,'r--','Interferencia');
hold off;

grid on;
ylim([-60 0]);

xlabel('Acimut (grados)');
ylabel('Potencia normalizada (dB)');
title('ULA con nulo en -30 grados');

%% FIGURA 7: ULA, diagrama polar superpuesto

figure;

pattern(ULA,fc,az_ULA,el_corte_ULA, ...
    'PropagationSpeed',c, ...
    'Weights',[w_steering_ULA w_null_ULA], ...
    'CoordinateSystem','polar', ...
    'Type','powerdb', ...
    'Normalize',true, ...
    'PlotStyle','Overlay');

title(sprintf( ...
    'ULA horizontal: apuntamiento a %d grados y nulo en %d grados', ...
    az_des_ULA,az_null_ULA));

%% FIGURA 8: ULA, diagramas polares separados

figure;

subplot(1,2,1);

pattern(ULA,fc,az_ULA,el_corte_ULA, ...
    'PropagationSpeed',c, ...
    'Weights',w_steering_ULA, ...
    'CoordinateSystem','polar', ...
    'Type','powerdb', ...
    'Normalize',true);

title('ULA sin null steering');

subplot(1,2,2);

pattern(ULA,fc,az_ULA,el_corte_ULA, ...
    'PropagationSpeed',c, ...
    'Weights',w_null_ULA, ...
    'CoordinateSystem','polar', ...
    'Type','powerdb', ...
    'Normalize',true);

title('ULA con nulo en -30 grados');