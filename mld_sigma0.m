%% MLD CALCULATION (Density Threshold Method)
%  CçLCULO DE LA CAPA DE MEZCLA (MŽtodo de Umbral de Densidad)
%
%  Project: Data Architecture & Open Ocean Monitoring
%  Function: Calculates Mixed Layer Depth (MLD) starting from 10 dbar reference.
%  Author: Rafael Rasse
%  Created: 2013-07-02
%  Updated: 2026 (Refactored for High-Precision Pipeline)

function mld = mld_sigma0(press, sigma_theta0, sigma_theta0_threshold)
    % Inputs:
    %   press: Pressure vector [dbar]
    %   sigma_theta0: Potential density vector [kg/m3]
    %   sigma_theta0_threshold: Threshold (e.g., 0.03)

    % Ensure column vectors / Asegurar vectores columna
    press = press(:);
    sigma_theta0 = sigma_theta0(:);

    % Handle profiles sorted backwards / Manejar perfiles invertidos
    if press(1) == max(press)
        press = flipud(press);
        sigma_theta0 = flipud(sigma_theta0);
    end

    % 1. Use 10 dbar as reference depth (Oceanographic Standard)
    %    Usar 10 dbar como profundidad de referencia (Est‡ndar Oceanogr‡fico)
    ipres10dbar = find(press >= 10.0, 1);
    
    if isempty(ipres10dbar)
        mld = NaN;
        return;
    end
    
    % Crop profile to start from 10 dbar / Recortar perfil desde 10 dbar
    press_crop = press(ipres10dbar:end);
    sigma_crop = sigma_theta0(ipres10dbar:end);
    
    % 2. Identify MLD based on threshold / Identificar MLD segœn el umbral
    % Reference: Density difference from the 10 dbar value
    imld = find(abs(sigma_crop - sigma_crop(1)) > sigma_theta0_threshold, 1);

    % 3. Output assignment / Asignaci—n de resultado
    if isempty(imld) 
        mld = NaN; % Profile is fully mixed / Perfil totalmente mezclado
    else
        mld = press_crop(imld);
    end
    
end