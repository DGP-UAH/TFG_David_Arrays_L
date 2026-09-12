
%  VALIDACIÓN ULA — Script completo exportado de Sensor Array Analyzer
close all
clc
clear

%% Configuración del array 
Array = phased.ULA('NumElements',10,...
'ArrayAxis','z');
Array.ElementSpacing = 0.5*0.6;
Array.Taper = ones(1,10).';

Elem = phased.IsotropicAntennaElement;
Elem.FrequencyRange = [0 500000000];
Array.Element = Elem;

Frequency = 500000000;
PropagationSpeed = 300000000;
SteeringAngles = [0;0];

%% Plot Array Geometry 
figure;
viewArray(Array,'ShowNormals',false,...
'ShowTaper',false,'ShowIndex','None',...
'ShowLocalCoordinates',true,'ShowAnnotation',false,...
'Orientation',[0;0;0]);

%%  Plot 3D 
Freq3D = 500000000;
w = ones(getNumElements(Array), length(Frequency));
format = 'polar';
plotType = 'Directivity';
figure;
pattern(Array, Freq3D , 'PropagationSpeed', PropagationSpeed,...
'CoordinateSystem', format,'weights', w(:,1),...
'ShowArray',false,'ShowLocalCoordinates',true,...
'ShowColorbar',true,'Orientation',[0;0;0],...
'Type', plotType);

%% Plot 2D azimuth 
w = ones(getNumElements(Array), length(Frequency));
format = 'polar';
cutAngle = 0;
plotType = 'Directivity';
plotStyle = 'Overlay';
figure;
pattern(Array, Frequency, -180:180, cutAngle, 'PropagationSpeed', PropagationSpeed,...
'CoordinateSystem', format ,'weights', w, ...
'Type', plotType, 'PlotStyle', plotStyle);

%% Plot 2D elevation 
w = ones(getNumElements(Array), length(Frequency));
format = 'polar';
cutAngle = 0;
plotType = 'Directivity';
plotStyle = 'Overlay';
figure;
pattern(Array, Frequency, cutAngle, -90:90, 'PropagationSpeed', PropagationSpeed,...
'CoordinateSystem', format ,'weights', w, ...
'Type', plotType, 'PlotStyle', plotStyle);

%% Plot U pattern  
w = ones(getNumElements(Array), length(Frequency));
format = 'uv';
plotType = 'Directivity';
plotStyle = 'Overlay';
figure;
pattern(Array, Frequency, -1:0.01:1, 0, 'PropagationSpeed', PropagationSpeed,...
'CoordinateSystem', format,'weights', w, ...
'Type', plotType, 'PlotStyle', plotStyle);

%% Plot Grating Lobe Diagram
figure;
plotGratingLobeDiagram(Array,Frequency(1),SteeringAngles(:,1),PropagationSpeed);
a