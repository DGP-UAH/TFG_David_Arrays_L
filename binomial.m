
% Create a Uniform Linear Array Object
Array = phased.ULA('NumElements',10,...
'ArrayAxis','y');
% The multiplication factor for lambda units to meter conversion
Array.ElementSpacing = 0.5*0.6;

% Generación de los coeficientes binomiales Pascal
N = Array.NumElements;
k = 0:(N-1);
coef_binomial = arrayfun(@(kk) nchoosek(N-1, kk), k)';  % fila N-1 del triángulo de Pascal
coef_binomial = coef_binomial / max(coef_binomial);      % normalizado a 1

Array.Taper = coef_binomial;

% Create an isotropic antenna element
Elem = phased.IsotropicAntennaElement;
Elem.FrequencyRange = [0 500000000];
Array.Element = Elem;
% Assign Frequencies and Propagation Speed
Frequency = 500000000;
PropagationSpeed = 300000000;
% Assign Steering Angles
SteeringAngles = [0;0];
% Create Figure
% Plot Array Geometry
figure;
viewArray(Array,'ShowNormals',false,...
'ShowTaper',false,'ShowIndex','None',...
'ShowLocalCoordinates',true,'ShowAnnotation',false,...
'Orientation',[0;0;0]);
% Calculate Steering Weights
Freq3D = 500000000;
% Find the weights
w = ones(getNumElements(Array), length(Frequency));
% Plot 3d graph
format = 'polar';
plotType = 'Directivity';
figure;
pattern(Array, Freq3D , 'PropagationSpeed', PropagationSpeed,...
'CoordinateSystem', format,'weights', w(:,1),...
'ShowArray',false,'ShowLocalCoordinates',true,...
'ShowColorbar',true,'Orientation',[0;0;0],...
'Type', plotType);
% Find the weights
w = ones(getNumElements(Array), length(Frequency));
% Plot 2d azimuth graph
format = 'polar';
cutAngle = 0;
plotType = 'Directivity';
plotStyle = 'Overlay';
figure;
pattern(Array, Frequency, -180:180, cutAngle, 'PropagationSpeed', PropagationSpeed,...
'CoordinateSystem', format ,'weights', w, ...
'Type', plotType, 'PlotStyle', plotStyle);
% Find the weights
w = ones(getNumElements(Array), length(Frequency));
% Plot 2d elevation graph
format = 'polar';
cutAngle = 0;
plotType = 'Directivity';
plotStyle = 'Overlay';
figure;
pattern(Array, Frequency, cutAngle, -90:90, 'PropagationSpeed', PropagationSpeed,...
'CoordinateSystem', format ,'weights', w, ...
'Type', plotType, 'PlotStyle', plotStyle);
% Find the weights
w = ones(getNumElements(Array), length(Frequency));
% Plot U Pattern
format = 'uv';
plotType = 'Directivity';
plotStyle = 'Overlay';
figure;
pattern(Array, Frequency, -1:0.01:1, 0, 'PropagationSpeed', PropagationSpeed,...
'CoordinateSystem', format,'weights', w, ...
'Type', plotType, 'PlotStyle', plotStyle);
% Plot Grating Lobe Diagram
figure;
plotGratingLobeDiagram(Array,Frequency(1),SteeringAngles(:,1),PropagationSpeed);