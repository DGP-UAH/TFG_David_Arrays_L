
% Construcción del array en L (dos ULA ortogonales)
c = 300000000;          % velocidad de propagación
Frequency = 500000000;  % banda UHF 
lambda = c/Frequency;
d = lambda/2;           

M1 = 8;  % elementos rama y 
M2 = 8;  % elementos rama z 
% Posiciones rama y: (0, m*d, 0), m = 0,...,M1-1
posY = [zeros(1,M1); (0:M1-1)*d; zeros(1,M1)];
posZ = [zeros(1,M2-1); zeros(1,M2-1); (1:M2-1)*d];

% Concatenación sin duplicar el vértice
ElementPosition = [posY, posZ];   % 3 x (M1+M2-1)

Array = phased.ConformalArray();
Array.ElementPosition = ElementPosition;
Array.ElementNormal = zeros(2, size(ElementPosition,2)); 
Array.Taper = 1;

Elem = phased.IsotropicAntennaElement;
Elem.FrequencyRange = [0 1000000000];
Array.Element = Elem;

PropagationSpeed = c;

figure;
viewArray(Array, 'ShowNormals', false, 'ShowTaper', false, ...
    'ShowIndex', 'All', 'ShowLocalCoordinates', true, ...
    'ShowAnnotation', false, 'Orientation', [0;0;0]);
title('Geometría del array en L (M_1=8, M_2=8, d=\lambda/2)');

w = ones(getNumElements(Array), 1);

% Patrón en el dominio (u,v), igual formato que usaste para el UPA
figure;
pattern(Array, Frequency, -1:0.01:1, -1:0.01:1, ...
    'PropagationSpeed', PropagationSpeed, 'CoordinateSystem', 'uv', ...
    'Weights', w, 'Type', 'directivity');
title('Patrón de directividad del array en L');

%  Diagrama de radiación del array en L

w = ones(getNumElements(Array), length(Frequency));

% Corte 2D en Azimut (elevación fija en 0°) 
format = 'polar';
cutAngle = 0;
plotType = 'Directivity';
plotStyle = 'Overlay';
figure;
pattern(Array, Frequency, -180:0.5:180, cutAngle, ...
    'PropagationSpeed', PropagationSpeed, ...
    'CoordinateSystem', format, 'weights', w, ...
    'Type', plotType, 'PlotStyle', plotStyle);
title('Corte en Azimut del array en L (elevación = 0°)');

% Corte 2D en Elevación (azimut fijo en 0°) 
format = 'polar';
cutAngle = 0;
plotType = 'Directivity';
plotStyle = 'Overlay';
figure;
pattern(Array, Frequency, cutAngle, -90:0.5:90, ...
    'PropagationSpeed', PropagationSpeed, ...
    'CoordinateSystem', format, 'weights', w, ...
    'Type', plotType, 'PlotStyle', plotStyle);
title('Corte en Elevación del array en L (azimut = 0°)');