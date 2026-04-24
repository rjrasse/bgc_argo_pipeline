%% BGC-ARGO NETCDF READER: Open Ocean Monitoring
%  LECTOR DE DATOS BGC-ARGO: Monitoreo de OcŽano Abierto
%
%  Project: Data Architecture & Biogeochemical Cycles
%  Proyecto: Arquitectura de Datos y Ciclos Biogeoqu’micos
%
%  Function: Data Ingestion from Argo NetCDF profiles
%  Funci—n: Ingesta de perfiles NetCDF de flotadores Argo
%
%  Author: Rafael Rasse
%  Created: 2013-07-02
%  Updated: 2026 (Refactored for High-Precision Pipeline)

function [tmp] = rd_ncread_SO_sector_6901583(fn)
    % Assign filename for traceability / Asignar nombre para trazabilidad
    tmp.filename = fn;
    
    % --- TIME & GEOLOCATION / TIEMPO Y GEOLOCALIZACIîN ---
    % Reference date for julian day conversion / Referencia para d’as julianos
    tmp.ref_date = ncread(fn, 'REFERENCE_DATE_TIME')';
    tmp.jday = ncread(fn, 'JULD'); 
    
    % Core coordinates / Coordenadas principales
    tmp.LAT = ncread(fn, 'LATITUDE');   % [degrees / grados]
    tmp.LON = ncread(fn, 'LONGITUDE');  % [degrees / grados]
    
    % --- PHYSICAL VARIABLES / VARIABLES FêSICAS ---
    % Force column vector (:) for table compatibility 
    % Forzar vector columna (:) para asegurar compatibilidad con tablas
    tmp.pres = ncread(fn, 'PRES_ADJUSTED'); 
    tmp.pres = tmp.pres(:); 
    
    % Map single lat/lon to profile length / Mapear lat/lon al largo del perfil
    tmp.lat = tmp.LAT(1);
    tmp.lon = tmp.LON(1); 
    
    % Physical sensors (Adjusted data) / Sensores f’sicos (Datos ajustados)
    tmp.T = ncread(fn, 'TEMP_ADJUSTED');    % Temperature / Temperatura
    tmp.T = tmp.T(:); 
    
    tmp.S = ncread(fn, 'PSAL_ADJUSTED');    % Salinity / Salinidad
    tmp.S = tmp.S(:);
    
    % --- BIOGEOCHEMICAL & OPTICAL / BIOGEOQUêMICA Y îPTICA ---
    tmp.chl_adjust = ncread(fn, 'CHLA_ADJUSTED');   % Chlorophyll-a [mg/m3]
    tmp.chl_adjust = tmp.chl_adjust(:);
    
    tmp.bbp700_adjst = ncread(fn, 'BBP700');        % Backscattering [m-1]
    tmp.bbp700_adjst = tmp.bbp700_adjst(:);
    
    % --- OPTIONAL SENSORS / SENSORES OPCIONALES ---
    % Uncomment to activate / Descomentar para activar
    % tmp.CDOM_adjst = ncread(fn, 'CDOM_ADJUSTED'); 
    % tmp.NO3_adjst = ncread(fn, 'NITRATE_ADJUSTED'); 
    % tmp.doxy_adjst = ncread(fn, 'DOXY_ADJUSTED');
    
end
