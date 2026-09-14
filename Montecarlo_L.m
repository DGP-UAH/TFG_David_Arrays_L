
%  Monte Carlo: tasa de emparejamiento correcto

clear; close all; clc;

%% Parámetros del array
c = 3e8;
Frequency = 500e6;
lambda = c/Frequency;
d = lambda/2;
M1 = 8; M2 = 8;
m = (0:M1-1).';
n = (0:M2-1).';

%% Parámetros de señal
P = 4;
N0 = 1;
SNR_dB = 10;
SNR_lin = 10^(SNR_dB/10);
Amplitud = sqrt(SNR_lin*N0);
N_snapshots = 1000;
N_MC = 1000;   % repeticiones Monte Carlo por caso

%% Configuraciones a comparar
configs = struct( ...
    'favorable', struct('theta',[9,24,41,64],  'phi',[-37,-6,15,75]), ...
    'limite',    struct('theta',[20,50,15,90], 'phi',[30,-40,-89,23]) );

nombres = fieldnames(configs);
tasa_acierto = zeros(1,2);

for c_idx = 1:2
    cfg = configs.(nombres{c_idx});
    theta_c = cfg.theta; phi_c = cfg.phi;
    u_c = cosd(theta_c).*sind(phi_c);
    v_c = sind(theta_c);
    aciertos = 0;

    % Objetos ULA/MUSIC creados una vez fuera del bucle (más rápido)
    arrayY = phased.ULA('NumElements',M1,'ElementSpacing',d);
    arrayZ = phased.ULA('NumElements',M2,'ElementSpacing',d);
    musicY = phased.MUSICEstimator('SensorArray',arrayY,'OperatingFrequency',Frequency, ...
        'PropagationSpeed',c,'ScanAngles',-90:0.05:90,'DOAOutputPort',true, ...
        'NumSignalsSource','Property','NumSignals',P);
    musicZ = phased.MUSICEstimator('SensorArray',arrayZ,'OperatingFrequency',Frequency, ...
        'PropagationSpeed',c,'ScanAngles',-90:0.05:90,'DOAOutputPort',true, ...
        'NumSignalsSource','Property','NumSignals',P);

    for mc = 1:N_MC
        % señal y ruido 
        s = (Amplitud/sqrt(2))*(randn(P,N_snapshots)+1j*randn(P,N_snapshots));
        ay_c = exp(1j*2*pi/lambda*d*m*u_c);
        az_c = exp(1j*2*pi/lambda*d*n*v_c);
        ruido_y = sqrt(N0/2)*(randn(M1,N_snapshots)+1j*randn(M1,N_snapshots));
        ruido_z = sqrt(N0/2)*(randn(M2,N_snapshots)+1j*randn(M2,N_snapshots));
        Xy_c = ay_c*s + ruido_y;
        Xz_c = az_c*s + ruido_z;
        Ryz_c = (Xy_c*Xz_c')/N_snapshots;

        % MUSIC por rama
        try
            [~,ang_y] = musicY(Xy_c.');
            [~,ang_z] = musicZ(Xz_c.');
        catch
            continue % si MUSIC no encuentra P picos, se cuenta como fallo (no incrementa aciertos)
        end
        if length(ang_y) < P || length(ang_z) < P
            continue
        end
        u_hat = sind(ang_y(:).'); v_hat = sind(ang_z(:).');

        % emparejamiento
        ay_est = exp(1j*2*pi/lambda*d*m*u_hat);
        az_est = exp(1j*2*pi/lambda*d*n*v_hat);
        rho = abs(ay_est'*Ryz_c*az_est);
        M_asig = matchpairs(-rho, max(rho(:)));

        % verificación
        u_p = u_hat(M_asig(:,1)); v_p = v_hat(M_asig(:,2));
        correcto = true;
        for f = 1:P
            [~, idx_real] = min(abs(u_p(f)-u_c) + abs(v_p(f)-v_c));
            if abs(u_c(idx_real)-u_p(f))>0.05 || abs(v_c(idx_real)-v_p(f))>0.05
                correcto = false; break;
            end
        end
        aciertos = aciertos + correcto;
    end
    tasa_acierto(c_idx) = aciertos/N_MC*100;
end

fprintf('Tasa de emparejamiento correcto:\n');
fprintf('  Caso favorable: %.1f%%\n', tasa_acierto(1));
fprintf('  Caso límite (end-fire): %.1f%%\n', tasa_acierto(2));


figure;
bar(tasa_acierto);
set(gca, 'XTickLabel', {'Caso favorable', 'Caso límite (end-fire)'});
ylabel('Tasa de emparejamiento correcto (%)');
title('Tasa de emparejamiento correcto — N_{MC}=1000');
ylim([0 100]);
grid on;