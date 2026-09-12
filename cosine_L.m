clear; clc; close all;

%% Construcción del array en L (dos ULA ortogonales)
c = 300000000;
Frequency = 500000000;
lambda = c/Frequency;
d = lambda/2;
M1 = 8;
M2 = 8;

posY = [zeros(1,M1); (0:M1-1)*d; zeros(1,M1)];
posZ = [zeros(1,M2-1); zeros(1,M2-1); (1:M2-1)*d];
ElementPosition = [posY, posZ];

PropagationSpeed = c;
n_cos = 4;

%%  Array ISOTRÓPICO 
Array_iso = phased.ConformalArray();
Array_iso.ElementPosition = ElementPosition;
Array_iso.ElementNormal = zeros(2, size(ElementPosition,2));
Array_iso.Taper = 1;
Elem_iso = phased.IsotropicAntennaElement;
Elem_iso.FrequencyRange = [0 1000000000];
Array_iso.Element = Elem_iso;

%% Array DIRECTIVO (coseno^n) 
Array_dir = phased.ConformalArray();
Array_dir.ElementPosition = ElementPosition;
Array_dir.ElementNormal = zeros(2, size(ElementPosition,2));
Array_dir.Taper = 1;
Elem_dir = phased.CosineAntennaElement;
Elem_dir.CosinePower = [n_cos n_cos];
Elem_dir.FrequencyRange = [0 1000000000];
Array_dir.Element = Elem_dir;

w = ones(getNumElements(Array_iso), 1);

%%  Figura 1: Corte en Azimut (elevación = 0°) 
figure('Name','Corte en Azimut','Position',[100 100 1000 500]);

ax1 = axes('Position',[0.05 0.12 0.4 0.78]);
pattern(Array_iso, Frequency, -180:0.5:180, 0, ...
    'PropagationSpeed', PropagationSpeed, 'CoordinateSystem', 'polar', ...
    'weights', w, 'Type', 'Directivity', 'Parent', ax1);
title(ax1, 'Isotrópico (n=0)');

ax2 = axes('Position',[0.55 0.12 0.4 0.78]);
pattern(Array_dir, Frequency, -180:0.5:180, 0, ...
    'PropagationSpeed', PropagationSpeed, 'CoordinateSystem', 'polar', ...
    'weights', w, 'Type', 'Directivity', 'Parent', ax2);
title(ax2, sprintf('Directivo (n=%d)', n_cos));

sgtitle('Corte en Azimut del array en L (elevación = 0°)');

%% Figura 2: Corte en Elevación acimut = 0°
figure('Name','Corte en Elevación','Position',[100 100 1000 500]);

ax3 = axes('Position',[0.05 0.12 0.4 0.78]);
pattern(Array_iso, Frequency, 0, -90:0.5:90, ...
    'PropagationSpeed', PropagationSpeed, 'CoordinateSystem', 'polar', ...
    'weights', w, 'Type', 'Directivity', 'Parent', ax3);
title(ax3, 'Isotrópico (n=0)');

ax4 = axes('Position',[0.55 0.12 0.4 0.78]);
pattern(Array_dir, Frequency, 0, -90:0.5:90, ...
    'PropagationSpeed', PropagationSpeed, 'CoordinateSystem', 'polar', ...
    'weights', w, 'Type', 'Directivity', 'Parent', ax4);
title(ax4, sprintf('Directivo (n=%d)', n_cos));

sgtitle('Corte en Elevación del array en L (azimut = 0°)');