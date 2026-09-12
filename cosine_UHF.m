clear; clc; close all;

%% Parámetros del array en L de referencia 
c = 300000000;
Frequency = 500000000;
lambda = c/Frequency;
d = lambda/2;
M1 = 8;
M2 = 8;

% Geometría del array en L (
posY = [zeros(1,M1); (0:M1-1)*d; zeros(1,M1)];
posZ = [zeros(1,M2-1); zeros(1,M2-1); (1:M2-1)*d];
ElementPosition = [posY, posZ];

PropagationSpeed = c;
n_cos = 1.51;   % antena Televés DINOVA BOSS (7 dBi pasivo)

%% Construcción del array con elemento coseno^n
Array = phased.ConformalArray();
Array.ElementPosition = ElementPosition;
Array.ElementNormal = zeros(2, size(ElementPosition,2));
Array.Taper = 1;

Elem = phased.CosineAntennaElement;
Elem.CosinePower = [n_cos n_cos];
Elem.FrequencyRange = [0 1000000000];
Array.Element = Elem;

fprintf('Array -> %s (n=%.2f, %d elementos)\n', class(Array.Element), n_cos, getNumElements(Array));

w = ones(getNumElements(Array), 1);

%% Corte en Azimut (elevación = 0°)
figure;
pattern(Array, Frequency, -180:0.5:180, 0, ...
    'PropagationSpeed', PropagationSpeed, 'CoordinateSystem', 'polar', ...
    'weights', w, 'Type', 'Directivity');
title(sprintf('Corte en Azimut del array en L — antena comercial (n=%.2f)', n_cos));

%% Corte en Elevación (acimut = 0°)
figure;
pattern(Array, Frequency, 0, -90:0.5:90, ...
    'PropagationSpeed', PropagationSpeed, 'CoordinateSystem', 'polar', ...
    'weights', w, 'Type', 'Directivity');
title(sprintf('Corte en Elevación del array en L — antena comercial (n=%.2f)', n_cos));